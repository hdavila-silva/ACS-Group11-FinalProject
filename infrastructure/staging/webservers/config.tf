# S3 Bucket Dev env webseever
terraform {
  backend "s3" {
    bucket = "group11-staging-private-bucket"
    key    = "dev/webserver/terraform.tfstate"
    region = "us-east-1"
  }
}