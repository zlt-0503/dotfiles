# Modular zsh configuration
# - common.zsh: safe settings shared with root
# - user.zsh: user-only plugins and extras

COMMON_ZSH="$HOME/.config/zsh/common.zsh"
[[ -f "$COMMON_ZSH" ]] && source "$COMMON_ZSH"

USER_ZSH="$HOME/.config/zsh/user.zsh"
[[ -f "$USER_ZSH" ]] && source "$USER_ZSH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export MANPATH="$HOME/.local/share/man:$(manpath)"
