terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}

# ─────────────────────────────────────────────────────────
# Provider
# ─────────────────────────────────────────────────────────
provider "aws" {
  region = var.region
}

# ─────────────────────────────────────────────────────────
# IAM role for Lambda (assume role + basic logging)
# ─────────────────────────────────────────────────────────

# Trust policy: allow Lambda service to assume this role
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# The role Lambda will use at runtime
resource "aws_iam_role" "lambda_role" {
  name               = "${var.function_name}_role_v2"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach AWS-managed policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ─────────────────────────────────────────────────────────
# Lambda Layer: Flask + serverless-wsgi
#  The zip contains a "python/" directory with installed packages inside (built in the build steps).
# ─────────────────────────────────────────────────────────
resource "aws_lambda_layer_version" "flask_layer" {
  filename            = "${path.module}/${var.layer_zip}"   # e.g., flask_layer.zip
  layer_name          = "flask-deps"
  compatible_runtimes = [var.runtime]
  description         = "Flask + serverless-wsgi"
}

# ─────────────────────────────────────────────────────────
# Lambda Function
#   - Code zip includes ONLY app.py + lambda_handler.py
#   - Dependencies are provided via the Layer above
# ─────────────────────────────────────────────────────────
resource "aws_lambda_function" "flask_lambda" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  runtime       = var.runtime
  handler       = "lambda_handler.lambda_handler"

  filename         = "${path.module}/${var.function_zip}"   # flask_lambda.zip
  source_code_hash = filebase64sha256("${path.module}/${var.function_zip}")

  # Attaching the layer that contains Flask + serverless-wsgi
  layers = [aws_lambda_layer_version.flask_layer.arn]

  memory_size = var.memory_size
  timeout     = var.timeout
}

# ─────────────────────────────────────────────────────────
# API Gateway v2 (HTTP API) with Lambda proxy integration
#   - $default route: ANY method, any path -> Lambda
#   - $default stage: no stage path in the URL
# ─────────────────────────────────────────────────────────

# Creating the HTTP API
resource "aws_apigatewayv2_api" "http_api" {
  name          = "flask-http-api"
  protocol_type = "HTTP"
}

# Integrating API Gateway -> Lambda (AWS_PROXY means full event passed to Lambda)
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.flask_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Routing EVERYTHING to Lambda via the default route
resource "aws_apigatewayv2_route" "any_proxy" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Allow API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "allow_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.flask_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}

# Deploy automatically using the $default stage (no /dev or /prod in URL)
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}
