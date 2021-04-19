pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh './gradlew build --no-daemon'
                archiveArtifacts artifacts: 'dist/trainSchedule.zip'
            }
        }
        stage('Build Docker Image') {
          when {
              branch 'master'
          }
          steps {
              sh 'docker image build -t kikimor2009/train-schedule -f Dockerfile .'
          }
        }
        stage('Push Docker Image') {
            steps {
              withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'pass', usernameVariable: 'usr')]) {
                sh """docker login -u ${usr} -p ${pass}
                      docker push kikimor2009/train-schedule:latest
                    """
              }
            }
        }
        stage('DeployToProduction') {
            when {
              branch 'master'
            }
            steps {
              milestone(1)
              withCredentials([usernamePassword(credentialsId: 'prod', passwordVariable: 'pass', usernameVariable: 'user')]) {
                sh "sshpass -p '$pass' -v ssh -o StrictHostKeyChecking=no ${user}@${env.prod_ip} 'docker pull kikimor2009/train-schedule:latest; \
                      docker stop train-schedule || echo no ct; docker rm train-schedule || echo no ct; \
                      docker run --restart always --name train-schedule -p 8080:8080 -d kikimor2009/train-schedule:latest'"
              }
            }
        }
    }
}
