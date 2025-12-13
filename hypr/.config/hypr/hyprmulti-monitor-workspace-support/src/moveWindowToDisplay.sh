#!/bin/bash

# Usage: ./move_window_display.sh next|prev [focus]
# Example: ./move_window_display.sh next focus

direction="$1"
focus_flag="${2:-false}"

if [[ "$direction" != "next" && "$direction" != "prev" ]]; then
    echo "Usage: $0 next|prev [focus]"
    exit 1
fi

# Get list of monitors in order
monitors=($(hyprctl -j monitors | jq -r '.[].name'))
count=${#monitors[@]}

# Get focused monitor
focused=$(hyprctl -j monitors | jq -r '.[] | select(.focused).name')

# Find index of focused monitor
for i in "${!monitors[@]}"; do
    if [[ "${monitors[$i]}" == "$focused" ]]; then
        idx=$i
        break
    fi
done

# Compute target monitor index
if [[ "$direction" == "next" ]]; then
    target=$(( (idx + 1) % count ))
else
    target=$(( (idx - 1 + count) % count ))
fi

target_monitor="${monitors[$target]}"

# Get the active workspace of the target monitor
target_ws=$(hyprctl -j monitors | jq -r ".[] | select(.name==\"$target_monitor\").activeWorkspace.id")

# Optionally focus that workspace
if [[ "$focus_flag" == "focus" ]]; then
    hyprctl dispatch movetoworkspace "$target_ws"
else
    hyprctl dispatch movetoworkspacesilent "$target_ws"
fi
