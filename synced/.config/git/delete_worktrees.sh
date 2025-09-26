#!/usr/bin/env zsh

source ~/.zsh_plugins/fzf-git/fzf-git.plugin.zsh

git wdelete "$(fzf_git_worktrees)"
