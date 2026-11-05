pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/kikimor2009/cicd-pipeline-train-schedule-pipelines.git']]])
            }
        }
        stage('Build') {
            steps {
                sh './gradlew build --no-daemon'
            }
        }
    }
    post {
        success {
            archiveArtifacts artifacts: 'dist/trainSchedule.zip', fingerprint: true, onlyIfSuccessful: true
        }
    }
}
