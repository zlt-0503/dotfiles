#!/bin/bash

case "${1:-}" in
    up) pamixer -i 5 ;;
    down) pamixer -d 5 ;;
    mute) pamixer -t ;;
    *)
        printf 'Usage: %s {up|down|mute}\n' "$0" >&2
        exit 2
        ;;
esac
