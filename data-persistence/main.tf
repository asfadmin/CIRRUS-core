terraform {
  required_providers {
    aws  = "~> 3.19.0"
    null = "~> 2.1.0"
  }
  backend "s3" {
  }
}

provider "aws" {
  ignore_tags {
    key_prefixes = ["gsfc-ngap"]
  }
}

module "data_persistence" {
  source = "https://github.com/nasa/cumulus/releases/download/v5.0.1/terraform-aws-cumulus.zip//tf-modules/data-persistence"

  prefix                = local.prefix
  subnet_ids            = data.aws_subnet_ids.subnet_ids.ids
  include_elasticsearch = var.include_elasticsearch

  elasticsearch_config = var.elasticsearch_config

}

locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
}

data "aws_region" "current" {}

data "aws_vpc" "application_vpcs" {
  tags = {
    Name = "Application VPC"
  }
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpc.application_vpcs.id

  tags = {
    Name = "Private application ${data.aws_region.current.name}a subnet"
  }
}
