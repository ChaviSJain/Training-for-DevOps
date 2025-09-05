# Test case named "basic_instance_test"
run "basic_instance_test" {
  command = plan   # Run terraform plan (no infra created)

  assert {
    condition     = aws_instance.ec2.instance_type == "t3.micro"  # Must be t3.micro
    error_message = "Expected instance type to be t3.micro"        # Error if not
  }

  assert {
    condition     = aws_instance.ec2.ami != ""    # AMI must not be empty
    error_message = "AMI ID should not be empty"  # Error if empty
  }
}
