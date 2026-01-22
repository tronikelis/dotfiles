#!/bin/bash

set -eu

id="$(openssl rand -hex 4)"
name="${1-scratch}/$id"

dir="/var/tmp/tmux/$id"
mkdir -p "$dir"

tmux new-session -ds "$name" -c "$dir"
tmux switch-client -t "$name"
