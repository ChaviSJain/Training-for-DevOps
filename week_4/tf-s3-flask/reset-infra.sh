#!/bin/bash
set -e

echo "🧹 Cleaning up AWS resources..."

ROLE_NAME="lambda_exec_role"
LAMBDA_NAME="flask_lambda"
API_NAME="flask-http-api"

# 🛡️ IAM Role Cleanup
if aws iam get-role --role-name "$ROLE_NAME" > /dev/null 2>&1; then
  echo "🔗 Detaching policies from $ROLE_NAME..."
  POLICIES=$(aws iam list-attached-role-policies --role-name "$ROLE_NAME" --query "AttachedPolicies[].PolicyArn" --output text)
  for POLICY in $POLICIES; do
    aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn "$POLICY"
  done

  echo "🗑️ Deleting IAM role $ROLE_NAME..."
  aws iam delete-role --role-name "$ROLE_NAME"
else
  echo "⚠️ IAM role $ROLE_NAME not found. Skipping."
fi

# 🧨 Lambda Function Cleanup
if aws lambda get-function --function-name "$LAMBDA_NAME" > /dev/null 2>&1; then
  echo "🗑️ Deleting Lambda function $LAMBDA_NAME..."
  aws lambda delete-function --function-name "$LAMBDA_NAME"
else
  echo "⚠️ Lambda function $LAMBDA_NAME not found. Skipping."
fi

# 🌐 API Gateway Cleanup
API_ID=$(aws apigatewayv2 get-apis --query "Items[?Name=='$API_NAME'].ApiId" --output text)
if [ -n "$API_ID" ]; then
  for ID in $API_ID; do
    echo "🗑️ Deleting API Gateway $ID..."
    aws apigatewayv2 delete-api --api-id "$ID" || echo "API $ID not found"
  done
else
  echo "⚠️ API Gateway '$API_NAME' not found. Skipping."
fi


echo "✅ Cleanup complete. Ready for terraform apply."
