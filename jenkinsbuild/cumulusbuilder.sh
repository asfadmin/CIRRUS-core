#!/bin/bash
echo "env inside container: "
env
cd /workspace/ || exit 1

# MATURITY needs to be lower case for AWS reasons.
MATURITY="`echo "$MATURITY_IN" | tr '[:upper:]' '[:lower:]'`"
export MATURITY


make all
