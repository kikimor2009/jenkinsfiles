// Course lab: compile a small C program in a Docker container and archive the binary.
//
// Jenkins configuration this pipeline expects:
//   agent:     any node with Docker installed
//   plugins:   Docker Pipeline
// No credentials are used: the lab repository is public.

pipeline {
    agent {
        docker {
            image 'linuxacademycontent/jenkins_pipelines'
        }
    }

    options {
        timestamps()
        timeout(time: 10, unit: 'MINUTES')
    }

    stages {
        stage('Preparation') {
            steps {
                sh 'git clone --depth 1 https://github.com/linuxacademy/content-pipelines-cje-labs.git'
            }
        }

        stage('Build') {
            steps {
                sh 'gcc --std=c99 -o mario content-pipelines-cje-labs/lab1_lab2/mario.c'
            }
        }

        stage('Archiving') {
            steps {
                archiveArtifacts artifacts: 'mario', fingerprint: true, onlyIfSuccessful: true
            }
        }
    }

    post {
        cleanup {
            // The workspace persists between builds; without this the next clone fails.
            sh 'rm -rf content-pipelines-cje-labs mario'
        }
    }
}
