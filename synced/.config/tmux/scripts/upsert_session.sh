#!/usr/bin/env bash

wd="$1"
name="$2"

if [[ -z "$name" ]]; then
    name="$(basename "$wd" | tr . _)"
fi

if [[ -z $TMUX ]]; then
    tmux new-session -A -s "$name" -c "$wd"
    exit 0
fi

if ! tmux has-session -t="$name" 2>/dev/null; then
    tmux new-session -ds "$name" -c "$wd"
fi

tmux switch-client -t "$name"
