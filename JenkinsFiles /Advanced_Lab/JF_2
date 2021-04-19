pipeline{
    agent {
        docker{ image 'centos:7'
                args '-u root'
                label 'docker2'
        }
    }

    stages{
        stage('dependencies'){
            steps{
                sh 'yum -y install python3 python3-pip zlib-devel gcc git'
            }
    }
        stage('copyart'){
            steps{
                copyArtifacts(projectName: 'pipeline1', flatten: true)
            }
        }
        stage('fetch'){
            steps{
                sh 'git clone https://github.com/linuxacademy/content-pipelines-cje-labs.git'
            }
        }
        stage('install'){
            steps{
                sh 'pip3 install -r content-pipelines-cje-labs/lab3_lab4/image_watermarker/requirements.txt'
            }
        }
        stage('exec'){
            steps{
                sh 'python3 content-pipelines-cje-labs/lab3_lab4/image_watermarker/watermark.py'
            }
        }
    }
    post{
        success{
            archiveArtifacts artifacts: '*watermarked.jpg'
        }
        cleanup{
            sh 'rm -rf content-pipelines-cje-labs *.jpg'
        }
    }
}
