# This makefile assumes you have the following environment variables set:
#
#  AWS_ACCESS_KEY_ID:     Set for the account to which you are deploying
#  AWS_SECRET_ACCESS_KEY: Set for the account to which you are deploying
#  AWS_REGION:            The region to which you are deploying
#  DEPLOY_NAME:           A unique name to distinguish this Cumulus instance from others
#  MATURITY:              One of: DEV, INT, TEST, PROD
#
#  DAAC_REPO:             The git repository URL with DAAC-specific Cumulus customization
#  DAAC_REF:              The DAAC_REPO git branch or tag name to checkout and deploy

export TF_IN_AUTOMATION="true"
export TF_VAR_MATURITY=${MATURITY}
export TF_VAR_DEPLOY_NAME=${DEPLOY_NAME}

SELF_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: clean \
	tf daac data-persistence cumulus destroy-cumulus all \
	workflows

clean:
	echo "Not implemented!"

checkout-daac:
	git clone ${DAAC_REPO} daac
	cd daac && git fetch && git checkout ${DAAC_REF} && git pull

.ONESHELL:
tf:
	cd tf
	terraform init -reconfigure -input=false
	terraform workspace new ${MATURITY} || terraform workspace select ${MATURITY}
	terraform import -input=false aws_s3_bucket.tf-state-bucket cumulus-${MATURITY}-tf-state || true
	terraform import -input=false aws_dynamodb_table.tf-locks-table cumulus-${MATURITY}-tf-locks || true
	terraform refresh -input=false -state=terraform.tfstate.d/${MATURITY}/terraform.tfstate
	terraform apply -input=false -auto-approve

.ONESHELL:
daac:
	cd daac/daac
	rm -f .terraform/environment
	terraform init -reconfigure -input=false \
		-backend-config "region=${AWS_REGION}" \
		-backend-config "bucket=cumulus-${MATURITY}-tf-state" \
		-backend-config "key=daac/terraform.tfstate" \
		-backend-config "dynamodb_table=cumulus-${MATURITY}-tf-locks"
	terraform workspace new ${DEPLOY_NAME} || terraform workspace select ${DEPLOY_NAME}
	if [ -f "variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	if [ -f "secrets/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export SECRETS_OPT="-var-file=secrets/${MATURITY}.tfvars"
		echo "Found maturity-specific secrets: $$SECRETS_OPT"
		echo "***************************************************************"
	fi
	terraform apply \
		$$VARIABLES_OPT \
		$$SECRETS_OPT \
		-input=false \
		-auto-approve

data-persistence:
	cd $@
	rm -f .terraform/environment
	terraform init -reconfigure -input=false \
		-backend-config "region=${AWS_REGION}" \
		-backend-config "bucket=cumulus-${MATURITY}-tf-state" \
		-backend-config "key=$@/terraform.tfstate" \
		-backend-config "dynamodb_table=cumulus-${MATURITY}-tf-locks"
	terraform workspace new ${DEPLOY_NAME} || terraform workspace select ${DEPLOY_NAME}
	if [ -f "../daac/data-persistence/variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=../daac/data-persistence/variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	if [ -f "../daac/data-persistence/secrets/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export SECRETS_OPT="-var-file=../daac/data-persistence/secrets/${MATURITY}.tfvars"
		echo "Found maturity-specific secrets: $$SECRETS_OPT"
		echo "***************************************************************"
	fi
	terraform apply \
		-var-file=../daac/data-persistence/terraform.tfvars \
		$$VARIABLES_OPT \
		$$SECRETS_OPT \
		-input=false \
		-auto-approve

cumulus:
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
	if [ -f "../daac/cumulus/variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=../daac/cumulus/variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	if [ -f "../daac/cumulus/secrets/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export SECRETS_OPT="-var-file=../daac/cumulus/secrets/${MATURITY}.tfvars"
		echo "Found maturity-specific secrets: $$SECRETS_OPT"
		echo "***************************************************************"
	fi
	terraform apply \
		-var-file=../daac/cumulus/terraform.tfvars \
		$$VARIABLES_OPT \
		$$SECRETS_OPT \
		-input=false \
		-auto-approve
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
	daac \
	data-persistence \
	cumulus


# ------ Workflows ------

.ONESHELL:
workflows:
	cd daac/workflows
	rm -f .terraform/environment
	terraform init -reconfigure -input=false \
		-backend-config "region=${AWS_REGION}" \
		-backend-config "bucket=cumulus-${MATURITY}-tf-state" \
		-backend-config "key=workflows/terraform.tfstate" \
		-backend-config "dynamodb_table=cumulus-${MATURITY}-tf-locks"
	terraform workspace new ${DEPLOY_NAME} || terraform workspace select ${DEPLOY_NAME}
	terraform apply -input=false -auto-approve
