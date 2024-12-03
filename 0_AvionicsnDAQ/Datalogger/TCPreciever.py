import socket
import json  # To deserialize the received JSON string back into an array

# Create a TCP/IP socket
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect the client to the server
server_address = ('localhost', 65432)
client_socket.connect(server_address)

try:
    # Receive data from the server
    data = client_socket.recv(1024)
    
    # Deserialize the JSON string back into an array
    numbers_array = json.loads(data.decode('utf-8'))
    
    print(f"Received array of numbers: {numbers_array}")
finally:
    client_socket.close()