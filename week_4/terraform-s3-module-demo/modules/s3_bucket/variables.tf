variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "acl" {
  description = "Access control list (e.g., private, public-read)"
  type        = string
  default     = "private"
}

variable "enable_public_read" {
  description = "Enable public read access to bucket objects"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
