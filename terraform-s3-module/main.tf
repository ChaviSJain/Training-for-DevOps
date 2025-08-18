#Creates a random 4-byte (8 hex characters) ID.
#S3 bucket names must be globally unique across AWS, so this prevents naming conflicts.
resource "random_id" "suffix" {
    byte_length=4
}

#var.bucket_prefix (provided via CLI) with the random suffix from above.
# This creates the actual S3 bucket in AWS.
resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_prefix}-${random_id.suffix.hex}"
  tags = var.tags
}

#Since our policy allows public read/write, we must disable AWS's automatic block
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


#Bucket policy for public read
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id #links policy to the created s3 bucket
  #this policy aloows public read access to the bucket
  policy = jsonencode({
    Version = "2012-10-17"
    #List of permission rules
    Statement = [
        {
            Sid = "PublicReadGetObject" #identifier for the rule
            Effect = "Allow" #Grants access
            Principal = "*" #Apllies to everyone
            Action = "s3:GetObject" #read and write allowed
            Resource = "${aws_s3_bucket.this.arn}/*" #applies to all objects inside bucket
        }
    ]
  })
  #ensures public access block is configured before applying the policy
  depends_on = [aws_s3_bucket_public_access_block.this]
}