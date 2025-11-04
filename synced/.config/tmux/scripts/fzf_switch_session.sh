#!/bin/bash

fzf_preview="tmux ls -f \"#{m:\$(echo {} | fextr 1 1),#{session_name}}\""

session="$(
    tmux ls -F '#{session_name}|||#{session_last_attached}' \
    | sort -n -t '|' -k 4 -r \
    | column -t -s '|||' \
    | fzf --preview-window down,1 --preview "$fzf_preview" --no-sort --tmux \
    | fextr 1 1
)"

if [[ ! "$session" ]]; then
    tmux display-message "empty selection"
    exit 0
fi

tmux switch -t="$session"
