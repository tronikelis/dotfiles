#!/bin/bash

accept="$(printf 'Ya\nNah' | rofi -dmenu -p "$1")"

if [[ "$accept" == 'Ya' ]]; then
    sh -c "$2"
fi
