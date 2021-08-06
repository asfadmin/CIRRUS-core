#!/usr/bin/env bash

# run this lambda after deploying the cumulus module

PAYLOAD=$(echo '{"executionMigrationParams": { "parallelScanSegments": 50, "writeConcurrency": 50 }}')

aws lambda invoke --function-name $DEPLOY_NAME-cumulus-$MATURITY-postgres-migration-async-operation \
  --payload "$PAYLOAD" $DEPLOY_NAME-cumulus-$MATURITY-dm2.log