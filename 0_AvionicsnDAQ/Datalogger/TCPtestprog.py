import socket
import json  # To send data in JSON format

# Define the host and port for the server
host = '0.0.0.0'  # Listen on all available interfaces (use specific IP for remote access)
port = 65432      # Port to listen on (ensure it's open and available)

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

while True:
    try:
        # Example data to send (can be any data you want, e.g., a list, dictionary, or string)
        data_to_send = {"message": "Hello from Python!"}

        # Serialize the data to JSON format
        json_data = json.dumps(data_to_send)

        # Send the serialized data to the client (LabVIEW)
        connection.sendall(json_data.encode('I32'))

        print("Data sent to LabVIEW.")
    except:
        print("Error connecting to LabVIEW")
        connection.close()
        server_socket.close()
        break


connection.close()
server_socket.close()