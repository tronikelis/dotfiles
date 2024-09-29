if [[ -f "$HOME/.cargo/env" ]]; then
	source "$HOME/.cargo/env"
fi

function add_to_path {
	if [[ -d "$1" ]]; then
		export PATH="$PATH:$1"
	fi
}

add_to_path "$HOME/.local/bin"
add_to_path "/opt/homebrew/bin"
add_to_path "$HOME/.bun"

if [[ -x "$(command -v go)" ]]; then
	add_to_path "$(go env GOPATH)/bin"
fi

export EDITOR=nvim
export VISUAL="$EDITOR"
export COREPACK_ENABLE_AUTO_PIN=0
