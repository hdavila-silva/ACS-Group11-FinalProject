# S3 bucket for terraform state in dev networking environment
terraform {
  backend "s3" {
    bucket = "acs730-dev"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}