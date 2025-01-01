# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

## before plugins loaded

plugins=(
    fzf-tab
    zsh-syntax-highlighting
    zsh-autosuggestions
    ssh-agent
    bd
    fzf-git
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

function killp() {
    lsof -i:$1 | grep LISTEN | awk '{print $2}' | xargs kill
}

function killj() {
    kill %${(k)^jobstates}
}

export LS_COLORS="$(vivid generate catppuccin-mocha)"

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

system_name="$(cat "$HOME/system_name.txt" 2>/dev/null)"

if echo "$system_name" | grep vinted_work_1 &>/dev/null; then
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
