### Multiprocessing development script                         ###
### Built to learn Python multiprocessing                      ###
##################################################################

import multiprocessing
import time
import math
import pandas as pd
import pickle

# Function to serialize and send DataFrame
def producer(queue):
    # Create a sample DataFrame
    df = pd.DataFrame({
        'A': range(5),
        'B': ['a', 'b', 'c', 'd', 'e']
    })
    
    # Serialize DataFrame using pickle
    serialized_df = pickle.dumps(df)
    print("Producer: Sending DataFrame")
    queue.put(serialized_df)  # Send the serialized DataFrame
    #time.sleep(1)

# Function to receive and deserialize the DataFrame
def consumer(queue):
    print("Consumer: Waiting to receive DataFrame...")
    serialized_df = queue.get()  # Receive the serialized DataFrame
    df = pickle.loads(serialized_df)  # Deserialize the DataFrame
    print("Consumer: Received DataFrame")
    print(df)

# Main function to create processes and pass data
if __name__ == "__main__":
    # Create a Queue for inter-process communication
    queue = multiprocessing.Queue()

    # Create producer and consumer processes
    producer_process = multiprocessing.Process(target=producer, args=(queue,))
    consumer_process = multiprocessing.Process(target=consumer, args=(queue,))

    # Start the processes
    producer_process.start()
    consumer_process.start()

    # Wait for the processes to finish
    producer_process.join()
    consumer_process.join()

    print("Both producer and consumer have finished.")