#!/usr/bin/env bash

set -Eeuo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
state_home=${XDG_STATE_HOME:-"$HOME/.local/state"}
timestamp=$(date +%Y%m%d-%H%M%S)
backup_root="$state_home/dotfiles/backups/$timestamp"
dry_run=false
backup_created=false

usage() {
    cat <<'EOF'
Usage: ./install.sh [--dry-run]

Create dotfile symlinks. Existing targets are moved to a timestamped backup
under $XDG_STATE_HOME/dotfiles/backups (default: ~/.local/state/dotfiles/backups).
EOF
}

case "${1:-}" in
    "") ;;
    --dry-run) dry_run=true ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac

ensure_parent() {
    local path=$1
    if "$dry_run"; then
        printf '[dry-run] mkdir -p %q\n' "$(dirname -- "$path")"
    else
        mkdir -p -- "$(dirname -- "$path")"
    fi
}

backup_target() {
    local target=$1
    local label=$2
    local backup_path="$backup_root/$label"

    if "$dry_run"; then
        printf '[dry-run] backup %q -> %q\n' "$target" "$backup_path"
        return
    fi

    mkdir -p -- "$(dirname -- "$backup_path")"
    mv -- "$target" "$backup_path"
    backup_created=true
    printf 'Backed up: %s -> %s\n' "$target" "$backup_path"
}

link_item() {
    local source=$1
    local target=$2
    local label=$3

    if [[ ! -e "$source" ]]; then
        printf 'Missing source: %s\n' "$source" >&2
        exit 1
    fi

    if [[ -L "$target" ]] && [[ "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
        printf 'Already linked: %s\n' "$target"
        return
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        backup_target "$target" "$label"
    fi

    ensure_parent "$target"
    if "$dry_run"; then
        printf '[dry-run] link %q -> %q\n' "$target" "$source"
    else
        ln -s -- "$source" "$target"
        printf 'Linked: %s -> %s\n' "$target" "$source"
    fi
}

# Directories that contain only portable, version-controlled configuration.
link_item "$repo_dir/config/hypr" "$config_home/hypr" "config/hypr"
link_item "$repo_dir/config/zsh" "$config_home/zsh" "config/zsh"
link_item "$repo_dir/config/kitty" "$config_home/kitty" "config/kitty"

# Fcitx5 also writes runtime cache files, so link only portable files and leave
# the surrounding directories writable.
link_item "$repo_dir/config/fcitx5/config" "$config_home/fcitx5/config" "config/fcitx5/config"
link_item "$repo_dir/config/fcitx5/profile" "$config_home/fcitx5/profile" "config/fcitx5/profile"
for name in chttrans.conf classicui.conf notifications.conf pinyin.conf punctuation.conf; do
    link_item "$repo_dir/config/fcitx5/conf/$name" "$config_home/fcitx5/conf/$name" "config/fcitx5/conf/$name"
done
link_item "$repo_dir/config/fcitx5/rime/default.custom.yaml" "$config_home/fcitx5/rime/default.custom.yaml" "config/fcitx5/rime/default.custom.yaml"
link_item "$repo_dir/data/fcitx5/themes/catppuccin-mocha-blue" "$data_home/fcitx5/themes/catppuccin-mocha-blue" "data/fcitx5/themes/catppuccin-mocha-blue"

# Traditional home-directory dotfiles.
link_item "$repo_dir/home/.zshrc" "$HOME/.zshrc" "home/.zshrc"
link_item "$repo_dir/home/.zshenv" "$HOME/.zshenv" "home/.zshenv"
link_item "$repo_dir/home/.tmux.conf" "$HOME/.tmux.conf" "home/.tmux.conf"

if "$dry_run"; then
    printf '\nDry run complete; no files were changed.\n'
elif "$backup_created"; then
    printf '\nInstall complete. Backups: %s\n' "$backup_root"
else
    printf '\nInstall complete. No backups were needed.\n'
fi
