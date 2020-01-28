# This makefile assumes you have the following environment variables set:
#
#  AWS_ACCESS_KEY_ID:     Set for the account to which you are deploying
#  AWS_SECRET_ACCESS_KEY: Set for the account to which you are deploying
#  AWS_REGION:            The region to which you are deploying
#  DEPLOY_NAME:           Either your userid for devs, or 'asf' for standard deployments
#  MATURITY:              One of: DEV, INT, TEST, PROD
#

export TF_IN_AUTOMATION="true"
export TF_VAR_MATURITY=${MATURITY}
export TF_VAR_DEPLOY_NAME=${DEPLOY_NAME}
export TF_VAR_AWS_REGION=${AWS_REGION}

# TODO: Move this to a config file--so the version of the CMA is a config parameter
cma="https://github.com/nasa/cumulus-message-adapter/releases/download/v1.1.3/cumulus-message-adapter.zip"

SELF_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: clean tf asf data-persistence cumulus destroy-cumulus all

clean:
	rm -rf tmp

.ONESHELL:
tf:
	cd tf
	terraform init -reconfigure -input=false
	terraform workspace new ${MATURITY} || terraform workspace select ${MATURITY}
	terraform import -input=false aws_s3_bucket.tf-state-bucket cumulus-${MATURITY}-tf-state || true
	terraform import -input=false aws_dynamodb_table.tf-locks-table cumulus-${MATURITY}-tf-locks || true
	terraform refresh -input=false -state=terraform.tfstate.d/${MATURITY}/terraform.tfstate
	terraform apply -input=false -auto-approve

tmp/cumulus-message-adapter.zip:
	mkdir -p tmp
	wget $(cma) -O tmp/cumulus-message-adapter.zip

.ONESHELL:
asf data-persistence cumulus: tmp/cumulus-message-adapter.zip
	cd $@
	rm -f .terraform/environment
	terraform init -reconfigure -input=false \
		-backend-config "region=${AWS_REGION}" \
		-backend-config "bucket=cumulus-${MATURITY}-tf-state" \
		-backend-config "key=$@/terraform.tfstate" \
		-backend-config "dynamodb_table=cumulus-${MATURITY}-tf-locks"
	terraform workspace new ${DEPLOY_NAME} || terraform workspace select ${DEPLOY_NAME}
	cp $(SELF_DIR)/patch/fetch_or_create_rsa_keys.sh \
		$(SELF_DIR)/cumulus/.terraform/modules/cumulus/tf-modules/archive/
	terraform apply -input=false -auto-approve
	if [ $$? -ne 0 ] # Workaround random Cumulus deploy fails
	then
		terraform apply -input=false -auto-approve
	fi

.ONESHELL:
destroy-cumulus:
	cd cumulus
	terraform init \
		-backend-config "region=${AWS_REGION}" \
		-backend-config "bucket=cumulus-${MATURITY}-tf-state" \
		-backend-config "key=cumulus/terraform.tfstate" \
		-backend-config "dynamodb_table=cumulus-${MATURITY}-tf-locks"
	terraform workspace new ${DEPLOY_NAME} || terraform workspace select ${DEPLOY_NAME}
	terraform destroy -input=false #-auto-approve

all: \
	tf \
	asf \
	data-persistence \
	cumulus
