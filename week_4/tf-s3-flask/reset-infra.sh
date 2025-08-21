#!/bin/bash
set -e

echo "🧹 Cleaning up AWS resources..."

# Detach IAM policies
POLICIES=$(aws iam list-attached-role-policies --role-name lambda_exec_role --query "AttachedPolicies[].PolicyArn" --output text)
for POLICY in $POLICIES; do
  aws iam detach-role-policy --role-name lambda_exec_role --policy-arn $POLICY
done

# Delete IAM role
aws iam delete-role --role-name lambda_exec_role || echo "IAM role not found"

# Delete Lambda function
aws lambda delete-function --function-name flask_lambda || echo "Lambda not found"

# Delete API Gateway
API_ID=$(aws apigatewayv2 get-apis --query "Items[?Name=='flask-http-api'].ApiId" --output text)
for ID in $API_ID; do
  aws apigatewayv2 delete-api --api-id $ID || echo "API $ID not found"
done

# Delete DynamoDB table
#aws dynamodb delete-table --table-name terraform-locks || echo "DynamoDB table not found"

echo "✅ Cleanup complete. Ready for terraform apply."
