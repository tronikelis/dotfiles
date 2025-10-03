#!/bin/bash

tmux switch -t="$(
    tmux ls -F '#{session_name}|||#{session_last_attached}' \
    | sort -n -t '|' -k 4 -r \
    | column -t -s '|||' \
    | fzf --no-sort --tmux \
    | awk '{for(i=1;i<NF;++i)print $i}'
)"
