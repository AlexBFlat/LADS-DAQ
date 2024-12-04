import socket
import struct
import json  # To send data in JSON format
import sys

# Define the host and port for the server
host = '0.0.0.0'  # Listen on all available interfaces (use specific IP for remote access)
port = 36578     # Port to listen on (ensure it's open and available)

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
i = 1
while True:
    try:
        # Example data to send (can be any data you want, e.g., a list, dictionary, or string)
        python_array = [0.00, 2.00, 3.00, 4.00]
        array_string = ','.join(map(str, python_array))
        i = i + 1

        # Serialize the data to JSON format

        # Send the serialized data to the client (LabVIEW)
        sendarray = array_string.encode('utf-8')
        PacketSize = sys.getsizeof(sendarray) + 6
        PacketSizepadded = PacketSize + bytes(6 - len(PacketSize))
        python_array.insert(0,PacketSizepadded)
        array_string2 = ','.join(map(str, python_array))
        connection.sendall(array_string2.encode('utf-8'))

        print("Data sent to LabVIEW.")
    except:
        print("Error connecting to LabVIEW")
        connection.close()
        server_socket.close()
        break


connection.close()
server_socket.close()