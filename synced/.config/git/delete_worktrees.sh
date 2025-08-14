#!/usr/bin/env zsh

source ~/.zsh_plugins/fzf-git/fzf-git.plugin.zsh

echo "$(fzf_git_worktrees)" | xargs -n 1 git wdelete
