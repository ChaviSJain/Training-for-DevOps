variable "bucket_name" {
  default = "chavi-demo-bucket"
}

variable "enable_public_read" {
  default = true
}

variable "tags" {
  default = {
    Owner       = "Chavi"
    Environment = "Dev"
  }
}
