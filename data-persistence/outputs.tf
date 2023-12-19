output "dynamo_tables" {
  value = module.data_persistence.dynamo_tables
}

output "elasticsearch_domain_arn" {
  value = module.data_persistence.elasticsearch_domain_arn
}

output "elasticsearch_hostname" {
  value = module.data_persistence.elasticsearch_hostname
}

output "elasticsearch_security_group_id" {
  value = module.data_persistence.elasticsearch_security_group_id
}

output "elasticsearch_alarms" {
  value = module.data_persistence.elasticsearch_alarms
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
