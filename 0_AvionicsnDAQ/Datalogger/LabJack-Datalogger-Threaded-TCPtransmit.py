"""
This example uses Python's built-in threading module to help reach faster
streaming speeds than streamTest.py.

Note: Our Python interfaces throw exceptions when there are any issues with
device communications that need addressed. Many of our examples will
terminate immediately when an exception is thrown. The onus is on the API
user to address the cause of any exceptions thrown, and add exception
handling when appropriate. We create our own exception classes that are
derived from the built-in Python Exception class and can be caught as such.
For more information, see the implementation in our source code and the
Python standard documentation.
"""
import sys
import threading
import time

from copy import deepcopy
from datetime import datetime

try:
    import Queue
except ImportError:  # Python 3
    import queue as Queue

import u3
import u6
import ue9
import socket
import struct
import json  # To send data in JSON format
import numpy as np

# MAX_REQUESTS is the number of packets to be read.
#MAX_REQUESTS = 5000
# SCAN_FREQUENCY is the scan frequency of stream mode in Hz.
NumChannels = 8
Samplerate = 50000
SCAN_FREQUENCY = Samplerate / NumChannels

d = None

###############################################################################
# U3
# Uncomment these lines to stream from a U3
###############################################################################

# At high frequencies ( >5 kHz), the number of samples will be MAX_REQUESTS
# times 48 (packets per request) times 25 (samples per packet)
# Define the host and port for the server
host = '0.0.0.0'  # Listen on all available interfaces (use specific IP for remote access)
port = 2870     # Port to listen on (ensure it's open and available)

# Create a TCP/IP socket
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to the address and port
server_socket.bind((host, port))

# Enable the server to listen for incoming connections
server_socket.listen(1)

print(f"Server listening on {host}:{port}...")

# Wait for a connection from the client (LabVIEW)
connection, client_address = server_socket.accept()

d = u3.U3()

# To learn the if the U3 is an HV
d.configU3()

# For applying the proper calibration to readings.
d.getCalibrationData()

# Set the FIO0 to Analog
FIOEIOAnalog = (2 ** NumChannels) - 1
fios = FIOEIOAnalog & 0xFF
eios = FIOEIOAnalog // 256
d.configIO(FIOAnalog=fios, EIOAnalog=eios)

print("Configuring U3 stream")
d.streamConfig(NumChannels, PChannels=[0, 1, 2, 3, 4, 5, 6, 7], NChannels=[31, 31, 31, 31, 31, 31, 31, 31], Resolution=3, ScanFrequency=SCAN_FREQUENCY)

def SampleAverager(r, AIN, fudgefactor):
    AIN0 = [1, 2]
    AIN0[0] = len(r[AIN])
    AIN0[1] = sum(r[AIN])/len(r[AIN])*fudgefactor
    return AIN0

###############################################################################
# U6
# Uncomment these lines to stream from a U6
###############################################################################
'''
# At high frequencies ( >5 kHz), the number of samples will be MAX_REQUESTS
# times 48 (packets per request) times 25 (samples per packet)
d = u6.U6()

# For applying the proper calibration to readings.
d.getCalibrationData()

print("Configuring U6 stream")
d.streamConfig(NumChannels=1, ChannelNumbers=[0], ChannelOptions=[0], SettlingFactor=1, ResolutionIndex=1, ScanFrequency=SCAN_FREQUENCY)
'''

###############################################################################
# UE9
# Uncomment these lines to stream from a UE9
###############################################################################
'''
# Changing MAX_REQUESTS to something higher for more samples.
MAX_REQUESTS = 10000

# At 200 Hz or higher frequencies, the number of samples will be MAX_REQUESTS
# times 8 (packets per request) times 16 (samples per packet).
d = ue9.UE9()
#d = ue9.UE9(ethernet=True, ipAddress="192.168.1.226")  # Over TCP/ethernet connect to UE9 with IP address 192.168.1.209

# For applying the proper calibration to readings.
d.getCalibrationData()

print("Configuring UE9 stream")

d.streamConfig(NumChannels=1, ChannelNumbers=[0], ChannelOptions=[0], SettlingTime=0, Resolution=12, ScanFrequency=SCAN_FREQUENCY)
'''

if d is None:
    print("""Configure a device first.
Please open streamTest-threading.py in a text editor and uncomment the lines for your device.

Exiting...""")
    sys.exit(0)


