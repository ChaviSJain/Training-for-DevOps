provider "aws" {
  region = var.region
}

# Execution role for Lambda (or precreate it)
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-hello"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello" {
  function_name    = "git-lambda-demo"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.11"
  filename         = var.lambda_zip_path            # produced by workflow
  source_code_hash = filebase64sha256(var.lambda_zip_path) # forces update on code change
  timeout          = 10
}

output "lambda_arn" { value = aws_lambda_function.hello.arn }
