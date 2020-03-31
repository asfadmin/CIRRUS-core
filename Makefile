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
	rm workflows
	rm daac
	rm -rf daac-repo

link-daac:
	ln -s ${DAAC_REPO} ./daac-repo
	ln -s daac-repo/daac ./daac
	ln -s daac-repo/workflows ./workflows

checkout-daac:
	git clone ${DAAC_REPO} daac-repo
	cd daac-repo && git fetch && git checkout ${DAAC_REF} && git pull && cd ..
	ln -s daac-repo/daac ./daac
	ln -s daac-repo/workflows ./workflows

tf-init:
	cd tf
	terraform init -reconfigure -input=false -no-color
	terraform workspace new ${DEPLOY_NAME}-${MATURITY} || terraform workspace select ${DEPLOY_NAME}-${MATURITY}

%-init:
	cd $*
	rm -f .terraform/environment
	terraform init -reconfigure -input=false -no-color \
		-backend-config "region=${AWS_REGION}" \
		-backend-config "bucket=${DEPLOY_NAME}-cumulus-${MATURITY}-tf-state" \
		-backend-config "key=$*/terraform.tfstate" \
		-backend-config "dynamodb_table=${DEPLOY_NAME}-cumulus-${MATURITY}-tf-locks"
	terraform workspace new ${DEPLOY_NAME}-${MATURITY} || terraform workspace select ${DEPLOY_NAME}-${MATURITY}

modules = tf daac data-persistence cumulus workflows
init-modules := $(modules:%-init=%)

validate: $(init-modules)
	for module in modules; do \
		cd $$module && terraform validate; \
	done

tf: tf-init
	cd tf
	terraform import -input=false aws_s3_bucket.tf-state-bucket ${DEPLOY_NAME}-cumulus-${MATURITY}-tf-state || true
	terraform import -input=false aws_dynamodb_table.tf-locks-table ${DEPLOY_NAME}-cumulus-${MATURITY}-tf-locks || true
	terraform refresh -input=false -state=terraform.tfstate.d/${DEPLOY_NAME}-${MATURITY}/terraform.tfstate
	terraform apply -input=false -auto-approve -no-color

daac: daac-init
	cd $@
	if [ -f "variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	terraform apply \
		$$VARIABLES_OPT \
		-input=false \
		-no-color \
		-auto-approve

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

workflows: workflows-init
	cd workflows
	terraform apply -input=false -auto-approve -no-color

all: \
	tf \
	daac \
	data-persistence \
	cumulus \
	workflows

destroy-cumulus: cumulus-init
	cd cumulus
	terraform destroy -input=false -auto-approve -no-color
