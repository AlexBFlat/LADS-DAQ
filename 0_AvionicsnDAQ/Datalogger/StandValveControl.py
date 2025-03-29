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
            data = client_socket.recv(1)
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

def socketconfig(host,port):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # Bind the socket to the address and port
    server_socket.bind((host, port))
    # Enable the server to listen for incoming connections
    server_socket.listen()
    server_socket.setblocking(False)
    return server_socket

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
hostDT = 'SFTSpi.local'   # Listen on all available interfaces (use specific IP for remote access)
portDT = 49157       # Port to listen on (ensure it's open and available)

running = 1
connected = 0
connectedDT = 0
DLConnected = 0
DLConnection = 0
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.settimeout(0.3)
client_socket.setblocking(False)
DLsock = socketconfig(hostDT,portDT)
while running == 1:        # Runs continuously, delaying by delay to achieve desired data rate.   
    try:
        [cmd, connected,client_socket] = TCPrecv(host,port,1,connected,client_socket,4,5,'Alex Console')
        array_string = '1'
        #[DLConnected, DLConnection] = TCPsend(DLsock,array_string,DLConnected,DLConnection,1,'Data logger',5,5)
        if cmd == '1':
            GPIO.output(pin, GPIO.HIGH)
        else:
            GPIO.output(pin, GPIO.LOW)
    except KeyboardInterrupt:
        running = 0