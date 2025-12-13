#!/usr/bin/env bash
# ~/.config/hypr/workspace_nav.sh

set -euo pipefail

get_active_monitor_workspaces() {
    # Get the focused monitor (even if no active window)
    focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
    if [[ -z "$focused_monitor" ]]; then
        focused_monitor=$(hyprctl monitors -j | jq -r '.[0].name')
    fi

    # Get all monitors and find our index
    monitors=$(hyprctl monitors -j)
    monitor_count=$(echo "$monitors" | jq 'length')
    monitor_index=0
    
    for ((i=0; i<monitor_count; i++)); do
        monitor_name=$(echo "$monitors" | jq -r ".[$i].name")
        if [[ "$monitor_name" == "$focused_monitor" ]]; then
            monitor_index=$i
            break
        fi
    done

    # Calculate workspace range
    start_ws=$((1 + monitor_index * 10))
    end_ws=$((start_ws + 9))
    current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

    echo "$focused_monitor $current_ws $start_ws $end_ws"
}

goto_workspace() {
    read -r focused_monitor current_ws start_ws end_ws <<< "$(get_active_monitor_workspaces)"
    target_ws=$((start_ws + $1 - 1))
    hyprctl dispatch workspace "$target_ws"
}

next_workspace() {
    read -r focused_monitor current_ws start_ws end_ws <<< "$(get_active_monitor_workspaces)"
    next_ws=$((current_ws + 1))
    [[ $next_ws -gt $end_ws ]] && next_ws=$start_ws
    hyprctl dispatch workspace "$next_ws"
}

prev_workspace() {
    read -r focused_monitor current_ws start_ws end_ws <<< "$(get_active_monitor_workspaces)"
    prev_ws=$((current_ws - 1))
    [[ $prev_ws -lt $start_ws ]] && prev_ws=$end_ws
    hyprctl dispatch workspace "$prev_ws"
}

show_info() {
    read -r focused_monitor current_ws start_ws end_ws <<< "$(get_active_monitor_workspaces)"
    echo "Focused Monitor: $focused_monitor"
    echo "Current Workspace: $current_ws"
    echo "Monitor Range: $start_ws-$end_ws"
}

case "$1" in
    next) next_workspace ;;
    prev) prev_workspace ;;
    goto) 
        [[ -z "$2" || ! "$2" =~ ^[1-9]$|^10$ ]] && {
            echo "Usage: $0 goto <1-10>"
            exit 1
        }
        goto_workspace "$2" 
        ;;
    info) show_info ;;
    *) echo "Usage: $0 {next|prev|goto <1-10>|info}"; exit 1 ;;
esac

pkill -RTMIN+8 waybar
