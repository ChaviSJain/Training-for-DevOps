provider "aws" {
  region = "ap-south-1"
}

module "my_s3_bucket" {
  source      = "../"
  bucket_prefix = "my-demo-bucket"
  acl = "public-read"
  tags = {
    Environment = "dev"
    Owner       = "Chavi"
  }
}
