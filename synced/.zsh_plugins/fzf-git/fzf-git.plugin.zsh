function unix_last_modified() {
    local v=""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        v="$(stat -f %m "$1")"
    else
        v="$(stat -c %Y "$1")"
    fi

    echo -n "$v"
}

function fzf_git() {
    fzf --multi --tmux 70%,50% "$@"
}

function fzf_git_branches() {
    git branch | cut -c 3- | fzf_git "$@"
}

function fzf_git_worktrees() {
    local sum=""
    while read -r line; do
        local t="$(fextr 1 2 <<<"$line")"
        local unix="$(unix_last_modified "$t")"

        sum="$sum$line $unix"$'\n'
    done < <(git worktree list)
    sum=${sum%$'\n'}

    sort -r -n -k 4 <<<"$sum" | fzf_git "$@" | fextr 1 3
}

function _fzf_git_worktrees() {
    zle -U "$(fzf_git_worktrees | shellescape | tr '\n' ' ')"
}

function _fzf_git_branches() {
    zle -U "$(fzf_git_branches | tr '\n' ' ')"
}

if [[ -o interactive ]]; then
    zle -N _fzf_git_worktrees
    zle -N _fzf_git_branches

    bindkey "^gb" _fzf_git_branches
    bindkey "^gw" _fzf_git_worktrees
fi
