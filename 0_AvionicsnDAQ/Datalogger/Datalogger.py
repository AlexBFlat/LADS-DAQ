
### Library imports ###
import datetime
import time
import socket
import os
import csv
from colorama import Fore, Back, Style, init

## Constants
NumChannels = 15   # Number of channels to be used.
datarate = 20   # Desired data rate in Hz.
decp = 2           # Defines number of decimal points desired.
host = "192.168.11.212"   # Listen on all available interfaces (use specific IP for remote access)
port = 49155       # Port to listen on (ensure it's open and available)

running = 1    # Initializes running variable.
NumChannels = NumChannels - 1

def clear_console():
    os.system('cls' if os.name == 'nt' else 'clear')

def move_cursor(row, col):
    print(f"\033[{row};{col}H", end="")

def TCPrecv(client_socket,LVConnected,host,port,cnnm,dbg,ln,col,bits):
    connectable = 0
    data = []
    cnnmlen = len(cnnm)
    try:
        
        connectable = 1
    except Exception as e:
        eno = e.errno
        if eno == 10061: # Not able to connect error.
            connectable = 0
        if eno == 10056: # Already connected.
            connectable = 1
    #client_socket.shutdown(socket.SHUT_RDWR)
    if connectable == 1:
        Connected = 1
        data = client_socket.recv(bits)
        move_cursor(ln,col)
        frontstr = f"{cnnm}: "
        print(Fore.WHITE + frontstr, end="\r")
        fstrl = len(frontstr)
        move_cursor(ln,fstrl+col)
        print(Fore.GREEN + " Connected     ", end="\r")
    else:
        move_cursor(ln,col)
        frontstr = f"{cnnm}: "
        print(Fore.WHITE + frontstr, end="\r")
        fstrl = len(frontstr)
        move_cursor(ln,fstrl+col)
        print(Fore.RED + " Not Connected", end="\r")
        Connected = 0
    '''if LVConnected == 0:
        try:
            client_socket.connect((host,port))
            Connected = 1
            data = client_socket.recv(bits)
            move_cursor(ln,col)
            frontstr = f"{cnnm}: "
            print(Fore.WHITE + frontstr, end="\r")
            fstrl = len(frontstr)
            move_cursor(ln,fstrl+col)
            print(Fore.GREEN + " Connected     ", end="\r")
        except Exception as e:
            Connected = 0
            if dbg == True:
                move_cursor(ln,col)
                frontstr = f"{cnnm}: "
                print(Fore.WHITE + frontstr, end="\r")
                fstrl = len(frontstr)
                move_cursor(ln,fstrl+col)
                print(Fore.RED + " Not Connected", end="\r")
    else:
            try:
                data = client_socket.recv(bits)
                move_cursor(ln,col)
                frontstr = f"{cnnm}: "
                print(Fore.WHITE + frontstr, end="\r")
                fstrl = len(frontstr)
                move_cursor(ln,fstrl+col)
                print(Fore.GREEN + " Connected     ", end="\r")
            except:
                move_cursor(ln,col)
                frontstr = f"{cnnm}: "
                print(Fore.WHITE + frontstr, end="\r")
                fstrl = len(frontstr)
                move_cursor(ln,fstrl+col)
                print(Fore.RED + " Not Connected", end="\r")
                Connected = 0''' 
    return [data,Connected]

clear_console()

### Main Loop ###
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_LV = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
connected = 0
'''while connected == 0:
    try:
        client_socket.connect((host,port))
        print(f"Connected to {host}:{port}")
        connected = 1
    except:
        connected = 0
        print('Not connected')'''
LVconnected = 0




Logging = 0
v = 0
try:
    while running == 1:        # Runs continuously, delaying by delay to achieve desired data rate.                            
        AINout = []
        data = []
        #data = client_socket.recv(191)
        [data, LVconnected] = TCPrecv(client_socket,LVconnected,host,port,'LJU3INT',True,4,0,191)
        try:
            if LVconnected == 1:
                decoded = data.decode('utf-8')
                split = decoded.split(',')
                TS = float(split[0])
                for i in range(1,len(split)):
                    AINout.append(float(split[i]))
        except:
            v = 0
        #LVdata = client_LV.recv(1)
        #print(LVdata)
        #logging = LVdata.decode('utf-8')
        if  Logging == 1:
             print('Logging!',end="\r")
             
        
except Exception as e:
        print(e)
        print('Closed!')
