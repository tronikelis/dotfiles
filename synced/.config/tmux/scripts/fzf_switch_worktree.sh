#!/usr/bin/env zsh

source ~/.zsh_plugins/fzf-git/fzf-git.plugin.zsh

wd="$(fzf_git_worktrees --no-multi)"

if [[ -z "$wd" ]]; then
    tmux display-message "empty selection"
    exit 0
fi

branch="$(
    cd "$wd" || exit
    git symbolic-ref --short HEAD
)"

root="$(
    cd "$wd" || exit
    # because there are 2 .git, 1 will be in $wd, another one for worktree root
    # so avoiding matching the current one like this
    cd ../ || exit

    if v="$(froot .git)"; then
        basename "$(dirname "$v")"
    fi
)"

# probably not a worktree
if [[ -z "$root" ]]; then
    root="$(basename "$wd")"
fi

~/.config/tmux/scripts/upsert_session.sh "$wd" "$root@$branch"
