resource "aws_s3_bucket" "static_website" {
  bucket = var.bucket_name
}