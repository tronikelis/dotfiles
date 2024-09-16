#!/bin/bash

set -eou pipefail

NL=$'\n'

projects=""

while read -r line; do
	# expands ~ into home
	line=$(bash -c "echo -n $line")
	projects+="$(ls "$line" | awk "{print \"$line\" \$0}")$NL"
done <~/project_dirs.txt

echo -n "$projects" | fzf --layout reverse \
	--header "Select Project:" \
	--header-first
