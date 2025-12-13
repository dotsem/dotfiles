#!/bin/sh

path="$HOME/.config/hypr/background-changer/img"
config="$HOME/.config/hypr/hyprpaper.conf"

index="$1"


# Get the image at the specified index (0-based)
image=$(ls -1 "$path"/*.jpg "$path"/*.png "$path"/*.jpeg 2>/dev/null | sort | sed -n "$((index + 1))p")

if [ -n "$image" ]; then
    for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do
        hyprctl hyprpaper preload "$image"
        hyprctl hyprpaper wallpaper "$monitor,$image"
    done
    hyprctl hyprpaper reload

    sed -i "s|^\$bgImg = .*|\$bgImg = $image|" "$config"


else
    notify-send "Wallpaper Error" "No image found at index $index in $path"
fi
