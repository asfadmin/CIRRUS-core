terraform {
  required_providers {
    aws  = "~> 2.46.0"
  }
}

provider "aws" {
}

data "aws_caller_identity" "current" {}

locals {
  cumulus-prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
}

// Deprecated state bucket -- no longer used, but don't want to
// destroy yet because we need to migrate state from this bucket to
// the new one.
resource "aws_s3_bucket" "tf-state-bucket" {
  bucket = "cumulus-${var.MATURITY}-tf-state"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "backend-tf-state-bucket" {
  bucket = "${local.cumulus-prefix}-tf-state-${data.aws_caller_identity.current.account_id}"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}

// Deprecated state locks table -- no longer used, but don't want to
// destroy yet because we need to migrate state from this table to
// the new one.
resource "aws_dynamodb_table" "tf-locks-table" {
  name = "cumulus-${var.MATURITY}-tf-locks"
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

resource "aws_dynamodb_table" "backend-tf-locks-table" {
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
