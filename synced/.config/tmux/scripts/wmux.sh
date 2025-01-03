#!/usr/bin/env bash

wd="$(_fzf_git_worktrees --no-multi)"

if [[ -z "$wd" ]]; then
    tmux display-message "empty selection"
    exit 0
fi

~/.config/tmux/scripts/upsert_session.sh "$wd"
