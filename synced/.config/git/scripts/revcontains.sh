#!/bin/bash

set -eu

function patch_id() {
    git patch-id --stable | awk '{print $1}'
}

if [[ -t 0 ]]; then
    echo "stdin is tty, expected patch data" >&2
    exit 2
fi

target="$1"
patch_id="$(patch_id)"


for commit in $(git rev-list "$target"); do
    if [[ "$(git show "$commit" | patch_id)" == "$patch_id" ]]; then
        echo "$commit"
        exit 0
    fi
done

echo "not found in $target" >&2
exit 1
