#!/usr/bin/env bash

# when upgrading to cumulus 16.0.0 the "make cumulus" tries to delete 3 lambda
# functions and their associated log groups.  It gets stuck in a cycle
#
#  Error: Cycle: module.cumulus.module.archive.aws_lambda_function.granule_files_cache_updater (destroy), module.cumulus.module.archive.aws_cloudwatch_log_group.granule_files_cache_updater_logs (destroy)
#
#  Error: Cycle: module.cumulus.module.archive.aws_lambda_function.publish_pdrs (destroy), module.cumulus.module.archive.aws_cloudwatch_log_group.publish_pdrs_logs (destroy)
#
#  Error: Cycle: module.cumulus.module.archive.aws_lambda_function.publish_granules (destroy), module.cumulus.module.archive.aws_cloudwatch_log_group.publish_granules_logs (destroy)
#
# this script deletes the log groups.  After they are deleted "make cumulus"
# runs successfully

aws logs delete-log-group --log-group-name "/aws/lambda/${DEPLOY_NAME}-cumulus-${MATURITY}-granuleFilesCacheUpdater"
aws logs delete-log-group --log-group-name "/aws/lambda/${DEPLOY_NAME}-cumulus-${MATURITY}-publishPdrs"
aws logs delete-log-group --log-group-name "/aws/lambda/${DEPLOY_NAME}-cumulus-${MATURITY}-publishGranules"
