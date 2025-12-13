#!/bin/sh

statefile="/tmp/hypr_blur_state"

if [ ! -f "$statefile" ]; then
    echo "10" > "$statefile"
fi

current=$(cat "$statefile")

if [ "$current" = "0" ]; then
    hyprctl keyword decoration:inactive_opacity 0.9
    hyprctl keyword decoration:active_opacity 0.95
    echo "10" > "$statefile"
else
    hyprctl keyword decoration:inactive_opacity 1
    hyprctl keyword decoration:active_opacity 1
    echo "0" > "$statefile"
fi
