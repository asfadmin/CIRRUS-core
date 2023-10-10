
data "terraform_remote_state" "orca" {
  count = var.use_orca == true ? 1 : 0
  backend   = "s3"
  workspace = var.DEPLOY_NAME
  config    = local.orca_remote_state_config
}
