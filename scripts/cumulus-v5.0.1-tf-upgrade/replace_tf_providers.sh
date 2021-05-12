#!/usr/bin/env bash

# must be done for each DEPLOY_NAME - MATURITY combo

cd /CIRRUS-core

make tf-init

function replace_providers() {
    path=${1}
    module=${2}

    # this will download new provider plugins, but ultimately fail; it runs
    # `terraform init -reconfigure` and is therefore a prerequisite to the
    # `terraform state replace-provider` command below
    make "${module}-init"

    cd "${path}/${module}"

    # replace the providers so the next init/plan will succeed; you can add
    # additional hashicorp plugins to the PROVIDER list if you use any that are
    # not listed here
    #
    # if nothing in the module uses the given provider, the replace-provider
    # command will exit without failure and report that there is nothing to
    # replace, so it's ok to `replace-provider` for providers that aren't
    # actually used by the module
    for PROVIDER in aws archive null; do
        echo "CIRRUS: replacing provider 'registry.terraform.io/-/${PROVIDER}'..."
        terraform state replace-provider -auto-approve\
                  registry.terraform.io/-/${PROVIDER} \
                  registry.terraform.io/hashicorp/${PROVIDER}
    done

    cd /CIRRUS-core
}

replace_providers /CIRRUS-DAAC daac
replace_providers /CIRRUS-core data-persistence
replace_providers /CIRRUS-core cumulus
replace_providers /CIRRUS-DAAC workflows

# all plans should work, exit with failure if any do not
set -e
cd /CIRRUS-core
make plan-tf
make plan-daac
make plan-data-persistence
make plan-cumulus
make plan-workflows
