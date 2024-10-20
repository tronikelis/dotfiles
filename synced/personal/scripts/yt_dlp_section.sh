#!/bin/bash

URL="$1"

FROM="$2"
TO="$3"

yt-dlp "$URL" \
	--download-sections "*$FROM-$TO"
