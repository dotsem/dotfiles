#!/bin/bash

CONFIG_DIR="$HOME/.config/hypr"
SAVE_FILE="$CONFIG_DIR/saved_workspaces"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

usage() {
    echo "Usage: $0 <save|release>"
    echo "  save   - Save current active workspace per monitor"
    echo "  release - Restore saved workspaces per monitor"
    exit 1
}

get_default_workspace() {
    local monitor_name="$1"
    local monitor_number
    
    # Extract monitor number from name (e.g., "DP-1" -> 1, "HDMI-A-1" -> 1)
    # This assumes monitors are named in a way that we can extract a number
    # If your monitors have different naming, we might need to adjust this
    monitor_number=$(echo "$monitor_name" | grep -o '[0-9]\+' | head -1)
    
    # If no number found, try to get monitor index from hyprctl
    if [ -z "$monitor_number" ]; then
        monitor_number=$(hyprctl monitors -j | jq -r --arg name "$monitor_name" '.[] | select(.name == $name) | .id + 1')
    fi
    
    # Default to 1 if still no number found
    if [ -z "$monitor_number" ] || [ "$monitor_number" = "null" ]; then
        monitor_number=1
    fi
    
    # Calculate default workspace: (monitor_number - 1) * 10 + 1
    local default_ws=$(( (monitor_number - 1) * 10 + 1 ))
    echo "$default_ws"
}

save_workspaces() {
    echo "Saving current workspaces..."
    
    # Get monitors and their active workspaces using hyprctl
    hyprctl monitors -j | jq -r '.[] | "\(.name) \(.activeWorkspace.id)"' > "$SAVE_FILE"
    
    if [ $? -eq 0 ]; then
        echo "Workspaces saved to $SAVE_FILE"
        echo "Current state:"
        cat "$SAVE_FILE"
    else
        echo "Error: Failed to save workspaces. Make sure jq is installed."
        exit 1
    fi
}

release_workspaces() {
    # Wait for reorganizeWorkspaces lock to be released (if present)
    LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/mmws_reorganize.lock"
    if [ -f "$LOCK_FILE" ]; then
        echo "Detected reorganize lock, waiting for reorganizeWorkspaces.sh to finish..."
        max_loops=50  # ~10s with 0.2s sleep
        i=0
        while [ -f "$LOCK_FILE" ] && [ "$i" -lt "$max_loops" ]; do
            sleep 0.2
            i=$((i + 1))
        done
        if [ -f "$LOCK_FILE" ]; then
            echo "Warning: reorganizeWorkspaces lock still present after timeout, continuing anyway."
        else
            echo "reorganizeWorkspaces finished, proceeding."
        fi
    fi

    if [ ! -f "$SAVE_FILE" ]; then
        echo "Error: No saved workspaces found at $SAVE_FILE"
        echo "Run '$0 save' first to save current workspaces"
        exit 1
    fi
    
    echo "Restoring saved workspaces..."
    
    # Get current monitors
    current_monitors=$(hyprctl monitors -j | jq -r '.[].name')
    
    # Restore saved workspaces
    while IFS=' ' read -r monitor workspace; do
        if [ -n "$monitor" ] && [ -n "$workspace" ]; then
            echo "Switching monitor '$monitor' to workspace $workspace"
            hyprctl dispatch workspace "$workspace"
            hyprctl dispatch focusmonitor "$monitor"
        fi
    done < "$SAVE_FILE"
    
    # Handle monitors that don't have saved workspaces
    while IFS= read -r monitor; do
        if ! grep -q "^$monitor " "$SAVE_FILE"; then
            default_workspace=$(get_default_workspace "$monitor")
            echo "Monitor '$monitor' not in saved file, defaulting to workspace $default_workspace"
            hyprctl dispatch workspace "$default_workspace"
            hyprctl dispatch focusmonitor "$monitor"
        fi
    done <<< "$current_monitors"
    
    echo "Workspaces restored from $SAVE_FILE"
}

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Please install jq: sudo apt install jq (or your package manager equivalent)"
    exit 1
fi

# Validate parameter
if [ $# -ne 1 ]; then
    usage
fi

case "$1" in
    save)
        save_workspaces
        ;;
    release)
        release_workspaces
        ;;
    *)
        usage
        ;;
esac