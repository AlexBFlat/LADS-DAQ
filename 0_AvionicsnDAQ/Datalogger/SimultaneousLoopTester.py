### Simultaneous Loop Tester                                   ###
### Built to test loop methods to allow for DAQ implementation ###
##################################################################

import u3
import u6
import ue9
import os
import threading
import time
import multiprocessing
import sys
import datetime
import queue as Queue
from copy import deepcopy

### Initial program setup ###
#os.system('cls' if os.name == 'nt' else 'clear')                            # Clear console.
#print('### Simultaneous Loop Tester                                   ###\n') # Prints starting statement.

### Program constants ###
NumChannels = 8


### Function definitions ###
# Function U3stream continuously streams data from the labjack U3.
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

def U3stream(SR,NC):
    d = None
    SCAN_FREQUENCY = SR / NC
    d = u3.U3()
    d.configU3()
    d.getCalibrationData()
    FIOEIOAnalog = (2 ** NC) - 1
    fios = FIOEIOAnalog & 0xFF
    eios = FIOEIOAnalog // 256
    d.configIO(FIOAnalog=fios, EIOAnalog=eios)
    print("Configuring U3 stream")
    d.streamConfig(NC, PChannels=[0, 1, 2, 3, 4, 5, 6, 7], NChannels=[31, 31, 31, 31, 31, 31, 31, 31], Resolution=3, ScanFrequency=SCAN_FREQUENCY)
    if d is None:
        print("""Configure a device first.
    Please open streamTest-threading.py in a text editor and uncomment the lines for your device.

    Exiting...""")
        sys.exit(0)
    sdr = StreamDataReader(d)

    
U3stream(50000,8)
