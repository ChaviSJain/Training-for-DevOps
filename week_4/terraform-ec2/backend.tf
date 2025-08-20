terraform{
    backend "s3" {
      bucket = "my-terraform-state-bucket"
      key = "ec2/terraform.tfstate"
      region = "ap-south-1"
      encrypt= true
    }
}