#!/bin/bash

name="${1-scratch}"

dir="/var/tmp/tmux"
mkdir -p "$dir" || exit

if ! tmux has-session -t="$name" 2>/dev/null; then
    tmux new-session -ds "$name" -c "$(mktemp -d --suffix=.scratch -p "$dir")"
fi

tmux switch-client -t "$name"
