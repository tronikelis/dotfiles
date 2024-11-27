# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

## before plugins loaded

plugins=(
    git
    fzf-tab
    zsh-syntax-highlighting
    zsh-autosuggestions
    ssh-agent
    bd
)

source $ZSH/oh-my-zsh.sh

## after plugins loaded

_comp_options+=(globdots)
zstyle ':completion:*' special-dirs false

## my things start here

# bind ctrl+space to accept suggestion
bindkey '^ ' autosuggest-accept
# history mappings
bindkey '^k' up-history
bindkey '^j' down-history

# history
HISTSIZE=100000
SAVEHIST=100000

alias ssh="kitten ssh"

alias vim="nvim"

alias cat="bat"

alias ls="eza --icons -a --group-directories-first"

alias tdm_sync_git_pull="cd ~/.tdm && git pull && tdm sync && cd -"

eval "$(zoxide init --cmd cd zsh)"

eval "$(starship init zsh)"

eval "$(fzf --zsh)"

function tmp_file() {
    if [[ -z "$1" ]]; then
        echo "pass file extension"
        return 1
    fi

    cdmktemp
    vim "tmp_file.$1"
}

function cheatsh() {
    curl -s "cheat.sh/$1" | less
}

function cloned() {
    git clone "$1" --depth 1
}

function cdmktemp() {
    cd "$(mktemp -d)"
}

diff_preview='git log --date=short --pretty=format:"%Cred%h%Creset %Cblue%ad%Creset %s" --color master..{}'
fzf_preview_window='right,50%,border-left,<80(down,40%,border-top)'

function get_fzf_header() {
    echo "current: $(git branch --show-current)"
}

function gci() {
    git branch |
        grep -v "^*" |
        cut -c 3- |
        fzf --preview-window "$fzf_preview_window" --header-first --header "$(get_fzf_header), switch:" --layout reverse --info inline --preview="$diff_preview" |
        xargs git switch
}

function gdi() {
    local args="$@"

    git branch |
        grep -v "^*" |
        cut -c 3- |
        fzf --preview-window "$fzf_preview_window" --header-first --header "$(get_fzf_header), delete:" --layout reverse --info inline --multi --print0 --preview="$diff_preview" |
        xargs -0 git branch --delete $args
}

function gwsi() {
    ~/personal/scripts/git/gwsi.sh
}

function gwdi() {
    ~/personal/scripts/git/gwdi.sh
}

function killp() {
    lsof -i:$1 | grep LISTEN | awk '{print $2}' | xargs kill
}

function sp() {
    # project dirs are taken from ~/project_dirs.txt
    cd "$(~/personal/scripts/select_project.sh)"
}

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a"

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'eza --icons --tree --color=always {}'"

cmd_copy="wl-copy"
if [[ "$OSTYPE" == "darwin"* ]]; then
    cmd_copy="pbcopy"
fi

# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | "$cmd_copy")+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

if cat "$HOME/system_name.txt" 2>/dev/null | grep vinted_work_1 &>/dev/null; then
    eval "$(direnv hook zsh)"
    eval "$(mise activate)"
else
    FNM_PATH="$HOME/.local/share/fnm"
    if [ -d "$FNM_PATH" ]; then
        export PATH="$HOME/.local/share/fnm:$PATH"
    fi
    if [ -x "$(command -v fnm)" ]; then
        eval "$(fnm env --shell zsh)"
        eval "$(fnm completions --shell zsh)"
    fi
fi
