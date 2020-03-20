#!/bin/bash
echo "env inside container: "
env
cd /workspace/ || exit 1

ls -al
ls -al tf
ls -al daac-repo

# MATURITY needs to be lower case for AWS reasons.
export MATURITY="`echo "$MATURITY_IN" | tr '[:upper:]' '[:lower:]'`"

make all
rval=$?

exit $rval
