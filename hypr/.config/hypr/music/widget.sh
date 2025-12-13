#!/bin/bash

# Configuration
PLAYER="spotify"

# Function to generate single-line JSON
generate_json() {
    local text="$1"
    local alt="$2"
    local class="$3"
    local buttons="$4"
    
    # Create single-line JSON with no newlines
    echo -n "{"
    echo -n "\"text\":\"$text\","
    echo -n "\"alt\":\"$alt\","
    echo -n "\"class\":\"$class\","
    echo -n "\"tooltip\":\"$text\""
    [[ -n "$buttons" ]] && echo -n ",$buttons"
    echo -n "}"
}

# Get player status
status=$(playerctl -p "$PLAYER" status 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo "stopped")

if [[ "$status" == "playing" || "$status" == "paused" ]]; then
    # Get metadata
    artist=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null || echo "Unknown Artist")
    title=$(playerctl -p "$PLAYER" metadata title 2>/dev/null || echo "Unknown Track")
    text_content="$artist - $title"
    
    # Escape JSON special characters
    text_content=${text_content//\"/\\\"}
    
    # Create buttons JSON
    play_pause_icon=$( [ "$status" == "playing" ] && echo "⏸" || echo "▶" )
    buttons="\"buttons\":[{\"identifier\":\"prev\",\"label\":\"⏮\"},{\"identifier\":\"play\",\"label\":\"$play_pause_icon\"},{\"identifier\":\"next\",\"label\":\"⏭\"}]"
    
    generate_json "$text_content" "$status" "$status" "$buttons"
else
    generate_json "No music" "stopped" "stopped" ""
fi