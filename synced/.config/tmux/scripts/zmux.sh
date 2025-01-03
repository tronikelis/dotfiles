#!/usr/bin/env bash

wd="$(_ZO_FZF_OPTS="--no-sort --layout=reverse --tmux 70%,50%" zoxide query -i)"

if [[ -z "$wd" ]]; then
    tmux display-message "empty selection"
    exit 0
fi

~/.config/tmux/scripts/upsert_session.sh "$wd"
