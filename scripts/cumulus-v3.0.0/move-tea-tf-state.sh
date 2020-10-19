#!/usr/bin/env bash

#These mv commands are per these instructions:
#  https://nasa.github.io/cumulus/docs/upgrade-notes/migrate_tea_standalone

# Move security group
terraform state mv module.cumulus.module.distribution.module.thin_egress_app.aws_security_group.egress_lambda module.thin_egress_app.aws_security_group.egress_lambda

# Move TEA storage bucket
terraform state mv module.cumulus.module.distribution.module.thin_egress_app.aws_s3_bucket.lambda_source module.thin_egress_app.aws_s3_bucket.lambda_source

# Move TEA lambda source code
terraform state mv module.cumulus.module.distribution.module.thin_egress_app.aws_s3_bucket_object.lambda_source module.thin_egress_app.aws_s3_bucket_object.lambda_source

# Move TEA lambda dependency code
terraform state mv module.cumulus.module.distribution.module.thin_egress_app.aws_s3_bucket_object.lambda_code_dependency_archive module.thin_egress_app.aws_s3_bucket_object.lambda_code_dependency_archive

# Move TEA Cloudformation template
terraform state mv module.cumulus.module.distribution.module.thin_egress_app.aws_s3_bucket_object.cloudformation_template module.thin_egress_app.aws_s3_bucket_object.cloudformation_template

# Move URS creds secret version
terraform state mv module.cumulus.module.distribution.aws_secretsmanager_secret_version.thin_egress_urs_creds aws_secretsmanager_secret_version.thin_egress_urs_creds

# Move URS creds secret
terraform state mv module.cumulus.module.distribution.aws_secretsmanager_secret.thin_egress_urs_creds aws_secretsmanager_secret.thin_egress_urs_creds

# Move TEA Cloudformation stack
terraform state mv module.cumulus.module.distribution.module.thin_egress_app.aws_cloudformation_stack.thin_egress_app module.thin_egress_app.aws_cloudformation_stack.thin_egress_app

# Move bucket map
#terraform state mv module.cumulus.module.distribution.aws_s3_bucket_object.bucket_map_yaml[0] aws_s3_bucket_object.bucket_map_yaml