module "data_persistence" {
  source = "https://github.com/nasa/cumulus/releases/download/v1.17.0/terraform-aws-cumulus.zip//tf-modules/data-persistence"

  prefix                     = local.prefix
  subnet_ids                 = "${list(sort(data.aws_subnet_ids.subnet_ids.ids)[0])}"
  include_elasticsearch      = var.include_elasticsearch
}

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

data "aws_vpc" "application_vpcs" {
  tags = {
    Name = "Application VPC"
  }
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpc.application_vpcs.id
}

variable "DEPLOY_NAME" {
  type = string
  default = "asf"
}

variable "MATURITY" {
  type = string
  default = "dev"
}

locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
}

variable "AWS_REGION" {
  type    = string
  default = "us-west-2"
}

variable "include_elasticsearch" {
  type    = bool
  default = true
}

output "dynamo_tables" {
  value = module.data_persistence.dynamo_tables
}

output "elasticsearch_domain_arn" {
  value = module.data_persistence.elasticsearch_domain_arn
}

output "elasticsearch_hostname" {
  value = module.data_persistence.elasticsearch_hostname
}

output "elasticsearch_security_group_id" {
  value = module.data_persistence.elasticsearch_security_group_id
}

output "elasticsearch_alarms" {
  value = module.data_persistence.elasticsearch_alarms
}
