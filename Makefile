# This makefile assumes you have the following environment variables set:
#
#  AWS_ACCESS_KEY_ID:     Set for the account to which you are deploying
#  AWS_SECRET_ACCESS_KEY: Set for the account to which you are deploying
#  AWS_REGION:            The region to which you are deploying
#  AWS_ACCOUNT_ID:	  The AWS account ID to which you are deploying
#  AWS_ACCOUNT_ID_LAST4:  The Last 4 digits of AWS_ACCOUNT_ID
#
#  DAAC_REPO:             The git repository URL with DAAC-specific Cumulus customization
#  DAAC_REF:              The DAAC_REPO git branch or tag name to checkout and deploy
#
#  DEPLOY_NAME:           A unique name to distinguish this Cumulus instance from others
#  MATURITY:              One of: DEV, INT, TEST, PROD

# ---------------------------
export TF_IN_AUTOMATION="true"
export TF_VAR_MATURITY=${MATURITY}
export TF_VAR_DEPLOY_NAME=${DEPLOY_NAME}

# ---------------------------
SELF_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
.ONESHELL:
.DEFAULT_GOAL := all
.PHONY: clean \
	checkout-daac \
	validate \
	migrate-tf-state migrate-daac-tf-state \
	tf daac data-persistence cumulus workflows all \
	destroy-cumulus

# ---------------------------
clean:
	rm -rf ${SELF_DIR}/daac-repo

# ---------------------------
link-daac:
	ln -s ${DAAC_REPO} ${SELF_DIR}/daac-repo

checkout-daac:
	git clone ${DAAC_REPO} ${SELF_DIR}/daac-repo
	cd ${SELF_DIR}/daac-repo
	git fetch
	git checkout ${DAAC_REF}
	git pull
	cd ${SELF_DIR}

# ---------------------------
tf-init:
	cd tf
	terraform init -reconfigure -input=false -no-color
	terraform workspace new ${MATURITY} || terraform workspace select ${MATURITY}

%-init:
	cd $*
	rm -f .terraform/environment
	terraform init -reconfigure -input=false -no-color \
		-backend-config "region=${AWS_REGION}" \
		-backend-config "bucket=${DEPLOY_NAME}-cumulus-${MATURITY}-tf-state-${AWS_ACCOUNT_ID_LAST4}" \
		-backend-config "key=$*/terraform.tfstate" \
		-backend-config "dynamodb_table=${DEPLOY_NAME}-cumulus-${MATURITY}-tf-locks"
	terraform workspace new ${DEPLOY_NAME} || terraform workspace select ${DEPLOY_NAME}

init-modules-list = tf data-persistence cumulus
init-modules := $(init-modules-list:%-init=%)

# ---------------------------
%-migrate-tf-state:
	echo "---------------------------"
	echo "Migrating state: " $*
	echo "---------------------------"
	cd $*
	rm -f .terraform/environment
	terraform init -no-color \
		-backend-config "region=${AWS_REGION}" \
		-backend-config "bucket=${DEPLOY_NAME}-cumulus-${MATURITY}-tf-state-${AWS_ACCOUNT_ID_LAST4}" \
		-backend-config "key=$*/terraform.tfstate" \
		-backend-config "dynamodb_table=${DEPLOY_NAME}-cumulus-${MATURITY}-tf-locks"

migrate-modules-list = data-persistence cumulus
migrate-modules := $(migrate-modules-list:%-migrate-tf-state=%)

migrate-daac-tf-state:
	cd ${SELF_DIR}/daac-repo
	make migrate-tf-state

migrate-tf-state: \
	migrate-daac-tf-state \
	data-persistence-migrate-tf-state \
	cumulus-migrate-tf-state

# ---------------------------
validate: $(init-modules)
	for module in modules; do \
		cd $$module && terraform validate; \
	done

# ---------------------------
tf: tf-init
	cd tf
	terraform import -input=false aws_s3_bucket.tf-state-bucket cumulus-${MATURITY}-tf-state || true
	terraform import -input=false aws_dynamodb_table.tf-locks-table cumulus-${MATURITY}-tf-locks || true
	terraform import -input=false aws_s3_bucket.backend-tf-state-bucket ${DEPLOY_NAME}-cumulus-${MATURITY}-tf-state-${AWS_ACCOUNT_ID_LAST4} || true
	terraform import -input=false aws_dynamodb_table.backend-tf-locks-table ${DEPLOY_NAME}-cumulus-${MATURITY}-tf-locks || true
	terraform refresh -input=false -state=terraform.tfstate.d/${MATURITY}/terraform.tfstate
	terraform apply -input=false -auto-approve -no-color

daac:
	cd ${SELF_DIR}/daac-repo
	make daac

# ---------------------------
data-persistence: data-persistence-init
	cd $@
	if [ -f "../daac-repo/$@/variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=../daac-repo/$@/variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	terraform apply \
		-var-file=../daac-repo/$@/terraform.tfvars \
		$$VARIABLES_OPT \
		-input=false \
		-no-color \
		-auto-approve

# ---------------------------
cumulus: cumulus-init
	if [ -f "${SELF_DIR}/.secrets/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export SECRETS_OPT="-var-file=${SELF_DIR}/.secrets/${MATURITY}.tfvars"
		echo "Found maturity-specific secrets: $$SECRETS_OPT"
		echo "***************************************************************"
	fi
	cd $@
	cp $(SELF_DIR)/patch/fetch_or_create_rsa_keys.sh \
		$(SELF_DIR)/cumulus/.terraform/modules/cumulus/tf-modules/archive/
	if [ -f "../daac-repo/$@/variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=../daac-repo/$@/variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	export TF_CMD="terraform apply \
				-var-file=../daac-repo/$@/terraform.tfvars \
				$$VARIABLES_OPT \
				$$SECRETS_OPT \
				-input=false \
				-no-color \
				-auto-approve"
	eval $$TF_CMD
	if [ $$? -ne 0 ] # Workaround random Cumulus deploy fails
	then
		eval $$TF_CMD
	fi

destroy-cumulus: cumulus-init
	cd cumulus
	terraform destroy -input=false -auto-approve -no-color

# ---------------------------
workflows: workflows-init
	cd ${SELF_DIR}/daac-repo
	make workflows

# ---------------------------
all: \
	tf \
	daac \
	data-persistence \
	cumulus \
	workflows
