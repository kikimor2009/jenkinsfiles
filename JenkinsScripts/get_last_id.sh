#!/bin/bash -e

template_to_find="build_id_"

full_version=$(git tag -l "$template_to_find"* --sort=-v:refname | head -n1)
if [ -z "$full_version" ]; then
  exit 3
fi

id=$(echo "$full_version" | grep -o '[0-9].*')
id=$((id + 1))

git_commit_id=$(git show -s --format=%h)

echo "$id.$git_commit_id"
