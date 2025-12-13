#!/bin/bash
pkill hypr_flutter
pgrep -x "bundle/hypr_flutter" > /dev/null || GDK_BACKEND=x11 $1 &