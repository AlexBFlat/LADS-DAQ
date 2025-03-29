import socket

# Create a TCP/IP socket
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect the client to the server
server_address = ('localhost', 65432)
client_socket.connect(server_address)

try:
    # Send data
    message = "Hello, Server!"
    client_socket.sendall(message.encode('utf-8'))
    
    # Receive response from the server
    data = client_socket.recv(1024)
    print(f"Received from server: {data.decode('utf-8')}")
finally:
    client_socket.close()