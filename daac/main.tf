terraform {
  required_providers {
    aws  = ">= 2.31.0"
    null = "~> 2.1"
  }
  backend "s3" {
  }
}

provider "aws" {
}

variable "DEPLOY_NAME" {
  type = string
}

variable "MATURITY" {
  type = string
}

locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
}

resource "aws_s3_bucket" "cumulus-internal-bucket" {
  bucket = "${local.prefix}-internal"
  lifecycle {
    prevent_destroy = true
  }
}

resource "null_resource" "get_newest_CMA" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "curl -L -o cumulus-message-adapter.zip https://github.com/nasa/cumulus-message-adapter/releases/download/${var.cma_version}/cumulus-message-adapter.zip"
  }
}
resource "aws_lambda_layer_version" "cma" {
  depends_on  = [null_resource.get_newest_CMA]
  filename    = "cumulus-message-adapter.zip"
  layer_name  = "${local.prefix}-CMA-layer"
  description = "Layer supporting the Cumulus Message Adapter https://github.com/nasa/cumulus-message-adapter"
  lifecycle {
    prevent_destroy = true
  }
}

output "cma_layer_arn" {
  value = "${aws_lambda_layer_version.cma.arn}"
}
