resource "aws_s3_bucket" "raise_tech_storage" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_public_access_block" "raise_tech_bucket_block" {
  bucket = aws_s3_bucket.raise_tech_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "raise_tech_versioning" {
  bucket = aws_s3_bucket.raise_tech_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}
