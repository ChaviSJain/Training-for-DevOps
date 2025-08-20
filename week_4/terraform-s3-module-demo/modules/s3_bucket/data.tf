data "aws_iam_policy_document" "public_read" {
  count = var.enable_public_read ? 1 : 0          # Only generate if public read is enabled

  statement {
    actions   = ["s3:GetObject"]                  # Allow read access
    resources = ["${aws_s3_bucket.bucket.arn}/*"] # Apply to all objects in bucket

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    effect = "Allow"
  }
}
