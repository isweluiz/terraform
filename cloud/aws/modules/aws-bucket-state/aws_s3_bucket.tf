resource "aws_s3_bucket" "state_terraform_s3" {
  bucket = "state-terraform-s3-resource"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "TFBucket"
    Environment = "Dev"
  }
}

# This allows you to see older versions of the file and revert to those older versions at any time, which can be a useful fallback mechanism if something goes wrong:
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.state_terraform_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.state_terraform_s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.state_terraform_s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}