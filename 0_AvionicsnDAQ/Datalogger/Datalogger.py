### Library imports ###
import u3
import datetime
import time
import socket
from datetime import datetime
import pytz
import pandas as pd
import openpyxl

### Opens LJU3 and pulls calibration data. ###
d = u3.U3()                                                                                                                                # Opens the first found LabJack U3.

## Constants
NumChannels = 15   # Number of channels to be used.
datarate = 20   # Desired data rate in Hz.
decp = 2           # Defines number of decimal points desired.
host = '0.0.0.0'   # Listen on all available interfaces (use specific IP for remote access)
LVport = 49153       # Port to listen on (ensure it's open and available)

## Conversion
#delay = 1/datarate # Converts delay into seconds of wait time
delay = 0

d.configIO(FIOAnalog = 0xFF, EIOAnalog = 0xFF) # Configures all EIO and FIO to analog read.
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# Bind the socket to the address and port
server_socket.bind((host, LVport))
# Enable the server to listen for incoming connections
server_socket.listen()
server_socket.setblocking(False)

Connected = 0

PChannels = [] # Initializes positive channels array.
NChannels = [] # Initializes negative channels array.

running = 1    # Initializes running variable.
NumChannels = NumChannels - 1
for i in range(0,NumChannels): # Iterates through number of channels and builds postitive / negative channel arrays.
    PChannels.append(i)        # Builds positive channels to all reference positive as the main pin.
    NChannels.append(31)       # Sets all negative channels to reference against ground (single-ended).

def move_cursor(row, col):
    print(f"\033[{row};{col}H", end="")

def TCPsend(server_socket,array_string,LVConnected,connection):
    if LVConnected == 0:
        try:
            connection, client_address = server_socket.accept()
            LVConnected = 1
        except:
            LVConnected = 0
            print(f"{array_string} Not Connected", end="\r") # Prints a space to move to the next line for the next iteration in the loop.
    else:
        #LVConnected = 1
        print(f"{array_string} Connected      ",end="\r")
        try:
            connection.sendall(array_string.encode('utf-8'))
        except:
            LVConnected = 0
    return [LVConnected, connection]

def AINread(NumChannels):
    AIN = []               # Initializes AIN array - pulling voltage values directly from the LJ.
    AINf = []              # Initializes limited AIN array - limits digits of values.
    outarray = []          # Initializes TCP output array.
    momtime = time.time()
    tstamp = f"{momtime:12.4f}"
    outarray.append(tstamp)
    for i in range(0,NumChannels+1): # Iterates through all AIN channels.
        if i <= 3:
            AIN.append(d.getAIN(posChannel=i, negChannel=31, longSettle=False,quickSample=False)) # Pulls AIN voltage values from LabJack.
        else:
            AIN.append(d.getAIN(posChannel=i, negChannel=31, longSettle=False,quickSample=False)*2.01124) # Pulls AIN voltage values from LabJack.
        AINf.append(f"{AIN[i]:08.4f}")     # Converts AIN values to limited decimal values.
        #print(f'AIN{i}: {AINf[i]}', end=" ")  # Prints out AIN values to console.
        outarray.append(AINf[i])
        array_string = ','.join(map(str, outarray))
    return array_string

LVConnected = 0
connection = 0

### Sensor configuration ###

df = pd.read_excel('AIN_Scaling.xlsx')
AINs = df['AIN']
C5s = df['C5']
C4s = df['C4']
C3s = df['C3']
C2s = df['C2']
C1s = df['C1']
C0s = df['C0']


### Main Loop ###
try:
    while running == 1:        # Runs continuously, delaying by delay to achieve desired data rate.                            
        array_string = AINread(NumChannels)
        print(array_string, end="\r")
        #TCPsend(connection,server_socket,array_string,name,line):
        [LVConnected, connection] = TCPsend(server_socket,array_string,LVConnected,connection)
        
        #print("")
        time.sleep(delay)                         # Delays as desired to limit datarate.
except:
        d.close()                                 # Closes LabJack on program end.

