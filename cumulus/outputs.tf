# ---------
# Cumulus workflow config
output "workflow_config" {
  value = module.cumulus.workflow_config
}

# ---------
# Cumulus Tasks
output "add_missing_file_checksums_task" {
  value = module.cumulus.add_missing_file_checksums_task
}
output "discover_granules_task" {
  value = module.cumulus.discover_granules_task
}
output "discover_pdrs_task" {
  value = module.cumulus.discover_pdrs_task
}
output "fake_processing_task" {
  value = module.cumulus.fake_processing_task
}
output "files_to_granules_task" {
  value = module.cumulus.files_to_granules_task
}
output "hello_world_task" {
  value = module.cumulus.hello_world_task
}
output "hyrax_metadata_updates_task" {
  value = module.cumulus.hyrax_metadata_updates_task
}
output "lzards_backup_task" {
  value = module.cumulus.lzards_backup_task
}
output "move_granules_task" {
  value = module.cumulus.move_granules_task
}

output "orca_recovery_adapter_task" {
  value = module.cumulus.orca_recovery_adapter_task
}

output "orca_copy_to_archive_adapter_task" {
  value = module.cumulus.orca_copy_to_archive_adapter_task
}

output "parse_pdr_task" {
  value = module.cumulus.parse_pdr_task
}
output "pdr_status_check_task" {
  value = module.cumulus.pdr_status_check_task
}

output "provider_kms_key_id" {
  value = module.cumulus.provider_kms_key_id
}

output "queue_granules_task" {
  value = module.cumulus.queue_granules_task
}
output "queue_pdrs_task" {
  value = module.cumulus.queue_pdrs_task
}
output "queue_workflow_task" {
  value = module.cumulus.queue_workflow_task
}
output "sf_sqs_report_task" {
  value = module.cumulus.sf_sqs_report_task
}
output "sync_granule_task" {
  value = module.cumulus.sync_granule_task
}
output "update_cmr_access_constraints_task" {
  value = module.cumulus.update_cmr_access_constraints_task
}
output "update_granules_cmr_metadata_file_links_task" {
  value = module.cumulus.update_granules_cmr_metadata_file_links_task
}
output "post_to_cmr_task" {
  value = module.cumulus.post_to_cmr_task
}
output "sqs2sfThrottle_lambda_function_arn" {
  value = module.cumulus.sqs2sfThrottle_lambda_function_arn
}

# ---------
# Cumulus IAM Resources
output "lambda_processing_role_name" {
  value = module.cumulus.lambda_processing_role_name
}
output "lambda_processing_role_arn" {
  value = module.cumulus.lambda_processing_role_arn
}
output "no_ingress_all_egress" {
  value = aws_security_group.no_ingress_all_egress
}

# ---------
# Cumulus URIs
output "archive_api_uri" {
  value = module.cumulus.archive_api_uri
}
output "archive_api_redirect_uri" {
  value = module.cumulus.archive_api_redirect_uri
}
output "distribution_url" {
  value = module.thin_egress_app.api_endpoint
}
output "s3_credentials_redirect_uri" {
  value = module.cumulus.s3_credentials_redirect_uri
}
output "distribution_redirect_uri" {
  value = module.thin_egress_app.urs_redirect_uri
}

# ---------
# Workflow reporting Queue and SNS topics
output "stepfunction_event_reporter_queue_url" {
  value = module.cumulus.stepfunction_event_reporter_queue_url
}
output "report_collections_sns_topic_arn" {
  value = module.cumulus.report_collections_sns_topic_arn
}
output "report_executions_sns_topic_arn" {
  value = module.cumulus.report_executions_sns_topic_arn
}
output "report_granules_sns_topic_arn" {
  value = module.cumulus.report_granules_sns_topic_arn
}
output "report_pdrs_sns_topic_arn" {
  value = module.cumulus.report_pdrs_sns_topic_arn
}
output "subnet_ids" {
  value = data.aws_subnets.subnet_ids.ids
}

output "ecs_cluster_arn" {
  value = module.cumulus.ecs_cluster_arn
}

output "cmr_environment" {
  value = var.cmr_environment
}

output "start_sf_queue_url" {
  value = module.cumulus.start_sf_queue_url
}

output "background_job_queue_url" {
  value = aws_sqs_queue.background_job_queue.id
}
output "vpc" {
  value = data.aws_vpc.application_vpcs.id
}

output "cirrus_core_version" {
  value = var.CIRRUS_CORE_VERSION
}

output "cirrus_daac_version" {
  value = var.CIRRUS_DAAC_VERSION
}
