provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "ec2" {
  ami = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "EC2"
  } 
}