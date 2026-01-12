#!/bin/bash

# --- CONFIGURATION ---
SIDE_MONITOR="eDP-1"
STATE_FILE="/tmp/hypr_last_main_monitor"
# ---------------------

# Get list of all monitor names
MONITORS=$(hyprctl monitors -j | jq -r '.[] | .name')
MONITOR_COUNT=$(echo "$MONITORS" | wc -l)
CURRENT_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')

# If only 1 monitor, do nothing
if [ "$MONITOR_COUNT" -le 1 ]; then
  exit 0
fi

# Get the two "main" monitors (all monitors minus the side one)
MAIN_MONITORS=($(echo "$MONITORS" | grep -v "$SIDE_MONITOR"))

# Helper to save state
save_main_state() {
  if [[ "$CURRENT_MONITOR" != "$SIDE_MONITOR" ]]; then
    echo "$CURRENT_MONITOR" >"$STATE_FILE"
  fi
}

# Helper to get last main monitor from state
get_last_main() {
  if [ -f "$STATE_FILE" ]; then
    cat "$STATE_FILE"
  else
    # Fallback to the first main monitor if no state exists
    echo "${MAIN_MONITORS[0]}"
  fi
}

case $1 in
main)
  if [ "$MONITOR_COUNT" -eq 2 ]; then
    # 2 Monitors: Just toggle to the one we aren't on
    TARGET=$(echo "$MONITORS" | grep -v "$CURRENT_MONITOR" | head -n 1)
  else
    # 3 Monitors
    if [ "$CURRENT_MONITOR" == "$SIDE_MONITOR" ]; then
      # If on side monitor, go back to the last used main
      TARGET=$(get_last_main)
    else
      # On a main monitor, toggle to the OTHER main monitor
      TARGET=$(echo "${MAIN_MONITORS[@]}" | tr ' ' '\n' | grep -v "$CURRENT_MONITOR" | head -n 1)
      save_main_state
    fi
  fi
  ;;
side)
  if [ "$MONITOR_COUNT" -eq 2 ]; then
    # 2 Monitors: Toggle behavior
    TARGET=$(echo "$MONITORS" | grep -v "$CURRENT_MONITOR" | head -n 1)
  else
    # 3 Monitors
    if [ "$CURRENT_MONITOR" == "$SIDE_MONITOR" ]; then
      # If already on side, return to last main
      TARGET=$(get_last_main)
    else
      # Switch to side, but remember where we were
      save_main_state
      TARGET="$SIDE_MONITOR"
    fi
  fi
  ;;
*)
  echo "Usage: $0 {main|side}"
  exit 1
  ;;
esac

# Execute the focus change
hyprctl dispatch focusmonitor "$TARGET"
