import var
import subprocess
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
        
def create_monitor(canvas, info, index, loaded=False):
    # Fetch IDs from shell script
    try:
        output = subprocess.check_output(["sh", os.path.join(os.path.dirname(__file__), "edid/get-monitors.sh")], text=True).splitlines()
        monitor_ids = dict(line.split(":", 1) for line in output)
    except Exception as e:
        print("Failed to fetch monitor IDs:", e)
        monitor_ids = {}

    # Determine position
    if not loaded:
        if index == 0:
            x_pos = 0
            y_pos = 0
            is_primary = True
        else:
            prev_monitor = var.monitors[index - 1]
            x_pos = prev_monitor.x + prev_monitor.width
            y_pos = 0
            is_primary = False
    else:
        x_pos = info["x"]
        y_pos = info["y"]
        is_primary = info["primary"]

    # Get ID from script or fallback
    name = info["name"]
    id_value = monitor_ids.get(name, f"UNKNOWN_{index}")

    m = Monitor(
        name=name,
        serial=id_value,
        width=info["width"],
        height=info["height"],
        x=x_pos,
        y=y_pos
    )
    m.primary = is_primary
    
    # Scale down for display (keeping proportions)
    display_width = max(200, min(400, int(m.width / var.SCALE_FACTOR)))
    display_height = max(120, min(240, int(m.height / var.SCALE_FACTOR)))
    
    var.monitors.append(m)
    outline = "green" if m.primary else "black"
    width = 3 if m.primary else 1
    
    rect = canvas.create_rectangle(
        m.x / var.SCALE_FACTOR, m.y / var.SCALE_FACTOR, 
        m.x / var.SCALE_FACTOR + display_width, m.y / var.SCALE_FACTOR + display_height,
        fill="lightblue", tags=m.name, outline=outline, width=width
    )
    
    text = canvas.create_text(
        m.x / var.SCALE_FACTOR + display_width / 2, m.y / var.SCALE_FACTOR + display_height / 2,
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
        for other in var.monitors:
            if other is not m:
                # Snap to left edge
                if abs(new_x - (canvas.coords(other.rect)[2])) < var.snap_threshold:
                    new_x = canvas.coords(other.rect)[2]
                # Snap to right edge
                elif abs(new_x + display_width - canvas.coords(other.rect)[0]) < var.snap_threshold:
                    new_x = canvas.coords(other.rect)[0] - display_width
                # Snap to top edge
                if abs(new_y - (canvas.coords(other.rect)[3])) < var.snap_threshold:
                    new_y = canvas.coords(other.rect)[3]
                # Snap to bottom edge
                elif abs(new_y + display_height - canvas.coords(other.rect)[1]) < var.snap_threshold:
                    new_y = canvas.coords(other.rect)[1] - display_height
        
        # Update display position (scaled down)
        canvas.coords(m.rect, new_x, new_y, new_x + display_width, new_y + display_height)
        canvas.coords(m.text, new_x + display_width / 2, new_y + display_height / 2)
        
        # Update actual position (scaled up)
        m.x = int(new_x * var.SCALE_FACTOR)
        m.y = int(new_y * var.SCALE_FACTOR)
        
        canvas.itemconfig(m.text, text=f"{m.name}\n{m.width}x{m.height}\n@{m.x},{m.y}")
    
    def set_primary(event):
        for other in var.monitors:
            if other is not m:
                other.primary = False
                canvas.itemconfig(other.rect, outline="black", width=1)
        m.primary = True
        canvas.itemconfig(m.rect, outline="green", width=3)
    
    canvas.tag_bind(m.name, '<Button-1>', start_drag)
    canvas.tag_bind(m.name, '<B1-Motion>', dragging)
    canvas.tag_bind(m.name, '<Button-3>', set_primary)