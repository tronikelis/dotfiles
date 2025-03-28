#!/bin/bash

tmux ls | fzf --tmux | awk '{print $1}' | rev | cut -c 2- | rev | xargs tmux switch -t
