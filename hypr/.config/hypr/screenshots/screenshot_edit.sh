#!/bin/bash
file=~/Pictures/screenshot_$(date +%s).png
grim -g "$(slurp)" - | tee "$file" | swappy -f - && wl-copy < "$file"