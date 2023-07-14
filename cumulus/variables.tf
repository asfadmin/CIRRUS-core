# Required
variable "DEPLOY_NAME" {
  type = string
}

variable "MATURITY" {
  type    = string
  default = "dev"
}

variable "cmr_environment" {
  type = string
}

variable "cmr_password" {
  type = string
}

variable "cmr_provider" {
  type = string
}

variable "cmr_username" {
  type = string
}

variable "cmr_oauth_provider" {
  type    = string
  default = "earthdata"
}

variable "launchpad_api" {
  type    = string
  default = "launchpadApi"
}

variable "launchpad_certificate" {
  type    = string
  default = "launchpad.pfx"
}

variable "launchpad_passphrase" {
  type    = string
  default = ""
}

variable "lzards_launchpad_certificate" {
  description = "Name of the Launchpad certificate uploaded to the 'crypto' directory of the `system_bucket` for use with the lzards-backup task`."
  type        = string
  default     = "lzards_launchpad.pfx"
}

variable "lzards_launchpad_passphrase" {
  description = "Passphrase for use with lzards_launchpad_certificate."
  type        = string
  default     = ""
}

variable "lzards_provider" {
  description = "LZARDS provider name"
  type        = string
  default     = ""
}

variable "lzards_api" {
  description = "LZARDS backup API endpoint"
  type        = string
  default     = ""
}

variable "lzards_s3_link_timeout" {
  description = "LZARDS S3 access link timeout (seconds)"
  type        = string
  default     = ""
}

variable "oauth_provider" {
  type    = string
  default = "earthdata"
}

variable "oauth_user_group" {
  type    = string
  default = "N/A"
}

variable "s3_replicator_config" {
  type        = object({ source_bucket = string, source_prefix = string, target_bucket = string, target_prefix = string })
  default     = null
  description = "Configuration for the s3-replicator module. Items with prefix of source_prefix in the source_bucket will be replicated to the target_bucket with target_prefix."
}

variable "saml_entity_id" {
  type    = string
  default = "N/A"
}

variable "saml_assertion_consumer_service" {
  type    = string
  default = "N/A"
}

variable "saml_idp_login" {
  type    = string
  default = "N/A"
}

variable "saml_launchpad_metadata_url" {
  type    = string
  default = "N/A"
}

variable "token_secret" {
  type = string
}

variable "urs_client_id" {
  type = string
}

variable "urs_client_password" {
  type = string
}

# Optional

variable "api_gateway_stage" {
  type        = string
  default     = "dev"
  description = "The archive API Gateway stage to create"
}

variable "distribution_url" {
  type    = string
  default = null
}


variable "ems_datasource" {
  type        = string
  description = "the data source of EMS reports"
  default     = "UAT"
}

variable "ems_host" {
  type        = string
  description = "EMS host"
  default     = "change-ems-host"
}

variable "ems_path" {
  type        = string
  description = "EMS host directory path for reports"
  default     = "/"
}

variable "ems_port" {
  type        = number
  description = "EMS host port"
  default     = 22
}

variable "ems_private_key" {
  type        = string
  description = "the private key file used for sending reports to EMS"
  default     = "ems-private.pem"
}

variable "ems_provider" {
  type        = string
  description = "the provider used for sending reports to EMS"
  default     = null
}

variable "ems_retention_in_days" {
  type        = number
  description = "the retention in days for reports and s3 server access logs"
  default     = 30
}

variable "ems_submit_report" {
  type        = bool
  description = "toggle whether the reports will be sent to EMS"
  default     = false
}

variable "ems_username" {
  type        = string
  description = "the username used for sending reports to EMS"
  default     = null

}

variable "key_name" {
  type    = string
  default = null
}

variable "permissions_boundary_arn" {
  type    = string
  default = null
}

variable "aws_profile" {
  type    = string
  default = null
}

variable "ems_deploy" {
  description = "If true, deploys the EMS reporting module"
  type        = bool
  default     = false
}

variable "log_api_gateway_to_cloudwatch" {
  type        = bool
  default     = false
  description = "Enable logging of API Gateway activity to CloudWatch."
}

variable "log_destination_arn" {
  type        = string
  default     = null
  description = "Remote kinesis/destination arn for delivering logs. Requires log_api_gateway_to_cloudwatch set to true."
}

variable "archive_api_port" {
  type    = number
  default = null
}

