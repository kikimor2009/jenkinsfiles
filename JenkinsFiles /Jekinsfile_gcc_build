pipeline {
    agent {
        docker {
            image 'linuxacademycontent/jenkins_pipelines'
        }
    }

    stages {
        stage('Preparation') {
            steps {
                sh 'git clone https://github.com/linuxacademy/content-pipelines-cje-labs.git'
            }
        }

        stage('Build') {
            steps {
                sh label: '', script: 'gcc --std=c99 -o mario content-pipelines-cje-labs/lab1_lab2/mario.c'
            }
        }

        stage('Archiving') {
            steps {
                archiveArtifacts artifacts: 'mario', fingerprint: true, followSymlinks: false, onlyIfSuccessful: true
            }
        }
    }
}
