import json
import os
from monitor import create_monitor
import app
import var

def load_layout():
    layout_name = app.name_entry.get().strip()
    if not layout_name:
        return
    
    if layout_name not in var.data:
        app.status_label.config(text=f"Layout {layout_name} not found in layout file")
        return
    
    # Clear existing monitors
    for m in var.monitors:
        app.canvas.delete(m.rect)
        app.canvas.delete(m.text)
    var.monitors.clear()
    
    # Create new monitors from layout
    for index, m_info in enumerate(var.data[layout_name]):
        create_monitor(app.canvas, m_info, index, True)
    
    app.status_label.config(text=f"Layout {layout_name}.json loaded")