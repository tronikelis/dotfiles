#!/bin/bash

tmux switch -t="$(tmux ls -F '#{session_name}' | fzf --tmux)"
