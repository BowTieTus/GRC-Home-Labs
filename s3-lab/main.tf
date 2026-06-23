terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "lab_bucket" {
  bucket = "my-grc-lab-bucket-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "lab_bucket" {
  bucket = aws_s3_bucket.lab_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "lab_bucket" {
  bucket                  = aws_s3_bucket.lab_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
