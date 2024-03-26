resource "aws_s3_object" "static_file" {
  for_each     = fileset(local.website_dir, "*")
  bucket       = aws_s3_bucket.static_website.id
  key          = each.key
  source       = "${local.website_dir}/${each.value}"
  content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), null)
  etag         = filemd5("${local.website_dir}/${each.value}")
}

resource "aws_s3_object" "js_and_css_files" {
  for_each     = fileset(local.website_dir, "reviews/*")
  bucket       = aws_s3_bucket.static_website.id
  key          = basename(each.key)
  source       = "${local.website_dir}/${each.value}"
  content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), null)
  etag         = filemd5("${local.website_dir}/${each.value}")
}