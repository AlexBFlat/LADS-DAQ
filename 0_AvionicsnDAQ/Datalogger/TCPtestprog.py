import socket
import json  # To serialize the array into a string format

# Create a TCP/IP socket
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to the server's address and port
server_address = ('192.168.56.1', 65432)
server_socket.bind(server_address)

# Enable the server to accept connections
server_socket.listen(1)

print("Waiting for a connection...")

# Accept an incoming connection
connection, client_address = server_socket.accept()

try:
    print(f"Connection established with {client_address}")

    # Create an array of numbers (example: from 1 to 10)
    numbers_array = [i for i in range(1, 11)]
    
    # Convert the array to a JSON string for easy transmission
    numbers_json = json.dumps(numbers_array)
    
    # Send the array to the client
    connection.sendall(numbers_json.encode('utf-8'))

finally:
    connection.close()
