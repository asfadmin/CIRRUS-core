FROM amazonlinux:2023 AS al2023
LABEL authors="dmsorensen"

ENV TERRAFORM_VERSION="1.9.2"
ENV AWS_CLI_VERSION="2.17.13"

# Docker
RUN dnf install -y docker

# CLI tools
RUN dnf install -y zip make clear

# AWS CLI
RUN \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-$AWS_CLI_VERSION.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && \
        ./aws/install

# Terraform
RUN \
        curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o "terraform.zip" && \
        unzip terraform.zip && \
        chmod +x terraform && \
        mv terraform /usr/local/bin

ENTRYPOINT []
