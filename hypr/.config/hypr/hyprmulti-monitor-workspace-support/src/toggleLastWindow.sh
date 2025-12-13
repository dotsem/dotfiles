#!/bin/bash

# Switch to the last focused window

# Get the focused and last window addresses
focused=$(hyprctl -j clients | jq -r '.[] | select(.focused).address')
last=$(hyprctl -j clients | jq -r '.[] | select(.focusHistoryID == 1).address')

# If last exists and isn't the same as focused, switch
if [[ -n "$last" && "$last" != "$focused" ]]; then
    hyprctl dispatch focuswindow "address:$last"
fi
