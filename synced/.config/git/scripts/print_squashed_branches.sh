#!/bin/bash

if [[ ! "$1" ]]; then
    echo "provide merge-base branch" >&2
    exit 1
fi

while read -r line; do
    if [[ "$line" == "$1" ]]; then
        continue
    fi

    if git diff --merge-base "$1" "$line" | git revcontains "$1" &>/dev/null; then
        printf "%s" "$line"
        echo
    fi
done < <(git branch | cut -c 3-)
