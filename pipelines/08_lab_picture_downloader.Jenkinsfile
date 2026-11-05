pipeline{
    agent {
        docker {
            image 'python:alpine'
            args '-u root'
            label 'docker1'
        }
    }
    stages{
        stage('prep'){
            steps{
                sh 'apk add git'
            }
        }
        stage('fetch'){
            steps{
            sh 'git clone https://github.com/linuxacademy/content-pipelines-cje-labs.git'
            }
        }
        stage('add'){
            steps{
                sh 'pip install -r content-pipelines-cje-labs/lab3_lab4/dog_pics_downloader/requirements.txt'
            }
        }
        stage('execute'){
            steps{
                sh 'python content-pipelines-cje-labs/lab3_lab4/dog_pics_downloader/dog_pic_get_class.py'
            }
        }
    }
    post{
        always{
            echo "execution complete"
        }
        success{
            archiveArtifacts artifacts: '*.jpg'
        }
        cleanup{
            sh 'rm -rf content-pipelines-cje-labs'
        }
    }
}
