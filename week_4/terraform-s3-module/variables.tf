


variable "tags" {
    description = "Tags to assign to the bucket"
    type = map(string)
    default = {}
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
}
