output "website_urls" {
  value = {
    for bucket, config in var.buckets :
    bucket => "https://${var.domain_name}${config.bucket_path}"
  }
}