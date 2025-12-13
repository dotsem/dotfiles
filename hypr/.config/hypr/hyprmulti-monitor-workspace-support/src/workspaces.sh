#!/usr/bin/env bash
# ~/.config/waybar/workspaces.sh

monitor_number=$1

# Get monitor info
monitor=$(hyprctl monitors -j | jq -r ".[$((monitor_number-1))]")
monitor_name=$(echo "$monitor" | jq -r '.name')
monitor_desc=$(echo "$monitor" | jq -r '.description' | cut -d' ' -f1)
active_ws=$(echo "$monitor" | jq -r '.activeWorkspace.id')

# Get workspaces info
workspaces=$(hyprctl workspaces -j)

# Calculate workspace range
start_ws=$((1 + (monitor_number-1) * 10))
end_ws=$((start_ws + 9))

# Check if this is the active monitor
active_monitor=$(hyprctl activewindow -j | jq -r '.monitor')
[[ "$active_monitor" == "null" ]] && active_monitor=$(hyprctl monitors -j | jq -r '.[0].name')
is_active=$([[ "$monitor_name" == "$active_monitor" ]] && echo "active-monitor" || echo "")

# Build workspace buttons
ws_buttons=()
for ((ws=start_ws; ws<=end_ws; ws++)); do
    ws_num=$((ws - start_ws + 1))
    class=""
    
    # Check if workspace exists
    if echo "$workspaces" | jq -e ".[] | select(.id == $ws)" >/dev/null; then
        class="occupied"
    fi
    
    # Check if active workspace
    [[ "$ws" == "$active_ws" ]] && class="active"
    
    ws_buttons+=("{\"number\": $ws_num, \"class\": \"$class\"}")
done

# Output for Waybar
echo "{
    \"text\": \"$monitor_desc: $(printf '%d ' "${ws_buttons[@]}")\",
    \"tooltip\": \"Monitor $monitor_number ($monitor_name)\",
    \"class\": \"$is_active\"
}"