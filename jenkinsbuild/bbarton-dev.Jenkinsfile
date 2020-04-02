pipeline {
  parameters {
    choice(name: 'MATURITY', choices: ['DEV', 'INT', 'TEST', 'PROD'], description: 'The MATURITY (AWS) account to deploy')
    string(name: 'DEPLOY_NAME', defaultValue: 'asf', description: 'The name of the stack for this MATURITY')

    choice(name: 'AWS_REGION', choices: ['us-west-2', 'us-east-1'], description: '')
    credentials(
        name: 'AWS_CREDS',
        description: '',
        defaultValue: 'ASF-117169578524',
        credentialType: 'com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl',
        required: true
      )
    credentials(
        name: 'CMR_CREDS',
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


    string(name: 'CHAT_HOST', defaultValue: 'https://chat.asf.alaska.edu/hooks/dm8kzc8rxpr57xkt9w6tnfaasr', description: '')
    choice(name: 'CHAT_ROOM', choices: ['bbarton-scratch', 'raindev', 'rain'], description: '')

    credentials(
        name: 'SECRET_TOKEN_ID',
        credentialType: 'com.cloudbees.plugins.credentials.impl.SecretTextCredentialsImpl',
        defaultValue: 'cumulus-sandbox-token-secret-20200114', //<option value="cumulus-sandbox-token-secret-20200114">"token_secret" for cumulus deployment</option>
        description: '',
        required: true
    )

    string(name: 'DAAC_REPO', defaultValue: 'git@github.com:asfadmin/asf-cumulus-core.git', description: '')
    string(name: 'DAAC_REF', defaultValue: 'master', description: '')

  }
  // Environment Setup
  environment {
    AWS_PROFILENAME="jenkins"
    MATURITY="dev"
  } // env

  // Build on a slave with docker (for pre-req?)
  agent { label 'docker' }

  stages {
    stage('Start Cumulus Deployment') {
      steps {
        // Send chat notification
        //mattermostSend channel: "${CHAT_ROOM}", color: '#EAEA5C', endpoint: "${env.CHATHOST}", message: "Build started: ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>). See (<{$env.RUN_CHANGES_DISPLAY_URL}|Changes>)."
      sh "env"
      sh "echo ${WORKSPACE}"
      sh "cd \"${WORKSPACE}\""
      sh "tree"

      }
    }

  } // stages
  // Send build status to Mattermost, Update build badge
  post {
    always {
      sh 'echo "done"'
    }
    success {
      mattermostSend channel: "${CHAT_ROOM}", color: '#CEEBD3', endpoint: "${env.CHATHOST}", message: "fake cirrus Build Successful: ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
    }
    failure {
      sh "env"
      sh "echo ${WORKSPACE}"
      sh "cd \"${WORKSPACE}\""
      sh "tree"

      //mattermostSend channel: "${CHAT_ROOM}", color: '#FFBDBD', endpoint: "${env.CHATHOST}", message: "Build Failed:  🤬${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)🤬"

    }
    changed {
      sh "echo 'This will run only if the state of the Pipeline has changed' && echo 'For example, if the Pipeline was previously failing but is now successful'"
    }
  }

} // pipeline
