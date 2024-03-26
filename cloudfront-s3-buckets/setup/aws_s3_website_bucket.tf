resource "aws_s3_bucket" "buckets" {
  for_each = var.buckets
  bucket   = each.value.bucket_name
}

resource "aws_s3_bucket_website_configuration" "bucket_websites" {
  for_each = aws_s3_bucket.buckets
  bucket   = each.value.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "website_buckets" {
  for_each = aws_s3_bucket.buckets
  bucket   = each.value.bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website_buckets" {
  for_each = aws_s3_bucket.buckets
  bucket   = each.value.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "website_buckets" {
  for_each = aws_s3_bucket.buckets
  bucket   = each.value.bucket

  depends_on = [
    aws_s3_bucket_ownership_controls.website_buckets,
    aws_s3_bucket_public_access_block.website_buckets,
  ]

  acl = "private"
}

resource "aws_s3_bucket_acl" "website_bucket" {
  for_each = aws_s3_bucket.buckets
  bucket   = each.value.bucket

  depends_on = [
    aws_s3_bucket_ownership_controls.website_buckets,
    aws_s3_bucket_public_access_block.website_buckets,
  ]

  acl = "private"
}

