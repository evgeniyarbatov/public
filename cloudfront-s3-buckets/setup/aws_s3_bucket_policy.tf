resource "aws_s3_bucket_policy" "allow_cloudfront" {
  for_each = aws_s3_bucket.buckets
  bucket   = each.value.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"

        Action = "s3:GetObject"

        Resource = [
          "${each.value.arn}",
          "${each.value.arn}/*"
        ]

        Principal = {
          Service = "cloudfront.amazonaws.com"
        }

        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      },
    ]
  })
}