pipeline {

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
