#!/usr/bin/env bash
set -euo pipefail

# toggle_monitor.sh
# Usage: toggle_monitor.sh primary|secondary
# Behavior:
# - If 3 monitors: "primary" toggles between the two non-eDP-1 outputs.
#   "secondary" toggles between the current primary and eDP-1 (stores last primary).
# - If 2 monitors: both modes toggle between the two outputs.

STATE_FILE="/tmp/niri-secondary-last"
SECONDARY_NAME="eDP-1"

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 primary|secondary" >&2
  exit 2
fi

MODE="$1"
if [[ "$MODE" != "primary" && "$MODE" != "secondary" ]]; then
  echo "Invalid mode: $MODE" >&2
  echo "Use 'primary' or 'secondary'" >&2
  exit 2
fi

XRR=$(xrandr --query)

# Gather connected outputs in order of appearance
mapfile -t OUTPUTS < <(echo "$XRR" | awk '/ connected/ {print $1}')
NUM=${#OUTPUTS[@]}

if [ $NUM -lt 2 ]; then
  echo "Need at least 2 connected monitors (found $NUM)" >&2
  exit 1
fi

# Find current primary (the output whose line contains " primary")
CURRENT_PRIMARY=$(echo "$XRR" | awk '/ connected/ {if ($0 ~ / primary /) print $1}')
if [ -z "$CURRENT_PRIMARY" ]; then
  # If none marked primary, use first connected as current
  CURRENT_PRIMARY=${OUTPUTS[0]}
fi

# Build primaries list: if 3 outputs, exclude eDP-1; if 2, include both
PRIMARIES=()
if [ "$NUM" -eq 3 ]; then
  for o in "${OUTPUTS[@]}"; do
    if [ "$o" != "$SECONDARY_NAME" ]; then
      PRIMARIES+=("$o")
    fi
  done
else
  # 2 or more (>=4 treated like 2 for this script's logic)
  PRIMARIES=("${OUTPUTS[@]}")
fi

toggle_to() {
  target="$1"
  if [ -z "$target" ]; then
    echo "No target to toggle to" >&2
    exit 1
  fi
  echo "Setting primary -> $target"
  xrandr --output "$target" --primary
}

if [ "$MODE" = "primary" ]; then
  # Toggle between the two primaries
  if [ ${#PRIMARIES[@]} -lt 2 ]; then
    # fallback: if only one in primaries, pick any other output
    for o in "${OUTPUTS[@]}"; do
      if [ "$o" != "${PRIMARIES[0]}" ]; then
        toggle_to "$o"
        exit 0
      fi
    done
  fi

  # Find other primary (the one in PRIMARIES that's not current)
  other=""
  for p in "${PRIMARIES[@]}"; do
    if [ "$p" != "$CURRENT_PRIMARY" ]; then
      other="$p"
      break
    fi
  done

  if [ -z "$other" ]; then
    # cycle to first
    other="${PRIMARIES[0]}"
  fi

  toggle_to "$other"

else
  # secondary mode
  if [ "$NUM" -eq 3 ]; then
    if [ "$CURRENT_PRIMARY" = "$SECONDARY_NAME" ]; then
      # toggle back to last saved primary
      if [ -f "$STATE_FILE" ]; then
        last=$(cat "$STATE_FILE")
        # validate last is connected
        found=false
        for o in "${OUTPUTS[@]}"; do
          if [ "$o" = "$last" ]; then
            found=true
            break
          fi
        done
        if [ "$found" = true ]; then
          toggle_to "$last"
        else
          # fallback to first primary
          toggle_to "${PRIMARIES[0]}"
        fi
      else
        toggle_to "${PRIMARIES[0]}"
      fi
    else
      # save current and switch to eDP-1
      echo "$CURRENT_PRIMARY" > "$STATE_FILE"
      toggle_to "$SECONDARY_NAME"
    fi
  else
    # 2 monitors: behave like primary toggle between the two outputs
    other=""
    for o in "${OUTPUTS[@]}"; do
      if [ "$o" != "$CURRENT_PRIMARY" ]; then
        other="$o"
        break
      fi
    done
    toggle_to "$other"
  fi
fi

exit 0
