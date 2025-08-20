# Use the local module to create an S3 bucket
module "my_bucket" {
  source             = "./modules/s3_bucket"  # Path to the reusable module
  bucket_name        = var.bucket_name        # Pass bucket name             # Pass ACL
  enable_public_read = false                  # Disable public read access
  tags               = var.tags               # Pass tags
}

resource "aws_s3_object" "upload_sample" {
  bucket = module.my_bucket.bucket_id         # Refrences bucket ID from module output
  key    = "uploads/sample.txt"               # Path inside the bucket
  source = "${path.module}/sample.txt"        # Local file to upload
  etag   = filemd5("${path.module}/sample.txt") # Ensures Terraform detects changes to the file and re-uploads if needed
}
