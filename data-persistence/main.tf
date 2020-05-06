terraform {
  required_providers {
    aws  = "~> 2.46.0"
    null = "~> 2.1.0"
  }
  backend "s3" {
  }
}

provider "aws" {
}

module "data_persistence" {
  source = "https://github.com/nasa/cumulus/releases/download/v1.20.0/terraform-aws-cumulus.zip//tf-modules/data-persistence"

  prefix                     = local.prefix
  subnet_ids                 = data.aws_subnet_ids.subnet_ids.ids
  include_elasticsearch      = var.include_elasticsearch
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
