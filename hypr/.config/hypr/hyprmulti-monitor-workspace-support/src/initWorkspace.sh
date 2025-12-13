#!/bin/bash

# Get list of active monitors in order
monitors=($(hyprctl monitors -j | jq -r '.[].name'))

# Loop through and assign starting workspace
for i in "${!monitors[@]}"; do
    mon="${monitors[$i]}"
    ws_start=$((i * 10 + 1))
    hyprctl dispatch focusmonitor "$mon"
    hyprctl dispatch workspace "$ws_start"
done

# Focus first monitor
hyprctl dispatch focusmonitor "${monitors[0]}"