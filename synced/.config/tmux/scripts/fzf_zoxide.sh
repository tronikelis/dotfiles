#!/bin/bash

fzf_preview="ls -LCp --color=always \"\$(echo {} | fextr 2 0)\""

export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --preview-window down,5 --preview \"$fzf_preview\" --no-sort --layout=reverse --tmux 70%,50%"

wd="$(zoxide query -i)"

if [[ -z "$wd" ]]; then
    tmux display-message "empty selection"
    exit 0
fi

~/.config/tmux/scripts/upsert_session.sh "$wd"
