#!/bin/bash

set -eu

curl -LO 'https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh?raw=true'

function fn_patch {
    if [[ -f "$1" ]]; then
        patch git-prompt.sh <"$1"
    fi
}

fn_patch "git-prompt-patch1-escape-percent.patch"
fn_patch "git-prompt-patch2-remove-ls-files.patch"
