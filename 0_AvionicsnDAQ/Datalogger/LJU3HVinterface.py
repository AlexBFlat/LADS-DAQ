### Library imports ###
import u3
import datetime
import time
import socket
from datetime import datetime
import pytz
import pandas as pd
import openpyxl
import os
from colorama import Fore, Back, Style, init

def clear_console():
    os.system('cls' if os.name == 'nt' else 'clear')

### Opens LJU3 and pulls calibration data. ###
d = u3.U3()                                                                                                                                # Opens the first found LabJack U3.
clear_console()

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


Connected = 0

PChannels = [] # Initializes positive channels array.
NChannels = [] # Initializes negative channels array.

running = 1    # Initializes running variable.
NumChannels = NumChannels - 1
for i in range(0,NumChannels): # Iterates through number of channels and builds postitive / negative channel arrays.
    PChannels.append(i)        # Builds positive channels to all reference positive as the main pin.
    NChannels.append(31)       # Sets all negative channels to reference against ground (single-ended).

def socketconfig(host,port):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # Bind the socket to the address and port
    server_socket.bind((host, port))
    # Enable the server to listen for incoming connections
    server_socket.listen()
    server_socket.setblocking(False)
    return server_socket

def move_cursor(row, col):
    print(f"\033[{row};{col}H", end="")

def TCPsend(server_socket,array_string,LVConnected,connection,dbg,cnnm,ln,col):
    cnnmlen = len(cnnm)
    if LVConnected == 0:
        try:
            connection, client_address = server_socket.accept()
            LVConnected = 1
        except:
            LVConnected = 0
            if dbg == True:
                move_cursor(ln,col)
                frontstr = f"{cnnm}: "
                print(Fore.WHITE + frontstr, end="\r")
                fstrl = len(frontstr)
                move_cursor(ln,fstrl+col)
                print(Fore.RED + " Not Connected", end="\r")
    else:
        #LVConnected = 1
        if dbg == True:
            move_cursor(ln,col)
            frontstr = f"{cnnm}: "
            print(Fore.WHITE + frontstr, end="\r")
            fstrl = len(frontstr)
            move_cursor(ln,fstrl+col)
            print(Fore.GREEN + " Connected     ", end="\r")
        try:
            connection.sendall(array_string.encode('utf-8'))
        except:
            LVConnected = 0
    return [LVConnected, connection]

def AINread(NumChannels,scaling):
    AIN = []               # Initializes AIN array - pulling voltage values directly from the LJ.
    AINv = []
    AINf = []              # Initializes limited AIN array - limits digits of values.
    outarray = []          # Initializes TCP output array.
    momtime = time.time()
    tstamp = f"{momtime:12.4f}"
    outarray.append(tstamp)
    for i in range(0,NumChannels+1): # Iterates through all AIN channels.
        if i <= 3:
            AINv.append(d.getAIN(posChannel=i, negChannel=31, longSettle=False,quickSample=False)) # Pulls AIN voltage values from LabJack.
            AIN.append(pow(AINv[i],5)*5+pow(AINv[i],4)*4+pow(AINv[i],3)*3+pow(AINv[i],2)*2+pow(AINv[i],1)*1+2)
        else:
            AINv.append(d.getAIN(posChannel=i, negChannel=31, longSettle=False,quickSample=False)*2.01124) # Pulls AIN voltage values from LabJack.
            AIN.append(pow(AINv[i],5)*5+pow(AINv[i],4)*4+pow(AINv[i],3)*3+pow(AINv[i],2)*2+pow(AINv[i],1)*1+2)
        AINf.append(f"{AIN[i]:10.4f}")     # Converts AIN values to limited decimal values.
        #print(f'AIN{i}: {AINf[i]}', end=" ")  # Prints out AIN values to console.
        outarray.append(AINf[i])
        array_string = ','.join(map(str, outarray))
    return array_string

LVConnected = 0
LVconnection = 0

NCConnected = 0
NCconnection = 0

DLConnected = 0
DLconnection = 0

### Sensor configuration ###

df = pd.read_excel('AIN_Scaling.xlsx')
#AINs = df['AIN']
C5v = df['C5']
C5s = (C5v.values)
C4v = df['C4']
C4s = (C4v.values)
C3v = df['C3']
C3s = (C3v.values)
C2v = df['C2']
C2s = (C2v.values)
C1v = df['C1']
C1s = (C1v.values)
C0v = df['C0']
C0s = (C0v.values)
scalings = [C5v, C4v, C3s, C2s, C1s, C0s]
#print(C1s)

ctr = 1
### Main Loop ###
start_time = time.time()
dbg = True
runfreq = 0
tct = 0
lvfr = 25
lvlmt = 1/lvfr
print('''|||=========================================///
|||     LabJack U3 Interface Program       ///
|||-------------System Status-------------///
|||                                      ///
|||                                     ///
|||                                    ///
|||===================================///''')
LVsock = socketconfig(host,LVport)
NCsock = socketconfig(host,49154)
DLsock = socketconfig(host,49155)
try:
    while running == 1:        # Runs continuously, delaying by delay to achieve desired data rate.                            
        end_time = time.time()
        elapsed_time = end_time - start_time
        tct = tct + elapsed_time
        if tct >= lvlmt:
            tct = 0
            [LVConnected, LVconnection] = TCPsend(LVsock,array_string,LVConnected,LVconnection,dbg,'LV Console 1',4,4)
            [NCConnected, NCconnection] = TCPsend(NCsock,array_string,NCConnected,NCconnection,dbg,'Nathan Console',5,4)
            [DLConnected, DLconnection] = TCPsend(DLsock,array_string,DLConnected,DLconnection,dbg,'Data Logger',6,4)
        if elapsed_time != 0:
            runfreq = 1/elapsed_time
        #print(f"Frequency: {runfreq}Hz",end="\r")
        array_string = AINread(NumChannels,scalings)
        #print(array_string, end="\r")
        #TCPsend(connection,server_socket,array_string,name,line):
        
        #print("")
        time.sleep(delay)                         # Delays as desired to limit datarate.
        ctr = ctr + 1
        start_time = end_time
except:
        print(Fore.WHITE + "                                 ")
        d.close()                                 # Closes LabJack on program end.
