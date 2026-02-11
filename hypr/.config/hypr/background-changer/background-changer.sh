#!/bin/sh

path="$HOME/.config/hypr/background-changer/img"
current_bg_file="$HOME/.config/hypr/background-changer/current_bg"

index="$1"

image=$(ls -1 "$path"/*.jpg "$path"/*.png "$path"/*.jpeg 2>/dev/null | sort | sed -n "$((index + 1))p")

if [ -n "$image" ]; then
    awww img "$image" --transition-type grow --transition-pos center --transition-step 60

    echo "$image" > "$current_bg_file"
else
    notify-send "Wallpaper Error" "No image found at index $index in $path"
fi
