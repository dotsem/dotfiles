#!/usr/bin/env bash
# ~/.config/hypr/scripts/syncWorkspaceWaybar.sh

# Unique identifier for this script
SCRIPT_ID="waybar_workspaces_$$"

# Kill any previous instances (including those from previous Waybar sessions)
pkill -f "syncWorkspaceWaybar.sh listen"
sleep 0.1  # Brief pause to ensure clean termination

# Atomic file lock with process tracking
LOCK_DIR="/tmp/waybar-workspaces.lock"
mkdir -p "$LOCK_DIR"
{
    flock -n 200 || exit 1
    echo "$$" > "$LOCK_DIR/pid"
    
    # Socket detection with retries
    get_socket() {
        for i in {1..5}; do
            local socket=$(ls -t "$XDG_RUNTIME_DIR/hypr/"*"/.socket2.sock" 2>/dev/null | head -1)
            [ -S "$socket" ] && echo "$socket" && return 0
            sleep 0.5
        done
        return 1
    }

    generate_output() {
        local current=$(hyprctl activeworkspace -j | jq -r '.id' | awk -F'.' '{print $1}')
        local buttons=() classes=()
        
        for i in {1..10}; do
            if [ "$i" -eq "$current" ]; then
                buttons+=("[$i]")
                classes+=("active")
            else
                buttons+=(" $i ")
                classes+=("inactive")
            fi
        done
        
        echo "{\"text\":\"${buttons[*]}\",\"class\":\"${classes[*]}\"}"
    }

    # Main listener with heartbeat
    listen() {
        local socket=$(get_socket) || exit 1
        
        # Initial output
        generate_output
        
        # Event loop with keepalive
        while true; do
            if ! socat -u "UNIX-CONNECT:$socket" - 2>/dev/null | while read -r line; do
                [[ "$line" =~ "workspace>>" || "$line" =~ "focusedmon>>" ]] && generate_output
            done; then
                # Reconnect if socat fails
                socket=$(get_socket) || break
                continue
            fi
            break
        done
    }

    case "$1" in
        listen) listen ;;
        click) 
            local ws="${2//[^0-9]/}"
            [ -n "$ws" ] && hyprctl dispatch workspace "$ws" 
            ;;
        *) generate_output ;;
    esac

    # Cleanup
    rm -f "$LOCK_DIR/pid"
    flock -u 200
} 200>"$LOCK_DIR/lockfile"