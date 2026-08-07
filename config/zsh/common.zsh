# Common/safe zsh settings shared across users (e.g., root)

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Status-aware prompt for root/shared shells. Regular users get their prompt
# from the user-specific Oh My Zsh theme.
if [[ $EUID -eq 0 ]]; then
    set_prompt() {
        local rc=$?

        if [[ $rc -eq 0 ]]; then
            PROMPT="%F{green}#%f "
        else
            PROMPT="%F{red}#%f "
        fi
    }
    precmd_functions+=(set_prompt)
fi

# Basic functions
mkcd() { mkdir -p "$1" && cd "$1"; }
psgrep() { ps aux | grep -v grep | grep -i -e VSZ -e "$1"; }

# Locale/editor
export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Completion settings
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.: .)LS_COLORS}"
zstyle ':completion:*' rehash true

autoload -Uz compinit
compinit

# Key bindings
bindkey -e
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# Shell options
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
