FROM amazonlinux:2

# This image can be used to do Python 3 & NodeJS development, and
# includes the AWS CLI and Terraform. It contains:

#   * CLI utilities: git, make, wget, etc
#   * Python 3
#   * NodeJS
#   * Yarn
#   * AWS CLI
#   * Terraform

ENV NODE_VERSION "10.x"
ENV TERRAFORM_VERSION "0.12.18"

# Add NodeJS and Yarn repos & update package index
RUN \
        curl -sL https://rpm.nodesource.com/setup_${NODE_VERSION} | bash - && \
        curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
        yum update -y

# CLI utilities
RUN yum install -y gcc git make openssl unzip wget zip

# Python 3 & NodeJS
RUN \
        yum install -y python3-devel && \
        yum install -y nodejs yarn

# AWS & Terraform
RUN \
        yum install -y awscli && \
        wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
        unzip *.zip && \
        chmod +x terraform && \
        mv terraform /usr/local/bin

# SSM SessionManager plugin
RUN \
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" &&\
        yum install -y session-manager-plugin.rpm
        
WORKDIR /CIRRUS-core
