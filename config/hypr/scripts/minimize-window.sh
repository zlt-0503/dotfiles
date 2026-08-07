#!/bin/bash

WINDOW_ADDRESS=$(hyprctl activewindow -j | jq -r '.address')

if [ -z "$WINDOW_ADDRESS" ] || [ "$WINDOW_ADDRESS" = "null" ]; then
    exit 1
fi

hyprctl dispatch "hl.dsp.window.move({ workspace = \"special:minimized\", follow = false, window = \"address:${WINDOW_ADDRESS}\" })"
