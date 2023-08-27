# To create the Docker image & start the container from it, this
# makefile assumes you have the following environment variable set:
#
#  DAAC_DIR               The (local) directory containing a fork of the
#                         `CIRRUS-DAAC` repo you wish to deploy.
#
# For deployment-related targets (run within the Docker container),
# This makefile assumes you have the following environment variables
# set:
#
#  AWS_ACCESS_KEY_ID:     Set for the account to which you are deploying
#  AWS_SECRET_ACCESS_KEY: Set for the account to which you are deploying
#  AWS_REGION:            The region to which you are deploying
#  AWS_ACCOUNT_ID:	  The AWS account ID to which you are deploying
#  AWS_ACCOUNT_ID_LAST4:  The Last 4 digits of AWS_ACCOUNT_ID
#
#  DEPLOY_NAME:           A unique name to distinguish this Cumulus instance from others
#  MATURITY:              One of: DEV, INT, TEST, PROD
#  PYTHON_VER: 			  python3 or python38 which sets the build target in make file

# ---------------------------
DOCKER_TAG := v17.0.0.0
export TF_IN_AUTOMATION="true"
export TF_VAR_MATURITY=${MATURITY}
export TF_VAR_DEPLOY_NAME=${DEPLOY_NAME}
PYTHON_VER ?= python3
# ---------------------------
SELF_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.DEFAULT_GOAL := all
.SILENT:
.ONESHELL:

# ---------------------------
define banner =
echo
echo "========================================"
if command -v figlet 2>/dev/null; then
	figlet $@
elif command -v banner 2>/dev/null; then
	banner $@
else
	echo "Making: $@"
fi
echo "========================================"
endef

# ---------------------------
.PHONY: image
image: Dockerfile
	docker build -f Dockerfile --no-cache -t cirrus-core:$(DOCKER_TAG) --target $(PYTHON_VER) --build-arg USER=`id -u` .

.PHONY: container-shell
container-shell:
	docker run -it --rm \
		--user `id -u` \
		--env DAAC_DIR="/CIRRUS-DAAC" \
		--env AWS_CONFIG_DIR="/" \
		--env PS1='\s-\v:\w\$$ ' \
		--env HISTFILE="/CIRRUS-core/.container_bash_history" \
		-v ${PWD}:/CIRRUS-core \
		-v ${DAAC_DIR}:/CIRRUS-DAAC \
		-v ${HOME}/.aws:/.aws \
		-v ${HOME}/.cache/pip:/.cache/pip \
		--name=cirrus-core \
		cirrus-core:$(DOCKER_TAG) \
		bash

# ---------------------------
.PHONY: tf-init
tf-init:
	$(banner)
	cd tf
	rm -rf terraform.tfstate.d
	terraform init -reconfigure -input=false -no-color
	terraform workspace new ${MATURITY} 2>/dev/null || terraform workspace select ${MATURITY}

%-init:
	$(banner)
	cd $*
	rm -f .terraform/environment
	terraform init -reconfigure -input=false -no-color \
		-backend-config "region=${AWS_REGION}" \
		-backend-config "bucket=${DEPLOY_NAME}-cumulus-${MATURITY}-tf-state-${AWS_ACCOUNT_ID_LAST4}" \
		-backend-config "key=$*/terraform.tfstate" \
		-backend-config "dynamodb_table=${DEPLOY_NAME}-cumulus-${MATURITY}-tf-locks"
	terraform workspace new ${DEPLOY_NAME} 2>/dev/null || terraform workspace select ${DEPLOY_NAME}

init-modules-list = tf data-persistence cumulus
init-modules := $(init-modules-list:%-init=%)

# ---------------------------
.PHONY: validate
validate: $(init-modules)
	$(banner)
	for module in modules; do \
		cd $$module && terraform validate; \
	done

# ---------------------------
.PHONY: tf
tf: tf-init
	$(banner)
	cd tf
	terraform import -input=false aws_s3_bucket.backend-tf-state-bucket ${DEPLOY_NAME}-cumulus-${MATURITY}-tf-state-${AWS_ACCOUNT_ID_LAST4} 2>/dev/null || true
	terraform import -input=false aws_dynamodb_table.backend-tf-locks-table ${DEPLOY_NAME}-cumulus-${MATURITY}-tf-locks 2>/dev/null || true
	terraform apply -input=false -auto-approve -no-color

.PHONY: plan-tf
plan-tf: tf-init
	$(banner)
	cd tf
	terraform import -input=false aws_s3_bucket.backend-tf-state-bucket ${DEPLOY_NAME}-cumulus-${MATURITY}-tf-state-${AWS_ACCOUNT_ID_LAST4} 2>/dev/null || true
	terraform import -input=false aws_dynamodb_table.backend-tf-locks-table ${DEPLOY_NAME}-cumulus-${MATURITY}-tf-locks 2>/dev/null || true
	terraform plan -input=false -no-color

