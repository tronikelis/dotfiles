#!/bin/bash

name="${1-scratch}"

if ! tmux has-session -t="$name" 2>/dev/null; then
    dir="/var/tmp/tmux/$(openssl rand -hex 4)"
    mkdir -p "$dir" || exit

    tmux new-session -ds "$name" -c "$dir"
fi

tmux switch-client -t "$name"
