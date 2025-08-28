### Config helpers
# used only in this zshrc, internal

function add_to_path() {
	if [[ -d "$1" ]]; then
		export PATH="$PATH:$1"
	fi
}

function is_executable() {
    test -x "$(command -v "$1")"
}




### Path
# update PATH

if [[ -e "$HOME/.cargo/env" ]]; then
	source "$HOME/.cargo/env"
fi

add_to_path "$HOME/.local/bin"
add_to_path "/opt/homebrew/bin"
add_to_path "$HOME/.bun/bin"

if is_executable "go"; then
	add_to_path "$(go env GOPATH)/bin"
fi









### Env
# vars exported to child processes

export EDITOR=nvim
export VISUAL="$EDITOR"
export COREPACK_ENABLE_AUTO_PIN=0
export PAGER="less"
if is_executable vivid; then
    export LS_COLORS="$(vivid generate catppuccin-mocha)"
fi

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









### Plugins config / completion config
# configure plugins here, before calling compinit, before sourcing plugins

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50

_comp_options+=(globdots)
zstyle ':completion:*' special-dirs false

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# fzf should complete ONLY with enter
zstyle ':fzf-tab:*' fzf-flags --bind=tab:toggle+down

zstyle ':completion:*' use-cache yes
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'











### Compinit initialize
# completion cache gets cleared after some time

bindkey -e
autoload -U compinit
if fttl ~/.zcompdump 24h; then
    rm ~/.zcompdump
fi
compinit






### Plugin source
# source plugins in correct order

# fzf-tab needs to be loaded after compinit, but before plugins which will wrap widgets
source ~/.zsh_plugins/fzf-tab/fzf-tab.plugin.zsh

source ~/.zsh_plugins/fzf-git/fzf-git.plugin.zsh
source ~/.zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source ~/.zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh






### Ssh-agent
# set up ssh-agent with some ttl

ssh_env_file=~/.ssh/ssh_agent_env
if ! pgrep -u "$USER" ssh-agent &>/dev/null; then
    eval "$(ssh-agent -t 4d | tee "$ssh_env_file")"
else
    { source "$ssh_env_file" } >/dev/null
fi








### Binds
# set up some custom binds

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# bind ctrl+space to accept suggestion
bindkey '^ ' autosuggest-accept







### History
# zsh history options

setopt HIST_IGNORE_SPACE
setopt HIST_FCNTL_LOCK
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

KEYTIMEOUT=100






### Aliases
# setup some aliases

alias ls="eza --icons -a --group-directories-first"
alias ll="ls --long --all"
alias ..="cd .."
alias tdm_sync_git_pull="cd ~/.tdm && git pull && tdm sync && cd -"
alias grep="grep --color=auto"







### Shell integrated utils
# shell integration with various utils

if is_executable zoxide; then
    # as I'm using zoxide with tmux, increase zoxide size
    export _ZO_MAXAGE=50000
    eval "$(zoxide init zsh)"
fi
if is_executable starship; then
    eval "$(starship init zsh)"
fi
if is_executable fzf; then
    eval "$(fzf --zsh)"
fi








### Helper functions
# some helpful interactive shell utils

function cheatsh() {
    curl -s "cheat.sh/$1" | less -R
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

function wfiles() {
    local dir="$1"
    shift
    while true; do
        fd . "$dir" | entr -d -r "$@"
        sleep 0.5
    done
}







### Custom setup
# based on system currently running

if [[ -e ~/.zshrc.private ]]; then
    source ~/.zshrc.private
fi





### Tmux
# init tmux

if [[ -z "$TMUX" ]]; then
    smux ./
fi
