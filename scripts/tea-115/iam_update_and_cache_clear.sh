#!/usr/bin/env bash

aws --region=us-west-2 --profile=${AWS_PROFILE} lambda invoke \
    --function-name ${DEPLOY_NAME}-cumulus-${MATURITY}-thin-egress-app-UpdatePolicyLambda \
    --payload "{}" -

aws --region=us-west-2 --profile=${AWS_PROFILE} lambda invoke \
    --function-name ${DEPLOY_NAME}-cumulus-${MATURITY}-thin-egress-app-BumperLambda --payload "{}" - 