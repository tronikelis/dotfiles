#!/bin/bash

curl -LO 'https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh?raw=true'

if [[ -f "git-prompt.patch" ]]; then
    patch git-prompt.sh <git-prompt.patch
fi
