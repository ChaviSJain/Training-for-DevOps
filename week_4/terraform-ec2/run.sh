#!/bin/bash

set -e  # Exit immediately if a command fails

echo "🔹 Initializing Terraform..."
terraform init

echo "🔹 Validating Terraform configuration..."
terraform validate

echo "🔹 Auto-formatting Terraform files..."
terraform fmt -recursive

echo "🔹 Running Terraform plan..."
terraform plan -out=tfplan

echo "🔹 Applying Terraform changes..."
terraform apply -auto-approve tfplan

echo "✅ Deployment complete!"

# Show outputs
echo "🔹 Terraform Outputs:"
terraform output
