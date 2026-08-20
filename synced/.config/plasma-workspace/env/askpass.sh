function command_exists {
    command -v "$1" &>/dev/null
}

if command_exists "ksshaskpass"; then
    export SSH_ASKPASS="ksshaskpass"
    export SUDO_ASKPASS="$(command -v ksshaskpass)"
fi

