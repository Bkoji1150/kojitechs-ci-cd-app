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
    }
}
