#!/usr/bin/env zsh

source ~/.zsh_plugins/fzf-git/fzf-git.plugin.zsh

fzf_git_worktrees | xargs -L1 -r git wdelete
