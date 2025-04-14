output "dynamo_tables" {
  value = module.data_persistence.dynamo_tables
}

output "rds_security_group_id" {
  value = data.terraform_remote_state.rds.outputs.rds_security_group_id
}

output "rds_user_access_secret_arn" {
  value = data.terraform_remote_state.rds.outputs.rds_user_access_secret_arn
}

output "cirrus_core_version" {
  value = var.CIRRUS_CORE_VERSION
}

output "cirrus_daac_version" {
  value = var.CIRRUS_DAAC_VERSION
}
