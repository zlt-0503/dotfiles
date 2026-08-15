#!/usr/bin/env bash

set -Eeuo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
target_user=$(id -un)
target_home=$HOME
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
state_home=${XDG_STATE_HOME:-"$HOME/.local/state"}
timestamp=$(date +%Y%m%d-%H%M%S)
backup_root="$state_home/dotfiles/backups/$timestamp"
dry_run=false
backup_created=false

declare -a moved_targets=()
declare -a moved_backups=()
declare -a moved_labels=()

nix_flags=(--extra-experimental-features "nix-command flakes")
activation_expr='
let
  flakeRef = builtins.getEnv "DOTFILES_FLAKE_REF";
  username = builtins.getEnv "DOTFILES_USERNAME";
  homeDirectory = builtins.getEnv "DOTFILES_HOME_DIRECTORY";
  flake = builtins.getFlake flakeRef;
in
(flake.lib.mkFedoraHome {
  inherit username homeDirectory;
  dotfilesDirectory = flakeRef;
}).activationPackage
'

usage() {
    cat <<'EOF'
Usage: ./install.sh [--dry-run]

Build and activate the Fedora Home Manager configuration for the current user.

  --dry-run  Build and validate the configuration, then show which existing
             targets would be backed up. The home directory is not changed.

Nix must already be installed, and flake.lock must have been generated with:
  nix --extra-experimental-features 'nix-command flakes' flake lock
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

require_nix() {
    if ! command -v nix >/dev/null 2>&1; then
        cat >&2 <<'EOF'
Nix is not installed yet. Install multi-user Nix using Fedora's `nix` and
`nix-daemon` packages, then run `nix --version` before returning to this
installer.
See README.md for the exact installation steps.
EOF
        exit 1
    fi

    if [[ ! -f "$repo_dir/flake.lock" ]]; then
        cat >&2 <<EOF
Missing $repo_dir/flake.lock.
Generate it after installing Nix:
  cd $repo_dir
  nix --extra-experimental-features 'nix-command flakes' flake lock
EOF
        exit 1
    fi
}

is_store_link() {
    local path=$1
    local resolved

    [[ -L "$path" ]] || return 1
    resolved=$(readlink -f -- "$path") || return 1
    [[ "$resolved" == /nix/store/* ]]
}

backup_target() {
    local target=$1
    local label=$2
    local backup_path="$backup_root/$label"

    if "$dry_run"; then
        printf '[dry-run] backup %s -> %s\n' "$target" "$backup_path"
        return
    fi

    mkdir -p -- "$(dirname -- "$backup_path")"
    mv -- "$target" "$backup_path"
    moved_targets+=("$target")
    moved_backups+=("$backup_path")
    moved_labels+=("$label")
    backup_created=true
    printf 'Backed up: %s -> %s\n' "$target" "$backup_path"
}

prepare_file() {
    local target=$1
    local label=$2

    if [[ ! -e "$target" && ! -L "$target" ]]; then
        return
    fi
    if is_store_link "$target"; then
        return
    fi
    backup_target "$target" "$label"
}

directory_is_managed() {
    local directory=$1
    local sentinel=$2
    is_store_link "$directory/$sentinel"
}

preserve_local_hypr_files() {
    local source_dir=$1
    local name source backup_path

    for name in machine.lua hyprpaper.conf; do
        source="$source_dir/$name"
        [[ -e "$source" ]] || continue
        backup_path="$backup_root/local/hypr/$name"
        if "$dry_run"; then
            printf '[dry-run] preserve local file %s -> %s\n' "$source" "$backup_path"
        else
            mkdir -p -- "$(dirname -- "$backup_path")"
            cp -a -- "$source" "$backup_path"
        fi
    done
}

prepare_directory() {
    local target=$1
    local label=$2
    local sentinel=$3
    local preserve_hypr=${4:-false}

    if [[ ! -e "$target" && ! -L "$target" ]]; then
        return
    fi
    if directory_is_managed "$target" "$sentinel"; then
        return
    fi
    if "$preserve_hypr"; then
        preserve_local_hypr_files "$target"
    fi
    backup_target "$target" "$label"
}

scan_conflicts() {
    prepare_directory "$config_home/hypr" "config/hypr" "hyprland.lua" true
    prepare_directory "$config_home/zsh" "config/zsh" "common.zsh"
    prepare_directory "$config_home/kitty" "config/kitty" "kitty.conf"
    prepare_directory "$config_home/nvim" "config/nvim" "init.lua"
    prepare_directory "$config_home/tmux" "config/tmux" "tmux.conf"
    prepare_directory \
        "$data_home/fcitx5/themes/catppuccin-mocha-blue" \
        "data/fcitx5/themes/catppuccin-mocha-blue" \
        "LICENSE"

    prepare_file "$HOME/.zshrc" "home/.zshrc"
    prepare_file "$HOME/.zshenv" "home/.zshenv"
    prepare_file "$HOME/.tmux.conf" "home/.tmux.conf"
    prepare_file "$config_home/fcitx5/config" "config/fcitx5/config"
    prepare_file "$config_home/fcitx5/profile" "config/fcitx5/profile"
    prepare_file "$config_home/fcitx5/conf/chttrans.conf" "config/fcitx5/conf/chttrans.conf"
    prepare_file "$config_home/fcitx5/conf/classicui.conf" "config/fcitx5/conf/classicui.conf"
    prepare_file "$config_home/fcitx5/conf/notifications.conf" "config/fcitx5/conf/notifications.conf"
    prepare_file "$config_home/fcitx5/conf/pinyin.conf" "config/fcitx5/conf/pinyin.conf"
    prepare_file "$config_home/fcitx5/conf/punctuation.conf" "config/fcitx5/conf/punctuation.conf"
    prepare_file "$config_home/fcitx5/rime/default.custom.yaml" "config/fcitx5/rime/default.custom.yaml"
}

restore_local_hypr_files() {
    local name source target

    for name in machine.lua hyprpaper.conf; do
        source="$backup_root/local/hypr/$name"
        target="$config_home/hypr/$name"
        [[ -e "$source" ]] || continue
        if [[ -e "$target" || -L "$target" ]]; then
            printf 'Kept existing local file: %s\n' "$target"
            continue
        fi
        cp -a -- "$source" "$target"
        printf 'Restored local file: %s\n' "$target"
    done
}

rollback_backups() {
    local failed_root="$backup_root/failed-activation"
    local index target backup label failed_path

    printf 'Activation failed; restoring pre-activation targets.\n' >&2
    for ((index=${#moved_targets[@]} - 1; index >= 0; index--)); do
        target=${moved_targets[$index]}
        backup=${moved_backups[$index]}
        label=${moved_labels[$index]}
        failed_path="$failed_root/$label"

        if [[ -e "$target" || -L "$target" ]]; then
            mkdir -p -- "$(dirname -- "$failed_path")"
            mv -- "$target" "$failed_path"
        fi
        mkdir -p -- "$(dirname -- "$target")"
        mv -- "$backup" "$target"
        printf 'Restored: %s\n' "$target" >&2
    done
}

require_nix

printf 'Target Home Manager user: %s (%s)\n' "$target_user" "$target_home"

printf 'Checking flake configuration...\n'
nix "${nix_flags[@]}" flake check "$repo_dir"

printf 'Building Home Manager activation package...\n'
activation_path=$(DOTFILES_FLAKE_REF="$repo_dir" \
    DOTFILES_USERNAME="$target_user" \
    DOTFILES_HOME_DIRECTORY="$target_home" \
    nix "${nix_flags[@]}" build \
    --impure \
    --expr "$activation_expr" \
    --no-link \
    --print-out-paths)
if [[ -z "$activation_path" || ! -x "$activation_path/activate" ]]; then
    printf 'Invalid activation package path: %s\n' "$activation_path" >&2
    exit 1
fi

if "$dry_run"; then
    scan_conflicts
    printf '\nDry run complete; the configuration builds and no home files were changed.\n'
    exit 0
fi

scan_conflicts

activation_failed() {
    local rc=$?
    trap - ERR
    if "$backup_created"; then
        rollback_backups
    fi
    exit "$rc"
}
trap activation_failed ERR

"$activation_path/activate"
trap - ERR

restore_local_hypr_files

if "$backup_created"; then
    printf '\nHome Manager activation complete. Backups: %s\n' "$backup_root"
else
    printf '\nHome Manager activation complete. No unmanaged targets needed backup.\n'
fi
