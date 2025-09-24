#!/bin/bash

tmux ls -F '#{session_name}' | fzf --tmux | shellescape | xargs -I{} tmux switch -t {}
