#!/bin/bash
set -e

echo "🔧 Building Lambda package..."

# Clean previous builds
rm -rf build lambda.zip
mkdir -p build


# Install Python dependencies into build/
echo "📦 Installing Python dependencies..."
python3 -m pip install --upgrade pip
python3 -m pip install -r lambda-function/requirements.txt -t build/

# Copy source files
echo "📁 Copying source files..."
cp lambda-function/app.py build/

# Patch in aws_wsgi.py manually
echo "🩹 Patching aws-wsgi module..."
cp aws_wsgi.py build/

# Verify aws_wsgi is present
if [ -f build/aws_wsgi.py ]; then
  echo "✅ aws-wsgi successfully patched"
else
  echo "❌ aws-wsgi patch failed — aborting"
  exit 1
fi

# Create zip package
echo "📦 Zipping Lambda package..."
cd build
zip -r ../lambda.zip .
cd ..

echo "🎉 Lambda package created: lambda.zip"
