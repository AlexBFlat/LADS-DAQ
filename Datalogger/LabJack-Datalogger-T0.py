# Library Inclusions
import numpy as np            # Imports numpy for numerical operations.
import scipy as sp            # Imports scipy.
import pandas as pa           # Imports Pandas for data processing.
import sys                    # Imports Python sys library.
from datetime import datetime # Imports datetime library to retrieve the date.
import u3                     # Imports UE3 Library.
import traceback              # Imports traceback

MAX_REQUESTS = 75     # MAX_REQUESTS is # of packets to be read.
SCAN_FREQUENCY = 15000 # Sets the data scan frequency.

# Connection initialization for a UE3
d = u3.U3()                    # Simplified variable for calling the UE3.
d.configU3()                   # Learns if the U3 is HV or LV.
d.getCalibrationData()         # Gets the calibration data (converts bytes to volts) from the U3's memory.
d.configIO(FIOAnalog = 15)        # Sets FIO0 and FIO1 to Analog.
print("Configuring U3 stream") # Lets the user know program is configuring for stream.
d.streamConfig(NumChannels=4, PChannels = [0, 1, 2, 3], NChannels = [31, 31, 31, 31], Resolution=3, ScanFrequency=SCAN_FREQUENCY)

# Allows for error handling.
try:
    print("Start stream")              # Lets the user know stream is starting.
    d.streamStart()                    # Starts stream in U3.
    start = datetime.now()             # Starts datetime.
    print("Start time is %s" % start)  # Prints start time for user.

    missed = 0                         # Initializes missed packet counter.
    dataCount = 0                      # Initializes dataCount.
    packetCount = 0                    # Initializes packet counter.

    AIN0 = 0                           # Initializes AIN variables.
    AIN1 = 0                           #
    AIN2 = 0                           #
    AIN3 = 0                           #

    for r in d.streamData():              #  Iterates through data stored in streamdata.
        if r is not None:                 #
            # Our stop condition          
            if dataCount >= MAX_REQUESTS: # Checks if data count is greater than the max requests, and exits if so.
                break                     #

            if r["errors"] != 0:          # Checks for errors.
                print("Errors counted: %s ; %s" % (r["errors"], datetime.now())) # If errors are present, writes out errors.
            
            if r["numPackets"] != d.packetsPerRequest:   # Checks if the number of packets is equal to the loop iteration counter. 
                print("----- UNDERFLOW : %s ; %s" %      # If so, states underflow.
                      (r["numPackets"], datetime.now())) #

            if r["missed"] != 0:                         # Checks if any packets are missed.
                missed += r['missed']                    # Iterates missed counter.
                print("+++ Missed %s" % r["missed"])     # Prints missed packet number.

            AIN0 = sum(r["AIN0"])/len(r["AIN0"])                             # Stores values of AIN0 taken during this time.
            AIN1 = sum(r["AIN1"])/len(r["AIN1"])                             # Stores values of AIN0 taken during this time.
            AIN2 = sum(r["AIN2"])/len(r["AIN2"])                             # Stores values of AIN0 taken during this time.
            AIN3 = sum(r["AIN3"])/len(r["AIN3"])                             # Stores values of AIN0 taken during this time.

            print('AIN0: %s AIN1: %s AIN2: %s AIN3: %s\n' % (AIN0, AIN1, AIN2, AIN3))                         # Prints out AIN0   
            d.toggleLED      
except:
    print("".join(i for i in traceback.format_exc()))
finally:
    stop = datetime.now()
    d.streamStop()
    print("Stream stopped.\n")
    d.close()

    sampleTotal = packetCount * d.streamSamplesPerPacket

    scanTotal = sampleTotal / 2  # sampleTotal / NumChannels
    print("%s requests with %s packets per request with %s samples per packet = %s samples total." %
          (dataCount, (float(packetCount)/dataCount), d.streamSamplesPerPacket, sampleTotal))
    print("%s samples were lost due to errors." % missed)
    sampleTotal -= missed
    print("Adjusted number of samples = %s" % sampleTotal)

    runTime = (stop-start).seconds + float((stop-start).microseconds)/1000000
    print("The experiment took %s seconds." % runTime)
    print("Actual Scan Rate = %s Hz" % SCAN_FREQUENCY)
    print("Timed Scan Rate = %s scans / %s seconds = %s Hz" %
          (scanTotal, runTime, float(scanTotal)/runTime))
    print("Timed Sample Rate = %s samples / %s seconds = %s Hz" %
          (sampleTotal, runTime, float(sampleTotal)/runTime))
# Open LabJack
#d = u3.U3() # Opens the first LabJackU3 found on USB.
#u3setup(d,1)