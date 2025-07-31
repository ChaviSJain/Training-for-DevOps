#!/bin/bash

# Navigate to app folder
cd "$(dirname "$0")"

# Build and launch
docker compose up --build -d
