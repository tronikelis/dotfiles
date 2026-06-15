autoload -Uz add-zsh-hook

function preexec_osc_133 {
    echo -n "\\x1b]133;A\\x1b\\"
}
add-zsh-hook preexec preexec_osc_133

function precmd_cursor_block {
    printf '\033[1 q'
}
add-zsh-hook precmd precmd_cursor_block


function add_to_path {
	if [[ -d "$1" ]]; then
		export PATH="$1:$PATH"
	fi
}

function command_exists {
    command -v "$1" &>/dev/null
}

function strip_home_from_path {
    if [[ "$1" == "$HOME"* ]]; then
        echo "~${1#"$HOME"}"
        return 0
    fi
    echo "$1"
}

add_to_path "$HOME/.local/bin"
add_to_path "/opt/homebrew/bin"
add_to_path "$HOME/.bun/bin"

if command_exists "go"; then
	add_to_path "$(go env GOPATH)/bin"
fi
if [[ -e "$HOME/.cargo/env" ]]; then
	source "$HOME/.cargo/env"
fi


export EDITOR=nvim
export VISUAL="$EDITOR"
export COREPACK_ENABLE_AUTO_PIN=0
export PAGER="less"
export LESS="--mouse" # make mouse scrolling work with less

if command_exists vivid; then
    export LS_COLORS="$(vivid generate catppuccin-mocha)"
fi

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4 \
\
\
--layout=reverse \
--cycle \
--bind 'ctrl-y:execute-silent(echo -n {} | copy)+abort' \
--bind 'ctrl-left:backward-word' \
--bind 'ctrl-right:forward-word' \
--bind ctrl-k:top"

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'eza --icons --tree --color=always {}'"

export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | copy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

export RIPGREP_CONFIG_PATH=~/.config/ripgrep/.ripgreprc

setopt PROMPT_SUBST

if [[ -e ~/.config/git/scripts/git-prompt.sh ]]; then
    source ~/.config/git/scripts/git-prompt.sh
fi

function precmd_set_git {
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_SHOWCONFLICTSTATE=yes
    GIT_PS1_SHOWCOLORHINTS=1
    if [[ "$(git config --bool bash.promptShowUntrackedFiles)" == "false" ]]; then
        unset GIT_PS1_SHOWUNTRACKEDFILES
    fi
    if [[ "$(git config --bool bash.promptShowDirtyState)" == "false" ]]; then
        unset GIT_PS1_SHOWDIRTYSTATE
    fi
    prompt_git="$(GIT_OPTIONAL_LOCKS=0 __git_ps1 ' git(%s)' 2>/dev/null)"
}
add-zsh-hook precmd precmd_set_git

function precmd_set_prompt_directory {
    prompt_directory="$(pwd)"

    local git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [[ "$git_root" ]]; then
        prompt_directory="$(realpath .)" # git resolves symlinks
        prompt_directory="$(basename "$git_root")${prompt_directory#"$git_root"}"
        return 0
    fi

    prompt_directory="$(strip_home_from_path "$prompt_directory")"
}
add-zsh-hook precmd precmd_set_prompt_directory

function precmd_print_newline {
    if [[ ! "$__precmd_print_newline" ]]; then
        __precmd_print_newline=1
        return 0
    fi
    echo
}
add-zsh-hook precmd precmd_print_newline

function precmd_set_prompt_jobs {
    prompt_jobs=""
    if [[ ! "$jobstates" ]]; then
        return 0
    fi
    prompt_jobs="$(echo "$jobstates" | tr ' ' '\n' | wc -l) "
}
add-zsh-hook precmd precmd_set_prompt_jobs

function precmd_set_caret {
    local exit_status="$?"
    prompt_caret=">"
    if [[ "$exit_status" != 0 && "$exit_status" != 130 ]]; then
        prompt_caret="%F{red}<%f"
    fi
}
add-zsh-hook precmd precmd_set_caret

function precmd_command_time {
    prompt_command_time=""
    if [[ "$prev_command_time" ]]; then
        prompt_command_time="$(($(date +%s)-$prev_command_time))"
        prompt_command_time="$(($prompt_command_time/60))"
        if [[ "$prompt_command_time" == 0 ]]; then
            prompt_command_time=""
        else
            prompt_command_time=" took %F{yellow}%B${prompt_command_time}m%b%f"
        fi
        prev_command_time=""
    fi
}
add-zsh-hook precmd precmd_command_time

function preexec_command_time {
    prev_command_time="$(date +%s)"
}
add-zsh-hook preexec preexec_command_time

