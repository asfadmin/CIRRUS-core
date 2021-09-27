#!/usr/bin/env bash

for TABLE in $(aws --profile=${AWS_PROFILE} dynamodb list-tables | jq -r ".TableNames[] | select(contains(\"${DEPLOY_NAME}-cumulus-${MATURITY}\"))"); do
    #don't delete the tf-locks table
    if [ "${TABLE}" != "${DEPLOY_NAME}-cumulus-${MATURITY}-tf-locks" ]; then
        aws --profile=${AWS_PROFILE} dynamodb delete-table --table-name ${TABLE}
    fi
done
