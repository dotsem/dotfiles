#!/bin/bash

# This script handles workspace migration when monitors are mirrored or unmirrored
# It ensures windows on mirrored monitors are moved to visible workspaces

CONFIG_DIR="$HOME/.config/hypr"

usage() {
    echo "Usage: $0 [monitor_name]"
    echo "  monitor_name - (Optional) Specific monitor that was just mirrored"
    echo "  If no monitor specified, checks all mirrored monitors"
    exit 1
}

get_mirrored_monitors() {
    # Get list of monitors that are currently mirroring another monitor
    hyprctl monitors -j | jq -r '.[] | select(.mirrorOf != null and .mirrorOf != "none") | .name'
}

get_active_monitors() {
    # Get list of monitors that are NOT mirroring (these are the visible ones)
    hyprctl monitors -j | jq -r '.[] | select(.mirrorOf == null or .mirrorOf == "none") | .name'
}

get_monitor_workspaces() {
    local monitor="$1"
    # Get all workspace IDs assigned to this monitor
    hyprctl monitors -j | jq -r --arg mon "$monitor" '.[] | select(.name == $mon) | .activeWorkspace.id'
}

find_target_monitor_for_workspace() {
    local ws_id="$1"
    # Find which active (non-mirrored) monitor should own this workspace based on ID range
    local active_monitors
    mapfile -t active_monitors < <(get_active_monitors)
    
    # Calculate which monitor range this workspace falls into
    local monitor_index=$(( (ws_id - 1) / 10 ))
    
    if [ "$monitor_index" -lt "${#active_monitors[@]}" ]; then
        echo "${active_monitors[$monitor_index]}"
    else
        # If out of range, use the last active monitor
        echo "${active_monitors[-1]}"
    fi
}

migrate_windows_from_mirrored_monitors() {
    local specific_monitor="$1"
    
    # Get all mirrored monitors
    local mirrored_monitors
    if [ -n "$specific_monitor" ]; then
        mirrored_monitors="$specific_monitor"
    else
        mapfile -t mirrored_monitors < <(get_mirrored_monitors)
    fi
    
    if [ ${#mirrored_monitors[@]} -eq 0 ]; then
        echo "No mirrored monitors found"
        return 0
    fi
    
    # Get all active (non-mirrored) monitors
    local active_monitors
    mapfile -t active_monitors < <(get_active_monitors)
    
    if [ ${#active_monitors[@]} -eq 0 ]; then
        echo "Error: No active monitors found!"
        notify-send -u critical "Hyprland Mirror" "No active monitors available"
        return 1
    fi
    
    echo "Active monitors: ${active_monitors[*]}"
    echo "Mirrored monitors: ${mirrored_monitors[*]}"
    
    local migrated_windows=0
    
    # For each mirrored monitor, move its windows to appropriate workspaces
    for mirrored_mon in "${mirrored_monitors[@]}"; do
        if [ -z "$mirrored_mon" ]; then continue; fi
        
        echo "Processing mirrored monitor: $mirrored_mon"
        
        # Get all windows on this monitor's workspaces
        # Note: Hyprland might still show workspaces on mirrored monitors, 
        # but they won't be visible
        local windows
        mapfile -t windows < <(hyprctl clients -j | jq -r --arg mon "$mirrored_mon" '.[] | select(.monitor == $mon) | "\(.address) \(.workspace.id)"')
        
        if [ ${#windows[@]} -eq 0 ]; then
            echo "No windows found on mirrored monitor $mirrored_mon"
            continue
        fi
        
        for win_info in "${windows[@]}"; do
            if [ -z "$win_info" ]; then continue; fi
            
            local win_addr=$(echo "$win_info" | awk '{print $1}')
            local ws_id=$(echo "$win_info" | awk '{print $2}')
            
            # Find the appropriate target monitor for this workspace ID
            local target_monitor=$(find_target_monitor_for_workspace "$ws_id")
            
            if [ -z "$target_monitor" ]; then
                # Fallback to first active monitor
                target_monitor="${active_monitors[0]}"
            fi
            
            echo "  Moving window $win_addr from workspace $ws_id to monitor $target_monitor"
            
            # Move the workspace to the target monitor first
            hyprctl dispatch moveworkspacetomonitor "$ws_id $target_monitor" 2>/dev/null
            
            # Focus the workspace to ensure it's active
            hyprctl dispatch workspace "$ws_id" 2>/dev/null
            
            ((migrated_windows++))
        done
    done
    
    if [ "$migrated_windows" -gt 0 ]; then
        notify-send "Hyprland Mirror" "Migrated $migrated_windows window(s) from mirrored monitor(s)"
        echo "Successfully migrated $migrated_windows windows"
    else
        echo "No windows needed migration"
    fi
}

reorganize_workspaces_after_mirror() {
    echo "Reorganizing workspaces after mirror change..."
    
    # Get all active (non-mirrored) monitors
    local active_monitors
    mapfile -t active_monitors < <(get_active_monitors)
    local monitor_count=${#active_monitors[@]}
    
    if [ "$monitor_count" -eq 0 ]; then
        echo "Error: No active monitors found!"
        return 1
    fi
    
    echo "Active monitor count: $monitor_count"
    
    # Assign workspaces to active monitors
    for i in "${!active_monitors[@]}"; do
        local mon="${active_monitors[$i]}"
        local base=$((i * 10))
        
        for ws in $(seq $((base + 1)) $((base + 10))); do
            echo "  Assigning workspace $ws to monitor $mon"
            hyprctl dispatch moveworkspacetomonitor "$ws $mon" 2>/dev/null
        done
    done
    
    echo "Workspace reorganization complete"
}

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Please install jq: sudo pacman -S jq (or your package manager equivalent)"
    exit 1
fi

# Main execution
SPECIFIC_MONITOR="${1:-}"

echo "=== Hyprland Mirror Workspace Migration ==="
echo "Timestamp: $(date)"

# First, migrate any windows from mirrored monitors
migrate_windows_from_mirrored_monitors "$SPECIFIC_MONITOR"

# Then reorganize workspaces to ensure they're properly assigned
reorganize_workspaces_after_mirror

echo "=== Migration Complete ==="
