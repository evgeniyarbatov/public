provider "aws" {
  region = var.aws_region
}

# CloudFront requires SSL certificates to be provisioned in the North Virginia (us-east-1) region.
provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}

# Lambda @ Edge needs to be in the North Virginia (us-east-1) region.
provider "aws" {
  alias  = "lamda_edge_provider"
  region = "us-east-1"
}