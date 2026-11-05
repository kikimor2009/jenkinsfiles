// Maven build and deploy, triggered by a GitHub push.
//   Build  - compile, run tests, package (every branch)
//   Deploy - publish to the Maven repository (main branch only)
//
// Jenkins configuration this pipeline expects:
//   tools:     Maven3.6 (Global Tool Configuration)
//   config:    Maven settings.xml with the repository credentials, as a Managed File
//              (Config File Provider plugin).
//   plugins:   Pipeline Maven Integration, AnsiColor, Timestamper, GitHub

pipeline {
    agent { label 'jenkinscloud-default' }

    environment {
        // Placeholder: replace with the id of your Managed settings.xml file
        // (Manage Jenkins > Managed files). Jenkins generates a UUID by default; use a
        // readable id instead of committing the UUID.
        MAVEN_SETTINGS_ID = 'maven-settings'
    }

    triggers {
        githubPush()
    }

    options {
        ansiColor('xterm')
        timestamps()
        buildDiscarder logRotator(artifactDaysToKeepStr: '30', artifactNumToKeepStr: '10', daysToKeepStr: '30', numToKeepStr: '20')
        timeout(time: 15, unit: 'MINUTES')
    }

    stages {
        stage('Build') {
            steps {
                withMaven(maven: 'Maven3.6', mavenSettingsConfig: env.MAVEN_SETTINGS_ID) {
                    sh 'mvn -B package'
                }
            }
        }

        stage('Deploy') {
            when { branch 'main' }
            steps {
                withMaven(maven: 'Maven3.6', mavenSettingsConfig: env.MAVEN_SETTINGS_ID) {
                    // Tests already ran in Build, so they are skipped here.
                    sh 'mvn -B -DskipTests deploy'
                }
            }
        }
    }
}
