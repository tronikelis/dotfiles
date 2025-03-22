#!/bin/bash

signing_key=""
sign=false
args=("$@")

while [[ -n "$1" ]]; do
    case "$1" in
    "-f")
        signing_key="${2%.pub}"
        ;;
    "-Y")
        if [[ "$2" == "sign" ]]; then
            sign=true
        fi
        ;;
    esac
    shift
done

if [[ -z "$signing_key" ]]; then
    echo "signing_key was empty" >&2
    exit 1
fi

# not the right command, return early
if [[ $sign == false ]]; then
    exec ssh-keygen "${args[@]}"
fi

# only run ssh-add if we don't have the identity added
ssh-add -l | grep -q "$(ssh-keygen -lf "$signing_key" | awk '{print $2}')" || ssh-add -q "$signing_key" || exit

exec ssh-keygen "${args[@]}"
