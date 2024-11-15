import os
import shutil
import requests
from bs4 import BeautifulSoup

# Set the path to the directory containing the Python code files
root_dir = 'C:\Users\Alex\Pictures'

# Set the path to the downloads folder
downloads_folder = 'C:\Users\Alex\Downloads'

# Set the Python version to update to (e.g. 3.10, 3.11, etc.)
target_version = '3.11'

# Create the downloads folder if it doesn't exist
if not os.path.exists(downloads_folder):
    os.makedirs(downloads_folder)

# Loop through all Python files in the root directory
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith('.py'):
            # Open the file and read its contents
            file_path = os.path.join(root, file)
            with open(file_path, 'r') as f:
                code = f.read()

            # Check if the file is using an older version of Python
            if 'python' in code.lower() and target_version not in code:
                # Update the file to use the target version of Python
                updated_code = code.replace('python', f'python{target_version}')

                # Save the updated file to the downloads folder
                output_file_path = os.path.join(downloads_folder, file)
                with open(output_file_path, 'w') as f:
                    f.write(updated_code)

                print(f'Updated {file} to Python {target_version} and saved to {output_file_path}')
            else:
                print(f'{file} is already using Python {target_version} or does not contain a Python version specification')

# Install required packages
print('Installing required packages...')
os.system('pip install beautifulsoup4 requests')

print('Script complete!')