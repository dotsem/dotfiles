#!/bin/bash

PLAYER="spotify"

status=$(playerctl -p "$PLAYER" status 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo "stopped")

if [[ "$status" != "playing" && "$status" != "paused" ]]; then
    echo '{"text":"No music","tooltip":"No music playing"}'
    exit 0
fi

artist=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null || echo "Unknown Artist")
title=$(playerctl -p "$PLAYER" metadata title 2>/dev/null || echo "Unknown Title")

# Escape any quotes
escaped_text="${artist//\"/\\\"} - ${title//\"/\\\"}"

echo "{\"text\":\"$escaped_text\",\"tooltip\":\"$escaped_text\"}"
