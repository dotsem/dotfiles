#!/bin/sh

for edid_path in /sys/class/drm/*/edid; do
  if [ -r "$edid_path" ]; then
    hex=$(xxd -p "$edid_path" | tr -d '\n')
    len=$(echo "$hex" | wc -c)

    if [ "$len" -lt 256 ]; then
      continue
    fi

    # Try to extract serial
    serial=""
    for i in 0 1 2 3; do
      off=$((108 + i * 36))
      tag=${hex:$((off + 6)):2}
      if [ "$tag" = "ff" ]; then
        raw=${hex:$((off + 10)):26}
        serial=$(echo "$raw" | xxd -r -p | tr -d '\0' | tr -d '\n' | sed 's/ *$//')
        break
      fi
    done

    port=$(basename "$(dirname "$edid_path")" | sed 's/^card[0-9]-//')

    if [ -n "$serial" ]; then
      echo "$port:ser:$serial"
    else
      hash=$(sha256sum "$edid_path" | cut -d' ' -f1)
      echo "$port:hsh:$hash"
    fi
  fi
done
