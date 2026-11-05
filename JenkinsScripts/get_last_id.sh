#!/bin/bash
set -euo pipefail

template_to_find="build_id_"

# No pipe to head, so pipefail can't trip on SIGPIPE.
full_version=$(git for-each-ref --count=1 --sort=-v:refname --format='%(refname:short)' "refs/tags/$template_to_find*")

if [ -z "$full_version" ]; then
  id=1
else
  id=${full_version#"$template_to_find"}
  if ! [[ "$id" =~ ^[0-9]+$ ]]; then
    echo "Tag '$full_version' does not end with a number" >&2
    exit 4
  fi
  id=$((id + 1))
fi

git_commit_id=$(git show -s --format=%h)

echo "$id.$git_commit_id"
