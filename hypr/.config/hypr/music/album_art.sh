#!/bin/bash

PLAYER="spotify"
IMG_PATH="/tmp/cover.jpeg"
CACHED_URL_PATH="/tmp/last_album_url"

album_art=$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null)

# Skip if no URL or not HTTP
if [[ -z "$album_art" || "$album_art" != http* ]]; then
    exit 1
fi

# Only download if changed or missing
last_url=$(cat "$CACHED_URL_PATH" 2>/dev/null || echo "")

if [[ "$album_art" != "$last_url" || ! -f "$IMG_PATH" ]]; then
    # Download and resize to 28x28 using ImageMagick
    curl -sL "$album_art" | convert jpg:- -resize 28x28! "$IMG_PATH" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        exit 1  # failed conversion/download
    fi
    echo "$album_art" > "$CACHED_URL_PATH"
fi

# Output final image path
echo "$IMG_PATH"
