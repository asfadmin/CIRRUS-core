locals {
  prefix               = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  aws_account_id       = data.aws_caller_identity.current.account_id
  aws_account_id_last4 = substr(data.aws_caller_identity.current.account_id, -4, 4)

  cirrus_core_version  = var.CIRRUS_CORE_BRANCH == "HEAD" ? var.CIRRUS_CORE_TAG: var.CIRRUS_CORE_BRANCH
  cirrus_daac_version  = var.CIRRUS_DAAC_BRANCH == "HEAD" ? var.CIRRUS_DAAC_TAG: var.CIRRUS_DAAC_BRANCH

  default_tags = {
    Deployment = local.prefix
  }
}
