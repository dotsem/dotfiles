import os
import var
import json
import app

def save_layout():
    layout_name = app.name_entry.get().strip()
    if not layout_name:
        return
    
    layout = []
    
    for m in var.monitors:
        print(m)
        layout.append({
            "name": m.name,
            "monitor": m.serial,
            "width": m.width,
            "height": m.height,
            "x": m.x,
            "y": m.y,
            "scale": m.scale,
            "primary": m.primary
        })
    
    var.data[layout_name] = layout
    
    with open(var.LAYOUT_PATH, "w") as f:
        json.dump(var.data, f, indent=2)
    
    app.status_label.config(text=f"Layout saved as {layout_name}.json")