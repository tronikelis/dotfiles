#!/bin/sh

tmpfile="$(mktemp)"

grim -g "$(slurp)" - | tee "$tmpfile" | wl-copy

swappy -f - <"$tmpfile"
