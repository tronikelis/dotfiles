function unix_last_modified() {
    local v="$(stat -f %m "$1" 2>/dev/null)"
    if [[ $? ]]; then
        v="$(stat -c %X "$1")"
    fi

    echo -n "$v"
}

function fzf_git() {
    fzf --multi --tmux 70%,50% "$@"
}

function fzf_git_branches() {
    git branch | cut -c 3- | fzf_git "$@" | tr '\n' ' '
}

function fzf_git_worktrees() {
    local sum=""
    while read -r line; do
        local t="$(awk '{print $1}' <<<"$line")"
        local unix="$(unix_last_modified "$t")"

        sum="$sum$line $unix"$'\n'
    done < <(git worktree list)

    sort -r -n -k 4 <<<"$sum" | fzf_git "$@" | awk '{print $1}' | tr '\n' ' '
}

function _fzf_git_worktrees() {
    zle -U "$(fzf_git_worktrees)"
}

function _fzf_git_branches() {
    zle -U "$(fzf_git_branches)"
}

if [[ -o interactive ]]; then
    zle -N _fzf_git_worktrees
    zle -N _fzf_git_branches

    bindkey "^gb" _fzf_git_branches
    bindkey "^gw" _fzf_git_worktrees
fi
