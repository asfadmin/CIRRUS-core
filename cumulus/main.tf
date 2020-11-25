module "cumulus" {
  source                                           = "https://github.com/nasa/cumulus/releases/download/v4.0.0/terraform-aws-cumulus.zip//tf-modules/cumulus"
  cumulus_message_adapter_lambda_layer_version_arn = data.terraform_remote_state.daac.outputs.cma_layer_arn

  prefix = local.prefix

  vpc_id            = data.aws_vpc.application_vpcs.id
  lambda_subnet_ids = data.aws_subnet_ids.subnet_ids.ids

  deploy_to_ngap = true

  ecs_cluster_instance_image_id   = "${var.ecs_cluster_instance_image_id != "" ? var.ecs_cluster_instance_image_id : data.aws_ssm_parameter.ecs_image_id.value}"
  ecs_cluster_instance_subnet_ids = data.aws_subnet_ids.subnet_ids.ids
  ecs_cluster_min_size            = 1
  ecs_cluster_desired_size        = 1
  ecs_cluster_max_size            = 2
  ecs_cluster_instance_type       = var.ecs_cluster_instance_type
  key_name                        = var.key_name

  urs_url             = var.urs_url
  urs_client_id       = var.urs_client_id
  urs_client_password = var.urs_client_password

  ems_host              = var.ems_host
  ems_port              = var.ems_port
  ems_path              = var.ems_path
  ems_datasource        = var.ems_datasource
  ems_private_key       = var.ems_private_key
  ems_provider          = var.ems_provider
  ems_retention_in_days = var.ems_retention_in_days
  ems_submit_report     = var.ems_submit_report
  ems_username          = var.ems_username

  metrics_es_host     = var.metrics_es_host
  metrics_es_username = var.metrics_es_username
  metrics_es_password = var.metrics_es_password

  cmr_client_id   = local.cmr_client_id
  cmr_environment = var.cmr_environment
  cmr_username    = var.cmr_username
  cmr_password    = var.cmr_password
  cmr_provider    = var.cmr_provider

  cmr_oauth_provider = var.cmr_oauth_provider

  launchpad_api         = var.launchpad_api
  launchpad_certificate = var.launchpad_certificate
  launchpad_passphrase  = var.launchpad_passphrase

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

  # Thin Egress App settings
  # must match stack_name variable for thin-egress-app module
  tea_stack_name = local.tea_stack_name
  # must match stage_name variable for thin-egress-app module
  tea_api_gateway_stage = local.tea_stage_name

  tea_rest_api_id               = module.thin_egress_app.rest_api.id
  tea_rest_api_root_resource_id = module.thin_egress_app.rest_api.root_resource_id
  tea_internal_api_endpoint     = module.thin_egress_app.internal_api_endpoint
  tea_external_api_endpoint     = module.thin_egress_app.api_endpoint

  sts_credentials_lambda_function_arn = data.aws_lambda_function.sts_credentials.arn

  archive_api_port            = var.archive_api_port
  private_archive_api_gateway = var.private_archive_api_gateway
  api_gateway_stage           = var.MATURITY
  log_destination_arn         = var.log_destination_arn

  deploy_distribution_s3_credentials_endpoint = var.deploy_distribution_s3_credentials_endpoint

  additional_log_groups_to_elk = var.additional_log_groups_to_elk

  ems_deploy = var.ems_deploy

  tags = local.default_tags
}

data "aws_lambda_function" "sts_credentials" {
  function_name = "gsfc-ngap-sh-s3-sts-get-keys"
}

data "aws_ssm_parameter" "ecs_image_id" {
  name = "image_id_ecs_amz2"
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

  tags = local.default_tags
}
