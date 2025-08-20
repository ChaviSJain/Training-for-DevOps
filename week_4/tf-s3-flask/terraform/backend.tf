terraform {
  backend "s3" {
    bucket         = "terraform-state-demo-0.1"
    key            = "lambda-demo/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile = true
    encrypt        = true
  }
}