terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "<= 5.22.0"
    }
  }
}

provider "aws" {
  ignore_tags {
    key_prefixes = ["gsfc-ngap"]
  }
}
