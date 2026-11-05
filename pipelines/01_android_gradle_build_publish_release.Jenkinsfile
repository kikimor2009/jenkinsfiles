// Android release pipeline:
// version from git tags -> release APK -> publish to local Maven -> copy APK to NAS
// -> push version tag -> notify, and trigger the downstream Maps job on success.
//
// Jenkins configuration this pipeline expects (nothing secret is stored in this file):
//   credentials:  and_build            (secret text)  Gradle token
//                 gitlab_push          (SSH key)      push access for tags
//                 telegram_chat_id     (secret text)  Telegram chat id
//   SSH server:   NAS_Bud              (Publish over SSH config)
//   plugins:      Telegram Notifications, Publish Over SSH, SSH Agent
//
// Versioning: stable and release builds create a new uni_mob_X.Y.Z tag. dev builds are not
// tagged (the tag would already exist); they reuse the latest version and are told apart by
// the commit hash, passed to Gradle as -PvCommit.
//
// Note: host key checking is ON. The Git host must already be in the agent's known_hosts,
// for example: ssh-keyscan <git-host> >> ~/.ssh/known_hosts (run once as the agent user).

def (MAJOR, MINOR, PATCH, COMMIT) = new String[4]

pipeline {
  agent { label 'Android' }
  environment {
    TELEGRAM_CHAT_ID = credentials('telegram_chat_id')
    // Prints MAJOR.MINOR.PATCH.COMMIT; the branch (dev|stable|release) decides which part is bumped.
    TAG = sh(script: "./Jenkins/get_tag_name.sh '${BRANCH_NAME}'", returnStdout: true).trim()
  }
  stages {
    stage("Prepare Env") {
      steps {
        script {
          def vars = env.TAG.split("\\.")
          MAJOR = vars[0]
          MINOR = vars[1]
          PATCH = vars[2]
          COMMIT = vars[3]
        }
      }
    }
    stage("Build") {
      steps {
        // The token is passed as an environment variable (Gradle reads ORG_GRADLE_PROJECT_<name>
        // as -P<name>), so it never appears in the command line or in Groovy string interpolation.
        withCredentials([string(credentialsId: 'and_build', variable: 'ORG_GRADLE_PROJECT_token')]) {
          sh """chmod +x ./gradlew
                ./gradlew --no-daemon -PvMajor=${MAJOR} -PvMinor=${MINOR} -PvPatch=${PATCH} -PvCommit=${COMMIT} -PmapsGitBranch='${BRANCH_NAME}' assembleRelease
              """
        }
      }
    }
    stage("Publish to Maven Local") {
      steps {
        withCredentials([string(credentialsId: 'and_build', variable: 'ORG_GRADLE_PROJECT_token')]) {
          sh "./gradlew --no-daemon -PgitBranch='${BRANCH_NAME}' publishToMavenLocal"
        }
      }
    }
    stage("Copy to NAS") {
      steps {
        sshPublisher(publishers: [sshPublisherDesc(configName: 'NAS_Bud', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: 'Android/UniCat/Stable', remoteDirectorySDF: false, removePrefix: 'app/build/outputs/apk/release/', sourceFiles: 'app/build/outputs/apk/release/UniCat_*')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])
      }
    }
    stage("Push Tags") {
      when { not { branch 'dev' } }
      steps {
        sshagent(['gitlab_push']) {
          sh """
            git tag uni_mob_${MAJOR}.${MINOR}.${PATCH}
            git push origin uni_mob_${MAJOR}.${MINOR}.${PATCH}
          """
        }
      }
    }
  }
  post {
    always {
      telegramSend(message: "Branch - ${BRANCH_NAME} Result - ${currentBuild.currentResult} Build URL - ${BUILD_URL}", chatId: env.TELEGRAM_CHAT_ID)
    }
    success {
      build(wait: false, job: "Android/Maps/${BRANCH_NAME}")
    }
  }
}