# ---------------------------
.PHONY: data-persistence
data-persistence: data-persistence-init
	$(banner)
	cd $@
	if [ -f "${DAAC_DIR}/data-persistence/variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=${DAAC_DIR}/data-persistence/variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	terraform apply \
		-var-file=${DAAC_DIR}/data-persistence/terraform.tfvars \
		$$VARIABLES_OPT \
		-input=false \
		-no-color \
		-auto-approve

# ---------------------------
.PHONY: plan-data-persistence
plan-data-persistence: data-persistence-init
	$(banner)
	cd data-persistence
	if [ -f "${DAAC_DIR}/data-persistence/variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=${DAAC_DIR}/data-persistence/variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	terraform plan \
		-var-file=${DAAC_DIR}/data-persistence/terraform.tfvars \
		$$VARIABLES_OPT \
		-input=false \
		-no-color

# ---------------------------
.PHONY: destroy-data-persistence
destroy-data-persistence: data-persistence-init
	$(banner)
	./scripts/destroy-dp-dynamo-tables.sh
	cd data-persistence
	if [ -f "${DAAC_DIR}/data-persistence/variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=${DAAC_DIR}/data-persistence/variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	terraform destroy \
		-var-file=${DAAC_DIR}/data-persistence/terraform.tfvars \
		$$VARIABLES_OPT \
		-input=false \
		-no-color \
		-auto-approve

# ---------------------------
.PHONY: cumulus
cumulus: cumulus-init
	$(banner)
	if [ -f "${DAAC_DIR}/$@/secrets/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export SECRETS_OPT="-var-file=${DAAC_DIR}/$@/secrets/${MATURITY}.tfvars"
		echo "Found maturity-specific secrets: $$SECRETS_OPT"
		echo "***************************************************************"
	fi
	cd $@
	if [ -f "${DAAC_DIR}/$@/variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=${DAAC_DIR}/$@/variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	export TF_CMD="terraform apply \
				-var-file=${DAAC_DIR}/$@/terraform.tfvars \
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

# ---------------------------
.PHONY: plan-cumulus
plan-cumulus: cumulus-init
	$(banner)
	if [ -f "${DAAC_DIR}/cumulus/secrets/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export SECRETS_OPT="-var-file=${DAAC_DIR}/cumulus/secrets/${MATURITY}.tfvars"
		echo "Found maturity-specific secrets: $$SECRETS_OPT"
		echo "***************************************************************"
	fi
	cd cumulus
	if [ -f "${DAAC_DIR}/cumulus/variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=${DAAC_DIR}/cumulus/variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	export TF_CMD="terraform plan \
				-var-file=${DAAC_DIR}/cumulus/terraform.tfvars \
				$$VARIABLES_OPT \
				$$SECRETS_OPT \
				-input=false \
				-no-color"
	eval $$TF_CMD
	if [ $$? -ne 0 ] # Workaround random Cumulus deploy fails
	then
		eval $$TF_CMD
	fi

.PHONY: destroy-cumulus
destroy-cumulus: cumulus-init
	$(banner)
	if [ -f "${DAAC_DIR}/cumulus/secrets/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export SECRETS_OPT="-var-file=${DAAC_DIR}/cumulus/secrets/${MATURITY}.tfvars"
		echo "Found maturity-specific secrets: $$SECRETS_OPT"
		echo "***************************************************************"
	fi
	cd cumulus
	if [ -f "${DAAC_DIR}/cumulus/variables/${MATURITY}.tfvars" ]
	then
		echo "***************************************************************"
		export VARIABLES_OPT="-var-file=${DAAC_DIR}/cumulus/variables/${MATURITY}.tfvars"
		echo "Found maturity-specific variables: $$VARIABLES_OPT"
		echo "***************************************************************"
	fi
	export TF_CMD="terraform destroy \
				-var-file=${DAAC_DIR}/cumulus/terraform.tfvars \
				$$VARIABLES_OPT \
				$$SECRETS_OPT \
				-input=false \
				-no-color \
				-auto-approve"
	eval $$TF_CMD

# ---------------------------
# Catch-all target to forward any undefined targets to the DAAC Makefile
# https://www.gnu.org/software/make/manual/html_node/Overriding-Makefiles.html#Overriding-Makefiles
%: force
	$(MAKE) -C ${DAAC_DIR} $@

force: ;

# ---------------------------
.PHONY: all
all: \
	tf \
	daac \
	data-persistence \
	cumulus \
	workflows

.PHONY: initial-deploy
initial-deploy: \
	tf \
	daac \
	rds \
	data-persistence \
	cumulus \
	workflows
