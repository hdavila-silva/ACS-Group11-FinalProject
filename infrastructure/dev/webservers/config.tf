# S3 Bucket Dev env webseever
terraform {
  backend "s3" {
    bucket = "acs730-dev"
    key    = "dev/webserver/terraform.tfstate"
    region = "us-east-1"
  }
}