import var
import os
import json

if not os.path.isfile(var.LAYOUT_PATH):
    with open(var.LAYOUT_PATH, "w") as f:
        json.dump({}, f)

with open(var.LAYOUT_PATH) as f:
    var.data = json.load(f)

import app

