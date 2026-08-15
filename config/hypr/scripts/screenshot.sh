#!/bin/bash

screenshot_dir="$HOME/Pictures/Screenshots"
mkdir -p -- "$screenshot_dir"
output="$screenshot_dir/shot-$(date +%F_%H-%M-%S).png"

case "${1:-}" in
    full)
        grim "$output"
        ;;
    region)
        geometry=$(slurp) || exit 0
        [[ -n "$geometry" ]] || exit 0
        grim -g "$geometry" "$output"
        ;;
    *)
        printf 'Usage: %s {full|region}\n' "$0" >&2
        exit 2
        ;;
esac
