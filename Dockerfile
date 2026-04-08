FROM amazonlinux:2023 AS python3
# This image can be used to do Python 3 & NodeJS development, and
# includes the AWS CLI and Terraform. It contains:
#
#   * CLI utilities: git, make, wget, etc
#   * Python 3
#   * NodeJS
#   * Yarn
#   * AWS CLI
#   * Terraform
#   * Docker

ENV TERRAFORM_VERSION="1.12.2"
ENV AWS_CLI_VERSION="2.27.43"
ARG USER

WORKDIR /CIRRUS-core
# Base packages + Python + Docker + Yarn
RUN dnf install -y \
        gcc \
        gcc-c++ \
        git \
        make \
        unzip \
        zip \
        jq \
        python3 \
        python3-pip \
        docker \
    && dnf clean all

# Remove any preexisting generic/older Node packages, then install Node 22/yarn globally
RUN dnf remove -y nodejs nodejs18 || true \
    && dnf install -y nodejs22\
    && dnf clean all

RUN npm install -g yarn

# Terraform
RUN \
        curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o "terraform.zip" && \
        unzip terraform.zip && \
        chmod +x terraform && \
        mv terraform /usr/local/bin && \
        rm -f terraform.zip

# AWS CLI
RUN \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && \
        ./aws/install && \
        rm -rf aws awscliv2.zip

# SSM SessionManager plugin
RUN \
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && \
        dnf install -y ./session-manager-plugin.rpm && \
        rm -f session-manager-plugin.rpm && \
        dnf clean all

# Add user for keygen in Makefile
ARG USER
RUN echo "user:x:${USER}:0:root:/:/bin/bash" >> /etc/passwd

RUN python3 -m pip install --no-cache-dir boto3 setuptools

# Uncommenting fixes:
#   fatal: detected dubious ownership in repository at '/CIRRUS-core'
#   fatal: detected dubious ownership in repository at '/CIRRUS-DAAC'
# COPY .gitconfig /.gitconfig

WORKDIR /CIRRUS-core

# Bypass the bootstrap.sh script that runs in lambda
ENTRYPOINT []
