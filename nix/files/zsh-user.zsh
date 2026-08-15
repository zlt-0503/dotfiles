# User-only behavior loaded after declarative Oh My Zsh initialization.

# Keep the existing external language-version managers. They are deliberately
# outside Nix management in this first migration.
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

if command -v manpath >/dev/null 2>&1; then
    export MANPATH="$HOME/.local/share/man:$(manpath)"
fi

# Load local, private customizations that are intentionally outside Git/Nix.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Auto load tmux for the first top-level interactive Kitty shell only.
if [[ -o interactive && -z "$TMUX" && -n "$KITTY_WINDOW_ID" ]] && command -v tmux >/dev/null 2>&1; then
    if [[ -z "$(tmux list-clients 2>/dev/null)" ]]; then
        exec tmux new-session -A -s default
    fi
fi

# Existing tmux panes survive a compositor logout. Refresh the graphical
# session variables that tmux received from a newly attached client.
_refresh_tmux_graphical_env() {
    [[ -n "$TMUX" ]] || return 0

    local name assignment
    local -a names=(
        DISPLAY
        WAYLAND_DISPLAY
        HYPRLAND_INSTANCE_SIGNATURE
        XDG_CURRENT_DESKTOP
        XDG_SESSION_DESKTOP
        XDG_SESSION_TYPE
        XDG_SESSION_ID
    )

    for name in "${names[@]}"; do
        assignment="$(tmux show-environment "$name" 2>/dev/null)" || continue
        [[ "$assignment" == "$name="* ]] || continue
        export "$assignment"
    done
}

if [[ -o interactive && -n "$TMUX" ]]; then
    autoload -Uz add-zsh-hook
    add-zsh-hook -d precmd _refresh_tmux_graphical_env 2>/dev/null
    add-zsh-hook precmd _refresh_tmux_graphical_env
    _refresh_tmux_graphical_env
fi
