#!/usr/bin/env bash

set -euo pipefail

monitor_num="$1"
click_data="$2"

# Extract workspace number from click data
workspace_num=$(echo "$click_data" | jq -r '.number')

# Calculate actual workspace
actual_ws=$(( (monitor_num - 1) * 10 + workspace_num ))

hyprctl dispatch workspace "$actual_ws"