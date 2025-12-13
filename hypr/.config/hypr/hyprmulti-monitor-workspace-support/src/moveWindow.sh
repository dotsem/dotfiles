#!/usr/bin/env bash
set -euo pipefail

arg="$1"

# Get current window info
window_json=$(hyprctl activewindow -j)
current_monitor=$(echo "$window_json" | jq -r '.monitor')

# Get all monitors
monitors_json=$(hyprctl monitors -j)
monitor_count=$(echo "$monitors_json" | jq 'length')



# Get current workspace ID
current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

current_index=$(( (current_workspace - 1) / 10 ))

# Workspace range for this monitor
start_ws=$(( current_index * 10 + 1 ))
end_ws=$(( start_ws + 9 ))
# Determine target workspace
if [[ "$arg" == "next" ]]; then
    target_workspace=$(( current_workspace + 1 ))
    if (( target_workspace > end_ws )); then
        target_workspace=$start_ws
    fi
elif [[ "$arg" == "prev" ]]; then
    target_workspace=$(( current_workspace - 1 ))
    if (( target_workspace < start_ws )); then
        target_workspace=$end_ws
    fi
else
    # Must be 1–10
    if ! [[ "$arg" =~ ^[0-9]+$ ]] || (( arg < 1 || arg > 10 )); then
        echo "Invalid argument: $arg (must be 1-10, next, or prev)"
        exit 1
    fi
    target_workspace=$(( start_ws + arg - 1 ))
fi

# Move window (do NOT change focus, do NOT reassign workspace)
hyprctl dispatch movetoworkspacesilent "$target_workspace"
