#!/bin/bash

fzf_preview="tmux ls -f \"#{m:\$(echo {} | fextr 1 2),#{session_name}}\""

session="$(
    tmux ls -F '#{session_name}|||#{pane_current_command}|||#{session_last_attached}' \
    | sort -n -t '|' -k 7 -r \
    | column -t -s '|||' \
    | fzf --preview-window down,1 --preview "$fzf_preview" --no-sort --tmux \
    | fextr 1 2
)"

if [[ ! "$session" ]]; then
    tmux display-message "empty selection"
    exit 0
fi

tmux switch -t="$session"
