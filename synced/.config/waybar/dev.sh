#!/bin/bash

prev=""

while true; do
    curr="$(cat ./config.jsonc)"
    if [[ "$prev" != "$curr" ]]; then
        prev="$curr"

        killall waybar
        waybar &
    fi

    sleep 1
done
