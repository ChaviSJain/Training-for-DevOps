#!/bin/bash

SERVER_IP="10.0.2.15"
PORT="2222"
USERNAME="vboxuser"
PROJECT_DIR="week_1"

echo "Copying files to the server..."
scp -P $PORT -r /Users/cjain/Training/$PROJECT_DIR $USERNAME@$SERVER_IP:/HOME/$USERNAME/

echo "CONNECTING TO THE SERVER AND DEPLOYING..."
ssh -p $PORT $USERNAME@$SERVER_IP << EOF
    cd /home/$USERNAME/$PROJECT_DIR
    echo "Building docker image.."
    sudo docker build -t flask-docker-app .
    echo "Running docker container..."
    sudo docker run -d -p 5000:5000 flask-docker-app
EOF

ECHO "DEPLOYMENT COMPLETE! VISIT http://localhost:5000"