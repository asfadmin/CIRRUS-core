pipeline {

  // Environment Setup
  environment {
    AWS_PROFILENAME="jenkins"
    REGISTRY="docker-registry.asf.alaska.edu:5000"
    MATURITY="dev"

  } // env

  // Build on a slave with docker (for pre-req?)
  agent { label 'docker' }

  stages {
    stage('initial stuff') {
      steps {
        // Send chat notification
        mattermostSend channel: "${CHAT_ROOM}", color: '#EAEA5C', endpoint: "${env.CHATHOST}", message: "Build started: ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>). See (<{$env.RUN_CHANGES_DISPLAY_URL}|Changes>)."
      }
    }
    stage('clone and checkout DAAC repo/ref') {
      steps {
        sh "cd ${WORKSPACE}"
        sh "git clone ${env.DAAC_REPO} daac"
        sh "cd daac && git fetch && git checkout ${env.DAAC_REF} && git pull"
        sh 'tree'
      }
    }
    stage('docker makefile running') {
      environment {
        FOO="bar"
        CMR_CREDS = credentials("${CMR_CREDS_ID}")
        URS_CREDS = credentials("${URS_CREDS_ID}")
        TOKEN_SECRET = credentials("${env.SECRET_TOKEN_ID}")/**/
      }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${env.AWSCREDS}"]])  {

            sh """docker run --rm   --env TF_VAR_cmr_username=${CMR_CREDS_USR} \
                                    --env TF_VAR_cmr_password=${CMR_CREDS_PSW} \
                                    --env TF_VAR_urs_client_id=${URS_CREDS_USR} \
                                    --env TF_VAR_urs_client_password=${URS_CREDS_PSW} \
                                    --env TF_VAR_token_secret=${TOKEN_SECRET} \
                                    --env DEPLOY_NAME=${DEPLOY_NAME} \
                                    --env MATURITY_IN=${MATURITY} \
                                    --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                                    --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                                    --env AWS_REGION=${AWS_REGION} \
                                    --env DAAC_REPO=${DAAC_REPO} \
                                    --env DAAC_REF=${DAAC_REF} \
                                    -v \"${WORKSPACE}\":/workspace \
                                    ${REGISTRY}/cumulus-builder:${env.CUMULUS_BUILDER_TAG} \
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
      mattermostSend channel: "${CHAT_ROOM}", color: '#CEEBD3', endpoint: "${env.CHATHOST}", message: "Build Successful: ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
    }
    failure {
      sh "env"
      sh "echo ${WORKSPACE}"
      sh "cd \"${WORKSPACE}\""
      sh "tree"

      mattermostSend channel: "${CHAT_ROOM}", color: '#FFBDBD', endpoint: "${env.CHATHOST}", message: "Build Failed:  🤬${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)🤬"

    }
  }

} // pipeline
