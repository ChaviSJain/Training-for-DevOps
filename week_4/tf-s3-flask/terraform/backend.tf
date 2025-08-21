terraform {
  backend "s3" {
    bucket         = "terraform-state-demo-v1"
    key            = "lambda-demo/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"                #storing state remotely in S3. It enables distributed locking using a DynamoDB table.
    encrypt        = true
  }
}
#successfully uses that table to:
#Write a lock entry (LockID)
#Prevent concurrent state changes
#Release the lock when done