module "thin_egress_app" {
  source = "s3::https://s3.amazonaws.com/asf.public.code/thin-egress-app/tea-terraform-build.1.3.3.zip"

  auth_base_url                      = var.urs_url
  bucket_map_file                    = local.bucket_map_key == null ? aws_s3_bucket_object.bucket_map_yaml.id : local.bucket_map_key
  bucketname_prefix                  = ""
  config_bucket                      = local.system_bucket
  cookie_domain                      = var.thin_egress_cookie_domain
  domain_cert_arn                    = var.thin_egress_domain_cert_arn
  domain_name                        = var.distribution_url == null ? null : replace(replace(var.distribution_url, "/^https?:///", ""), "//$/", "")
  download_role_in_region_arn        = var.thin_egress_download_role_in_region_arn
  jwt_algo                           = var.thin_egress_jwt_algo
  jwt_secret_name                    = local.thin_egress_jwt_secret_name
  lambda_code_dependency_archive_key = var.thin_egress_lambda_code_dependency_archive_key
  log_api_gateway_to_cloudwatch      = var.log_api_gateway_to_cloudwatch
  permissions_boundary_name          = "NGAPShRoleBoundary"
  private_vpc                        = data.aws_vpc.application_vpcs.id
  s3credentials_endpoint             = var.s3credentials_endpoint
  stack_name                         = local.tea_stack_name
  stage_name                         = local.tea_stage_name
  urs_auth_creds_secret_name         = aws_secretsmanager_secret.thin_egress_urs_creds.name
  use_cors                           = var.use_cors
  vpc_subnet_ids                     = data.aws_subnet_ids.subnet_ids.ids
  tags                               = local.default_tags
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
  key    = "${local.prefix}/thin-egress-app/${local.prefix}-bucket_map.yaml"
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

resource "aws_cloudwatch_log_subscription_filter" "egress_api_gateway_log_subscription_filter" {
  count           = (var.log_api_gateway_to_cloudwatch && var.log_destination_arn != null) ? 1 : 0
  name            = "${local.prefix}-EgressApiGatewayCloudWatchLogSubscriptionToSharedDestination"
  distribution    = "ByLogStream"
  destination_arn = var.log_destination_arn
  filter_pattern  = ""
  log_group_name  = module.thin_egress_app.egress_log_group
}

# Egress Lambda Log Group
resource "aws_cloudwatch_log_group" "egress_lambda_log_group" {
  count             = (var.log_destination_arn != null) ? 1 : 0
  name              = "/aws/lambda/${module.thin_egress_app.egress_lambda_name}"
  retention_in_days = var.egress_lambda_log_retention_days
  tags              = local.default_tags
}

# Egress Lambda Log Group Filter
resource "aws_cloudwatch_log_subscription_filter" "egress_lambda_log_subscription_filter" {
  count           = (var.log_destination_arn != null) ? 1 : 0
  depends_on      = [aws_cloudwatch_log_group.egress_lambda_log_group]
  name            = "${local.prefix}-EgressLambdaLogSubscriptionToSharedDestination"
  destination_arn = var.log_destination_arn
  distribution    = "ByLogStream"
  filter_pattern  = ""
  log_group_name  = aws_cloudwatch_log_group.egress_lambda_log_group[0].name
}
