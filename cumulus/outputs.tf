output "workflow_config" {
  value = module.cumulus.workflow_config
}

output "sf_sns_report_task" {
  value = module.cumulus.sf_sns_report_task
}

output "fake_processing_task" {
  value = module.cumulus.fake_processing_task
}

output "archive_api_uri" {
  value = module.cumulus.archive_api_uri
}

output "archive_api_redirect_uri" {
  value = module.cumulus.archive_api_redirect_uri
}

output "distribution_url" {
  value = module.cumulus.distribution_url
}

output "s3_credentials_redirect_uri" {
  value = module.cumulus.s3_credentials_redirect_uri
}

output "distribution_redirect_uri" {
  value = module.cumulus.distribution_redirect_uri
}

# Workflow reporting SNS topics

output "report_executions_sns_topic_arn" {
  value = module.cumulus.report_executions_sns_topic_arn
}

output "report_granules_sns_topic_arn" {
  value = module.cumulus.report_executions_sns_topic_arn
}

output "report_pdrs_sns_topic_arn" {
  value = module.cumulus.report_pdrs_sns_topic_arn
}

output "subnet_ids" {
  value = data.aws_subnet_ids.subnet_ids.ids
}

output "hello_world_task" {
  value = {
    task_arn = module.cumulus.hello_world_task.task_arn
  }
}
