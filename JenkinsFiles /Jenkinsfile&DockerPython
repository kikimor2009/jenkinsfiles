pipeline {
    agent {
        docker {
            args '-u root'
            image 'python:alpine'
        }
    }
    stages {
        stage('Install git & checkout') {
            steps {
                sh 'apk add git'
                git 'https://github.com/linuxacademy/content-pipelines-cje-labs.git'
            }
        }
        stage('Requerments') {
            steps {
                sh 'pip install -r lab3_lab4/dog_pics_downloader/requirements.txt'
            }
        }
        stage('Execute') {
            steps {
                sh 'python lab3_lab4/dog_pics_downloader/dog_pic_get_class.py'
            }
        }
    }
    post {
      always {
        echo "Job execution complete"
      }
  cleanup {
    sh 'rm -rf ./*'
  }
  success {
    archiveArtifacts artifacts: '*.jpg', fingerprint: true, followSymlinks: false
  }
  unsuccessful {
    echo "ob execution failed. Please check output"
  }
}
}
