#!/bin/bash -i

source ~/.oh-my-zsh/custom/plugins/fzf-git/fzf-git.sh/fzf-git.sh

wd="$(_fzf_git_worktrees --no-multi)"

if [[ -z "$wd" ]]; then
    tmux display-message "empty selection"
    exit 0
fi

~/.config/tmux/scripts/upsert_session.sh "$wd"
