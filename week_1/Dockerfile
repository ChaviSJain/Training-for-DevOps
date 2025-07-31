# Use the official Python 3.11 slim image as the base to keep the image lightweight
FROM python:3.11-slim

# Set the working directory inside the container to /Training
# All subsequent commands will run in this directory
WORKDIR /Training

# Copy the requirements.txt file from your local machine to the container
COPY requirements.txt .

# Install all Python dependencies listed in requirements.txt using pip
RUN pip install -r requirements.txt

# Copy everything from your current directory into the container's working directory
COPY . .

# Specify the command to run when the container starts: this will run app.py using Python
CMD ["python", "app.py"]
