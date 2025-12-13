import tkinter as tk
from tkinter import filedialog
import subprocess
import json
import os

class Monitor:
    def __init__(self, name, serial, width=1920, height=1080, x=0, y=0, scale=1):
        self.name = name
        self.serial = serial
        self.width = width
        self.height = height
        self.x = x
        self.y = y
        self.scale = scale
        self.rect = None
        self.text = None
        self.offset_x = 0
        self.offset_y = 0
        self.primary = False

monitors = []
canvas_width = 1920
canvas_height = 1080
snap_threshold = 15
SCALE_FACTOR = 8  # Changed from 10 to make 1920 fit better

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
        elif "ID" in line:
            current["serial"] = line.strip().split()[-1]
    
    if current:
        parsed_monitors.append(current)
    return parsed_monitors

def create_monitor(canvas, info, index, loaded=False):
    # First monitor at 0x0, subsequent monitors to the right
    if not loaded:
        if index == 0:
            x_pos = 0
            y_pos = 0
            is_primary = True
        else:
            prev_monitor = monitors[index-1]
            x_pos = prev_monitor.x + prev_monitor.width
            y_pos = 0
            is_primary = False
    else:
        x_pos = info["x"]
        y_pos = info["y"]
        is_primary = info["primary"]
    
    m = Monitor(
        name=info["name"],
        serial=info.get("serial", f"UNKNOWN_{index}"),
        width=info["width"],
        height=info["height"],
        x=x_pos,
        y=y_pos
    )
    m.primary = is_primary
    
    # Scale down for display (keeping proportions)
    display_width = max(200, min(400, int(m.width / SCALE_FACTOR)))
    display_height = max(120, min(240, int(m.height / SCALE_FACTOR)))
    
    monitors.append(m)
    outline = "green" if m.primary else "black"
    width = 3 if m.primary else 1
    
    rect = canvas.create_rectangle(
        m.x / SCALE_FACTOR, m.y / SCALE_FACTOR, 
        m.x / SCALE_FACTOR + display_width, m.y / SCALE_FACTOR + display_height,
        fill="lightblue", tags=m.name, outline=outline, width=width
    )
    
    text = canvas.create_text(
        m.x / SCALE_FACTOR + display_width / 2, m.y / SCALE_FACTOR + display_height / 2,
        text=f"{m.name}\n{m.width}x{m.height}\n@{m.x},{m.y}", 
        tags=m.name
    )
    
    m.rect = rect
    m.text = text
    
    def start_drag(event):
        m.offset_x = event.x - canvas.coords(m.rect)[0]
        m.offset_y = event.y - canvas.coords(m.rect)[1]
    
    def dragging(event):
        new_x = event.x - m.offset_x
        new_y = event.y - m.offset_y
        
        # Calculate display dimensions
        display_width = (canvas.coords(m.rect)[2] - canvas.coords(m.rect)[0])
        display_height = (canvas.coords(m.rect)[3] - canvas.coords(m.rect)[1])
        
        # Edge collision detection
        canvas_display_width = canvas.winfo_width()
        canvas_display_height = canvas.winfo_height()
        
        new_x = max(0, min(canvas_display_width - display_width, new_x))
        new_y = max(0, min(canvas_display_height - display_height, new_y))
        
        # Monitor snapping
        for other in monitors:
            if other is not m:
                # Snap to left edge
                if abs(new_x - (canvas.coords(other.rect)[2])) < snap_threshold:
                    new_x = canvas.coords(other.rect)[2]
                # Snap to right edge
                elif abs(new_x + display_width - canvas.coords(other.rect)[0]) < snap_threshold:
                    new_x = canvas.coords(other.rect)[0] - display_width
                # Snap to top edge
                if abs(new_y - (canvas.coords(other.rect)[3])) < snap_threshold:
                    new_y = canvas.coords(other.rect)[3]
                # Snap to bottom edge
                elif abs(new_y + display_height - canvas.coords(other.rect)[1]) < snap_threshold:
                    new_y = canvas.coords(other.rect)[1] - display_height
        
        # Update display position (scaled down)
        canvas.coords(m.rect, new_x, new_y, new_x + display_width, new_y + display_height)
        canvas.coords(m.text, new_x + display_width / 2, new_y + display_height / 2)
        
        # Update actual position (scaled up)
        m.x = int(new_x * SCALE_FACTOR)
        m.y = int(new_y * SCALE_FACTOR)
        
        canvas.itemconfig(m.text, text=f"{m.name}\n{m.width}x{m.height}\n@{m.x},{m.y}")
    
    def set_primary(event):
        for other in monitors:
            if other is not m:
                other.primary = False
                canvas.itemconfig(other.rect, outline="black", width=1)
        m.primary = True
        canvas.itemconfig(m.rect, outline="green", width=3)
    
    canvas.tag_bind(m.name, '<Button-1>', start_drag)
    canvas.tag_bind(m.name, '<B1-Motion>', dragging)
    canvas.tag_bind(m.name, '<Button-3>', set_primary)

