output "api_gateway_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
  description = "Public URL for the Flask Lambda API"
}
