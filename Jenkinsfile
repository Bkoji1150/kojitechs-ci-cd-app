pipeline {
    agent any
   
    tools {
        maven 'mvn'
    } 
    parameters { 
        string(name: 'REPO_NAME', description: 'PROVIDER THE NAME OF ECR REPO', defaultValue: 'ci-cd-demo-kojitechs-webapp',  trim: true)
        string(name: 'REPO_URL', description: 'PROVIDER THE NAME OF DOCKERHUB/ECR URL', defaultValue: '735972722491.dkr.ecr.us-east-1.amazonaws.com',  trim: true)
        string(name: 'AWS_REGION', description: 'AWS REGION', defaultValue: 'us-east-1')
        string(name: 'Nexus_Sever', description: 'Provide server endpoint of nexus', defaultValue: '44.211.144.210:8081')
        choice(name: 'ACTION', choices: ['RELEASE', 'RELEASE', 'NO'], description: 'Select action, BECAREFUL IF YOU SELECT DESTROY TO PROD')
    } 
    environment {
        tag = sh(returnStdout: true, script: "git rev-parse --short=10 HEAD").trim()
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "${params.Nexus_Sever}"
        NEXUS_REPOSITORY = "kojitechs-app-release"
        NEXUS_SNAPSHOT_REPO = "kojitechs-app-snapshot"
        NEXUS_CREDENTIAL_ID = "Nexus-login"
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
                    def pom = readMavenPom file: 'pom.xml'

                    def nexusRepo = pom.version.endsWith("SNAPSHOT") ? NEXUS_SNAPSHOT_REPO : NEXUS_REPOSITORY
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        nexusArtifactUploader artifacts: 
                        [
                            [
                                artifactId: pom.artifactId,
                                classifier: '', 
                                file: artifactPath, 
                                type: pom.packaging
                            ]
                        ], 
                            credentialsId: NEXUS_CREDENTIAL_ID, 
                            groupId: pom.groupId, 
                            nexusUrl: NEXUS_URL, 
                            nexusVersion: NEXUS_VERSION, 
                            protocol:  nexusRepo, 
                            repository: NEXUS_REPOSITORY,
                            version: pom.version
                    }else {
                        error "*** File: ${artifactPath}, could not be found";
                    }    
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
                slackSend botUser: true, channel: 'jenkins_notification', color: 'danger',
                message: "Build faild${currentBuild.fullDisplayName} failed.\nSonarQube Report: ${sonarScanResults.status}", 
                teamDomain: 'slack', tokenCredentialId: 'slack-token'
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
