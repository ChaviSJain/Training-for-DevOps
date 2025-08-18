# Adjustable inputs for region, names, and runtime.
variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "function_name" {
  description = "Lambda function name"
  type        = string
  default     = "flask_lambda"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.9"
}

variable "memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 10
}

# Local zip filenames (produced by build steps)
variable "layer_zip" {
  description = "Path to the Lambda Layer zip containing Python deps under /python"
  type        = string
  default     = "flask_layer.zip"
}

variable "function_zip" {
  description = "Path to the Lambda function zip (only app.py + lambda_handler.py)"
  type        = string
  default     = "flask_lambda.zip"
}