def save_layout():
    layout_name = name_entry.get().strip()
    if not layout_name:
        return
    
    layout = {
        "layout_name": layout_name,
        "monitors": []
    }
    
    for m in monitors:
        layout["monitors"].append({
            "name": m.name,
            "serial": m.serial,
            "width": m.width,
            "height": m.height,
            "x": m.x,
            "y": m.y,
            "scale": m.scale,
            "primary": m.primary
        })
    
    layout_dir = os.path.expanduser("~/.config/hypr/monitors")
    os.makedirs(layout_dir, exist_ok=True)
    
    with open(os.path.join(layout_dir, f"{layout_name}.json"), "w") as f:
        json.dump(layout, f, indent=2)
    
    status_label.config(text=f"Layout saved as {layout_name}.json")

def load_layout():
    layout_name = name_entry.get().strip()
    if not layout_name:
        return
    
    layout_dir = os.path.expanduser("~/.config/hypr/monitors")
    path = os.path.join(layout_dir, f"{layout_name}.json")
    
    if not os.path.isfile(path):
        status_label.config(text=f"Layout {layout_name}.json not found")
        return
    
    with open(path, "r") as f:
        data = json.load(f)
    
    # Clear existing monitors
    for m in monitors:
        canvas.delete(m.rect)
        canvas.delete(m.text)
    monitors.clear()
    
    # Create new monitors from layout
    for index, m_info in enumerate(data["monitors"]):
        print(m_info)
        create_monitor(canvas, m_info, index, True)
    
    status_label.config(text=f"Layout {layout_name}.json loaded")

# Create main window
root = tk.Tk()
root.title("Hyprland Monitor Layout Tool")

# Create a frame for controls at the top
control_frame = tk.Frame(root)
control_frame.pack(fill=tk.X, padx=5, pady=5)

# Layout name
tk.Label(control_frame, text="Layout Name:").pack(side=tk.LEFT)
name_entry = tk.Entry(control_frame, width=20)
name_entry.insert(0, "default")
name_entry.pack(side=tk.LEFT, padx=5)

# Buttons
tk.Button(control_frame, text="Save Layout", command=save_layout).pack(side=tk.LEFT, padx=5)
tk.Button(control_frame, text="Load Layout", command=load_layout).pack(side=tk.LEFT, padx=5)

# Status label
status_label = tk.Label(root, text="", fg="blue")
status_label.pack()

# Create canvas with scrollbars
canvas_frame = tk.Frame(root)
canvas_frame.pack(fill=tk.BOTH, expand=True)

# Add scrollbars
hscroll = tk.Scrollbar(canvas_frame, orient=tk.HORIZONTAL)
vscroll = tk.Scrollbar(canvas_frame, orient=tk.VERTICAL)

# Main canvas (scaled down)
canvas = tk.Canvas(
    canvas_frame,
    width=800,
    height=600,
    bg="white",
    xscrollcommand=hscroll.set,
    yscrollcommand=vscroll.set
)
hscroll.config(command=canvas.xview)
vscroll.config(command=canvas.yview)

# Grid layout for scrollbars
canvas.grid(row=0, column=0, sticky="nsew")
vscroll.grid(row=0, column=1, sticky="ns")
hscroll.grid(row=1, column=0, sticky="ew")

# Configure grid weights
canvas_frame.grid_rowconfigure(0, weight=1)
canvas_frame.grid_columnconfigure(0, weight=1)

# Set canvas scroll region (adjust based on your monitor layout)
canvas.config(scrollregion=(0, 0, canvas_width/SCALE_FACTOR, canvas_height/SCALE_FACTOR))

# Initialize with connected monitors
connected = get_connected_monitors()
for index, info in enumerate(connected):
    create_monitor(canvas, info, index)

root.mainloop()