# The base URL (no stage path needed because we use the $default stage)
output "api_url" {
  description = "Invoke URL for the HTTP API"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}
