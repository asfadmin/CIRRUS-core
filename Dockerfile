FROM amazonlinux:2

# This image can be used to do Python 3 & NodeJS development, and
# includes the AWS CLI and Terraform. It contains:

#   * CLI utilities: git, make, wget, etc
#   * Python 3
#   * NodeJS
#   * Yarn
#   * AWS CLI
#   * Terraform

ENV NODE_VERSION "14.x"
ENV TERRAFORM_VERSION "0.13.6"

# Add NodeJS and Yarn repos & update package index
RUN \
        curl -sL https://rpm.nodesource.com/setup_${NODE_VERSION} | bash - && \
        curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
        yum update -y

# CLI utilities
RUN yum install -y gcc gcc-c++ git make openssl unzip wget zip jq

# Python 3 & NodeJS
RUN \
        yum install -y python3-devel && \
        yum install -y nodejs yarn

# AWS & Terraform
RUN \
        python3 -m pip install boto3 && \
        wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
        unzip *.zip && \
        chmod +x terraform && \
        mv terraform /usr/local/bin && \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && \
        ./aws/install

# SSM SessionManager plugin
RUN \
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" &&\
        yum install -y session-manager-plugin.rpm

WORKDIR /CIRRUS-core
