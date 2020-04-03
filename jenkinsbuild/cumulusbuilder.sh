#!/bin/bash
echo "env inside container: "
env
cd /workspace/ || exit 1

ls -al
ls -al tf
ls -al daac-repo

# MATURITY needs to be lower case for AWS reasons.
export MATURITY="`echo "$MATURITY" | tr '[:upper:]' '[:lower:]'`"
env

make all
exit $?
