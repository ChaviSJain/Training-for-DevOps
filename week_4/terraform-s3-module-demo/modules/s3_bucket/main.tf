# Create the S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name       # Name of the bucket

  tags = var.tags                # Apply custom tags
}

# Optional public read policy
resource "aws_s3_bucket_policy" "public_read" {
  count  = var.enable_public_read ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.public_read[0].json
}


resource "aws_s3_bucket_public_access_block" "secure" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = !var.enable_public_read
  block_public_policy     = !var.enable_public_read
  ignore_public_acls      = !var.enable_public_read
  restrict_public_buckets = !var.enable_public_read
}