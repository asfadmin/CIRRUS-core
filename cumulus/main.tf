module "cumulus" {
  source                                   = "https://github.com/nasa/cumulus/releases/download/v3.0.0/terraform-aws-cumulus.zip//tf-modules/cumulus"
  cumulus_message_adapter_lambda_layer_arn = data.terraform_remote_state.daac.outputs.cma_layer_arn

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

  permissions_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/NGAPShRoleBoundary"

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
  tea_api_egress_log_group      = module.thin_egress_app.egress_log_group

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

locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"

  buckets = data.terraform_remote_state.daac.outputs.bucket_map

  bucket_map_key = data.terraform_remote_state.daac.outputs.bucket_map_key == "" ? null : data.terraform_remote_state.daac.outputs.bucket_map_key

  protected_bucket_names = [for k, v in local.buckets : v.name if v.type == "protected"]
  public_bucket_names    = [for k, v in local.buckets : v.name if v.type == "public"]

  tea_stack_name              = "${local.prefix}-thin-egress-app"
  tea_stage_name              = var.MATURITY
  thin_egress_jwt_secret_name = "${local.prefix}-jwt_secret_for_tea"

  daac_remote_state_config = {
    bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "daac/terraform.tfstate"
    region = "${data.aws_region.current.name}"
  }

  data_persistence_remote_state_config = {
    bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "data-persistence/terraform.tfstate"
    region = "${data.aws_region.current.name}"
  }

  system_bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-internal"

  cmr_client_id = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"

  default_tags = {
    Deployment = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  }
}

resource "aws_secretsmanager_secret" "thin_egress_urs_creds" {
  name_prefix = "${local.prefix}-tea-urs-creds-"
  description = "URS credentials for the ${local.prefix} Thin Egress App"
  tags        = local.default_tags
}

resource "aws_secretsmanager_secret_version" "thin_egress_urs_creds" {
  secret_id = aws_secretsmanager_secret.thin_egress_urs_creds.id
  secret_string = jsonencode({
    UrsId   = var.urs_client_id
    UrsAuth = base64encode("${var.urs_client_id}:${var.urs_client_password}")
  })
}

resource "aws_s3_bucket_object" "bucket_map_yaml" {
  bucket = local.system_bucket
  key    = "${local.prefix}/thin-egress-app/bucket_map.yaml"
  content = templatefile("./thin-egress-app/bucket_map.yaml.tmpl", {
    protected_buckets = local.protected_bucket_names,
    public_buckets    = local.public_bucket_names
  })
  etag = md5(templatefile("./thin-egress-app/bucket_map.yaml.tmpl", {
    protected_buckets = local.protected_bucket_names,
    public_buckets    = local.public_bucket_names
  }))
  tags = local.default_tags
}

module "thin_egress_app" {
  source = "s3::https://s3.amazonaws.com/asf.public.code/thin-egress-app/tea-terraform-build.88.zip"

  auth_base_url              = var.urs_url
  bucket_map_file            = local.bucket_map_key == null ? aws_s3_bucket_object.bucket_map_yaml.id : local.bucket_map_key
  bucketname_prefix          = ""
  config_bucket              = local.system_bucket
  domain_name                = var.distribution_url == null ? null : replace(replace(var.distribution_url, "/^https?:///", ""), "//$/", "")
  jwt_secret_name            = local.thin_egress_jwt_secret_name
  permissions_boundary_name  = var.permissions_boundary_arn == null ? null : reverse(split("/", var.permissions_boundary_arn))[0]
  private_vpc                = data.aws_vpc.application_vpcs.id
  stack_name                 = local.tea_stack_name
  stage_name                 = local.tea_stage_name
  urs_auth_creds_secret_name = aws_secretsmanager_secret.thin_egress_urs_creds.name
  vpc_subnet_ids             = data.aws_subnet_ids.subnet_ids.ids
}

terraform {
  required_providers {
    aws  = ">= 2.31.0"
    null = "~> 2.1"
  }
  backend "s3" {
  }
}

provider "aws" {
  ignore_tags {
    key_prefixes = ["gsfc-ngap"]
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "application_vpcs" {
  tags = {
    Name = "Application VPC"
  }
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpc.application_vpcs.id

  tags = {
    Name = "Private application ${data.aws_region.current.name}a subnet"
  }
}

data "terraform_remote_state" "daac" {
  backend   = "s3"
  workspace = "${var.DEPLOY_NAME}"
  config    = local.daac_remote_state_config
}

data "terraform_remote_state" "data_persistence" {
  backend   = "s3"
  workspace = "${var.DEPLOY_NAME}"
  config    = local.data_persistence_remote_state_config
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
