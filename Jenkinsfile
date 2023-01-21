pipeline {
    agent any
   
  tools {
    maven 'mvn'
  } 
   
    stages {
        stage('Checkout Code') {
            steps {
              checkout scm
            }
        }
        stage('mvn Compile and Build') {
            steps {
                sh 'mvn clean install package'
            }
        }
        stage('Unit Tests Execution') {
            steps {
                sh """
                 mvn surefire:test
                 ls -al target
                """
            }
        }
        stage('Static Code analysis with Sonarqube') {
            steps {
              withSonarQubeEnv(installationName: 'sonar') {
                sh 'mvn sonar:sonar'
              }
            }
        }
        stage('Waiting for quality Gate Result') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                  waitForQualityGate abortPipeline: true
               }
            }
        }
        // stage('Docker build && tag image') {
        //     steps {
        //         sh"""
        //         ls -al 
        //         docker build -t kojitechstags-register .
        //         aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 735972722491.dkr.ecr.us-east-1.amazonaws.com
        //         docker tag kojitechstags-register:latest 735972722491.dkr.ecr.us-east-1.amazonaws.com/ci-cd-demo-kojitechs-webapp:latest
        //         docker push 735972722491.dkr.ecr.us-east-1.amazonaws.com/ci-cd-demo-kojitechs-webapp:latest
        //         """
        //     }
        // }
    }
    post {
        success {
            slackSend botUser: true, channel: 'jenkins_notification', color: 'good',
            message: " with ${currentBuild.fullDisplayName} completed successfully.\nMore info ${env.BUILD_URL}\nLogin to ${params.ENVIRONMENT} and confirm.", 
            teamDomain: 'slack', tokenCredentialId: 'slack-token'
        }
        failure {
            slackSend botUser: true, channel: 'jenkins_notification', color: 'danger',
            message: "Build faild${currentBuild.fullDisplayName} failed.", 
            teamDomain: 'slack', tokenCredentialId: 'slack-token'
        }
        aborted {
            slackSend botUser: true, channel: 'jenkins_notification', color: 'hex',
            message: "Pipeline aborted due to a quality gate failure ${currentBuild.fullDisplayName} got aborted.\nMore Info ${env.BUILD_URL}", 
            teamDomain: 'slack', tokenCredentialId: 'slack-token'
        }
        cleanup {
            cleanWs()
        }
    }
}
