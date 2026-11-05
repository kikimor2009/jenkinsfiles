# jenkinsfiles

Jenkins pipeline practice: declarative Jenkinsfiles for Android/Gradle, Maven and Docker builds, SSH and container deploys, and course labs, plus small shell helpers that derive version numbers from git tags.

The pipelines use placeholder names for credentials, hosts and registries. Replace them with your own values before running anything. Each Jenkinsfile starts with a comment listing what it needs from Jenkins.

## Layout

```
JenkinsScripts/   helper scripts that compute a version string from git tags
pipelines/        Jenkinsfiles, numbered by topic
```

## Pipelines

| # | File | Topic |
|---|---|---|
| 01 | `01_android_gradle_build_publish_release.Jenkinsfile` | Android release: versioning from git tags, Gradle build, publish to local Maven, copy to a NAS over SSH, push a version tag, Telegram notification, trigger a downstream job. |
| 02 | `02_maven_build_deploy.Jenkinsfile` | Maven: GitHub push trigger, build with tests on every branch, separate deploy stage on `main`, build retention and timeout. |
| 03 | `03_train_schedule_ci_cd.Jenkinsfile` | End-to-end CI/CD for a Gradle web app: build, Docker image build and push, SSH deploy to staging, manual approval, SSH deploy to production. |
| 04 | `04_lab_gcc_build.Jenkinsfile` | Docker agent: compile a C program and archive the binary. |
| 05 | `05_lab_python_image_pipeline.Jenkinsfile` | Docker agent: install dependencies, download pictures, watermark them and archive the results in one pipeline. |

### What each one practices

- **01** - environment variables from a script, credentials, `sshagent`, Publish over SSH, tagging, `post` conditions, triggering other jobs.
- **02** - declarative `triggers` and `options`, `withMaven`, `when { branch }`.
- **03** - `when` conditions, `input` approval with timeout, `milestone`, credentials kept out of the command line, shared Groovy function, SSH key deploys.
- **04, 05** - Docker agents, `archiveArtifacts`, `post { cleanup }`.

### Setup notes

- `01` needs credentials `and_build`, `gitlab_push` and `telegram_chat_id`, an SSH server config `NAS_Bud`, and the version script at `./Jenkins/get_tag_name.sh` in the project repo. It passes the branch name to the script, so only `dev`, `stable` and `release` branches build. `dev` builds are not tagged and pass the commit hash as `-PvCommit`.
- `02` needs a Maven tool `Maven3.6` and a managed settings file (placeholder id `maven-settings`).
- `03` needs credentials `dockerhub`, `staging_ssh` and `prod_ssh`, and global variables `STAGING_HOST` and `PROD_HOST`. Replace `example` in `IMAGE_NAME` with your registry namespace.
- `04` and `05` clone the public `linuxacademy/content-pipelines-cje-labs` repository and need a node with Docker. `05` runs in `python:3-slim`; pinned dependencies in the lab may need extra build packages.
- SSH host key checking is on in `01` and `03`. Add the target hosts to the agent's `known_hosts` first, for example `ssh-keyscan <host> >> ~/.ssh/known_hosts`.

## JenkinsScripts

Both scripts must run inside a git checkout. They print the result to stdout and write errors to stderr with a non-zero exit code.

### `get_tag_name.sh [dev|stable|release]`

Finds the latest `uni_mob_1*` tag (version sort) and prints `major.minor.patch.commit`. The tag must look like `uni_mob_<major>.<minor>.<patch>`.

| Argument | Result |
|---|---|
| `dev` (default) | same version as the latest tag |
| `stable` | patch + 1 |
| `release` | minor + 1, patch reset to 0 |

Exit codes: `3` no matching tag, `4` unsupported branch, `5` tag not in `major.minor.patch` format.

### `get_last_id.sh`

Finds the latest `build_id_<number>` tag and prints `<next id>.<short commit>`. Starts at `1` when no tag exists.

Exit codes: `4` tag suffix is not a number.
