#!/bin/bash
set -euo pipefail

# Usage: get_tag_name.sh [dev|stable|release]
# Prints major.minor.patch.commit based on the latest matching git tag.
#   dev     - same version as the latest tag
#   stable  - patch + 1
#   release - minor + 1, patch = 0

tag_prefix="uni_mob_"
tag_filter="${tag_prefix}1*"   # only major version 1 tags
build_branch="${1:-dev}"

full_tag=$(git for-each-ref --count=1 --sort=-v:refname --format='%(refname:short)' "refs/tags/$tag_filter")
if [ -z "$full_tag" ]; then
  echo "No tag matching '$tag_filter' found" >&2
  exit 3
fi

version=${full_tag#"$tag_prefix"}
IFS=. read -r major minor patch <<< "$version"
for part in "$major" "$minor" "$patch"; do
  if ! [[ "$part" =~ ^[0-9]+$ ]]; then
    echo "Tag '$full_tag' is not in '${tag_prefix}major.minor.patch' format" >&2
    exit 5
  fi
done

case "$build_branch" in
  release) minor=$((minor + 1)); patch=0 ;;
  stable)  patch=$((patch + 1)) ;;
  dev)     ;;
  *)
    echo "Unsupported branch '$build_branch'. Use dev, stable or release" >&2
    exit 4
    ;;
esac

git_commit_id=$(git show -s --format=%h)

echo "$major.$minor.$patch.$git_commit_id"
