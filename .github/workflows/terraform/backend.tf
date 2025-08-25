terraform {
  backend "s3" {
    bucket = "terraform-demo-state-v1"
    key    = "lambda/hello/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
    # If your org still uses DynamoDB state locking:
    dynamodb_table = "terraform-locks" # Note: DynamoDB locking is deprecated in favor of S3-native; migrate when ready.
  }
}