variable "archive_api_url" {
  type    = string
  default = null
}

variable "private_archive_api_gateway" {
  type    = bool
  default = true
}

variable "metrics_es_host" {
  type    = string
  default = null
}

variable "metrics_es_password" {
  type    = string
  default = null
}

variable "metrics_es_username" {
  type    = string
  default = null
}

variable "metrics_es_aws_account_id" {
  type    = string
  default = null
}

variable "api_users" {
  type    = list(string)
  default = []
}

variable "urs_url" {
  description = "The URL of the Earthdata login (URS) site"
  type        = string
  default     = "https://uat.urs.earthdata.nasa.gov/"
}

variable "deploy_distribution_s3_credentials_endpoint" {
  description = "Whether or not to include the S3 credentials endpoint in the Thin Egress App"
  type        = bool
  default     = true
}

variable "es_index_shards" {
  description = "The number of shards for the Elasticsearch index"
  type        = number
  default     = 2
}

variable "es_request_concurrency" {
  type        = number
  default     = 10
  description = "Maximum number of concurrent requests to send to Elasticsearch. Used in index-from-database operation"
}

variable "ecs_cluster_instance_image_id" {
  type        = string
  description = "AMI ID of ECS instances"
  default     = ""
}

variable "ecs_cluster_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ecs_cluster_desired_size" {
  description = "The desired maximum number of instances for your ECS autoscaling group"
  type        = number
  default     = 1
}
variable "ecs_cluster_max_size" {
  description = "The maximum number of instances for your ECS cluster"
  type        = number
  default     = 2
}

variable "ecs_cluster_min_size" {
  description = "The minimum number of instances for your ECS cluster"
  type        = number
  default     = 1
}

variable "ecs_cluster_instance_docker_volume_size" {
  type        = number
  description = "Size (in GB) of the volume that Docker uses for image and metadata storage"
  default     = 50
}

variable "bucket_map" {
  type    = map(object({ name = string, type = string }))
  default = {}
}

variable "bucket_map_key" {
  description = "Optional S3 Key for TEA bucket map object to override default Cumulus configuration"
  type        = string
  default     = null
}

variable "additional_log_groups_to_elk" {
  type    = map(string)
  default = {}
}

variable "thin_egress_cookie_domain" {
  type        = string
  default     = null
  description = "Valid domain for cookie"
}

variable "thin_egress_domain_cert_arn" {
  type        = string
  default     = null
  description = "Certificate Manager SSL Cert ARN if deployed outside NGAP/CloudFront"
}

variable "thin_egress_download_role_in_region_arn" {
  type        = string
  default     = null
  description = "ARN for reading of data buckets for in-region requests"
}

variable "thin_egress_jwt_algo" {
  type        = string
  default     = null
  description = "Algorithm with which to encode the JWT cookie"
}

variable "thin_egress_lambda_code_dependency_archive_key" {
  type        = string
  default     = null
  description = "S3 Key of packaged python modules for lambda dependency layer."
}

variable "egress_lambda_log_retention_days" {
  type        = number
  default     = 30
  description = "Number of days to retain TEA logs"
}

variable "cmr_acl_based_credentials" {
  type        = bool
  default     = false
  description = "Option to enable/disable user based CMR ACLs to derive permission for s3 credential access tokens"
}

variable "thottled_queue_execution_limit" {
  type        = number
  description = "Cumulus Throttled Queue execution limit"
  default     = 5
}

variable "lambda_memory_sizes" {
  description = "Memory sizes for lambda functions"
  type        = map(string)
  default     = {}
}

variable "lambda_timeouts" {
  description = "Configurable map of timeouts for ingest task lambdas in the form <lambda_identifier>_timeout: <timeout>"
  type        = map(string)
  default     = {}
}

variable "use_cors" {
  type        = bool
  default     = false
  description = "Enable cross origin resource sharing"
}

variable "cloudwatch_log_retention_periods" {
  type        = map(number)
  description = "number of days logs will be retained for the respective cloudwatch log group, in the form of <module>_<cloudwatch_log_group_name>_log_retention"
  default     = {}
}

variable "default_log_retention_days" {
  type        = number
  default     = 30
  description = "Optional default value that user chooses for their log retention periods"
}

variable "s3credentials_endpoint" {
  type        = bool
  default     = false
  description = "Switch that will enable TEA deployment of the /s3credentials endpoint for s3 direct access."
}
