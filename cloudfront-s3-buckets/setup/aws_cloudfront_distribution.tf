resource "aws_cloudfront_origin_access_control" "current" {
  for_each                          = aws_s3_bucket.buckets
  name                              = "OAC ${each.value.bucket}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [aws_s3_bucket.buckets]

  dynamic "origin" {
    for_each = aws_s3_bucket.buckets
    content {
      domain_name              = origin.value.bucket_regional_domain_name
      origin_id                = "${origin.value.id}-origin"
      origin_access_control_id = aws_cloudfront_origin_access_control.current[origin.key].id
    }
  }

  comment         = "${var.domain_name} distribution"
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"
  price_class     = "PriceClass_200"

  aliases = [
    var.domain_name,
  ]

  default_root_object = "index.html"

  dynamic "default_cache_behavior" {
    for_each = {
      for bucket, config in var.buckets :
      bucket => config
      if config.bucket_path == "/*"
    }
    content {
      cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true
      target_origin_id       = "${default_cache_behavior.value.bucket_name}-origin"
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = {
      for bucket, config in var.buckets :
      bucket => config
      if config.bucket_path != "/*"
    }
    content {
      path_pattern           = ordered_cache_behavior.value.bucket_path
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      target_origin_id       = "${ordered_cache_behavior.value.bucket_name}-origin"
      viewer_protocol_policy = "redirect-to-https"

      min_ttl     = 0
      default_ttl = 86400
      max_ttl     = 31536000
      compress    = true

      lambda_function_association {
        event_type   = "origin-request"
        include_body = false
        lambda_arn   = aws_lambda_function.rewrite_request_path.qualified_arn
      }

      forwarded_values {
        query_string = false
        headers      = ["Origin"]

        cookies {
          forward = "none"
        }
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.common_tags
}