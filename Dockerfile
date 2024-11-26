# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container
COPY . /app

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# --no-cache-dir: Prevents pip from caching downloaded files, 
# reducing the size of the Docker image by avoiding unnecessary cache storage.
# -r requirements.txt: Instructs pip to install all the packages listed in the requirements.txt file.

# Expose the port the app runs on
EXPOSE 5000

# Define the command to run the application
CMD ["python", "main.py"]
