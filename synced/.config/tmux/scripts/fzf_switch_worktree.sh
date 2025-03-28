#!/bin/zsh

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
    while true; do
        cd .. || exit
        if [[ "$(pwd)" == "/" ]]; then
            break
        fi

        if stat ".git" &>/dev/null; then
            basename "$(pwd)"
            break
        fi
    done
)"

# probably not a worktree
if [[ -z "$root" ]]; then
    root="$(basename "$wd")"
fi

~/.config/tmux/scripts/upsert_session.sh "$wd" "$root@$branch"
