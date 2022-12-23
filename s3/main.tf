# Create S3 Bucket for dev terraform.state
resource "aws_s3_bucket" "s3-dev" {
  bucket        = "${var.prefix}-dev-private-bucket"
  force_destroy = true
  tags = {
    Name        = "private bucket"
    Environment = "dev"
  }
}

# Create ACL for S3
resource "aws_s3_bucket_acl" "s3-dev-acl" {
  bucket = aws_s3_bucket.s3-dev.id
  acl    = "private"
}

# Limit access to S3
resource "aws_s3_bucket_public_access_block" "dev-s3-acl" {
  bucket = aws_s3_bucket.s3-dev.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}


# # Create S3 Bucket for staging terraform.state

resource "aws_s3_bucket" "s3-staging" {
  bucket        = "${var.prefix}-staging-private-bucket"
  force_destroy = true
  tags = {
    Name        = "private bucket"
    Environment = "staging"
  }
}


resource "aws_s3_bucket_acl" "s3-staging-acl" {
  bucket = aws_s3_bucket.s3-staging.id
  acl    = "private"
}

# Limit access to S3
resource "aws_s3_bucket_public_access_block" "staging-s3-acl" {
  bucket = aws_s3_bucket.s3-staging.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# # Create S3 Bucket for prod terraform.state

resource "aws_s3_bucket" "s3-prod" {
  bucket        = "${var.prefix}-prod-private-bucket"
  force_destroy = true
  tags = {
    Name        = "private bucket"
    Environment = "prod"
  }
}

resource "aws_s3_bucket_acl" "s3-prod-acl" {
  bucket = aws_s3_bucket.s3-prod.id
  acl    = "private"
}

# Limit access to S3
resource "aws_s3_bucket_public_access_block" "prod-s3-acl" {
  bucket = aws_s3_bucket.s3-prod.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

### S3 Bucket for webpage

# Create S3 Bucket
resource "aws_s3_bucket" "webpage-s3" {
  bucket        = "${var.prefix}-webpage-bucket"
  force_destroy = true
  tags = {
    Name        = "webpage bucket"
  }
}