class StreamDataReader(object):
    def __init__(self, device):
        self.device = device
        self.data = Queue.Queue()
        self.dataCount = 0
        self.missed = 0
        self.finished = False

    def readStreamData(self):
        self.finished = False

        print("Start stream.")
        start = datetime.now()
        try:
            self.device.streamStart()
            while not self.finished:
                # Calling with convert = False, because we are going to convert in
                # the main thread.
                returnDict = next(self.device.streamData(convert=False))
                #returnDict = self.device.streamData(convert=False).next()  # Python 2.5
                if returnDict is None:
                    print("No stream data")
                    continue

                self.data.put_nowait(deepcopy(returnDict))

                self.missed += returnDict["missed"]
                self.dataCount += 1
                #if self.dataCount >= MAX_REQUESTS:
                #    self.finished = True

            print("Stream stopped.\n")
            self.device.streamStop()
            stop = datetime.now()

            # Delay to help prevent print text overlapping in the two threads.
            time.sleep(0.200)

            sampleTotal = self.dataCount * self.device.packetsPerRequest * self.device.streamSamplesPerPacket
            scanTotal = sampleTotal / 1  # sampleTotal / NumChannels

            print("%s requests with %s packets per request with %s samples per packet = %s samples total." %
                  (self.dataCount, self.device.packetsPerRequest, self.device.streamSamplesPerPacket, sampleTotal))

            print("%s samples were lost due to errors." % self.missed)
            sampleTotal -= self.missed
            print("Adjusted number of samples = %s" % sampleTotal)

            runTime = (stop-start).seconds + float((stop-start).microseconds)/1000000
            print("The experiment took %s seconds." % runTime)
            print("Actual Scan Rate = %s Hz" % SCAN_FREQUENCY)
            print("Timed Scan Rate = %s scans / %s seconds = %s Hz" %
                  (scanTotal, runTime, float(scanTotal)/runTime))
            print("Timed Sample Rate = %s samples / %s seconds = %s Hz" %
                  (sampleTotal, runTime, float(sampleTotal)/runTime))
        except Exception:
            try:
                # Try to stop stream mode. Ignore exception if it fails.
                self.device.streamStop()
            except:
                pass
            self.finished = True
            e = sys.exc_info()[1]
            print("readStreamData exception: %s %s" % (type(e), e))


sdr = StreamDataReader(d)

sdrThread = threading.Thread(target=sdr.readStreamData)

# Start the stream and begin loading the result into a Queue
sdrThread.start()

errors = 0
missed = 0
# Read from Queue until there is no data. Adjust Queue.get timeout
# for slow scan rates.
while True:
    try:
        # Pull results out of the Queue in a blocking manner.
        result = sdr.data.get(True, 1)

        # If there were errors, print that.
        if result["errors"] != 0:
            errors += result["errors"]
            missed += result["missed"]
            print("+++++ Total Errors: %s, Total Missed: %s +++++" % (errors, missed))

        # Convert the raw bytes (result['result']) to voltage data.
        r = d.processStreamData(result['result'])
        AIN0 = f"{SampleAverager(r,"AIN0", 1):08.4f}"
        AIN1 = f"{SampleAverager(r,"AIN1", 1):08.4f}"
        AIN2 = f"{SampleAverager(r,"AIN2", 1):08.4f}"
        AIN3 = f"{SampleAverager(r,"AIN3", 1):08.4f}"
        AIN4 = f"{SampleAverager(r,"AIN4", 1):08.4f}"
        AIN5 = f"{SampleAverager(r,"AIN5", 1):08.4f}"
        AIN6 = f"{SampleAverager(r,"AIN6", 1):08.4f}"
        # Do some processing on the data to show off.
        #print("Average of values: AIN0: %s AIN1: %s AIN2: %s AIN3: %s AIN4: %s AIN5: %s AIN6: %s" % (AIN0[1], AIN1[1], AIN2[1], AIN3[1], AIN4[1], AIN5[1], AIN6[1]))
        print("AIN0: %s AIN4: %s" % (AIN0[1],AIN4[1]))    
        python_array = [AIN0[:8], AIN1[:8], AIN2[:8], AIN3[:8]]
        array_string = ','.join(map(str, python_array))
        # Serialize the data to JSON format

        # Send the serialized data to the client (LabVIEW)
        connection.sendall(array_string.encode('utf-8'))
    except Queue.Empty:
        if sdr.finished:
            print("Done reading from the Queue.")
        else:
            print("Queue is empty. Stopping...")
            sdr.finished = True
        break
    except KeyboardInterrupt:
        sdr.finished = True
    except Exception:
        e = sys.exc_info()[1]
        print("main exception: %s %s" % (type(e), e))
        sdr.finished = True
        break

# Wait for the stream thread to stop
sdrThread.join()

# Close the device
d.close()