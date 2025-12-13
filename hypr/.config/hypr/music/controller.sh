#!/bin/bash

# Get player status and metadata
player="spotify"  # or "playerctld" for auto-detection
status=$(playerctl -p "$player" status 2>/dev/null)

if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
    artist=$(playerctl -p "$player" metadata artist)
    title=$(playerctl -p "$player" metadata title)
    position=$(playerctl -p "$player" position)
    length=$(playerctl -p "$player" metadata mpris:length)  # in microseconds

    # Convert time to seconds
    pos_s=$(printf "%.0f" "$position")
    len_s=$((length / 1000000))

    # Progress bar (simple)
    percent=$((100 * pos_s / len_s))
    bar=$(printf "%-${percent}s" "#" | tr ' ' '#')
    bar=$(printf "%-20s" "$bar")

    # Output JSON
    echo "{\"text\": \"$artist - $title\", \"alt\": \"$status\", \"tooltip\": \"${pos_s}s / ${len_s}s\", \"class\": \"$status\", \"progress\": $percent}"
else
    echo '{"text": "No music", "class": "stopped"}'
fi
