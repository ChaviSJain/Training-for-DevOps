terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "ap-south-1"   
}
#archive provider → allows Terraform to zip files


# Package the Lambda code into a ZIP
#AWS Lambda always requires code to be uploaded as a ZIP file
data "archive_file" "lambda_zip" {
  type        = "zip"                                # Specifies ZIP format
  source_dir  = "${path.module}/src"                 # Directory containing Lambda source code
  output_path = "${path.module}/lambda.zip"          # Path to save the zipped file
}

# IAM role for Lambda
#AWS Lambda needs permissions to run.
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"                          # Name of the IAM role

  assume_role_policy = jsonencode({                  # Inline trust policy
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"                      # Allows Lambda to assume this role
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"             # Trusted service is Lambda
      }
    }]
  })
}

# Attach basic Lambda logging permissions to the IAM role created above
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create the Lambda function
resource "aws_lambda_function" "demo_lambda" {
  function_name = "demo-lambda"                      # Name of the Lambda function
  role          = aws_iam_role.lambda_exec.arn       # IAM role ARN for execution
  handler       = "handler.lambda_handler"           # Entry point in your Python code
  runtime       = "python3.11"                       # Python runtime version

  filename         = data.archive_file.lambda_zip.output_path         # Path to zipped code
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256 # Ensures code updates trigger redeployment
}


# Create a function URL so you can call it easily
resource "aws_lambda_function_url" "demo_url" {
  function_name      = aws_lambda_function.demo_lambda.function_name  # Links to the Lambda function
  authorization_type = "NONE"                                         # No auth — public access ,anyone can invoke it
}


output "lambda_url" {
  value = aws_lambda_function_url.demo_url.function_url
}
