variable "DEPLOY_NAME" {
  type = string
}

variable "MATURITY" {
  type = string
  default = "dev"
}

variable "include_elasticsearch" {
  type    = bool
  default = true
}

variable "elasticsearch_config" {
  description = "Configuration object for Elasticsearch"
  type = object({
    domain_name    = string
    instance_count = number
    instance_type  = string
    version        = string
    volume_size    = number
  })
  default = {
    domain_name    = "es"
    instance_count = 1
    instance_type  = "t2.small.elasticsearch"
    version        = "5.3"
    volume_size    = 10
  }
}
