#!/usr/bin/env bash

# script to remove AccessTokensTable per the migration instructions
#  https://github.com/nasa/cumulus/releases/tag/v1.23.2
#
#
aws dynamodb delete-table \
    --table-name $DEPLOY_NAME-cumulus-$MATURITY-AccessTokensTable