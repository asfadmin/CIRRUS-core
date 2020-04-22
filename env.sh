#!/bin/bash

AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile "$AWS_PROFILE")
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile "$AWS_PROFILE")
AWS_REGION=$(aws configure get region --profile "$AWS_PROFILE")
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
AWS_ACCOUNT_ID_LAST4=${AWS_ACCOUNT_ID: -4:4}

if (( $# != 3 )); then
    echo "Usage: source env.sh aws_profile_name deploy_name maturity"
else
    export AWS_PROFILE=$1
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export AWS_REGION
    export AWS_ACCOUNT_ID
    export AWS_ACCOUNT_ID_LAST4
    export DEPLOY_NAME=$2
    export MATURITY=$3
fi
