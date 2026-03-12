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

  configuration_secret_values = sensitive(var.configuration_secret != null ? jsondecode(data.aws_secretsmanager_secret_version.configuration_secret[0].secret_string) : {})
  archive_api_url             = sensitive(lookup(local.configuration_secret_values, "archive_api_url", var.archive_api_url))
  urs_client_password         = sensitive(lookup(local.configuration_secret_values, "urs_client_password", var.urs_client_password))
  metrics_es_password         = sensitive(lookup(local.configuration_secret_values, "metrics_es_password", var.metrics_es_password))
  cmr_password                = sensitive(lookup(local.configuration_secret_values, "cmr_password", var.cmr_password))
  cmr_username                = sensitive(lookup(local.configuration_secret_values, "cmr_username", var.cmr_username))
  launchpad_passphrase        = sensitive(lookup(local.configuration_secret_values, "launchpad_passphrase", var.launchpad_passphrase))
  lzards_launchpad_passphrase = sensitive(lookup(local.configuration_secret_values, "lzards_launchpad_passphrase", var.lzards_launchpad_passphrase))
  token_secret                = sensitive(lookup(local.configuration_secret_values, "token_secret", var.token_secret))
  urs_client_id               = sensitive(lookup(local.configuration_secret_values, "urs_client_id", var.urs_client_id))
  
  urs_tea_client_id       = var.urs_tea_client_id != null ? var.urs_tea_client_id : local.urs_client_id
  urs_tea_client_password = var.urs_tea_client_password != null ? var.urs_tea_client_password : local.urs_client_password
  
  throttled_queues = [
    for q in var.dynamic_throttled_queues : {
      url             = "https://sqs.${data.aws_region.current.name}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${local.prefix}-${q.queue_name}"
      execution_limit = q.execution_limit
    }
  ]
}

check "urs_client_id_required" {
  assert {
    condition     = local.urs_client_id != null
    error_message = "urs_client_id must be provided either via the configuration_secret or the urs_client_id variable."
  }
}

check "cmr_password_required" {
  assert {
    condition     = local.cmr_password != null
    error_message = "cmr_password must be provided either via the configuration_secret or the cmr_password variable."
  }
}

check "cmr_username_required" {
  assert {
    condition     = local.cmr_username != null
    error_message = "cmr_username must be provided either via the configuration_secret or the cmr_username variable."
  }
}

check "urs_client_password_required" {
  assert {
    condition     = local.urs_client_password != null
    error_message = "urs_client_password must be provided either via the configuration_secret or the urs_client_password variable."
  }
}

check "token_secret_required" {
  assert {
    condition     = local.token_secret != null
    error_message = "token_secret must be provided either via the configuration_secret or the token_secret variable."
  }
}

