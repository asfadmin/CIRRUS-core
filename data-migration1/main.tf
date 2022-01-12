terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.5.0"
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

locals {

  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"

  default_tags = {
    Deployment = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  }

  permissions_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/NGAPShRoleBoundary"

  data_persistence_remote_state_config = {
    bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "data-persistence/terraform.tfstate"
    region = data.aws_region.current.name
  }

  rds_remote_state_config = {
    bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "rds/terraform.tfstate"
    region = data.aws_region.current.name
  }

}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "terraform_remote_state" "data_persistence" {
  backend   = "s3"
  config    = local.data_persistence_remote_state_config
  workspace = var.DEPLOY_NAME
}

data "terraform_remote_state" "rds" {
  backend   = "s3"
  config    = local.rds_remote_state_config
  workspace = var.DEPLOY_NAME
}

module "data_migration1" {
  source = "https://github.com/nasa/cumulus/releases/download/v9.9.0/terraform-aws-cumulus-data-migrations1.zip"

  prefix = local.prefix

  permissions_boundary_arn = local.permissions_boundary_arn

  vpc_id            = data.aws_vpc.application_vpcs.id
  lambda_subnet_ids = data.aws_subnet_ids.subnet_ids.ids

  dynamo_tables = data.terraform_remote_state.data_persistence.outputs.dynamo_tables

  rds_security_group_id      = data.terraform_remote_state.rds.outputs.rds_security_group_id
  rds_user_access_secret_arn = data.terraform_remote_state.rds.outputs.rds_user_access_secret_arn
  rds_connection_heartbeat   = var.rds_connection_heartbeat

  provider_kms_key_id = var.provider_kms_key_id

  tags = merge(var.tags, local.default_tags)
}

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
