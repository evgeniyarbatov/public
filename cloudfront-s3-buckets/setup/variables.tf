variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "domain_name" {
  type    = string
  default = "yourcomain.com"
}

variable "buckets" {
  type = map(object({
    bucket_name = string
    bucket_path = string
  }))
  default = {
    main = {
      bucket_name = "yourcomain.com"
      bucket_path = "/*"
    },
    news = {
      bucket_name = "yourcomain.com-news"
      bucket_path = "/news/*"
    },
    blog = {
      bucket_name = "yourcomain.com-blog"
      bucket_path = "/blog/*"
    },
  }
}

variable "common_tags" {
  type = map(string)
  default = {
    Project = "yourcomain.com"
  }
}