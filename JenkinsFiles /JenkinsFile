def (MAJOR, MINOR, PATCH, COMMIT) = new String[4]

pipeline {
  agent { label 'Android' }
  environment {
        TAG = sh(script:'./Jenkins/GetTagName.sh', returnStdout: true).trim()
  }
  stages {
    stage ("Prepare Env") {
      steps {
        script {
          VARS = env.TAG.split("\\.")
          MAJOR = VARS[0]
          MINOR = VARS[1]
          PATCH = VARS[2]
          COMMIT = VARS[3]
        }
      }
    }
    stage("Build") {
      steps {
        withCredentials([string(credentialsId: 'and_build', variable: 'TOKEN')]) {
          sh """chmod -R 755 ./*
                ./gradlew --no-daemon -PvMajor=${MAJOR} -PvMinor=${MINOR} -PvPatch=${PATCH} -PmapsGitBranch=${BRANCH_NAME} -Ptoken=${TOKEN} assembleRelease
              """
        }
      }
    }
    stage("Copy to NAS") {
      steps {
        sshPublisher(publishers: [sshPublisherDesc(configName: 'NAS_Bud', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: 'Android/UniCat/Stable', remoteDirectorySDF: false, removePrefix: 'app/build/outputs/apk/release/', sourceFiles: 'app/build/outputs/apk/release/UniCat_*')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])
      }
    }
    stage("Push Tags") {
      steps {
        sshagent(['gitlab_pull']) {
                    sh("""
                        #!/usr/bin/env bash
                        export GIT_SSH_COMMAND="ssh -oStrictHostKeyChecking=no"
			                  git tag uni_mob_${MAJOR}.${MINOR}.${PATCH}
                        git push origin --tags
                     """)
         }
       }
     }
  }
  post {
    always {
      telegramSend(message: "Branch - $BRANCH_NAME Result - ${currentBuild.currentResult} Build URL - $BUILD_URL", chatId: -468000522)
    }
  }
}
