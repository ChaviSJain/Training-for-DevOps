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
  region = "ap-south-1"   # change if needed
}
#terraform block → defines which providers/plugins Terraform needs.
#aws provider → tells Terraform to talk to AWS in region us-east-1.
#archive provider → allows Terraform to zip files


# Package the Lambda code into a ZIP
#AWS Lambda always requires code to be uploaded as a ZIP file
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/lambda.zip"
}

# IAM role for Lambda
#AWS Lambda needs permissions to run.
#This creates an IAM Role (lambda_exec_role) that says:
#"Lambda service is allowed to assume this role.”
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach basic Lambda logging permissions
#Gives Lambda permission to write logs to CloudWatch Logs.To see error logs in console.
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create the Lambda function
resource "aws_lambda_function" "demo_lambda" {
  function_name = "demo-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  #ensures Lambda updates whenever the code changes
}

# Create a function URL so you can call it easily
resource "aws_lambda_function_url" "demo_url" {
  function_name      = aws_lambda_function.demo_lambda.function_name
  authorization_type = "NONE"
  #Anyone can hit this URL.
}

output "lambda_url" {
  value = aws_lambda_function_url.demo_url.function_url
}
