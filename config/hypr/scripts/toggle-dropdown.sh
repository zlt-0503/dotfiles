#!/bin/bash

TERM_TITLE="$"
WORKSPACE_NAME="$"
WORKSPACE_FULL_NAME="special:$"

has_dropdown() {
    hyprctl clients -j | jq -e --arg workspace "$WORKSPACE_FULL_NAME" 'any(.[]; .workspace.name == $workspace)' >/dev/null
}

if ! has_dropdown; then
    kitty --title "${TERM_TITLE}" &

    for _ in {1..20}; do
        sleep 0.1
        has_dropdown && break
    done

fi

hyprctl dispatch 'hl.dsp.workspace.toggle_special("$")'
