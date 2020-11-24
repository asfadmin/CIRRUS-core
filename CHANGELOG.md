# CHANGELOG
## v4.0.0.0

* Upgrade to Cumulus [V4.0.0](https://github.com/nasa/Cumulus/releases/tag/v4.0.0)
* change `cumulus_message_adapter_lambda_layer_arn` -> `cumulus_message_adapter_lambda_layer_arn` under the `cumulus` module in `cumulus/main.ft`
* change `thin_egress_app` module's source to  `thin-egress-app/tea-terraform-build.100.zip` in `cumulus/thin_egress_app`

## v3.0.1.0

* Upgrade to Cumulus [V3.0.1](https://github.com/nasa/Cumulus/releases/tag/v3.0.1)

## v3.0.0.0

* Upgrade to Cumulus [V3.0.0](https://github.com/nasa/Cumulus/releases/tag/v3.0.0)
* NOTE: Make sure to follow the upgrade instructions to prevent the
  deletion and recreation of your TEA API Gateway.
* change `Makefile` to add new `plan-*` targets for each step to allow running of
  `terraform plan` for each step (ex. `make plan-cumulus`)
* change `cumulus/main.tf` changes to support separation of TEA from Cumulus
* change `cumulus/outputs.tf` update the TEA outputs needed by workflows
* change `cumulus/variables.tf` add new variables and formatting
* change `data-persistence/main.tf` update for cumulus 3.0.0

* add `cumulus/common.tf` items which are needed by both cumulus and tea
* add `cumulus/thin_egress.tf` TEA tf module definition
* add `cumulus/thin-egress-app/bucket_map.yaml.tmpl` the default TEA bucket map template
* add `scripts/cumulus-v3.0.0/move-tea-tf-state.sh` contains the commands mentioned
in the TEA migration instructions (https://nasa.github.io/cumulus/docs/upgrade-notes/migrate_tea_standalone)

### Notes about v3.0.0 migration as relates to CIRRUS

* The `make daac` step of this version of CIRRUS generates a new output (`bucket_map_key`).  Look at the corresponding
[CIRRUS-DAAC](https://github.com/asfadmin/CIRRUS-DAAC/blob/master/daac/outputs.tf) to add that value to your `daac/outputs.tf` file and then run `make daac`
* Where the TEA migration instructions mention `terraform plan` use the new `make plan-cumulus` target get the output mentioned
* Run `make daac` and `make data-persistence` prior to `make plan-cumulus`
* Normally you run all CIRRUS `make` commands from the root `CIRRUS-core` directory.  All the `terraform state mv *` commands
require being in the `CIRRUS-core/cumulus` directory.  A script has been added to `scripts/cumulus-v3.0.0` with all the commands
in one file.  You may wish to run them from the script, or you may want to run them one at a time.  Make sure you have a
backup of your state per the Cumulus instructions.

## v2.0.7.0

* Upgrade to Cumulus [V2.0.7](https://github.com/nasa/Cumulus/releases/tag/v2.0.7)

## v2.0.6.0

* Upgrade to Cumulus [V2.0.6](https://github.com/nasa/Cumulus/releases/tag/v2.0.6)

## v2.0.4.0

* Upgrade to Cumulus [V2.0.4](https://github.com/nasa/Cumulus/releases/tag/v2.0.4) to upgrade TEA to build 88

## v2.0.3.0

* Upgrade to Cumulus [V2.0.3](https://github.com/nasa/Cumulus/releases/tag/v2.0.3) to fix syncgranule checksum and dashboard stats issues

## v2.0.2.0

* Upgrade to Cumulus [V2.0.2](https://github.com/nasa/Cumulus/releases/tag/v2.0.2) to fix delete granule bug
* add optional bucket_map_key variable to allow override of default TEA bucket_map
* output cmr environment and hyrax-metadata-update task for use in workflows

## v2.0.1.0

### CHANGES

* Upgrade to Cumulus v2.0.1.
* review Cumulus deployment instructions for version [2.0.0](https://github.com/nasa/Cumulus/releases/tag/v2.0.0)
there is a manual step. [2.0.1](https://github.com/nasa/Cumulus/releases/tag/v2.0.1) only contains a bug fix
* Expose EC2 instance type for the default Cumulus ECS cluster.  Still deafaults to `t3.medium`.
  Can be changed via any of the cumulus .tfvars files in CIRRUS-DAAC

## v1.24.0.0

### CHANGES

* Upgrade to Cumulus v1.24.0.
* review Cumulus
  [deployment instructions](https://github.com/nasa/Cumulus/releases/tag/v1.24.0)
* added two extra cumulus outputs which are needed for ECS based tasks

## v1.23.2.0

### CHANGES

* Upgrade to Cumulus v1.23.2.
* review Cumulus
  [deployment instructions](https://github.com/nasa/Cumulus/releases/tag/v1.23.2)

## v1.22.1.0

### CHANGES

* Upgrade to Cumulus v1.22.1.
* review Cumulus
  [deployment instructions](https://github.com/nasa/Cumulus/releases/tag/v1.21.0)

## v1.21.0.0

### CHANGES

* Upgrade to Cumulus v1.21.0.
* review Cumulus
  [deployment instructions](https://github.com/nasa/Cumulus/releases/tag/v1.21.0)

## v1.20.0.0

### CHANGES

* Upgrade to Cumulus v1.20.0.  There are several breaking changes in this
  release.
* `cumulus/main.tf` added `deploy_to_ngap = true` per Cumulus
  [deployment instructions](https://github.com/nasa/Cumulus/releases/tag/v1.20.0)

## v1.19.0.0

### CHANGES

* Upgrade to Cumulus v1.19.0.  There are several breaking changes in this
  release.  Make sure to follow the
  [deployment instructions](https://github.com/nasa/Cumulus/releases/tag/v1.19.0).
* `setup_jwt_cookie.sh` script added to create and deploy a TEA secret with the
  name of `${DEPLOY_NAME}-cumulus-${MATURITY}-jwt_secret_for_tea`
* `cumulus/main.tf` updated to make use of secret created by
  `setup_jwt_cookie.sh`
* `cumuluse/outputs.tf` updated to output `sf_sqs_report_task` rather than
  `sf_sns_report_task`

## v1.18.0.1

### CHANGES

* Remove the deprecated TF state resources that are no longer needed.

## v1.18.0.0

### CHANGES

* Upgrade to Cumulus v1.18.0. There should be no breaking changes from
  CIRRUS v1.17.0.0.

## v1.17.0.0

### Upgrade Notes:

1. CIRRUS' Makefile will now delegate to the DAAC repo for the
   following make targets:

   * migrate-tf-state: NEW--see note below
   * daac
   * workflows

  Add these three targets to your DAAC Makefile. See the CIRRUS-DAAC
  repo for examples of each of these three targets.

2. If you're currently using a previous version of CIRRUS, you'll
need to migrate the Terraform state from the old backend AWS resources
to new ones. You can do this by running this for _*each*_ deployment /
maturity combination that you've deployed:

        $ source env.sh ...        # See README
        $ make migrate-tf-state

You'll be prompted to migrate state from the old resources to the
new. Simply respond with 'yes' to each of the four prompts and you'll
be ready to go.

3. For local development, CIRRUS no longer looks for secrets in the
   CIRRUS-core repo's `.secrets` directory. Instead, it relies on the
   secrets being configured as described in the CIRRUS-DAAC
   repo. Remove any local `.secrets` files and directory and see the
   CIRRUS-DAAC README for instructions on how to setup local
   development secrets.

### CHANGES

* First official full release of CIRRUS
* Uses Cumulus v1.17.0
* Fix TF state resource names and add a Makefile target to migrate
  state from the old resources to the new one.
* Get the bucket config from the DAAC module (which needs to create
  it) and pass it to Cumulus.
* Set and export the AWS_PROFILE envvar in the `env.sh` script.
* Fix a stringification bug in the Jenkinsfile.
* Fix the extra 'retry' command if deploying Cumulus fails randomly
  the first time.
* Pass the ECS cluster instance AMI id to Cumulus.
* The Makefile now defers to the DAAC repo to run the `daac` and
  `workflows` targets. It does this by `cd`ing into the DAAC repo
  directory and simply executing `make daac` and `make
  workflows`. This means that the DAAC repo should have a Makefile
  with those two targets defined.
* Use the MATURITY as the value for Cumulus' `api_gateway_stage` and
  `distribution_api_gateway_stage`. This means the API gateway stage
  in each NGAP account corresponds with the MATURITY.
* Fix various Jenkinsfile parameter declarations, defaults, and
  descriptions.

## v0.1.2

* Include an example secrets TF variable file.
* Add output variables for all Cumulus tasks (lambdas) so they can be
  used in downstream TF modules.
* Add output variables for Cumulus' `lambda_processing_role_arn` and
  `no_ingress_all_egress` AWS security group.
* Turn off TF color output.
* The default Makefile target is now `all`. So running `make` and
  `make all` are equivalent.

## v0.1.1

* Lookup the correct NGAP VPC using the Name property.

## v0.1.0

* Initial CIRRUS release
