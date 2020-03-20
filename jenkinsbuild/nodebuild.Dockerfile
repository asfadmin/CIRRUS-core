FROM amazonlinux:2

ENV DEPLOY_NAME=daac-cumulus-core
ENV MATURITY_IN=DEV

RUN yum update -y && \
        curl -sL https://rpm.nodesource.com/setup_10.x | bash - && curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
        yum install -y python3-devel make git nodejs yarn openssl wget awscli zip unzip && \
        wget https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip && \
        unzip *.zip && \
        chmod +x terraform && \
        mv terraform /usr/local/bin
