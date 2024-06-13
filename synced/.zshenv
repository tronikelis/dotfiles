. "$HOME/.cargo/env"

function add_to_path {
	if [[ -d "$1" ]]; then
		export PATH="$PATH:$1"
	fi
}

add_to_path "$HOME/.local/bin/"
add_to_path "/opt/homebrew/bin"

if [[ -x "$(command -v go)" ]]; then
	add_to_path "$(go env GOPATH)/bin"
fi

export EDITOR=nvim
export VISUAL="$EDITOR"
