locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"

  default_tags = {
    Deployment = local.prefix
  }

  permissions_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/NGAPShRoleBoundary"

  rds_remote_state_config = {
    bucket = "${local.prefix}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "rds/terraform.tfstate"
    region = data.aws_region.current.name
  }
}
