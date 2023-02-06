terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1"
    }
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
  source = "https://github.com/nasa/cumulus/releases/download/v11.1.8/terraform-aws-cumulus.zip//tf-modules/data-persistence"

  prefix                = local.prefix
  subnet_ids            = data.aws_subnet_ids.subnet_ids.ids
  include_elasticsearch = var.include_elasticsearch

  elasticsearch_config = var.elasticsearch_config

  vpc_id                     = data.aws_vpc.application_vpcs.id
  permissions_boundary_arn   = local.permissions_boundary_arn
  rds_user_access_secret_arn = data.terraform_remote_state.rds.outputs.rds_user_access_secret_arn
  rds_security_group_id      = data.terraform_remote_state.rds.outputs.rds_security_group_id

  tags = local.default_tags
}

locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"

  default_tags = {
    Deployment = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  }

  permissions_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/NGAPShRoleBoundary"

  rds_remote_state_config = {
    bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "rds/terraform.tfstate"
    region = data.aws_region.current.name
  }

}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "application_vpcs" {
  tags = {
    Name = "Application VPC"
  }
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpc.application_vpcs.id

  filter {
    name = "tag:Name"
    values = ["Private application ${data.aws_region.current.name}a subnet",
    "Private application ${data.aws_region.current.name}b subnet"]
  }
}

data "terraform_remote_state" "rds" {
  backend   = "s3"
  workspace = var.DEPLOY_NAME
  config    = local.rds_remote_state_config
}
