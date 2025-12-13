#!/bin/bash

# This script handles the complete mirror setup/teardown process
# It coordinates workspace migration and state saving

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/hypr"

usage() {
    echo "Usage: $0 <enable|disable> <monitor_name> [source_monitor]"
    echo ""
    echo "Commands:"
    echo "  enable  <monitor> <source> - Enable mirroring: monitor will mirror source"
    echo "  disable <monitor>           - Disable mirroring for the specified monitor"
    echo ""
    echo "Examples:"
    echo "  $0 enable HDMI-A-1 eDP-1   # HDMI-A-1 will mirror eDP-1"
    echo "  $0 disable HDMI-A-1        # HDMI-A-1 returns to independent display"
    exit 1
}

enable_mirror() {
    local mirror_monitor="$1"
    local source_monitor="$2"
    
    if [ -z "$mirror_monitor" ] || [ -z "$source_monitor" ]; then
        echo "Error: Both mirror and source monitor must be specified"
        usage
    fi
    
    echo "=== Enabling Mirror: $mirror_monitor -> $source_monitor ==="
    
    # 1. Save current mirror state before making changes
    echo "Step 1: Saving current mirror state..."
    "$SCRIPT_DIR/mirrorCache.sh" save
    
    # 2. Get current config for the monitor to be mirrored
    echo "Step 2: Getting monitor configuration..."
    local monitor_config=$(hyprctl monitors -j | jq -r --arg mon "$mirror_monitor" \
        '.[] | select(.name == $mon) | "\(.width)x\(.height)@\(.refreshRate),\(.x)x\(.y),\(.scale)"')
    
    if [ -z "$monitor_config" ]; then
        echo "Error: Could not find monitor '$mirror_monitor'"
        notify-send -u critical "Hyprland Mirror" "Monitor '$mirror_monitor' not found"
        return 1
    fi
    
    # 3. Apply mirror configuration
    echo "Step 3: Applying mirror configuration..."
    echo "  Config: $mirror_monitor,$monitor_config,mirror,$source_monitor"
    hyprctl keyword monitor "$mirror_monitor,$monitor_config,mirror,$source_monitor"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to apply mirror configuration"
        notify-send -u critical "Hyprland Mirror" "Failed to mirror $mirror_monitor"
        return 1
    fi
    
    # 4. Wait for Hyprland to update
    sleep 0.5
    
    # 5. Migrate workspaces and windows
    echo "Step 4: Migrating workspaces and windows..."
    "$SCRIPT_DIR/reorganizeMirroredWorkspaces.sh" "$mirror_monitor"
    
    echo "=== Mirror Enabled Successfully ==="
    notify-send "Hyprland Mirror" "$mirror_monitor is now mirroring $source_monitor"
}

disable_mirror() {
    local monitor="$1"
    
    if [ -z "$monitor" ]; then
        echo "Error: Monitor name must be specified"
        usage
    fi
    
    echo "=== Disabling Mirror: $monitor ==="
    
    # 1. Check if monitor is actually mirroring
    local mirror_of=$(hyprctl monitors -j | jq -r --arg mon "$monitor" \
        '.[] | select(.name == $mon) | .mirrorOf // "none"')
    
    if [ "$mirror_of" = "none" ] || [ -z "$mirror_of" ]; then
        echo "Monitor '$monitor' is not currently mirroring"
        notify-send "Hyprland Mirror" "$monitor is not mirroring"
        return 0
    fi
    
    echo "  Currently mirroring: $mirror_of"
    
    # 2. Save current state before disabling
    echo "Step 1: Saving current mirror state..."
    "$SCRIPT_DIR/mirrorCache.sh" save
    
    # 3. Get monitor's current config without mirror
    echo "Step 2: Getting monitor configuration..."
    local monitor_config=$(hyprctl monitors -j | jq -r --arg mon "$monitor" \
        '.[] | select(.name == $mon) | "\(.width)x\(.height)@\(.refreshRate),\(.x)x\(.y),\(.scale)"')
    
    if [ -z "$monitor_config" ]; then
        echo "Error: Could not find monitor '$monitor'"
        return 1
    fi
    
    # 4. Remove mirror configuration
    echo "Step 3: Removing mirror configuration..."
    echo "  Config: $monitor,$monitor_config"
    hyprctl keyword monitor "$monitor,$monitor_config"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to disable mirror"
        notify-send -u critical "Hyprland Mirror" "Failed to disable mirror for $monitor"
        return 1
    fi
    
    # 5. Wait for Hyprland to update
    sleep 0.5
    
    # 6. Reorganize workspaces
    echo "Step 4: Reorganizing workspaces..."
    "$SCRIPT_DIR/reorganizeMirroredWorkspaces.sh"
    
    echo "=== Mirror Disabled Successfully ==="
    notify-send "Hyprland Mirror" "$monitor is now an independent display"
}

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Please install jq: sudo pacman -S jq (or your package manager equivalent)"
    exit 1
fi

# Validate parameters
if [ $# -lt 2 ]; then
    usage
fi

COMMAND="$1"
MONITOR="$2"
SOURCE_MONITOR="${3:-}"

case "$COMMAND" in
    enable)
        if [ -z "$SOURCE_MONITOR" ]; then
            echo "Error: Source monitor must be specified for enable command"
            usage
        fi
        enable_mirror "$MONITOR" "$SOURCE_MONITOR"
        ;;
    disable)
        disable_mirror "$MONITOR"
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'"
        usage
        ;;
esac
