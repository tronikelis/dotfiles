#!/bin/bash

set -eo pipefail

wd="$(
    cd "$1" || exit
    pwd
)"
name="$2"

if [[ -z "$name" ]]; then
    name="$(basename "$(dirname "$wd")")/$(basename "$wd")"
fi

zoxide add "$wd"

name="$(printf "$name" | tr . _)"

if [[ -z $TMUX ]]; then
    tmux new-session -A -s "$name" -c "$wd"
    exit 0
fi

if ! tmux has-session -t="$name" 2>/dev/null; then
    tmux new-session -ds "$name" -c "$wd"
fi

tmux switch-client -t "$name"
