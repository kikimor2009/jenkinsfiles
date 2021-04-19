pipeline {
  agent { label 'Android' }
  stages {
    stage("Build") {
      steps {
        withCredentials([string(credentialsId: 'and_build', variable: 'TOKEN')]) {
          sh """chmod -R 755 ./*
                ./gradlew --no-daemon -PgitBranch=${BRANCH_NAME} -Ptoken=${TOKEN} publishToMavenLocal
              """
          }
      }
    }
  }
  post {
    success {
      build( wait: false, job: "Android/GeoMaps-GitLab/${BRANCH_NAME}")
    }
  }
}
