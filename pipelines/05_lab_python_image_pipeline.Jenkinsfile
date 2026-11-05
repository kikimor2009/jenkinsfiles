// End-to-end Python image pipeline (course lab):
//   fetch the lab code -> install dependencies -> download pictures -> watermark them -> archive
// Everything runs in one Docker container and one workspace, so the downloaded pictures
// are passed to the watermark step as plain files.
//
// Jenkins configuration this pipeline expects:
//   agent:     a node labelled "docker" with Docker installed
//   plugins:   Docker Pipeline
// No credentials are used: the lab repository is public.

pipeline {
    agent {
        docker {
            image 'python:3-slim'
            args '-u root'
            label 'docker'
        }
    }

    environment {
        LAB_REPO = 'https://github.com/linuxacademy/content-pipelines-cje-labs.git'
        LAB_DIR  = 'content-pipelines-cje-labs/lab3_lab4'
    }

    options {
        timestamps()
        timeout(time: 15, unit: 'MINUTES')
    }

    stages {
        stage('Prepare') {
            steps {
                sh 'apt-get update && apt-get install -y --no-install-recommends git'
                sh 'git clone --depth 1 "$LAB_REPO"'
            }
        }

        stage('Install dependencies') {
            steps {
                sh 'pip install -r "$LAB_DIR/dog_pics_downloader/requirements.txt"'
                sh 'pip install -r "$LAB_DIR/image_watermarker/requirements.txt"'
            }
        }

        stage('Download pictures') {
            steps {
                sh 'python "$LAB_DIR/dog_pics_downloader/dog_pic_get_class.py"'
            }
        }

        stage('Watermark pictures') {
            steps {
                sh 'python "$LAB_DIR/image_watermarker/watermark.py"'
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: '*.jpg', fingerprint: true
        }
        unsuccessful {
            echo 'Pipeline failed. Check the console output.'
        }
        cleanup {
            sh 'rm -rf content-pipelines-cje-labs *.jpg'
        }
    }
}
