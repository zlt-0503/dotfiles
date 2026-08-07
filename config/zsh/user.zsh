# User-only zsh settings (aliases, plugins, extra environment)

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM=${ZSH_CUSTOM:-$ZSH/custom}
ZSH_THEME="spaceship"

plugins=(
    git
    fzf
    zsh-autosuggestions
    zsh-syntax-highlighting
    z
    sudo
    extract
    colored-man-pages
    command-not-found
    docker
    docker-compose
    npm
    node
    python
    pip
    kubectl
    history
    common-aliases
)

source $ZSH/oh-my-zsh.sh

# Load user aliases after Oh My Zsh so they take precedence over plugin aliases.
ALIASES_ZSH="$HOME/.config/zsh/aliases.zsh"
[[ -f "$ALIASES_ZSH" ]] && source "$ALIASES_ZSH"

# Plugin Installation Check
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    echo "[warn] zsh-autosuggestions not found. Install with:"
    echo "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    echo "[warn] zsh-syntax-highlighting not found. Install with:"
    echo "git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi

if [[ ! -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]]; then
    echo "[warn] Spaceship theme not found. Install with:"
    echo "git clone https://github.com/spaceship-prompt/spaceship-prompt ${ZSH_CUSTOM}/themes/spaceship-prompt --depth=1"
    echo "ln -s ${ZSH_CUSTOM}/themes/spaceship-prompt/spaceship.zsh-theme ${ZSH_CUSTOM}/themes/spaceship.zsh-theme"
fi

# Load local customizations
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi

# Auto load tmux for the first top-level interactive Kitty shell only.
if [[ -o interactive && -z "$TMUX" && -n "$KITTY_WINDOW_ID" ]] && command -v tmux >/dev/null 2>&1; then
    if [[ -z "$(tmux list-clients 2>/dev/null)" ]]; then
        exec tmux new-session -A -s default
    fi
fi

# Existing tmux panes survive a compositor logout, so their process
# environment otherwise keeps the previous Hyprland IPC signature. tmux
# refreshes its session environment on attach; copy those values into each
# long-lived zsh before commands such as hyprctl or hyprshutdown are run.
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

export PATH="$PATH:$HOME/.local/bin/"
