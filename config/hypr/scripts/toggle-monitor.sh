#!/bin/bash

if pgrep -f "kitty.*scratchpad-monitor" > /dev/null; then
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("monitor")'
else
    kitty --title scratchpad-monitor btop &
    sleep 0.5
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("monitor")'
fi
