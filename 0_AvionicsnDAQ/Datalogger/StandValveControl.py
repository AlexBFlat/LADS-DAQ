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
import sys
import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)
pin = 17
GPIO.setup(pin, GPIO.OUT)

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
            data = client_socket.recv(1)
            dataout = data.decode('utf-8')
            #print(dataout)
            if len(data) == 0:
                connected = 0
                client_socket.close()
                client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                client_socket.settimeout(0.3)
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


clear_console()
print('''|||=========================================///
|||      Stand valve control program       ///
|||-------------System Status-------------///
|||                                      ///
|||                                     ///
|||                                    ///
|||===================================///''')
host = '169.254.28.201'
port = 49156
hostDT = '169.254.28.202'   # Listen on all available interfaces (use specific IP for remote access)
portDT = 49155       # Port to listen on (ensure it's open and available)

running = 1
connected = 0
connectedDT = 0
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.settimeout(0.3)
client_socketDT = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socketDT.settimeout(0.3)
while running == 1:        # Runs continuously, delaying by delay to achieve desired data rate.   
    try:
        [cmd, connected,client_socket] = TCPrecv(host,port,1,connected,client_socket,4,5,'Alex Console')
        [data, connectedDT,client_socketDT] = TCPrecv(hostDT,portDT,191,connectedDT,client_socketDT,5,5,'LJ interf')
        move_cursor(8,1)
        print(data)
        move_cursor(9,1)
        if cmd == '1':
            GPIO.output(pin, GPIO.HIGH)
        else:
            GPIO.output(pin, GPIO.LOW)
    except KeyboardInterrupt:
        running = 0