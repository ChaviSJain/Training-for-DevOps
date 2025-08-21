# Create the S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name       # Name of the bucket

  tags = var.tags                # Apply custom tags
}

# Optional public read policy
resource "aws_s3_bucket_policy" "public_read" {
  count  = var.enable_public_read ? 1 : 0                    # Create only if public read is enabled
  bucket = aws_s3_bucket.bucket.id                           # get bucket id.Attach policy to bucket
  policy = data.aws_iam_policy_document.public_read[0].json  # Use generated policy
}


