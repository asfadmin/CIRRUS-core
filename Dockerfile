FROM amazonlinux:2023 AS python3
# This image can be used to do Python 3 & NodeJS development, and
# includes the AWS CLI and Terraform. It contains:

#   * CLI utilities: git, make, wget, etc
#   * Python 3
#   * NodeJS
#   * Yarn
#   * AWS CLI
#   * Terraform
#   * Docker
ENV NODE_VERSION="22.x"
ENV TERRAFORM_VERSION="1.12.2"
ENV AWS_CLI_VERSION="2.27.43"

# CLI utilities
RUN yum install -y gcc gcc-c++ git make unzip zip jq

# Install Docker
RUN dnf install -y docker git make unzip zip jq gcc gcc-c++

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

# Add NodeJS and Yarn repos & update package index

RUN \
#        yum install https://rpm.nodesource.com/pub_${NODE_VERSION}/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y && \
#        yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1 && \
        curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
        yum update -y

# Node JS
RUN \
        yum install -y nodejs22 yarn pip

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

FROM public.ecr.aws/lambda/python:3.12 AS python3.12
# This image can be used to do Python 3 & NodeJS development, and
# includes the AWS CLI and Terraform. It contains:

#   * CLI utilities: git, make, wget, etc
#   * Python 3
#   * NodeJS
#   * Yarn
#   * AWS CLI
#   * Terraform
#   * Docker
ENV NODE_VERSION="22.x"
ENV TERRAFORM_VERSION="1.12.2"
ENV AWS_CLI_VERSION="2.27.43"

# Add NodeJS and Yarn repos & update package index
RUN \
    curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
    dnf update -y && \
    dnf clean all

# CLI utilities
RUN dnf install -y gcc gcc-c++ git make unzip zip jq

# Install Docker
RUN dnf install -y docker git make unzip zip jq gcc gcc-c++

# Add Docker

ARG DOCKER_VERSION=25.0.5
RUN yum install gzip -y && yum install tar -y
RUN curl -fsSL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
  | tar -xz -C /usr/local/bin --strip-components=1 docker/docker \
 && docker --version
ENV DOCKER_CONFIG=/tmp/.docker
RUN mkdir -p "$DOCKER_CONFIG" && chmod 1777 "$DOCKER_CONFIG" 
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
        dnf install -y nodejs22 yarn pip

# SSM SessionManager plugin
RUN \
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && \
        rpm -i session-manager-plugin.rpm && \
        rm -f session-manager-plugin.rpm

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
