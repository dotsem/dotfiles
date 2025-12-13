import tkinter as tk
import var
from load import load_layout
from save import save_layout
from monitorSniffer import get_connected_monitors
from monitor import create_monitor

root = tk.Tk()
root.title("Hyprland Monitor Layout Tool")

# Create a frame for controls at the top
control_frame = tk.Frame(root)
control_frame.pack(fill=tk.X, padx=5, pady=5)

# Layout name
tk.Label(control_frame, text="Layout Name:").pack(side=tk.LEFT)
name_entry = tk.Entry(control_frame, width=20)
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
canvas.config(scrollregion=(0, 0, var.canvas_width/var.SCALE_FACTOR, var.canvas_height/var.SCALE_FACTOR))

# Initialize with connected monitors
connected = get_connected_monitors()
for index, info in enumerate(connected):
    create_monitor(canvas, info, index)

root.mainloop()