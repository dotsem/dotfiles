import subprocess

def get_connected_monitors():
    result = subprocess.run(["hyprctl", "monitors"], capture_output=True, text=True)
    lines = result.stdout.splitlines()
    parsed_monitors = []
    current = {}
    
    for line in lines:
        if "Monitor" in line:
            if current:
                parsed_monitors.append(current)
            current = {}
            current["name"] = line.split("Monitor")[1].strip().split(" ")[0]
        elif " at " in line:
            parts = line.strip().split(" at ")
            res_part = parts[0].split("@")[0]
            pos_part = parts[1]
            width, height = res_part.split("x")
            x, y = pos_part.split("x")
            current["width"] = int(width)
            current["height"] = int(height)
            current["x"] = int(x)
            current["y"] = int(y)
        elif "model" in line:
            current["serial"] = line.strip().split()[-1]
    
    if current:
        parsed_monitors.append(current)
    return parsed_monitors
