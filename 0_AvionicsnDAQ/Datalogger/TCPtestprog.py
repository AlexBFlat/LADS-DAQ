import socket
import struct
import json  # To send data in JSON format
import numpy as np

# Define the host and port for the server
host = '0.0.0.0'  # Listen on all available interfaces (use specific IP for remote access)
port = 2870     # Port to listen on (ensure it's open and available)

# Create a TCP/IP socket
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to the address and port
server_socket.bind((host, port))

# Enable the server to listen for incoming connections
server_socket.listen(1)

print(f"Server listening on {host}:{port}...")

# Wait for a connection from the client (LabVIEW)
connection, client_address = server_socket.accept()

print(f"Connection established with {client_address}")
v1 = 1.00
v2 = 2.00
v3 = 3.00
v4 = 4.00
python_array = []
while True:
    try:
        # Example data to send (can be any data you want, e.g., a list, dictionary, or string)
        v1 = v1 + .1
        v2 = v2 + .2
        v3 = v3 + .3
        v4 = v4 + .4
        V1f = f"{v1:08.4f}"
        V2f = f"{v2:08.4f}"
        V3f = f"{v3:08.4f}"
        V4f = f"{v4:08.4f}"

        python_array = [V1f, V2f, V3f, V4f]
        array_string = ','.join(map(str, python_array))
        # Serialize the data to JSON format

        # Send the serialized data to the client (LabVIEW)
        connection.sendall(array_string.encode('utf-8'))

        print("Data sent to LabVIEW.")
    except:
        print("Error connecting to LabVIEW")
        connection.close()
        server_socket.close()
        break


connection.close()
server_socket.close()