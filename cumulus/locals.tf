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

  orca_remote_state_config = {
    bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "orca/terraform.tfstate"
    region = data.aws_region.current.name
  }
  orca_lambda_copy_to_archive_arn = var.use_orca == true ? data.terraform_remote_state.orca[0].outputs.orca_module.orca_lambda_copy_to_archive_arn : ""
  orca_sfn_recovery_workflow_arn  = var.use_orca == true ? data.terraform_remote_state.orca[0].outputs.orca_module.orca_sfn_recovery_workflow_arn : ""
  orca_api_uri                    = var.use_orca == true ? data.terraform_remote_state.orca[0].outputs.orca_module.orca_api_deployment_invoke_url : ""

  default_tags = {
    Deployment = local.prefix
  }

  urs_tea_client_id       = var.urs_tea_client_id != null ? var.urs_tea_client_id : var.urs_client_id
  urs_tea_client_password = var.urs_tea_client_password != null ? var.urs_tea_client_password : var.urs_client_password
}
