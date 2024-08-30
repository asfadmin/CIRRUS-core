module "cumulus" {
  source = "https://github.com/nasa/cumulus/releases/download/v18.3.3/terraform-aws-cumulus.zip//tf-modules/cumulus"

  cumulus_message_adapter_lambda_layer_version_arn = data.terraform_remote_state.daac.outputs.cma_layer_arn

  prefix = local.prefix

  vpc_id            = data.aws_vpc.application_vpcs.id
  lambda_subnet_ids = data.aws_subnets.subnet_ids.ids

  deploy_to_ngap = true

  ecs_cluster_instance_image_id = var.ecs_cluster_instance_image_id != "" ? var.ecs_cluster_instance_image_id : data.aws_ssm_parameter.ecs_image_id.value

  ecs_cluster_instance_subnet_ids         = data.aws_subnets.subnet_ids.ids
  ecs_cluster_min_size                    = var.ecs_cluster_min_size
  ecs_cluster_desired_size                = var.ecs_cluster_desired_size
  ecs_cluster_max_size                    = var.ecs_cluster_max_size
  ecs_cluster_instance_type               = var.ecs_cluster_instance_type
  ecs_cluster_instance_docker_volume_size = var.ecs_cluster_instance_docker_volume_size

  key_name = var.key_name

  rds_security_group         = data.terraform_remote_state.data_persistence.outputs.rds_security_group_id
  rds_user_access_secret_arn = data.terraform_remote_state.data_persistence.outputs.rds_user_access_secret_arn

  urs_url             = var.urs_url
  urs_client_id       = var.urs_client_id
  urs_client_password = var.urs_client_password

  metrics_es_host     = var.metrics_es_host
  metrics_es_username = var.metrics_es_username
  metrics_es_password = var.metrics_es_password

  es_index_shards        = var.es_index_shards
  es_request_concurrency = var.es_request_concurrency

  cmr_client_id   = local.cmr_client_id
  cmr_environment = var.cmr_environment
  cmr_username    = var.cmr_username
  cmr_password    = var.cmr_password
  cmr_provider    = var.cmr_provider

  cmr_oauth_provider = var.cmr_oauth_provider

  lambda_memory_sizes = var.lambda_memory_sizes
  lambda_timeouts     = var.lambda_timeouts

  launchpad_api         = var.launchpad_api
  launchpad_certificate = var.launchpad_certificate
  launchpad_passphrase  = var.launchpad_passphrase

  lzards_launchpad_certificate = var.lzards_launchpad_certificate
  lzards_launchpad_passphrase  = var.lzards_launchpad_passphrase
  lzards_provider              = var.lzards_provider
  lzards_api                   = var.lzards_api
  lzards_s3_link_timeout       = var.lzards_s3_link_timeout

  oauth_provider   = var.oauth_provider
  oauth_user_group = var.oauth_user_group

  saml_entity_id                  = var.saml_entity_id
  saml_assertion_consumer_service = var.saml_assertion_consumer_service
  saml_idp_login                  = var.saml_idp_login
  saml_launchpad_metadata_url     = var.saml_launchpad_metadata_url

  token_secret = var.token_secret

  permissions_boundary_arn = local.permissions_boundary_arn

  system_bucket = local.system_bucket
  buckets       = local.buckets

  elasticsearch_alarms            = data.terraform_remote_state.data_persistence.outputs.elasticsearch_alarms
  elasticsearch_domain_arn        = data.terraform_remote_state.data_persistence.outputs.elasticsearch_domain_arn
  elasticsearch_hostname          = data.terraform_remote_state.data_persistence.outputs.elasticsearch_hostname
  elasticsearch_security_group_id = data.terraform_remote_state.data_persistence.outputs.elasticsearch_security_group_id

  dynamo_tables = data.terraform_remote_state.data_persistence.outputs.dynamo_tables

  archive_api_users = var.api_users
  archive_api_url   = var.archive_api_url

  orca_lambda_copy_to_archive_arn = local.orca_lambda_copy_to_archive_arn
  orca_sfn_recovery_workflow_arn  = local.orca_sfn_recovery_workflow_arn
  orca_api_uri                    = local.orca_api_uri

  # must match stage_name variable for thin-egress-app module
  tea_api_gateway_stage = local.tea_stage_name

  tea_rest_api_id               = module.thin_egress_app.rest_api.id
  tea_rest_api_root_resource_id = module.thin_egress_app.rest_api.root_resource_id
  tea_internal_api_endpoint     = module.thin_egress_app.internal_api_endpoint
  tea_external_api_endpoint     = module.thin_egress_app.api_endpoint

  sts_credentials_lambda_function_arn   = data.aws_lambda_function.sts_credentials.arn
  sts_policy_helper_lambda_function_arn = data.aws_lambda_function.sts_policy_helper.arn
  cmr_acl_based_credentials             = var.cmr_acl_based_credentials

  archive_api_port            = var.archive_api_port
  private_archive_api_gateway = var.private_archive_api_gateway
  api_gateway_stage           = var.MATURITY
  log_destination_arn         = var.log_destination_arn

  deploy_cumulus_distribution                 = var.deploy_cumulus_distribution
  deploy_distribution_s3_credentials_endpoint = var.deploy_distribution_s3_credentials_endpoint

  additional_log_groups_to_elk = var.additional_log_groups_to_elk

  cloudwatch_log_retention_periods = var.cloudwatch_log_retention_periods
  default_log_retention_days       = var.default_log_retention_days

  throttled_queues = [{
    url             = aws_sqs_queue.background_job_queue.id,
    execution_limit = var.throttled_queue_execution_limit
  }]

  ecs_include_docker_cleanup_cronjob = var.ecs_include_docker_cleanup_cronjob
}

resource "aws_security_group" "no_ingress_all_egress" {
  name   = "${local.prefix}-cumulus-tf-no-ingress-all-egress"
  vpc_id = data.aws_vpc.application_vpcs.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
