_fzf_git_fzf() {
    fzf --height=50% --tmux 90%,70% --multi \
        --border-label-pos=2 \
        --preview-window='bottom,50%,border-top' \
        "$@"
}

