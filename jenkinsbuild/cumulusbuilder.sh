#!/bin/bash
echo "env inside container: "
env
cd /workspace/ || exit 1

# MATURITY needs to be lower case for AWS reasons.
export MATURITY="`echo "$MATURITY_IN" | tr '[:upper:]' '[:lower:]'`"

make all
rm -rf ./daac-repo/tmp
