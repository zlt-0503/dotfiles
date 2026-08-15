#!/bin/bash

case "${1:-}" in
    up) brightnessctl set +10% ;;
    down) brightnessctl set 10%- ;;
    *)
        printf 'Usage: %s {up|down}\n' "$0" >&2
        exit 2
        ;;
esac
