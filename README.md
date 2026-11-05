# jenkinsfiles

Old Jenkins pipeline scripts and helper shell scripts from when I was a junior engineer. This is a personal archive of early CI/CD work: course labs, Android and Gradle builds, a Maven job, and a few deploy pipelines. Nothing here is maintained, and the jobs are not meant to be reused as-is.

## Layout

### JenkinsScripts

Shell helpers that read git tags and print a version string.

- `get_tag_name.sh` — latest tag matching a prefix, printed as `major.minor.patch.commit`. The branch decides whether minor or patch is bumped.
- `get_last_id.sh` — latest `build_id_*` tag, printed as the next id plus the short commit hash.

### pipelines

Declarative Jenkins pipelines.

- `01_android_gradle_release.Jenkinsfile` — Android Gradle release build. Copies the APK to a NAS, pushes a git tag, and sends a Telegram message.
- `02_android_gradle_publish_maven.Jenkinsfile` — Android Gradle publish to the local Maven repo, then triggers a follow-up job.
- `03_maven_build_deploy.Jenkinsfile` — Maven package and deploy.
- `04_gradle_ssh_stage_prod_deploy.Jenkinsfile` — Gradle build, then SSH deploy to staging and production, with a manual check before production.
- `05_gradle_docker_ssh_deploy.Jenkinsfile` — Gradle build, Docker image push, then SSH deploy of the container.
- `06_lab_gradle_train_schedule.Jenkinsfile` — checkout and Gradle build of a sample train-schedule app.
- `07_lab_gcc_build.Jenkinsfile` — clone a lab repo and compile a small C program.
- `08_lab_docker_python.Jenkinsfile` — Python lab job running in a Docker agent.
- `09_lab_picture_downloader.Jenkinsfile` and `10_lab_image_watermarker.Jenkinsfile` — lab pipelines for a picture downloader and an image watermarker.
