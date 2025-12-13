#!/bin/bash

PLAYER="spotify"
status=$(playerctl -p "$PLAYER" status 2>/dev/null | tr '[:upper:]' '[:lower:]')

if [[ "$status" == "playing" ]]; then
    icon="⏸"
elif [[ "$status" == "paused" ]]; then
    icon="▶"
else
    icon=""
fi

echo "{\"text\":\"$icon\",\"tooltip\":\"Toggle Play/Pause\"}"
