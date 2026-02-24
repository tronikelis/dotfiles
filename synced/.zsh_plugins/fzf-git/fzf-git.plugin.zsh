preview_git_log="git log --pretty=format:'%C(yellow)%h %Cblue%ad %Cgreen%an %Creset%s' --date=short --color=always"

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
    git branch |
        cut -c 3- |
        fzf_git --preview-window down --preview "$preview_git_log {}" "$@"
}

function fzf_git_worktrees() {
    local sum=""
    while read -r line; do
        local t="$(fextr 1 2 <<<"$line")"
        if [[ ! "$t" ]]; then
            continue
        fi
        local unix="$(unix_last_modified "$t")"

        sum="$sum$line $unix"$'\n'
    done < <(git worktree list)
    sum=${sum%$'\n'}

    sort -r -n -k 4 <<<"$sum" |
        fzf_git --preview-window down --preview "cd \"\$(echo {} | fextr 1 3)\" && $preview_git_log" "$@" |
        fextr 1 3
}

function fzf_git_status() {
    git status --short |
        fzf_git --preview "set -o pipefail; git diff --exit-code -- {2..} | delta && bat --color=always {2..}" |
        fextr 2 0
}

function _fzf_git_worktrees() {
    zle -U "$(fzf_git_worktrees | shellescape | tr '\n' ' ')"
}

function _fzf_git_branches() {
    zle -U "$(fzf_git_branches | tr '\n' ' ')"
}

function _fzf_git_status() {
    zle -U "$(fzf_git_status | shellescape | tr '\n' ' ')"
}

if [[ -o interactive ]]; then
    zle -N _fzf_git_worktrees
    zle -N _fzf_git_branches
    zle -N _fzf_git_status

    bindkey "^gb" _fzf_git_branches
    bindkey "^gw" _fzf_git_worktrees
    bindkey "^gs" _fzf_git_status
fi
