variable "bucket_name" {
  default = "chavi-demo-bucket"
}

variable "acl" {
  default = "private"
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
