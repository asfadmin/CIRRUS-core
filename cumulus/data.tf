data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "application_vpcs" {
  tags = {
    Name = "Application VPC"
  }
}

data "aws_subnets" "subnet_ids" {
  filter {
    name = "tag:Name"
    values = ["Private application ${data.aws_region.current.name}a subnet",
    "Private application ${data.aws_region.current.name}b subnet"]
  }
}

data "terraform_remote_state" "daac" {
  backend   = "s3"
  workspace = var.DEPLOY_NAME
  config    = local.daac_remote_state_config
}

data "terraform_remote_state" "data_persistence" {
  backend   = "s3"
  workspace = var.DEPLOY_NAME
  config    = local.data_persistence_remote_state_config
}

data "aws_lambda_function" "sts_credentials" {
  function_name = "gsfc-ngap-sh-s3-sts-get-keys"
}

data "aws_lambda_function" "sts_policy_helper" {
  function_name = "gsfc-ngap-sh-sts-policy-helper"
}

data "aws_ssm_parameter" "ecs_image_id" {
  name = "/ngap/amis/image_id_ecs_al2023_x86"
}

data "terraform_remote_state" "orca" {
  count     = var.use_orca == true ? 1 : 0
  backend   = "s3"
  workspace = var.DEPLOY_NAME
  config    = local.orca_remote_state_config
}