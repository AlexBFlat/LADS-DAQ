### Library imports ###
import datetime
import time
import socket

## Constants
NumChannels = 6   # Number of channels to be used.
datarate = 20   # Desired data rate in Hz.
decp = 2           # Defines number of decimal points desired.
host = '0.0.0.0'   # Listen on all available interfaces (use specific IP for remote access)
port = 49153       # Port to listen on (ensure it's open and available)

## Conversion
delay = 1/datarate # Converts delay into seconds of wait time

server_address = (host,port)

running = 1    # Initializes running variable.
NumChannels = NumChannels - 1

### Main Loop ###
try:
    while running == 1:        # Runs continuously, delaying by delay to achieve desired data rate.                            
        print('Running')
except Exception as e:
        print('Closed!')
