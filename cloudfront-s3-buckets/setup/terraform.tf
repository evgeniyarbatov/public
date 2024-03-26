terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "yourcomain.com-terraform-state"
    dynamodb_table = "yourcomain.com-tf-state-lock"
    key            = "yourcomain.com-setup.tfstate"
    region         = "ap-southeast-1"
  }
}