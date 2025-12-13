#!/bin/bash
# Handle workspace and window management when monitor mirroring changes
# This script ensures windows on mirrored monitors are properly handled

SCRIPT_DIR="$(dirname "$0")"

# Get list of all monitors and their mirror status
get_monitor_info() {
    hyprctl monitors -j | jq -r '.[] | "\(.name):\(.mirrorOf)"'
}

# Get list of visible (non-mirrored) monitors
get_visible_monitors() {
    hyprctl monitors -j | jq -r '.[] | select(.mirrorOf == "") | .name'
}

# Get list of mirrored monitors
get_mirrored_monitors() {
    hyprctl monitors -j | jq -r '.[] | select(.mirrorOf != "") | .name'
}

# Get workspaces on a specific monitor
get_workspaces_on_monitor() {
    local monitor="$1"
    hyprctl workspaces -j | jq -r ".[] | select(.monitor == \"$monitor\") | .id"
}

# Get active workspace on a monitor
get_active_workspace_on_monitor() {
    local monitor="$1"
    hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\") | .activeWorkspace.id"
}

# Get windows on a workspace
get_windows_on_workspace() {
    local workspace="$1"
    hyprctl clients -j | jq -r ".[] | select(.workspace.id == $workspace) | .address"
}

# Move window to workspace
move_window_to_workspace() {
    local window="$1"
    local workspace="$2"
    hyprctl dispatch movetoworkspace "$workspace,address:$window"
}

# Function to handle mirror enable (monitor becomes mirrored)
handle_mirror_enable() {
    local mirrored_monitor="$1"
    local source_monitor="$2"
    
    echo "Monitor $mirrored_monitor is now mirroring $source_monitor"
    
    # Get workspaces on the mirrored monitor
    local workspaces=$(get_workspaces_on_monitor "$mirrored_monitor")
    
    if [ -z "$workspaces" ]; then
        echo "No workspaces on $mirrored_monitor to migrate"
        return 0
    fi
    
    # Get first visible workspace on source monitor
    local target_workspace=$(get_active_workspace_on_monitor "$source_monitor")
    
    if [ -z "$target_workspace" ]; then
        echo "Warning: Could not find target workspace on $source_monitor"
        return 1
    fi
    
    echo "Migrating windows from $mirrored_monitor to workspace $target_workspace"
    
    # For each workspace on the mirrored monitor
    while read -r workspace; do
        echo "  Processing workspace $workspace"
        
        # Get all windows on this workspace
        local windows=$(get_windows_on_workspace "$workspace")
        
        # Move each window to the target workspace
        while read -r window; do
            if [ -n "$window" ]; then
                echo "    Moving window $window to workspace $target_workspace"
                move_window_to_workspace "$window" "$target_workspace"
            fi
        done <<< "$windows"
    done <<< "$workspaces"
    
    echo "Migration complete"
}

# Function to handle mirror disable (monitor becomes independent)
handle_mirror_disable() {
    local monitor="$1"
    
    echo "Monitor $monitor is now independent"
    
    # Create or switch to a workspace on this monitor
    local new_workspace=$(get_active_workspace_on_monitor "$monitor")
    
    if [ -z "$new_workspace" ]; then
        # Find an unused workspace ID
        local used_workspaces=$(hyprctl workspaces -j | jq -r '.[].id' | sort -n)
        local new_id=1
        while echo "$used_workspaces" | grep -q "^$new_id$"; do
            ((new_id++))
        done
        
        echo "Creating new workspace $new_id on $monitor"
        hyprctl dispatch workspace "$new_id"
        hyprctl dispatch moveworkspacetomonitor "$new_id" "$monitor"
    fi
}

# Function to reorganize workspaces after mirror change
reorganize_after_mirror_change() {
    echo "Reorganizing workspaces after mirror configuration change..."
    
    # Get current mirror state
    local monitor_info=$(get_monitor_info)
    
    # Check each monitor
    while IFS=: read -r monitor mirror_of; do
        if [ -n "$mirror_of" ]; then
            # Monitor is mirroring another
            handle_mirror_enable "$monitor" "$mirror_of"
        else
            # Monitor is independent
            # Check if it has any workspaces, if not create one
            local workspaces=$(get_workspaces_on_monitor "$monitor")
            if [ -z "$workspaces" ]; then
                echo "Monitor $monitor has no workspaces, ensuring it has one..."
                handle_mirror_disable "$monitor"
            fi
        fi
    done <<< "$monitor_info"
    
    # Run the standard workspace reorganization
    if [ -f "$SCRIPT_DIR/reorganizeWorkspaces.sh" ]; then
        echo "Running standard workspace reorganization..."
        "$SCRIPT_DIR/reorganizeWorkspaces.sh"
    fi
}

# Function to save state before mirroring
save_state_before_mirror() {
    local monitor="$1"
    local cache_dir="$HOME/.cache/hypr_flutter"
    mkdir -p "$cache_dir"
    
    echo "Saving state for monitor $monitor before mirroring..."
    
    # Save active workspace
    local active_ws=$(get_active_workspace_on_monitor "$monitor")
    echo "$active_ws" > "$cache_dir/mirror_restore_workspace_$monitor"
    
    # Save workspace list
    get_workspaces_on_monitor "$monitor" > "$cache_dir/mirror_restore_workspaces_$monitor"
    
    echo "State saved for $monitor"
}

# Function to restore state after mirror disable
restore_state_after_mirror() {
    local monitor="$1"
    local cache_dir="$HOME/.cache/hypr_flutter"
    
    if [ ! -f "$cache_dir/mirror_restore_workspace_$monitor" ]; then
        echo "No saved state for $monitor"
        return 1
    fi
    
    echo "Restoring state for monitor $monitor..."
    
    local saved_workspace=$(cat "$cache_dir/mirror_restore_workspace_$monitor")
    
    # Try to restore the workspace to this monitor
    if [ -n "$saved_workspace" ]; then
        echo "Restoring workspace $saved_workspace to $monitor"
        hyprctl dispatch moveworkspacetomonitor "$saved_workspace" "$monitor"
        hyprctl dispatch workspace "$saved_workspace"
    fi
    
    # Clean up cache
    rm -f "$cache_dir/mirror_restore_workspace_$monitor"
    rm -f "$cache_dir/mirror_restore_workspaces_$monitor"
    
    echo "State restored for $monitor"
}

# Main command handling
case "${1:-}" in
    reorganize)
        reorganize_after_mirror_change
        ;;
    enable)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 enable <mirrored_monitor> <source_monitor>"
            exit 1
        fi
        save_state_before_mirror "$2"
        handle_mirror_enable "$2" "$3"
        ;;
    disable)
        if [ -z "$2" ]; then
            echo "Usage: $0 disable <monitor>"
            exit 1
        fi
        handle_mirror_disable "$2"
        restore_state_after_mirror "$2"
        ;;
    *)
        echo "Usage: $0 {reorganize|enable|disable}"
        echo ""
        echo "Commands:"
        echo "  reorganize                           - Reorganize all workspaces after mirror changes"
        echo "  enable <mirror_monitor> <source>     - Handle mirror enable for a monitor"
        echo "  disable <monitor>                    - Handle mirror disable for a monitor"
        exit 1
        ;;
esac
