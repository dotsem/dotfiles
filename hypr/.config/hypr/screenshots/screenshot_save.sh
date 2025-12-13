#!/bin/bash
file=~/Pictures/screenshot_$(date +%s).png
grim -g "$(slurp)" "$file" && wl-copy < "$file"