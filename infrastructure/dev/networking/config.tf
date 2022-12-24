# S3 bucket for terraform state in dev networking environment
terraform {
  backend "s3" {
    bucket = "group11-dev-private-bucket"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}