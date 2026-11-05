# jenkinsfiles

An archive of early Jenkins CI/CD work: declarative pipelines for Android/Gradle, Maven and Docker builds, SSH deploys, and a few course labs, plus the git-tag helper scripts they used for versioning.

This is a personal archive, not a maintained project. The pipelines reference credentials, agent labels, internal hosts and Jenkins jobs that no longer exist, so they will not run as-is. Treat them as reference examples.

## Repository layout

```
JenkinsScripts/   helper scripts that compute a version string from git tags
pipelines/        Jenkinsfiles, numbered by topic
```

## JenkinsScripts

Both scripts must run inside a git checkout, print their result to stdout, and write errors to stderr with a non-zero exit code.

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

## pipelines

| # | File | What it does |
|---|---|---|
| 01 | `01_android_gradle_build_publish_release.Jenkinsfile` | Android release pipeline. Versions from git tags, builds the release APK, runs `publishToMavenLocal`, copies the APK to a NAS over SSH, pushes a new `uni_mob_*` tag, sends a Telegram notification, and triggers the downstream Maps job (`Android/Maps/<branch>`) on success. |
| 02 | `02_maven_build_deploy.Jenkinsfile` | Maven `package` then `deploy`, triggered by a GitHub push, with build retention and a timeout. |
| 03 | `03_gradle_ssh_stage_prod_deploy.Jenkinsfile` | Gradle build, SSH deploy to staging, manual approval, then SSH deploy to production (`master` only). |
| 04 | `04_gradle_docker_ssh_deploy.Jenkinsfile` | Gradle build, Docker image build and push, then SSH deploy of the container (`master` only). |
| 05 | `05_lab_gradle_train_schedule.Jenkinsfile` | Course lab: checkout and Gradle build of a sample train-schedule app. |
| 06 | `06_lab_gcc_build.Jenkinsfile` | Course lab: compile a small C program in a Docker agent and archive the binary. |
| 07 | `07_lab_docker_python.Jenkinsfile` | Course lab: run the dog-pictures downloader in a `python:alpine` Docker agent. |
| 08 | `08_lab_picture_downloader.Jenkinsfile` | Same dog-pictures lab as 07, written differently (clone step, dedicated agent label). |
| 09 | `09_lab_image_watermarker.Jenkinsfile` | Course lab: watermark images fetched from another job's artifacts, on a CentOS 7 agent. |

Pipelines 05-09 are course labs and clone sample repositories from GitHub (`linuxacademy/content-pipelines-cje-labs`, and a train-schedule app).

## Known issues

- `01` expects the version script at `./Jenkins/get_tag_name.sh` inside the Android repo (copy `JenkinsScripts/get_tag_name.sh` there). It passes the Jenkins branch name, so only `dev`, `stable` and `release` branches build; any other branch fails with exit code 4.
- `01` reads its secrets from Jenkins credentials (`and_build`, `gitlab_push`, `telegram_chat_id`); the header comment in the file lists everything it expects. `dev` builds are not tagged and get the commit hash as `-PvCommit`. Host key checking is on, so the Git host must be in the agent's `known_hosts`.
- `04` logs in to Docker Hub with `docker login -p`, which exposes the password in the process list and build log. `stdin` login is the safer option.
- `04` turns off SSH host key checking (`StrictHostKeyChecking=no`) and passes the password to `sshpass` on the command line. Do not copy that into real pipelines.
- `07` and `08` duplicate each other, and `07` has typos in its stage and message strings.
