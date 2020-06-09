#!/usr/bin/env bash

# script to remove AccessTokensTable per the migration instructions
#  https://github.com/nasa/cumulus/releases/tag/v1.23.2
#
# need to run this first to set up environment:
#   $ source env.sh <profile-name> <deploy-name> <maturity>
#

aws dynamodb delete-table \
    --table-name $DEPLOY_NAME-cumulus-$MATURITY-AccessTokensTable