pipeline {
  parameters {
    choice(name: 'MATURITY', choices: ['DEV', 'INT', 'TEST', 'PROD'], description: 'The MATURITY (AWS) account to deploy')
    string(name: 'DEPLOY_NAME', defaultValue: '', description: 'The name of the stack for this MATURITY')

    string(name: 'DAAC_REPO', defaultValue: '', description: '')
    string(name: 'DAAC_REF', defaultValue: 'master', description: '')

    string(name: 'AWS_REGION', defaultValue: '', description: 'AWS Region to deploy to')
    credentials(
        name: 'AWS_CREDS',
        description: '',
        defaultValue: 'ASF-117169578524',
        credentialType: 'com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl',
        required: true
      )

    credentials(
        name: 'CMR_CREDS_ID',
        credentialType: 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl',
        defaultValue: 'asf-cumulus-core-cmr_creds_UAT', //<option value="asf-cumulus-core-cmr_creds_UAT">benbart/****** (CMR username &amp; password for use in the asf-cumulus-core NGAP sandbox account)</option>
        description: '',
        required: true
      )
    credentials(
        name: 'URS_CREDS_ID',
        credentialType: 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl',
        defaultValue: 'aa4a3277-cfd4-4edb-90dc-f55f6f99f835', //<option value="aa4a3277-cfd4-4edb-90dc-f55f6f99f835">Jenkins/******</option>
        description: 'urs_client_id and urs_password for cumulus',
        required: true
      )
    credentials(
        name: 'SECRET_TOKEN_ID',
        credentialType: 'com.cloudbees.plugins.credentials.impl.SecretTextCredentialsImpl',
        defaultValue: 'cumulus-sandbox-token-secret-20200114', //<option value="cumulus-sandbox-token-secret-20200114">"token_secret" for cumulus deployment</option>
        description: '',
        required: true
    )

    string(name: 'CHAT_HOST', defaultValue: 'https://chat.asf.alaska.edu/hooks/dm8kzc8rxpr57xkt9w6tnfaasr', description: '')
    choice(name: 'CHAT_ROOM', choices: ['bbarton-scratch', 'raindev', 'rain'], description: '')
  }

  // Environment Setup
  environment {
    AWS_PROFILENAME="jenkins"
  } // env

  // Build on a slave with docker (for pre-req?)
  agent { label 'docker' }

  stages {
    stage('Start Cumulus Deployment') {
      steps {
        // Send chat notification
        mattermostSend channel: "${CHAT_ROOM}", color: '#EAEA5C', endpoint: "${params.CHAT_HOST}", message: "Build started: ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>). See (<{$env.RUN_CHANGES_DISPLAY_URL}|Changes>)."
      }
    }
    stage('Clone and checkout DAAC repo/ref') {
      steps {
        sh "cd ${WORKSPACE}"
        sh "if [ ! -d \"daac-repo\" ]; then git clone ${params.DAAC_REPO} daac-repo; fi"
        sh "cd daac-repo && git fetch origin ${params.DAAC_REF} && git checkout ${params.DAAC_REF} && cd .."
        sh 'tree'
      }
    }
    stage('Build the CIRRUS deploy Docker image') {
      steps {
        sh """cd jenkinsbuild && \
              docker build -f nodebuild.Dockerfile -t cirrusbuilder .
           """
      }
    }
    stage('Deploy Cumulus within CIRRUS deploy Docker container') {
      environment {
        CMR_CREDS = credentials("${params.CMR_CREDS_ID}")
        URS_CREDS = credentials("${params.URS_CREDS_ID}")
        TOKEN_SECRET = credentials("${params.SECRET_TOKEN_ID}")/**/
      }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${params.AWS_CREDS}"]])  {

            sh """docker run --rm   --user `id -u` \
                                    --env DEPLOY_NAME='${params.DEPLOY_NAME}' \
                                    --env MATURITY='${params.MATURITY}' \
                                    --env AWS_ACCESS_KEY_ID='${AWS_ACCESS_KEY_ID}' \
                                    --env AWS_SECRET_ACCESS_KEY='${AWS_SECRET_ACCESS_KEY}' \
                                    --env AWS_REGION='${params.AWS_REGION}' \
                                    --env DAAC_REPO='${params.DAAC_REPO}' \
                                    --env DAAC_REF='${params.DAAC_REF}' \
                                    --env TF_VAR_cmr_username='${CMR_CREDS_USR}' \
                                    --env TF_VAR_cmr_password='${CMR_CREDS_PSW}' \
                                    --env TF_VAR_urs_client_id='${URS_CREDS_USR}' \
                                    --env TF_VAR_urs_client_password='${URS_CREDS_PSW}' \
                                    --env TF_VAR_token_secret='${TOKEN_SECRET}' \
                                    -v \"${WORKSPACE}\":/workspace \
                                    cirrusbuilder \
                                    /bin/bash /workspace/jenkinsbuild/cumulusbuilder.sh
            """

        }// withCredentials
      }// steps
    }// stage
  } // stages
  // Send build status to Mattermost, Update build badge
  post {
    always {
      sh 'echo "done"'
    }
    success {
      mattermostSend channel: "${CHAT_ROOM}", color: '#CEEBD3', endpoint: "${params.CHAT_HOST}", message: "Build Successful: ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
    }
    failure {
      sh "env"
      sh "echo ${WORKSPACE}"
      sh "cd \"${WORKSPACE}\""
      sh "tree"

      mattermostSend channel: "${CHAT_ROOM}", color: '#FFBDBD', endpoint: "${params.CHAT_HOST}", message: "Build Failed:  🤬${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)🤬"

    }
    changed {
      sh "echo 'This will run only if the state of the Pipeline has changed' && echo 'For example, if the Pipeline was previously failing but is now successful'"
    }
  }

} // pipeline
