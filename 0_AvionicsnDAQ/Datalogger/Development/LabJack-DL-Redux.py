### Program to map out the labjack low-level functions ###
import u3
import datetime
import time
import multiprocessing as mp

d = u3.U3()                                                                                                                                # Opens the first found LabJack U3.
d.getCalibrationData()                                                                                                                     # Grabs calibration data for conversion from bits to voltage and the like.

## Constants
channel1 = 0
channel2 = 11
NumChannels = 15
datarate = 50 # Desired data rate in Hz.

## Conversion
delay = 1/datarate

## d.configIO() configures the FIO lines
# The LabJack U3 has four dedicated FIO lines (FIO4 - FIO7, with AIN0-AIN3 being also included) and eight EIO lines on the DB-25 connector (EIO0 - EIO7). Set as 0000000 for all digital or 11111111 for all analog.
# WriteMask: Determines which bits will be written.
# TimerCounterConfig: Used to disable / enable timers and counters. Will be assigned IO pins starting with FIO0 plus TimerCounterPinOffset (4-8).
#                     Timer0 takes first IO pin, then Timer1, then Counter0, then Counter1. Timers are initialized to mode 10, and must be re-configured if otherwise required.
# Assign UART Pins: will assign IO lines to UART module.
# DAC1Enable: DAC1 is always enabled.
# FIOAnalog: set the numerical value of the bits as set for configuring the FIO lines. 1 is analog and 0 is digital.
#            if you want all FIO's (0-7) to be analog, you must convert 11111111 into decimal (255) or hex (0xFF). Hex must be used for stream config (I think)
# EIOAnalog: same as FIOAnalog but for the EIO's
d.configIO(FIOAnalog = 0xFF, EIOAnalog = 0xFF) # Configures all EIO and FIO to analog read.

## getFeedback(u3.AIN) acquires values from the LabJack
# PositiveChannel: the analog channel you are pulling voltage from. 31 is VREG (The LabJack's internally provided voltage)
# NegativeChannel: defines the reference by which the voltage value is derived. 31 is the labjack ground, any other number is another analog port.
# LongSettling: defines if additional time is given to settle out.
# QuickSample: If true, a faster analog input is conducted at the expense of reading accuracy.
#ainbits, = d.getFeedback(u3.AIN(PositiveChannel=channel1, NegativeChannel=31, LongSettling=False,QuickSample=False))                             # Grabs AIN0 bit value. 


## d.binarytocalib... converts binary values into voltage.
# bits defines the bit analog value in. This is the bits value acquired above.
# isLowVoltage: True if using a LJU3-LV, false if using an HV series U3.
# isSingleEnded: Defines if value you are converting is single ended (Voltage is referenced to ground)
# ChannelNumber: Defines which channel you are looking at.
#ainValue = d.binaryToCalibratedAnalogVoltage(bits=ainbits, isLowVoltage=False,isSingleEnded=True,isSpecialSetting=False, channelNumber=channel1) #

## d.getAIN gets AIN in voltage, performing both of the above operations at once.
# posChannel: positive channel (AIN of channel you are looking at if single-ended).
# negChannel: Negative channel (What voltage is referenced against, 31 if reference to ground, which is single-ended)
# longSettle: same as described above.
# quickSample: same as described above.
#ainValue2 = d.getAIN(posChannel=channel2, negChannel=31, longSettle=False,quickSample=False)

## d.StreamConfig
# NumChannels: Number of channels you will sample per scan (1-25)
# SamplesPerPacket: Specifies number of samples to be pulled of the FIFO buffer and returned. For faster stream speeds, utilize 25 samples / per second.
# ScanConfig: Specifies the stream base clock and effective resolution.
# ScanFrequency: Frequency of scans.
# Resolution: Determines resolution setting for all analog inputs.
# PChannel/NChannel: Specify positive and negative channels as described above. Both are arrays.
#SCAN_FREQUENCY = Samplerate / NumChannels
PChannels = []
NChannels = []

running = 1
for i in range(0,NumChannels):
    PChannels.append(i)
    NChannels.append(31)
try:
    while running == 1:
        i = 0
        '''for r in d.streamData():
            AIN0, = r['AIN0']
            print(f'i value: {i} AIN0: {AIN0}')
            i = i + 1
            print(r['AIN0'])'''
        AIN = []
        AINf = []
        for i in range(0,NumChannels+1):
            AIN.append(d.getAIN(posChannel=i, negChannel=31, longSettle=False,quickSample=False))
            AINf.append(f"{AIN[i]:.4f}")
            print(f'AIN{i}: {AINf[i]}', end=" ")
            #print(f'Data rate: {datarate} Hz')
        print("")
        time.sleep(delay)
except:
        running = 0
        d.close()


#AINgrab(NumChannels,d)

#print(f'A{channel1} Bits: {ainbits}')    
#print(f'A{channel1}: {ainValue} V')
#print(f'A{channel2}: {ainValue2} V')
