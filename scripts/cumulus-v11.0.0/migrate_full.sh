#!/usr/bin/env bash

# run this script (or migrate_only_files.sh) after deploying Cumulus v11, per
# the Cumulus v11.0.0 release notes: https://github.com/nasa/cumulus/releases/tag/v11.0.0

PAYLOAD=$(echo '{"migrationsList": ["granules"], "granuleMigrationParams": {"migrateAndOverwrite": "true"}}' | base64)
aws lambda invoke --function-name "${PREFIX}-postgres-migration-async-operation" \
  --payload "${PAYLOAD}" "${DEPLOY_NAME}-cumulus-${MATURITY}-pg-migration-full.log"
