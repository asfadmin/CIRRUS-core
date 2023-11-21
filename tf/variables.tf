variable "DEPLOY_NAME" {
  type = string
}

variable "MATURITY" {
  type    = string
  default = "dev"
}

variable "CIRRUS_CORE_BRANCH" {
  type    = string
}

variable "CIRRUS_DAAC_BRANCH" {
  type    = string
}

variable "CIRRUS_CORE_TAG" {
  type    = string
}

variable "CIRRUS_DAAC_TAG" {
  type    = string
}
