terraform {
  required_providers {
    aws  = "~> 2.46.0"
  }
}

provider "aws" {
}

locals {
  cumulus-prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
}

resource "aws_s3_bucket" "tf-state-bucket" {
  bucket = "${local.cumulus-prefix}-tf-state"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "tf-locks-table" {
  name = "${local.cumulus-prefix}-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  lifecycle {
    prevent_destroy = true
  }
}
