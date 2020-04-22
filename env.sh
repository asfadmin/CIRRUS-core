#!/bin/bash

AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile "$AWS_PROFILE")
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile "$AWS_PROFILE")
AWS_REGION=$(aws configure get region --profile "$AWS_PROFILE")

if (( $# != 3 )); then
    echo "Usage: source env.sh aws_profile_name deploy_name maturity"
else
    export AWS_PROFILE=$1
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export AWS_REGION
    export DEPLOY_NAME=$2
    export MATURITY=$3
fi
