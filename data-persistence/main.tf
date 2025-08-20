module "data_persistence" {
  source = "https://github.com/nasa/cumulus/releases/download/v20.2.1/terraform-aws-cumulus.zip//tf-modules/data-persistence"

  prefix                = local.prefix
  subnet_ids            = data.aws_subnets.subnet_ids.ids

  vpc_id                     = data.aws_vpc.application_vpcs.id
  permissions_boundary_arn   = local.permissions_boundary_arn
  rds_user_access_secret_arn = data.terraform_remote_state.rds.outputs.rds_user_access_secret_arn
  rds_security_group_id      = data.terraform_remote_state.rds.outputs.rds_security_group_id
}
