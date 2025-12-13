#!/bin/bash
# Save as ~/.config/hypr/scripts/sync-workspace.sh
# Make executable: chmod +x ~/.config/hypr/scripts/sync-workspace.sh

# Configuration
WORKSPACES_PER_MONITOR=10
STATE_FILE="$HOME/.config/hypr/current_sync_workspace"

# Get current sync workspace from state file
get_current_sync_workspace() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "1"
    fi
}

# Save current sync workspace to state file
save_current_sync_workspace() {
    echo "$1" > "$STATE_FILE"
}

# Get monitor information dynamically with eDP-1 always first
get_monitors() {
    local all_monitors=($(hyprctl monitors -j | jq -r '.[].name'))
    local ordered_monitors=()
    
    # Always put eDP-1 first if it exists (laptop)
    for monitor in "${all_monitors[@]}"; do
        if [ "$monitor" = "eDP-1" ]; then
            ordered_monitors+=("$monitor")
            break
        fi
    done
    
    # Add all other monitors in their natural order (excluding eDP-1)
    for monitor in "${all_monitors[@]}"; do
        if [ "$monitor" != "eDP-1" ]; then
            ordered_monitors+=("$monitor")
        fi
    done
    
    # Output the ordered monitors
    printf '%s\n' "${ordered_monitors[@]}"
}

# Calculate workspace for a monitor and sync workspace number
calculate_workspace() {
    local monitor_index=$1
    local sync_workspace=$2
    echo $(( (monitor_index * WORKSPACES_PER_MONITOR) + sync_workspace ))
}

# Main switching logic with mouse position preservation
switch_to_sync_workspace() {
    local target_workspace=$1
    
    # Validate workspace number
    if [ "$target_workspace" -lt 1 ] || [ "$target_workspace" -gt "$WORKSPACES_PER_MONITOR" ]; then
        echo "Error: Workspace must be between 1 and $WORKSPACES_PER_MONITOR"
        exit 1
    fi
    
    # Get current mouse position and which monitor it's on
    local mouse_info=$(hyprctl cursorpos)
    local mouse_x=$(echo "$mouse_info" | cut -d',' -f1)
    local mouse_y=$(echo "$mouse_info" | cut -d',' -f2)
    
    # Find which monitor the mouse is currently on
    local current_mouse_monitor=""
    local current_mouse_monitor_index=-1
    
    local monitors=($(get_monitors))
    local monitor_count=${#monitors[@]}
    
    for i in "${!monitors[@]}"; do
        local monitor="${monitors[$i]}"
        local monitor_info=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\")")
        local monitor_x=$(echo "$monitor_info" | jq -r '.x')
        local monitor_y=$(echo "$monitor_info" | jq -r '.y') 
        local monitor_width=$(echo "$monitor_info" | jq -r '.width')
        local monitor_height=$(echo "$monitor_info" | jq -r '.height')
        
        # Check if mouse is within this monitor's bounds
        if [ "$mouse_x" -ge "$monitor_x" ] && [ "$mouse_x" -lt "$((monitor_x + monitor_width))" ] && \
           [ "$mouse_y" -ge "$monitor_y" ] && [ "$mouse_y" -lt "$((monitor_y + monitor_height))" ]; then
            current_mouse_monitor="$monitor"
            current_mouse_monitor_index=$i
            break
        fi
    done
    
    if [ "$monitor_count" -eq 0 ]; then
        echo "Error: No monitors found"
        exit 1
    fi
    
    # Switch each monitor to its corresponding workspace
    for i in "${!monitors[@]}"; do
        local monitor="${monitors[$i]}"
        local workspace=$(calculate_workspace "$i" "$target_workspace")
        
        # Focus the monitor and switch to the calculated workspace
        hyprctl dispatch focusmonitor "$monitor"
        hyprctl dispatch workspace "$workspace"
    done
    
    # If we found where the mouse was, focus back to that monitor's new workspace
    if [ "$current_mouse_monitor_index" -ge 0 ]; then
        local target_monitor="${monitors[$current_mouse_monitor_index]}"
        local target_workspace_for_mouse=$(calculate_workspace "$current_mouse_monitor_index" "$target_workspace")
        hyprctl dispatch focusmonitor "$target_monitor"
        hyprctl dispatch workspace "$target_workspace_for_mouse"
    fi
    
    # Save the current sync workspace
    save_current_sync_workspace "$target_workspace"
    
    echo "Switched to sync workspace $target_workspace (monitors: ${monitors[*]})"
    if [ -n "$current_mouse_monitor" ]; then
        echo "Mouse focus maintained on monitor $current_mouse_monitor"
    fi
}

# Handle input parameter
workspace_input=$1

case "$workspace_input" in
    "next")
        current=$(get_current_sync_workspace)
        next_workspace=$((current + 1))
        if [ "$next_workspace" -gt "$WORKSPACES_PER_MONITOR" ]; then
            next_workspace=1
        fi
        switch_to_sync_workspace "$next_workspace"
        ;;
    "prev")
        current=$(get_current_sync_workspace)
        prev_workspace=$((current - 1))
        if [ "$prev_workspace" -lt 1 ]; then
            prev_workspace="$WORKSPACES_PER_MONITOR"
        fi
        switch_to_sync_workspace "$prev_workspace"
        ;;
    [1-9]|10)
        switch_to_sync_workspace "$workspace_input"
        ;;
    *)
        echo "Usage: $0 <1-10|next|prev>"
        echo "Current sync workspace: $(get_current_sync_workspace)"
        exit 1
        ;;
esac