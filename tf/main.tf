resource "aws_s3_bucket" "backend-tf-state-bucket" {
  bucket = "${local.prefix}-tf-state-${local.aws_account_id_last4}"
  lifecycle {
    prevent_destroy = true
  }
  tags = local.default_tags
}

resource "aws_s3_bucket_versioning" "backend-tf-state-bucket-versioning" {
  bucket = aws_s3_bucket.backend-tf-state-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "backend-tf-locks-table" {
  name         = "${local.prefix}-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  lifecycle {
    prevent_destroy = true
  }
  tags = local.default_tags
}
