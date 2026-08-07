#!/bin/bash

# Smart launcher for tmux terminal in Kitty
# Similar to smart-launch.sh but specifically for a tmux session

# Use a unique title to identify this special terminal
WINDOW_TITLE="tmux-terminal"
WINDOW_CLASS="kitty"

focus_client() {
    local client_json
    client_json=$(hyprctl clients -j | jq -c "map(select(.title | contains(\"$WINDOW_TITLE\")))[0]")

    if [ -n "$client_json" ] && [ "$client_json" != "null" ]; then
        local address
        address=$(echo "$client_json" | jq -r '.address')

        [ -n "$address" ] && hyprctl dispatch "hl.dsp.focus({ window = \"address:${address}\" })"
        return 0
    fi

    return 1
}

# Focus existing window if present
if focus_client; then
    exit 0
fi

# Otherwise launch and wait for the window to appear, then focus
kitty --title "$WINDOW_TITLE" tmux new-session -A -s main &

for _ in {1..50}; do
    sleep 0.1
    if focus_client; then
        exit 0
    fi
done
