pipeline {
    agent any

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
                sh 'mvn surefire:test'
            }
        }
        // stage('Static Code analysis with Sonarqube') {
        //     steps {
        //         echo 'mvn sonar:sonar'
        //     }
        // }
        // stage('Waiting for quality Gate Result') {
        //     steps {
        //         echo 'timeout:3 unit 3 && return says ok esle abort'
        //     }
        // }
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
}
