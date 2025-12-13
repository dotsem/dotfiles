#!/bin/bash
# ~/.config/hypr/script/moveToSyncWorkspace.sh

WORKSPACES_PER_MONITOR=10

get_monitors() {
    hyprctl monitors -j | jq -r '.[].name' | sort
}

get_current_monitor() {
    hyprctl activewindow -j | jq -r '.monitor'
}

get_monitor_index() {
    local target_monitor=$1
    local monitors=($(get_monitors))
    for i in "${!monitors[@]}"; do
        if [ "${monitors[$i]}" = "$target_monitor" ]; then
            echo "$i"
            return
        fi
    done
    echo "0"
}

calculate_workspace() {
    echo $(($1 * WORKSPACES_PER_MONITOR + $2))
}

move_only() {
    local target_sync_workspace=$1
    local current_monitor=$(get_current_monitor)
    
    if [ "$current_monitor" = "null" ]; then
        notify-send "Error" "No active window!"
        exit 1
    fi

    local monitor_index=$(get_monitor_index "$current_monitor")
    local target_workspace=$(calculate_workspace $monitor_index $target_sync_workspace)
    
    # Use --silent to move without switching
    hyprctl dispatch movetoworkspacesilent "$target_workspace"
}

case "$1" in
    [1-9]|10) move_only "$1" ;;
    *) echo "Usage: $0 <1-10>"; exit 1 ;;
esac