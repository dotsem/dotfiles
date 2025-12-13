#!/bin/bash

# Create a lock file so other scripts can wait for this script to finish
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/mmws_reorganize.lock"
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# Get all connected monitors
mapfile -t monitors < <(hyprctl monitors -j | jq -r '.[].name')
monitor_count=${#monitors[@]}

# Compute max valid workspace ID
max_workspace=$((monitor_count * 10))

# Assign workspaces to new monitors
for i in "${!monitors[@]}"; do
    mon="${monitors[$i]}"
    base=$((i * 10))
    first_ws=$((base + 1))

    # Read monitor's active workspace BEFORE creating workspaces so we don't get
    # the last ws from the creation loop.
    mon_active=$(hyprctl monitors -j | jq -r --arg MON "$mon" '.[] | select(.name == $MON) | .activeWorkspace.id // -1')

    # Create and move the 10 workspaces for this monitor WITHOUT activating them
    for ws in $(seq "$first_ws" $((base + 10))); do
        hyprctl dispatch moveworkspacetomonitor "$ws $mon"
    done

    # If the monitor doesn't currently have an active workspace within its
    # assigned range, set its active workspace to the first workspace of the range.
    if ! [[ "$mon_active" -ge "$first_ws" && "$mon_active" -le $((base + 10)) ]]; then
        # Focus the monitor then activate the first workspace of this monitor's range
        hyprctl dispatch focusmonitor "$mon"
        hyprctl dispatch workspace "$first_ws"
    fi
done

# Get all windows and their workspaces
mapfile -t windows < <(hyprctl clients -j | jq -r '.[] | "\(.address) \(.workspace.id)"')

# Track remapped windows for notification
migrated_windows=0

for win in "${windows[@]}"; do
    win_addr=$(echo "$win" | awk '{print $1}')
    ws_id=$(echo "$win" | awk '{print $2}')

    if [ "$ws_id" -gt "$max_workspace" ]; then
        # Compute destination workspace
        relative_pos=$(( (ws_id - 1) % 10 + 1 ))
        target_ws=$(( (monitor_count - 1) * 10 + relative_pos ))

        # Move window
        hyprctl dispatch movetoworkspace "$target_ws,address:$win_addr"
        ((migrated_windows++))
    fi
done

if [ "$migrated_windows" -gt 0 ]; then
    notify-send "Hyprland Workspace Cleanup" "$migrated_windows window(s) migrated to valid workspaces"
else
    notify-send "Hyprland Workspace Cleanup" "No migration needed"
fi
