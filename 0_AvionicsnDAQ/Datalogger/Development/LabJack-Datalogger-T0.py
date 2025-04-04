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
NumChannels = 5
Samplerate = 50000
SCAN_FREQUENCY = Samplerate / NumChannels

d = None

###############################################################################
# U3
# Uncomment these lines to stream from a U3
###############################################################################

d = u3.U3()

# To learn the if the U3 is an HV
d.configU3()

# For applying the proper calibration to readings.
d.getCalibrationData()

# Set the FIO0 to Analog
FIOEIOAnalog = (2 ** NumChannels) - 1
fios = 0xFF
eios = 0xFF
d.configIO(FIOAnalog=fios, EIOAnalog=eios)
PChannels = []
NChannels = []
for i in range(0,NumChannels):
    PChannels.append(i)
    if i <= 7:
        NChannels.append(31)
    else:
        NChannels.append(i)
        
print("Configuring U3 stream")
d.streamConfig(NumChannels=NumChannels, PChannels=PChannels, NChannels=NChannels, Resolution=3, ScanFrequency=SCAN_FREQUENCY)

def SampleAverager(r, AIN, fudgefactor):
    AIN0 = [1, 2]
    AIN0[0] = len(r[AIN])
    AIN0[1] = sum(r[AIN])/len(r[AIN])*fudgefactor
    return AIN0

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

class SendData:
    def __init__(self):
        self.data = Queue.Queue()

    def hello(self):
        self.data.put_nowait(2)


def is_multiple_of_10(num):
    return num % 10 == 0
port = 2780
ip = "000.000.00.00"
sdr = StreamDataReader(d)
SND = SendData()

sdrThread = threading.Thread(target=sdr.readStreamData)
sndThread = threading.Thread(target=SND.hello)

# Start the stream and begin loading the result into a Queue
sdrThread.start()
sndThread.start()

errors = 0
missed = 0
logging = 0
i = 1
# Read from Queue until there is no data. Adjust Queue.get timeout
# for slow scan rates.
AIN = []
Astr = "Values:"
while True:
    #sndres = SND.data.get()
    #print(sndres)
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
        for i in range(0,NumChannels):
            AIs = f'AIN{i}'
            if i >= 4:
                pAI = SampleAverager(r,AIs, 2)
            else:
                pAI = SampleAverager(r,AIs, 1)
            AIval = f"{pAI[1]:08.4f}"
            AIN.append(AIval)
            Astr += f" {AIs}: {AIval}V"
        print(Astr)  
        Astr = "Values:"
        AIN = []
        i += 1
        
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
sndThread.join()

# Close the device
d.close()