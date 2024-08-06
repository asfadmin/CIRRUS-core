locals {
  prefix               = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  aws_account_id       = data.aws_caller_identity.current.account_id
  aws_account_id_last4 = substr(data.aws_caller_identity.current.account_id, -4, 4)

  default_tags = {
    Deployment = local.prefix
  }

  dar_yes_tags = {
    DAR = "YES"
  }
}
