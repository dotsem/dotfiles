#!/usr/bin/env python3

import os
import sys
import json
import subprocess
from time import sleep
from PIL import Image
import base64
import tempfile

def get_active_player():
    try:
        # Try multiple times to find the player
        for _ in range(5):
            players = subprocess.check_output(
                ["playerctl", "-l"],
                stderr=subprocess.PIPE
            ).decode().strip().split('\n')
            
            if players and players[0]:
                return players[0]
            
            sleep(0.5)
        
        return None
    except:
        return None

def get_player_info(player):
    try:
        if not player:
            return None

        metadata = subprocess.check_output(
            ["playerctl", "-p", player, "metadata", "--format", "json"],
            stderr=subprocess.PIPE
        ).decode().strip()
        
        if not metadata:
            return None

        metadata = json.loads(metadata)
        status = subprocess.check_output(
            ["playerctl", "-p", player, "status"],
            stderr=subprocess.PIPE
        ).decode().strip().lower()

        # Get position and duration
        try:
            position = float(subprocess.check_output(
                ["playerctl", "-p", player, "position"],
                stderr=subprocess.PIPE
            ))
            duration = float(metadata.get('mpris:length', 0)) / 1e6
        except:
            position = 0
            duration = 0

        # Get album art
        art_url = metadata.get('mpris:artUrl', '')
        art_data = None

        if art_url.startswith('file://'):
            art_path = art_url[7:]
            if os.path.exists(art_path):
                try:
                    with Image.open(art_path) as img:
                        img.thumbnail((64, 64))
                        with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as temp_file:
                            img.save(temp_file.name, 'PNG')
                            with open(temp_file.name, 'rb') as f:
                                art_data = base64.b64encode(f.read()).decode('utf-8')
                            os.unlink(temp_file.name)
                except Exception as e:
                    print(f"Art error: {e}", file=sys.stderr)

        return {
            'artist': metadata.get('xesam:artist', ['Unknown Artist'])[0],
            'title': metadata.get('xesam:title', 'Unknown Track'),
            'album': metadata.get('xesam:album', 'Unknown Album'),
            'status': status,
            'position': position,
            'duration': duration,
            'art': art_data,
            'player': player
        }
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return None

def format_output(info):
    if not info:
        return json.dumps({
            'text': 'No active player',
            'alt': 'stopped',
            'class': 'stopped',
            'percentage': 0
        })

    progress = (info['position'] / info['duration']) * 100 if info['duration'] > 0 else 0
    text = f"{info['artist']} - {info['title']}"

    output = {
        'text': text,
        'alt': info['status'],
        'class': info['status'],
        'percentage': progress,
        'tooltip': f"{info['artist']} - {info['title']}\nAlbum: {info['album']}\nPlayer: {info['player']}"
    }

    if info['art']:
        output['art'] = info['art']

    return json.dumps(output)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Handle control commands
        command = sys.argv[1]
        player = get_active_player()
        if player:
            try:
                subprocess.run(["playerctl", "-p", player, command], check=True)
            except:
                pass
    else:
        # Output current status
        player = get_active_player()
        info = get_player_info(player)
        print(format_output(info))