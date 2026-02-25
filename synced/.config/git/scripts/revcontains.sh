#!/bin/bash

set -eu

if [[ -t 0 ]]; then
    echo "stdin is tty, expected patch data" >&2
    exit 2
fi

target="$1"
patch_id="$(git patch-id --stable | awk '{print $1}')"

parallel_command="$(
cat << "EOF"
    if [[ "$(git show "$1" | git patch-id --stable | awk '{print $1}')" == "$0" ]]; then
        echo "$1"
        exit 255
    fi
    exit 0
EOF
)"

if ! git rev-list "$target" | xargs -r -L1 -P$(nproc) bash -c "$parallel_command" "$patch_id" 2>/dev/null; then
    exit 0
fi

exit 1
