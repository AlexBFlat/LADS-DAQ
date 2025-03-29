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
    if connected == 0:
        try:
            client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
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
        returndata = dataout
        move_cursor(ln,col)
        frontstr = f"{cnnm}: "
        print(Fore.WHITE + frontstr, end="\r")
        fstrl = len(frontstr)
        move_cursor(ln,fstrl+col)
        print(Fore.GREEN + " Connected     ", end="\r")
    return [returndata,connected,client_socket]


clear_console()
print('''|||=========================================///
|||      Stand valve control program       ///
|||-------------System Status-------------///
|||                                      ///
|||                                     ///
|||                                    ///
|||===================================///''')
host = '192.168.10.113'
port = 49156
running = 1
connected = 0
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    while running == 1:        # Runs continuously, delaying by delay to achieve desired data rate.   
        [data, connected,client_socket] = TCPrecv(host,port,1,connected,client_socket,4,5,'Alex Console')
        #if data == '1':
            #GPIO.output(pin, GPIO.HIGH)
        #else:
            #GPIO.output(pin, GPIO.LOW)
        '''#print('running')
        if connected == 0:
            try:
                client_socket.connect(('192.168.10.113',49156))
                connected = 1
            except:
                print ('Failed connection')
        else:
            data = client_socket.recv(1)
            dataout = data.decode('utf-8')
            print(dataout)
            if len(data) == 0:
               connected = 0
               client_socket.close()
               client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)'''
               
except:
    print('failure')
    sys.exit()