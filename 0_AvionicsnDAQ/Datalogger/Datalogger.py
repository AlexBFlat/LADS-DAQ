
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
host = '169.254.28.202'   # Listen on all available interfaces (use specific IP for remote access)
hostcmd = '169.254.28.201'
portcmd = 49157
port = 49155       # Port to listen on (ensure it's open and available)

running = 1    # Initializes running variable.
NumChannels = NumChannels - 1

def clear_console():
    os.system('cls' if os.name == 'nt' else 'clear')

def move_cursor(row, col):
    print(f"\033[{row};{col}H", end="")

def TCPrecv(host,port,bits,connected,client_socket,ln,col,cnnm):
    try:
        if connected == 0:
            try:
                client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                client_socket.settimeout(0.3)
                client_socket.setblocking(False)
                client_socket.connect((host,port))
                connected = 1
            except:
                l=1
            returndata = 0
            move_cursor(ln,col)
            frontstr = f"{cnnm}: "
            print(Fore.WHITE + frontstr, end="\r")
            fstrl = len(frontstr)
            move_cursor(ln,fstrl+col)
            print(Fore.RED + " Not Connected", end="\r")
        else:
            data = client_socket.recv(bits)
            dataout = data.decode('utf-8')
            #print(dataout)
            if len(data) == 0:
                connected = 0
                client_socket.close()
                client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                client_socket.settimeout(0.3)
                client_socket.setblocking(False)
            returndata = dataout
            move_cursor(ln,col)
            frontstr = f"{cnnm}: "
            print(Fore.WHITE + frontstr, end="\r")
            fstrl = len(frontstr)
            move_cursor(ln,fstrl+col)
            print(Fore.GREEN + " Connected     ", end="\r")
        return [returndata,connected,client_socket]
    except:
        return [0,connected,client_socket]

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

clear_console()

### Main Loop ###
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.settimeout(0.3)
client_socket.setblocking(False)
client_socket2 = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket2.settimeout(0.3)
client_socket2.setblocking(False)
client_LV = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
connected = 0
connected2 = 0
'''while connected == 0:
    try:
        client_socket.connect((host,port))
        print(f"Connected to {host}:{port}")
        connected = 1
    except:
        connected = 0
        print('Not connected')'''
LVconnected = 0


clear_console()
print('''|||=========================================///
|||      Stand valve control program       ///
|||-------------System Status-------------///
|||                                      ///
|||                                     ///
|||                                    ///
|||===================================///''')
Logging = 0
v = 0
try:
    while running == 1:        # Runs continuously, delaying by delay to achieve desired data rate.                            
        [data,connected,client_socket] = TCPrecv(host,port,191,connected,client_socket,4,5,'LJU3 interface')
        #[logcmd,connected2,client_socket2] = TCPrecv(host,portcmd,1,connected2,client_socket2,5,5,'LJU3 interface')
        move_cursor(8,1)
        print(data)
        #move_cursor(9,1)
        #print(logcmd)
except Exception as e:
        print(e)
        print('Closed!')