prompt_newline=$'\n'
PS1='%F{blue}${prompt_directory//[%]/%%}%f\
%B${prompt_git}%b\
${prompt_command_time}\
${prompt_newline//[%]/%%}\
%F{red}%B${prompt_jobs//[%]/%%}%b%f\
%F{cyan}%B${prompt_caret}%b%f '


ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50

_comp_options+=(globdots)
zstyle ':completion:*' special-dirs false

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# fzf should complete ONLY with enter
zstyle ':fzf-tab:*' fzf-flags --bind=tab:toggle+down

zstyle ':completion:*' use-cache yes
# fuzzy completion for zsh
zstyle ':completion:*' matcher-list '' 'm:{a-z\-}={A-Z\_}' 'r:|?=** m:{a-z\-}={A-Z\_}'

bindkey -e
autoload -Uz compinit
if fttl ~/.zcompdump 24h; then
    rm ~/.zcompdump
fi
compinit -C

# fzf-tab needs to be loaded after compinit, but before plugins which will wrap widgets
source ~/.zsh_plugins/fzf-tab/fzf-tab.plugin.zsh

source ~/.zsh_plugins/fzf-git/fzf-git.plugin.zsh
source ~/.zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source ~/.zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
source ~/.zsh_plugins/fzf/fzf.plugin.zsh


ssh_env_file=~/.ssh/ssh_agent_env
if ! pgrep -u "$USER" ssh-agent &>/dev/null; then
    source <(ssh-agent -t 4h | tee "$ssh_env_file")
    chmod 600 "$ssh_env_file"
else
    { source "$ssh_env_file" } >/dev/null
fi


bindkey "^[[1;5C" vi-forward-word
bindkey "^[[1;5D" vi-backward-word

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# bind ctrl+space to accept suggestion
bindkey '^ ' autosuggest-accept


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


alias ls="eza --icons -a --group-directories-first"
alias ll="ls --long --all"
alias ..="cd .."
alias grep="grep --color=auto"


if command_exists zoxide; then
    # as I'm using zoxide with tmux, increase zoxide size
    export _ZO_MAXAGE=50000
    source <(zoxide init zsh)
fi


function cheatsh {
    curl -s "cheat.sh/$1" | less -R
}

function cdmktemp {
    cd "$(mktemp -d)"
}

function cdroot {
    if [[ ! "$1" ]]; then
        echo "provide target"
        return 1
    fi
    cd "$(froot "$1")"
}

function killp {
    lsof -i:$1 | tail -n +2 | awk '{print $2}' | xargs -r kill
}

function killj {
    kill %${(k)^jobstates}
}

function smux {
    ~/.config/tmux/scripts/upsert_session.sh "$@"
}

function wfiles {
    local flags=""
    case "$1" in
        "r")
            flags="-r"
            ;;
        "n")
            ;;
        *)
            echo "first argument r/n" >&2
            return 1
            ;;
    esac
    local dir="$2"
    if [[ ! "$dir" ]]; then
        echo "second argument directory" >&2
        return 1
    fi

    shift
    shift

    while true; do
        fd . "$dir" | entr -d -s $flags "$*"
        # entr normally returns one of the following values:
        #
        # 0 Normal termination after receiving SIGINT
        # 1 No regular files were provided as input or an error occurred
        # 2 Files were added or removed from a directory
        exit_status="$?"
        if [[ "$exit_status" == 0 || "$exit_status" == 1 ]]; then
            return 1
        fi
    done
}

# https://sumnerevans.com/posts/software-engineering/stop-using-conventional-commits/
# branch format: <scope>.<word>_<word>
function _git_commit_message_from_branch {
    zle -U "$(git branch --show-current | sed 's/\./: /g ; s/_/ /g')"
}
zle -N _git_commit_message_from_branch
bindkey "^gm" _git_commit_message_from_branch

function cpcmd {
    history | tail -n 1 | fextr 2 0 | sed 's/\\n/\n/g' | copy
}

function cpcmdout {
    tmux copy-mode
    tmux send -X previous-prompt
    tmux send -X begin-selection
    tmux send -X next-prompt
    tmux send -X copy-selection-and-cancel
}

function showmem {
    ps -o rss,command -p "$1" | tail -1 | awk '{printf $1/1024 " MiB\t"; $1=""; print $0}'
}

function tmpvar {
    tmp="$(mktemp)"
    echo "$tmp"
}


# custom setup
if [[ -e ~/.zshrc.private ]]; then
    source ~/.zshrc.private
fi

# remove duplicates in $PATH
typeset -aU path

