#!/bin/bash

prev=""

while true; do
    curr=""

    for filename in *; do
        curr+="$(cat "$filename")"
    done

    if [[ "$prev" != "$curr" ]]; then
        prev="$curr"

        killall waybar
        waybar &
    fi

    sleep 1
done
