#!/bin/bash

tmux ls -F '#{session_name}' | fzf --tmux | xargs -I{} tmux switch -t="{}"
