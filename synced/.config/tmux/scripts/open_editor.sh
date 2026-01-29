#!/bin/bash

set -eu

filename="$(
node - "$1" <<EOF
    console.log((process.argv[2].split(":")[0] || "").trim())
EOF
)"

line="$(
node - "$1" <<EOF
    const colons = process.argv[2].split(":")
    let line = ""
    if (colons.length > 1) {
        line = colons[1]
    }
    console.log((line || "").trim())
EOF
)"

column="$(
node - "$1" <<EOF
    const colons = process.argv[2].split(":")
    let line = ""
    if (colons.length > 2) {
        line = colons[2]
    }
    console.log((line || "").trim())
EOF
)"

current_session="$(tmux display-message -p '#{session_id}')"
pane_window="$(
    tmux list-panes -a \
        -f "#{&&:#{==:#{session_id},$current_session},#{==:#{pane_current_command},$EDITOR}}" \
        -F '#{pane_id} #{window_id}'
)"

pane="$(echo "$pane_window" | awk '{print $1}')"
window="$(echo "$pane_window" | awk '{print $2}')"

# open nvim if not already open
if [[ ! "$pane" ]]; then
    tmux new-window -c "#{pane_current_path}"
    pane="$(tmux display-message -p '#{pane_id}')"
    tmux send-keys -t "$pane" "$EDITOR" Enter
fi

tmux send-keys -t "$pane" -X cancel 2>/dev/null || true
tmux send-keys -t "$pane" Escape

function send_cmd() {
    tmux send-keys -t "$pane" ":$1" Enter
}
send_cmd "drop $filename"
if [[ "$line" ]]; then
    send_cmd "normal! ${line}G"
fi
if [[ "$column" ]]; then
    send_cmd "normal! 0"
    send_cmd "normal! ${column}l"
    # go back one, because 1l should be the first column, but it actually moves the cursor
    send_cmd "normal! 1h" 
fi

tmux select-window -t "$window"
tmux select-pane -t "$pane" -Z;

