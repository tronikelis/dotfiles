#!/bin/bash

hyprpicker_id=-1

tmpfile="$(mktemp)"

hyprpicker -r -z &
sleep 0.3
hyprpicker_id=$!

grim -g "$(slurp)" - | tee "$tmpfile" | wl-copy

if [[ $hyprpicker_id != -1 ]]; then
    kill $hyprpicker_id
fi

swappy -f - <"$tmpfile"
