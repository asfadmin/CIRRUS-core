FROM amazonlinux:2023 AS core_base
# This image can be used to do Python 3 & NodeJS development, and
# includes the AWS CLI and Terraform. It contains:

#   * CLI utilities: git, make, wget, etc
#   * Python 3
#   * NodeJS
#   * Yarn
#   * AWS CLI
#   * Terraform

ENV NODE_VERSION="20.x"
ENV TERRAFORM_VERSION="1.9.2"
ENV AWS_CLI_VERSION="2.17.13"

# Install NodeJS
RUN curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION} | bash -
RUN dnf install -y nodejs

# CLI utilities
RUN dnf install -y gcc gcc-c++ git make openssl unzip wget zip jq

# AWS & Terraform
RUN \
        wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
        unzip *.zip && \
        chmod +x terraform && \
        mv terraform /usr/local/bin && \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-$AWS_CLI_VERSION.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && \
        ./aws/install

# SSM SessionManager plugin
RUN \
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" &&\
        dnf install -y session-manager-plugin.rpm

# Add user for keygen in Makefile
ARG USER
RUN \
        echo "user:x:${USER}:0:root:/:/bin/bash" >> /etc/passwd

# Uncommenting breaks: CIRRUS-ASF's CI/CD
# Uncommenting fixes: `fatal: detected dubious ownership in repository at '/CIRRUS-core'
# Uncommenting fixes: `fatal: detected dubious ownership in repository at '/CIRRUS-DAAC'
# COPY .gitconfig /.gitconfig

WORKDIR /CIRRUS-core

# Python310 target
FROM core_base AS python310
ENV PYTHON_3_10_VERSION "3.10.14"
RUN \
        dnf groupinstall "Development Tools" -y && \
        dnf install openssl-devel bzip2-devel libffi-devel sqlite-devel -y && \
        cd /usr/local && \
        wget https://www.python.org/ftp/python/${PYTHON_3_10_VERSION}/Python-${PYTHON_3_10_VERSION}.tgz && \
        tar xzf Python-${PYTHON_3_10_VERSION}.tgz && cd Python-${PYTHON_3_10_VERSION} &&  \
        ./configure --enable-optimizations \
              --enable-shared \
              --enable-loadable-sqlite-extensions \
              --prefix /usr/local \
              LDFLAGS=-Wl,-rpath=/usr/local/lib && \
        make altinstall &&  \
        update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.10 1 && \
        python3 -m pip install boto3 setuptools

# Python38 target
FROM core_base AS python38
ENV PYTHON_3_8_VERSION "3.8.16"
RUN \
        dnf groupinstall "Development Tools" -y && \
        dnf install openssl-devel bzip2-devel libffi-devel sqlite-devel -y && \
        cd /usr/local && \
        wget https://www.python.org/ftp/python/${PYTHON_3_8_VERSION}/Python-${PYTHON_3_8_VERSION}.tgz && \
        tar xzf Python-${PYTHON_3_8_VERSION}.tgz && cd Python-${PYTHON_3_8_VERSION} && \
        ./configure --enable-optimizations \
              --enable-shared \
              --enable-loadable-sqlite-extensions \
              --prefix /usr/local \
              LDFLAGS=-Wl,-rpath=/usr/local/lib && \
        make altinstall &&  \
        update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.8 1 && \
        python3 -m pip install boto3 setuptools


# Python3 target
FROM core_base AS python3
# Python 3
RUN \
        dnf install -y python3-devel && \
        dnf install -y python3-pip && \
        python3 -m pip install boto3 setuptools
