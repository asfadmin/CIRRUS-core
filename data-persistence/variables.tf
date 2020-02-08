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
