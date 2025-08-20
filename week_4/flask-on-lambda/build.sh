#!/bin/bash
set -e  # Exit on error

echo "🔧 Building Lambda package..."

# Define paths
SRC_DIR="lambda-function"
BUILD_DIR="build"
ZIP_FILE="lambda.zip"

# Clean previous build
rm -rf $BUILD_DIR $ZIP_FILE
mkdir $BUILD_DIR

# Install dependencies into build folder
python3 -m pip install --no-binary :all: -r $SRC_DIR/requirements.txt -t $BUILD_DIR

# Copy app.py
cp $SRC_DIR/app.py $BUILD_DIR/

# Zip contents
cd $BUILD_DIR
zip -r ../$ZIP_FILE .
cd ..

echo "✅ Lambda package created: $ZIP_FILE"
