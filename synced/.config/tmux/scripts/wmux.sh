#!/bin/bash -i

source ~/.oh-my-zsh/custom/plugins/fzf-git/fzf-git.sh/fzf-git.sh
source ~/.oh-my-zsh/custom/plugins/fzf-git/_fzf_git_fzf.sh

wd="$(_fzf_git_worktrees --no-multi --preview-window=bottom,50%,border-top)"

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

~/.config/tmux/scripts/upsert_session.sh "$wd" "$root@$branch"
