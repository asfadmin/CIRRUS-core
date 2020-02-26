# This makefile assumes you have the following environment variables set:
#
#  AWS_ACCESS_KEY_ID:     Set for the account to which you are deploying
#  AWS_SECRET_ACCESS_KEY: Set for the account to which you are deploying
#  AWS_REGION:            The region to which you are deploying
#
#  DAAC_REPO:             The git repository URL with DAAC-specific Cumulus customization
#  DAAC_REF:              The DAAC_REPO git branch or tag name to checkout and deploy
#
#  DEPLOY_NAME:           A unique name to distinguish this Cumulus instance from others
#  MATURITY:              One of: DEV, INT, TEST, PROD

export TF_IN_AUTOMATION="true"
export TF_VAR_MATURITY=${MATURITY}
export TF_VAR_DEPLOY_NAME=${DEPLOY_NAME}

SELF_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.ONESHELL:

.PHONY: clean \
	checkout-daac \
	validate \
	tf daac data-persistence cumulus workflows all \
	destroy-cumulus

clean:
	rm -rf ${SELF_DIR}/daac-repo

link-daac:
	ln -s ${DAAC_REPO} ${SELF_DIR}/daac-repo

checkout-daac:
	git clone ${DAAC_REPO} ${SELF_DIR}/daac-repo
	cd ${SELF_DIR}/daac-repo
	git fetch
	git checkout ${DAAC_REF}
	git pull
	cd ${SELF_DIR}

tf-init:
	cd tf
	terraform init -reconfigure -input=false
	terraform workspace new ${MATURITY} || terraform workspace select ${MATURITY}

%-init:
	cd $*
	rm -f .terraform/environment
	terraform init -reconfigure -input=false \
		-backend-config "region=${AWS_REGION}" \
		-backend-config "bucket=cumulus-${MATURITY}-tf-state" \
		-backend-config "key=$*/terraform.tfstate" \
		-backend-config "dynamodb_table=cumulus-${MATURITY}-tf-locks"
	terraform workspace new ${DEPLOY_NAME} || terraform workspace select ${DEPLOY_NAME}

modules = tf data-persistence cumulus
init-modules := $(modules:%-init=%)

validate: $(init-modules)
	for module in modules; do \
		cd $$module && terraform validate; \
	done

tf: tf-init
	cd tf
	terraform import -input=false aws_s3_bucket.tf-state-bucket cumulus-${MATURITY}-tf-state || true
	terraform import -input=false aws_dynamodb_table.tf-locks-table cumulus-${MATURITY}-tf-locks || true
	terraform refresh -input=false -state=terraform.tfstate.d/${MATURITY}/terraform.tfstate
	terraform apply -input=false -auto-approve

daac: daac-init
	cd ${SELF_DIR}/daac-repo
	make daac

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
		-auto-approve

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
	terraform apply \
		-var-file=../daac-repo/$@/terraform.tfvars \
		$$VARIABLES_OPT \
		$$SECRETS_OPT \
		-input=false \
		-auto-approve
	if [ $$? -ne 0 ] # Workaround random Cumulus deploy fails
	then
		terraform apply -input=false -auto-approve
	fi

workflows: workflows-init
	cd ${SELF_DIR}/daac-repo
	make workflows

all: \
	tf \
	daac \
	data-persistence \
	cumulus \
	workflows

destroy-cumulus: cumulus-init
	cd cumulus
	terraform destroy -input=false -auto-approve
