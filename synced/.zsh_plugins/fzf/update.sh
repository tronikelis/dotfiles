#!/bin/bash

set -eu

curl -LO 'https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh?raw=true'

if [[ -f "patch.patch" ]]; then
    patch key-bindings.zsh <patch.patch
fi

rm key-bindings.zsh.orig &>/dev/null || true
