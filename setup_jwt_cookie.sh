#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile "$AWS_PROFILE")
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile "$AWS_PROFILE")
AWS_REGION=$(aws configure get region --profile "$AWS_PROFILE")
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
JWT=$(aws secretsmanager describe-secret --secret-id "$SECRET_NAME" 2>/dev/null | wc -c)

function GENERATE_JWTKEYS_FILE {
    cat >  ${STACKNAME}_jwtkeys.json <<EOL
{
    "rsa_priv_key": "${rsa_priv_key}",
    "rsa_pub_key":  "${rsa_pub_key}"
}
EOL

}

function GENERATE_TEA_CREDS {
  mkdir -p ./tmp
  cd ./tmp || exit 1
  ssh-keygen -t rsa -b 4096 -m PEM -f jwtcookie.key -N ''
  openssl base64 -in jwtcookie.key -out jwtcookie.key.b64 -A
  openssl base64 -in jwtcookie.key.pub -out jwtcookie.key.pub.b64 -A

  export rsa_priv_key=$(<jwtcookie.key.b64)
  export rsa_pub_key=$(<jwtcookie.key.pub.b64)
  rm jwtcookie.key*
  GENERATE_JWTKEYS_FILE
}

if (( $# != 3 )); then
    echo "Usage: source setup_jwt_cookie.sh aws_profile_name deploy_name maturity"
else
    AWS_PROFILE=$1
    DEPLOY_NAME=$2
    MATURITY=$3

    AWSENV="--profile=$AWS_PROFILE --region=$AWS_REGION"

    # Stack Setup
    SECRET_NAME=${DEPLOY_NAME}-cumulus-${MATURITY}-jwt_secret_for_tea

    GENERATE_TEA_CREDS

    aws secretsmanager create-secret --name ${SECRET_NAME} \
        ${AWSENV} \
        --description "RS256 keys for TEA app JWT cookies" \
        --secret-string file://.//${STACKNAME}_jwtkeys.json
    rm ./${STACKNAME}_jwtkeys.json
    cd $DIR
fi


