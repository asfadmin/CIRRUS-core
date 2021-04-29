#!/usr/bin/env bash

# These commands are necessary to replace the providers, the plan-*** must be
# run first to download new provider plugins, but it will fail.  Then the
# replace-provider commands can be run.  Finally re-run the plan and it will
# succeed

# must be done for each DEPLOY_NAME - MATURITY combo

cd /CIRRUS-core

make plan-tf

make plan-daac

cd /CIRRUS-DAAC/daac

terraform state replace-provider -auto-approve registry.terraform.io/-/aws registry.terraform.io/hashicorp/aws
terraform state replace-provider -auto-approve registry.terraform.io/-/archive registry.terraform.io/hashicorp/archive
terraform state replace-provider -auto-approve registry.terraform.io/-/null registry.terraform.io/hashicorp/null

cd /CIRRUS-core

make plan-daac

make plan-data-persistence

cd /CIRRUS-core/data-persistence

terraform state replace-provider -auto-approve registry.terraform.io/-/aws registry.terraform.io/hashicorp/aws

cd /CIRRUS-core

make plan-data-persistence

make plan-cumulus

cd /CIRRUS-core/cumulus

terraform state replace-provider -auto-approve registry.terraform.io/-/aws registry.terraform.io/hashicorp/aws

cd /CIRRUS-core

make plan-cumulus

make plan-workflows

cd /CIRRUS-DAAC/workflows

terraform state replace-provider -auto-approve registry.terraform.io/-/aws registry.terraform.io/hashicorp/aws

cd /CIRRUS-core

make plan-workflows
