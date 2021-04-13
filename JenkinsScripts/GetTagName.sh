#!/bin/bash -xe

#path_to_repo="$WORKSPACE/UA"
#filename="ENV_VARS.txt"
template_to_find="uni_mob_1"
build_branch=dev #$branch

#cd "$path_to_repo" || exit 2

full_version=$(git tag -l "$template_to_find"* --sort=-v:refname | head -n1)
if [ -z "$full_version" ]; then
  #echo "Can't load current software version. Check your template_to_find"
  exit 3
#else
#  echo "Git soft version is $full_version."
fi

git_major_version=$(echo "$full_version" | grep -o '[0-9].*' | cut -d '.' -f1)
git_minor_version=$(echo "$full_version" | grep -o '[0-9].*' | cut -d '.' -f2)
git_patch_version=$(echo "$full_version" | grep -o '[0-9].*' | cut -d '.' -f3)
git_commit_id=$(git show -s --format=%h)

if [ "$build_branch" == "release" ]; then
  major=$git_major_version
  minor=$((git_minor_version + 1))
  patch=0
elif [ "$build_branch" == "stable" ]; then
  major=$git_major_version
  minor=$git_minor_version
  patch=$((git_patch_version + 1))
elif [ "$build_branch" == "dev" ]; then
  major=$git_major_version
  minor=$git_minor_version
  patch=$git_patch_version
else
  #echo "Supported branches are dev, stable, release. Check your build_branch"
  exit 4
fi

#echo "MAJOR=$major" > "$path_to_repo"/"$filename"
#echo "MINOR=$minor" >> "$path_to_repo"/"$filename"
#echo "PATCH=$patch" >> "$path_to_repo"/"$filename"
#echo "COMMIT=$git_commit_id" >> "$path_to_repo"/"$filename"
#echo "Current build version will be $major.$minor.$patch-$git_commit_id"

echo "$major.$minor.$patch.$git_commit_id"
