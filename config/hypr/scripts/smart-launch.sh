#!/bin/bash

# Smart launcher for Hyprland
# Usage: smart-launch.sh <window_class> <command>
#
# If a window with the given class exists, focus it.
# Otherwise, launch the command.

WINDOW_CLASS="$1"
shift
COMMAND="$@"

focus_client() {
    local client_json
    client_json=$(hyprctl clients -j | jq -c "map(select(.class == \"$WINDOW_CLASS\"))[0]")

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
$COMMAND &

for _ in {1..50}; do
    sleep 0.1
    if focus_client; then
        exit 0
    fi
done
