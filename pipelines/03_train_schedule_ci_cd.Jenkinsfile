// End-to-end CI/CD for a sample Gradle web app (train-schedule):
//   build -> Docker image -> push -> deploy to staging -> manual approval -> deploy to production
// Build runs on every branch. Image, push and deploys run on main only.
//
// Jenkins configuration this pipeline expects (nothing secret is stored in this file):
//   credentials:  dockerhub     (username + password)  registry login
//                 staging_ssh   (SSH key + username)   deploy user on the staging host
//                 prod_ssh      (SSH key + username)   deploy user on the production host
//   global env:   STAGING_HOST, PROD_HOST   host names or IPs of the target servers
//   agent:        Docker CLI installed; Docker is also needed on the target hosts
//   plugins:      SSH Credentials (for sshUserPrivateKey)
//
// Note: SSH host key checking is ON. Both target hosts must already be in the agent's
// known_hosts, for example: ssh-keyscan <host> >> ~/.ssh/known_hosts (run once as the agent user).

// Runs the new container on a remote host over SSH, with credentials kept out of the command line.
def deploy(String host, String credentialsId, String image) {
    withCredentials([sshUserPrivateKey(credentialsId: credentialsId, keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
        withEnv(["TARGET_HOST=${host}", "IMAGE=${image}"]) {
            sh '''
                ssh -i "$SSH_KEY" "$SSH_USER@$TARGET_HOST" "
                    docker pull $IMAGE &&
                    (docker stop train-schedule || true) &&
                    (docker rm train-schedule || true) &&
                    docker run --restart always --name train-schedule -p 8080:8080 -d $IMAGE
                "
            '''
        }
    }
}

pipeline {
    agent any

    environment {
        // Placeholder: replace "example" with your registry namespace (must match the dockerhub login).
        IMAGE_NAME = 'example/train-schedule'
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Build') {
            steps {
                sh './gradlew build --no-daemon'
                archiveArtifacts artifacts: 'dist/trainSchedule.zip'
            }
        }

        stage('Build and push Docker image') {
            when { branch 'main' }
            steps {
                sh 'docker image build -t "$IMAGE_NAME:$IMAGE_TAG" -t "$IMAGE_NAME:latest" -f Dockerfile .'
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'REGISTRY_USER', passwordVariable: 'REGISTRY_PASS')]) {
                    sh '''
                        echo "$REGISTRY_PASS" | docker login -u "$REGISTRY_USER" --password-stdin
                        docker push "$IMAGE_NAME:$IMAGE_TAG"
                        docker push "$IMAGE_NAME:latest"
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to staging') {
            when { branch 'main' }
            steps {
                deploy(env.STAGING_HOST, 'staging_ssh', "${IMAGE_NAME}:${IMAGE_TAG}")
            }
        }

        stage('Deploy to production') {
            when { branch 'main' }
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    input 'Does the staging environment look OK?'
                }
                milestone(1)
                deploy(env.PROD_HOST, 'prod_ssh', "${IMAGE_NAME}:${IMAGE_TAG}")
            }
        }
    }
}
