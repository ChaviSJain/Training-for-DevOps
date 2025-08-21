#!/bin/bash
set -e

BUCKET_NAME="terraform-state-demo-v1"
REGION="ap-south-1"

echo "🔍 Checking if S3 bucket '$BUCKET_NAME' exists..."

if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "✅ Bucket '$BUCKET_NAME' already exists."
else
  echo "🚀 Creating bucket '$BUCKET_NAME' in region '$REGION'..."
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"

  echo "🔐 Enabling encryption and versioning..."
  aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

  aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
      "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }]
    }'

  echo "✅ Bucket '$BUCKET_NAME' created and secured."
fi
