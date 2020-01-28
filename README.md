# Cumulus Core

## Overview

This repository contains the configuration and deployment scripts to
deploy Cumulus Core for a DAAC. It is a modified version of the [Cumulus Template
Deploy](https://github.com/nasa/cumulus-template-deploy)
project. Specifically, all parts of the deployment have been
Terraformed and the configuration minimized.

See the [Cumulus
Documentation](https://nasa.github.io/cumulus/docs/deployment/deployment-readme)
for detailed information about configuring, deploying, and running
Cumulus.

## Prerequisites

* [Terraform](https://www.terraform.io/)
* [AWS CLI](https://aws.amazon.com/cli/)
* [GNU Make](https://www.gnu.org/software/make/)
* [NodeJS 8.11](https://nodejs.org/en/)
* [Yarn](https://yarnpkg.com/lang/en/)

Note: The [Node Version Manager (nvm)](https://github.com/nvm-sh/nvm)
is a useful tool to both install specific versions of NodeJS, but also
switch between them for different projects, depending on their
requirements.

## Configuration

* The Terraform configuration in each environment can be tailored for
your DAAC. Primarily this will mean updating the `terraform.tfvars`
files for your DAAC's Cumulus deployment. Of course you may want to
add additional resources in the Terraform configuration files as well.

*In Progress*
When choosing values for MATURITY and DEPLOY_NAME:
* The combined length cannot exceed 12 characters
* Must consist of `a-z` (lower case characters), `0-9`, and `-` (hyphen) only

## Deploying Cumulus

1. Setup your environment with the AWS profile that has permissions to
   deploy to the target NGAP account:

        $ source env.sh <profile-name> <deploy-name> <maturity>

        e.g., to deploy to the NGAP sandbox account with the initials
        of a developer (to make deployment unique) with maturity of 'dev':

        $ source env.sh asf-sandbox-cumulus kb dev

2. Verify that the environment variables are set:

        $ env | grep AWS

    You should see the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and
    AWS_REGION, DEPLOY_NAME, and MATURITY environment variables set.

3. Deploy Cumulus:

        $ make all
