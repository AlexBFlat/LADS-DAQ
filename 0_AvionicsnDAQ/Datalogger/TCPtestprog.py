import socket

# Create a TCP/IP socket
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Bind the socket to a specific address and port
server_address = ('localhost', 65432)
server_socket.bind(server_address)

# Enable the server to accept connections
server_socket.listen(1)

print("Waiting for a connection...")
connection, client_address = server_socket.accept()

try:
    print(f"Connection established with {client_address}")

    # Receive data in chunks and print it
    while True:
        data = connection.recv(1024)
        if not data:
            break
        print(f"Received: {data.decode('utf-8')}")
        # Send data back to the client
        connection.sendall(data)
finally:
    connection.close()