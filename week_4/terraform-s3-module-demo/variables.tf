variable "bucket_name" {
  default = "v1-demo-bucket"
}

variable "enable_public_read" {
  default = false
}

variable "tags" {
  default = {
    Owner       = "Chavi"
    Environment = "Dev"
  }
}
