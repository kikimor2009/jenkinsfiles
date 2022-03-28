properties([pipelineTriggers([githubPush()])])

pipeline {
    agent { label 'jenkinscloud-default' }
    
    options {
        ansiColor('xterm')
        timestamps()
        buildDiscarder logRotator(artifactDaysToKeepStr: '30', artifactNumToKeepStr: '10', daysToKeepStr: '30', numToKeepStr: '20')
        timeout(15)
    }

    stages {
        stage('Build') {
            steps {
                withMaven(maven: 'Maven3.6', mavenSettingsConfig: '8284e31f-eacf-43e3-9421-b7de5acd7066') {
                    sh "mvn -DskipTests package"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                withMaven(maven: 'Maven3.6', mavenSettingsConfig: '8284e31f-eacf-43e3-9421-b7de5acd7066') {
                    sh "mvn -DskipTests deploy"
                }
            }
        }
    }
}
