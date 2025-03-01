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

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# fzf should complete ONLY with enter
zstyle ':fzf-tab:*' fzf-flags --bind=tab:toggle+down

## my things start here

# bind ctrl+space to accept suggestion
bindkey '^ ' autosuggest-accept
# history mappings
bindkey '^k' up-history
bindkey '^j' down-history

# history
HISTSIZE=100000
SAVEHIST=100000
KEYTIMEOUT=100

alias ssh="kitten ssh"

alias ls="eza --icons -a --group-directories-first"

alias tdm_sync_git_pull="cd ~/.tdm && git pull && tdm sync && cd -"

# as I'm using zoxide with tmux, increase zoxide size
export _ZO_MAXAGE=50000
eval "$(zoxide init zsh)"

eval "$(starship init zsh)"

eval "$(fzf --zsh)"

function cheatsh() {
    curl -s "cheat.sh/$1" | less
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

function smux() {
    ~/.config/tmux/scripts/upsert_session.sh "$@"
}

export LS_COLORS="$(vivid generate catppuccin-mocha)"

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a --layout=reverse --cycle"

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

# tmux!
if [[ -z "$TMUX" ]]; then
    smux ./
fi
