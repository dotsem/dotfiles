#!/usr/bin/env bash
# ~/.config/hypr/monitor_detector.sh

set -euo pipefail

# Get monitors in order from your existing script or hyprctl
# Using your format: OUTPUT:serial:identifier
detect_monitors() {
    # Use your existing monitor detection script or replace with:
    hyprctl monitors -j | jq -r '.[] | "\(.name):\(.description)"'
}

generate_workspace_config() {
    local monitor_list="$1"
    local config_file="$2"
    
    echo "# Auto-generated workspace configuration" > "$config_file"
    
    local monitor_index=0
    while IFS= read -r monitor; do
        local output=$(echo "$monitor" | cut -d':' -f1)
        local monitor_desc=$(echo "$monitor" | cut -d':' -f2- | cut -d' ' -f1)
        monitor_index=$((monitor_index + 1))
        
        # Calculate workspace range
        local start_ws=$((1 + (monitor_index - 1) * 10))
        local end_ws=$((monitor_index * 10))
        
        # Generate workspace lines
        for ((ws=start_ws; ws<=end_ws; ws++)); do
            echo "workspace = $ws, monitor:$output, default:$([ $ws -eq $start_ws ] && echo "true" || echo "false")" >> "$config_file"
        done
        
        # Create Waybar config symlink
        mkdir -p "$HOME/.config/waybar/monitor-$monitor_index"
        ln -sf "$HOME/.config/waybar/config.jsonc" "$HOME/.config/waybar/monitor-$monitor_index/config.jsonc"
        ln -sf "$HOME/.config/waybar/style.css" "$HOME/.config/waybar/monitor-$monitor_index/style.css"
        
    done <<< "$monitor_list"
}

main() {
    local monitor_list=$(detect_monitors)
    if [[ -z "$monitor_list" ]]; then
        echo "ERROR: No monitors detected!" >&2
        exit 1
    fi
    
    local temp_file=$(mktemp)
    generate_workspace_config "$monitor_list" "$temp_file"
    
    local config_file="$HOME/.config/hypr/monitor_workspaces.conf"
    mv "$temp_file" "$config_file"
    
    echo "Generated workspace config for $(echo "$monitor_list" | wc -l) monitors"
}

main