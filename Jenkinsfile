pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                echo 'git clone is happening'
            }
        }
        stage('mvn Compile and Build') {
            steps {
                echo 'mvn Compile and Build'
            }
        }
        stage('Unit Tests Execution') {
            steps {
                echo 'mvn Compile and Build'
            }
        }
        stage('Static Code analysis with Sonarqube') {
            steps {
                echo 'mvn sonar:sonar'
            }
        }
        stage('Waiting for quality Gate Result') {
            steps {
                echo 'timeout:3 unit 3 && return says ok esle abort'
            }
        }
        stage('Docker build && tag image') {
            steps {
                sh"""
                docker build -t kojitechstags-register .
                aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 735972722491.dkr.ecr.us-east-1.amazonaws.com
                docker tag kojitechstags-register:latest 735972722491.dkr.ecr.us-east-1.amazonaws.com/ci-cd-demo-kojitechs-webapp:latest
                docker push 735972722491.dkr.ecr.us-east-1.amazonaws.com/ci-cd-demo-kojitechs-webapp:latest
                """
            }
        }
    }
}
