#!/bin/bash

set -eu

function trim() {
    echo "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

filename="${1%:*}"
line="${1#*:}"

filename="$(trim "$filename")"
line="$(trim "$line")"

current_session="$(tmux display-message -p '#{session_id}')"
pane_window="$(
    tmux list-panes -a \
        -f "#{&&:#{==:#{session_id},$current_session},#{==:#{pane_current_command},$EDITOR}}" \
        -F '#{pane_id} #{window_id}'
)"

pane="$(echo "$pane_window" | awk '{print $1}')"
window="$(echo "$pane_window" | awk '{print $2}')"

if [[ ! "$pane" ]]; then
    tmux display-message "$EDITOR not open in any panes"
    exit 1
fi

tmux send-keys -t "$pane" -X cancel 2>/dev/null || true
tmux send-keys -t "$pane" Escape

cmd=":drop $filename"
if [[ "$line" && "$filename" != "$line" ]]; then
    cmd="$cmd | $line"
fi

tmux send-keys -t "$pane" "$cmd" Enter
tmux select-window -t "$window"
tmux select-pane -t "$pane" -Z;

