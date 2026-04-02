#!/bin/bash

set -eu

curl -LO 'https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh?raw=true'
patch key-bindings.zsh <patch.patch
