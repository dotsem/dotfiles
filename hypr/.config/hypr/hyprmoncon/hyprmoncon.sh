#!/bin/sh

LAYOUT_FILE="$HOME/.config/hypr/hyprmoncon/layout.json"
ID_SCRIPT="$HOME/.config/hypr/hyprmoncon/src/edid/get-monitors.sh"

# Check if required files exist
[ ! -f "$LAYOUT_FILE" ] && echo "❌ No layout file found." && exit 1
[ ! -x "$ID_SCRIPT" ] && echo "❌ Missing get-monitors.sh" && exit 1

# Get current monitor IDs (like: eDP-1:hsh:xxx)
mapfile -t MONITOR_IDS < <("$ID_SCRIPT")
CURRENT_IDS=$(printf "%s\n" "${MONITOR_IDS[@]}" | cut -d':' -f2- | sort)

MATCHED_LAYOUT=""

# Loop over each layout in the file
for layout_name in $(jq -r 'keys[]' "$LAYOUT_FILE"); do
    saved_ids=$(jq -r ".\"$layout_name\"[] | .monitor" "$LAYOUT_FILE" | sort)

    # Compare the sorted ID lists
    if [ "$(echo "$CURRENT_IDS")" = "$(echo "$saved_ids")" ]; then
        MATCHED_LAYOUT="$layout_name"
        break
    fi
done

# Apply the matched layout
if [ -n "$MATCHED_LAYOUT" ]; then
    echo "✅ Loaded layout: $MATCHED_LAYOUT"
    jq -r ".[\"$MATCHED_LAYOUT\"][] | 
        \"hyprctl keyword monitor \\(.name),\\(.width)x\\(.height)@60,\\(.x)x\\(.y),\\(.scale)\"" \
        "$LAYOUT_FILE" | while read -r cmd; do
        eval "$cmd"
    done
else
    echo "⚠️ No matching layout found, auto-aligning"
    hyprctl dispatch dpms on
fi
