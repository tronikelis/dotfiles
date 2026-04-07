if [[ "$(echo $(wc -l <~/.zshenv))" != 3 ]]; then
    echo "WARN: zshenv contains logic" >&2
fi
