locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"

  buckets = data.terraform_remote_state.daac.outputs.bucket_map

  bucket_map_key = data.terraform_remote_state.daac.outputs.bucket_map_key == "" ? null : data.terraform_remote_state.daac.outputs.bucket_map_key

  protected_bucket_names = [for k, v in local.buckets : v.name if v.type == "protected"]
  public_bucket_names    = [for k, v in local.buckets : v.name if v.type == "public"]

  tea_stack_name              = "${local.prefix}-thin-egress-app"
  tea_stage_name              = var.MATURITY
  thin_egress_jwt_secret_name = "${local.prefix}-jwt_secret_for_tea"

  permissions_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/NGAPShRoleBoundary"

  daac_remote_state_config = {
    bucket = "${local.prefix}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "daac/terraform.tfstate"
    region = data.aws_region.current.name
  }

  data_persistence_remote_state_config = {
    bucket = "${local.prefix}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "data-persistence/terraform.tfstate"
    region = data.aws_region.current.name
  }

  system_bucket = "${local.prefix}-internal"

  cmr_client_id = local.prefix

  default_tags = {
    Deployment = local.prefix
  }
}
