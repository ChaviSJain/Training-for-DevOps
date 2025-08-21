#!/bin/bash
set -e

BUCKET_NAME="terraform-state-demo-v1"
TABLE_NAME="terraform-locks"
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

echo "🔍 Checking if DynamoDB table '$TABLE_NAME' exists..."
if aws dynamodb describe-table --table-name "$TABLE_NAME" 2>/dev/null; then
  echo "✅ DynamoDB table '$TABLE_NAME' already exists."
else
  echo "📦 Creating DynamoDB table '$TABLE_NAME' for state locking..."
  aws dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"

  echo "⏳ Waiting for table to become ACTIVE..."
  aws dynamodb wait table-exists --table-name "$TABLE_NAME"

  echo "✅ DynamoDB table '$TABLE_NAME' is ready."
fi
