#!/bin/sh

statefile="/tmp/hypr_gaps_state"

if [ ! -f "$statefile" ]; then
    echo "10" > "$statefile"
fi

current=$(cat "$statefile")

if [ "$current" = "0" ]; then
    hyprctl keyword general:gaps_in 10
    hyprctl keyword general:gaps_out 10
    echo "10" > "$statefile"
else
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    echo "0" > "$statefile"
fi
