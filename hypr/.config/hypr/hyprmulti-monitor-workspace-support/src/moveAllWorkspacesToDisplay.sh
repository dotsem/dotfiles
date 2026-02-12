#!/usr/bin/env bash

# Usage: ./moveAllWorkspacesToDisplay.sh next|prev
# Moves all windows from the currently focused display to the next/prev display,
# maintaining their relative workspace IDs (1-10).

set -euo pipefail

direction="${1:-next}"

if [[ "$direction" != "next" && "$direction" != "prev" ]]; then
    echo "Usage: $0 next|prev"
    exit 1
fi

# Get all monitors in order
monitors_json=$(hyprctl monitors -j)
monitor_count=$(echo "$monitors_json" | jq 'length')

if [[ "$monitor_count" -lt 2 ]]; then
    echo "Only one monitor detected. Nothing to move."
    exit 0
fi

# Find focused monitor info
focused_mon=$(echo "$monitors_json" | jq -r '.[] | select(.focused == true)')
source_id=$(echo "$focused_mon" | jq -r '.id')
source_name=$(echo "$focused_mon" | jq -r '.name')

# Find index of focused monitor in the list
source_index=0
for ((i=0; i<monitor_count; i++)); do
    mon_name=$(echo "$monitors_json" | jq -r ".[$i].name")
    if [[ "$mon_name" == "$source_name" ]]; then
        source_index=$i
        break
    fi
done

# Determine target index and target monitor name/id
if [[ "$direction" == "next" ]]; then
    target_index=$(( (source_index + 1) % monitor_count ))
else
    target_index=$(( (source_index - 1 + monitor_count) % monitor_count ))
fi

target_mon_json=$(echo "$monitors_json" | jq ".[$target_index]")
target_name=$(echo "$target_mon_json" | jq -r '.name')

# Get all clients
clients_json=$(hyprctl clients -j)

# Move windows
# We filter clients by monitor ID (source_id)
# Workspace logic: target_ws = 1 + (target_index * 10) + (source_ws - 1) % 10
echo "Moving windows from $source_name (index $source_index) to $target_name (index $target_index)..."

# Filter and iterate over windows on the source monitor
echo "$clients_json" | jq -c ".[] | select(.monitor == $source_id)" | while read -r client; do
    addr=$(echo "$client" | jq -r '.address')
    ws_id=$(echo "$client" | jq -r '.workspace.id')
    
    # Skip special workspaces (negative IDs)
    if [[ "$ws_id" -lt 1 ]]; then
        continue
    fi
    
    # Calculate relative workspace position (0-9)
    rel_ws=$(( (ws_id - 1) % 10 ))
    
    # Target workspace ID based on target monitor index
    target_ws=$(( 1 + (target_index * 10) + rel_ws ))
    
    # Move the window silently
    hyprctl dispatch movetoworkspacesilent "$target_ws,address:$addr"
done

notify-send "Hyprland" "All windows moved from $source_name to $target_name"
