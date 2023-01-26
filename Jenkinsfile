pipeline {
    agent any
   
    tools {
        maven 'mvn'
    } 
    parameters { 
        string(name: 'REPO_NAME', description: 'PROVIDER THE NAME OF ECR REPO', defaultValue: 'ci-cd-demo-kojitechs-webapp',  trim: true)
        string(name: 'REPO_URL', description: 'PROVIDER THE NAME OF DOCKERHUB/ECR URL', defaultValue: '735972722491.dkr.ecr.us-east-1.amazonaws.com',  trim: true)
        string(name: 'AWS_REGION', description: 'AWS REGION', defaultValue: 'us-east-1')
        choice(name: 'ACTION', choices: ['RELEASE', 'RELEASE', 'NO'], description: 'Select action, BECAREFUL IF YOU SELECT DESTROY TO PROD')
    } 
    environment {
        tag = sh(returnStdout: true, script: "git rev-parse --short=10 HEAD").trim()
    }  
    stages {
        stage('mvn Compile and Build') {
          steps {
            sh"""mvn clean install package &&
                  mvn surefire:test
              """    
            }
        }
        stage('Static Code analysis with Sonarqube') {
            steps {
            script{    
                withSonarQubeEnv(installationName: 'sonar') {
                    sh 'mvn sonar:sonar'
                }   
                timeout(time: 1, unit: 'HOURS') {
                    def sonarScanResults = waitForQualityGate()
                    if (sonarScanResults.status != 'OK') {
                        error "Pipeline aborted due to quality gate failure: ${sonarScanResults.status}"
                    }
                }
            }
        }
        }
        stage('Upload Artifact to Nexus') {
            steps {      
                sh"""
                    pwd && ls -al
                    docker build -t ${params.REPO_NAME} .
                  """ 
              }
        }
        stage('Docker Build Image') {
            steps {      
                 script {
                    def readPomVersion = readMavenPom file: 'pom.xml'
                    nexusArtifactUploader artifacts: 
                    [
                        [
                            artifactId: 'usermgmt-webapp', 
                            classifier: '', file: 'target/usermgmt-webapp.war', 
                            type: 'war'
                        ]
                    ], 
                        credentialsId: 'Nexus-login', 
                        groupId: 'com.kojitechs.restservices', 
                        nexusUrl: '44.211.144.210:8081', 
                        nexusVersion: 'nexus3', 
                        protocol: 'http', repository: 
                        'kojitechs-app-release',
                        version: "${readPomVersion.version}"
                }
            }    
        }
        stage('Confirm your action') {
                steps {
                    script {
                        timeout(time: 5, unit: 'MINUTES') {
                        def userInput = input(id: 'confirm', message: params.ACTION + '?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Release image version?', name: 'confirm'] ])
                    }
                }
            }  
        } 
        stage('Release latest image version to ECR') {
            steps {
                sh 'echo "continue"'
                    script{  
                        if (params.ACTION == "RELEASE"){
                            script {
                                try {
                                    sh """
                                        aws ecr get-login-password  --region ${params.AWS_REGION} | docker login --username AWS --password-stdin ${params.REPO_URL}                 
                                        docker tag ${params.REPO_NAME}:latest ${params.REPO_URL}/${params.REPO_NAME}:${tag}
                                        docker push ${params.REPO_URL}/${params.REPO_NAME}:${tag}
                                        docker tag ${params.REPO_URL}/${params.REPO_NAME}:${tag} ${params.REPO_URL}/${params.REPO_NAME}:latest
                                        docker push ${params.REPO_URL}/${params.REPO_NAME}:latest
                                    """
                                } catch (Exception e){
                                echo "Error occurred: ${e}"
                                sh "An eception occured"
                                }
                          }
                      }
                      else {
                        sh"""
                            echo  "llego" + params.ACTION
                            image release would not be deployed!"
                        """ 
                        } 
                    }
                }
            }
        }
        post {
            success {
                slackSend botUser: true, channel: 'jenkins_notification', color: 'good',
                message: " with ${currentBuild.fullDisplayName} completed successfully.\nMore info ${env.BUILD_URL}\nLogin to ${params.ENVIRONMENT} and confirm.", 
                teamDomain: 'slack', tokenCredentialId: 'slack-token'
            }
            failure {
                script {
                        if (sonarScanResults != null) {
                            slackSend botUser: true, channel: 'jenkins_notification', color: 'danger',
                            message: "Build faild${currentBuild.fullDisplayName} failed.\nSonarQube Report: ${sonarScanResults}", 
                            teamDomain: 'slack', tokenCredentialId: 'slack-token'
                    }   else {
                            echo "Job '${currentBuild.fullDisplayName}' failed..."
                    } 
                }
            }
            aborted {
                slackSend botUser: true, channel: 'jenkins_notification', color: 'hex',
                message: "Pipeline aborted due to quality gate failure: ${sonarScanResults.status}.\nMore Info ${env.BUILD_URL}", 
                teamDomain: 'slack', tokenCredentialId: 'slack-token'
            }
            cleanup {
                cleanWs()
            }
        }
}
