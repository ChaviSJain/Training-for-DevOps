provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"  # Name of the IAM role for Lambda execution

  assume_role_policy = jsonencode({  # Trust policy allowing Lambda to assume this role
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"  # Grants permission to assume the role
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"  # Specifies Lambda as the trusted service
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name  # Attaches the policy to the IAM role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  # Grants basic permissions for Lambda to write logs to CloudWatch
}


resource "aws_lambda_function" "flask_lambda" {
  function_name = var.lambda_function_name  # Lambda function name from variable
  filename      = "${path.module}/../lambda.zip"  # Path to the zipped Flask app
  handler       = "app.handler"  # Entry point: app.py file with handler() function
  runtime       = "python3.11"  # Specifies Python runtime version
  role          = aws_iam_role.lambda_exec.arn  # IAM role ARN for Lambda execution
  source_code_hash = filebase64sha256("${path.module}/../lambda.zip")
  # Ensures Lambda updates when the ZIP file changes
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "flask-http-api"  # Name of the API Gateway
  protocol_type = "HTTP"  # Uses HTTP API (v2) for lightweight routing
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id  # Links to the API Gateway
  integration_type = "AWS_PROXY"  # Direct proxy integration with Lambda
  integration_uri  = aws_lambda_function.flask_lambda.invoke_arn  # Lambda invoke ARN
  integration_method = "POST"  # HTTP method used to invoke Lambda
  payload_format_version = "2.0"  # Uses API Gateway v2.0 payload format
}


resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id  # Links to the API Gateway
  route_key = "ANY /"  # Matches any HTTP method and root path
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  # Routes requests to the Lambda integration
}


resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id  # Links to the API Gateway
  name        = "$default"  # Default stage name (auto-created by API Gateway)
  auto_deploy = true  # Automatically deploy changes without manual intervention
}


resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"  # Unique ID for the permission statement
  action        = "lambda:InvokeFunction"  # Grants invoke permission
  function_name = aws_lambda_function.flask_lambda.function_name  # Target Lambda function
  principal     = "apigateway.amazonaws.com"  # Allows API Gateway to invoke Lambda
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
  # Restricts permission to this specific API Gateway
}

