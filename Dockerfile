FROM public.ecr.aws/lambda/python:3.9 as python3
# This image can be used to do Python 3 & NodeJS development, and
# includes the AWS CLI and Terraform. It contains:

#   * CLI utilities: git, make, wget, etc
#   * Python 3
#   * NodeJS
#   * Yarn
#   * AWS CLI
#   * Terraform
#   * Docker

# Amazon Linux 2 does not support node 18.x or node 20.x glibc=2.27 and >=2.28 is required
ENV NODE_VERSION "16.x"
ENV TERRAFORM_VERSION "1.9.2"
ENV AWS_CLI_VERSION "2.17.13"

# Add NodeJS and Yarn repos & update package index
RUN \
        yum install https://rpm.nodesource.com/pub_${NODE_VERSION}/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y && \
        yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1 && \
        curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
        yum update -y

# CLI utilities
RUN yum install -y gcc gcc-c++ git make openssl unzip zip jq docker

# Terraform
RUN \
        curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o "terraform.zip" && \
        unzip terraform.zip && \
        chmod +x terraform && \
        mv terraform /usr/local/bin

# AWS CLI
RUN \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-$AWS_CLI_VERSION.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && \
        ./aws/install

# Node JS
RUN \
        yum install -y nodejs yarn

# SSM SessionManager plugin
RUN \
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && \
        yum install -y session-manager-plugin.rpm

# Add user for keygen in Makefile
ARG USER
RUN \
        echo "user:x:${USER}:0:root:/:/bin/bash" >> /etc/passwd

RUN python3 -m pip install boto3 setuptools

# Uncommenting fixes: `fatal: detected dubious ownership in repository at '/CIRRUS-core'
# Uncommenting fixes: `fatal: detected dubious ownership in repository at '/CIRRUS-DAAC'
# COPY .gitconfig /.gitconfig

WORKDIR /CIRRUS-core

# Bypass the bootstrap.sh script that runs in lambda
ENTRYPOINT []
