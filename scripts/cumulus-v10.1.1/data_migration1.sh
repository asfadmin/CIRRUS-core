#!/usr/bin/env bash

# run this lambda after deploying the data-persistence module and before deploying the cumulus module

PAYLOAD=$(echo '{"forceRulesMigration": true}')

aws lambda invoke --function-name $DEPLOY_NAME-cumulus-$MATURITY-data-migration1 \
  --payload "$PAYLOAD" $DEPLOY_NAME-cumulus-$MATURITY-dm1.log
