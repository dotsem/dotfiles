# =============================================
# Oh My Zsh + Starship Minimal Configuration
# =============================================

# --- Oh My Zsh Setup ---
export ZSH="$HOME/.oh-my-zsh"  # Path to OMZ
ZSH_THEME=""                   # Disable OMZ themes (Starship will handle prompt)

# Plugins (lightweight, no output during init)
plugins=(
  git                     # Git aliases and functions
  zsh-autosuggestions     # Fish-like suggestions
  zsh-syntax-highlighting # Command syntax highlighting
)

alias clipboard="xsel -ib"
alias pp="pnpm"
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'
alias zed="$HOME/.local/bin/zed"
alias nuke="shutdown now"
function cl() {
	cd "$1"
	ls --color=auto
}

export RUSTC_WRAPPER="sccache"

# Load Oh My Zsh (must be after plugin declaration)
source $ZSH/oh-my-zsh.sh

# --- Starship Prompt ---
# Check if Starship exists, install if not
if ! command -v starship &> /dev/null; then
  echo "Installing Starship..."
  curl -sS https://starship.rs/install.sh | sh
fi

# Initialize Starship
eval "$(starship init zsh)"

# --- Terminal Behavior ---
# Fix for Alacritty resizing (no right-bar issues)
TRAPWINCH() {
  zle && zle reset-prompt
}

# --- Environment ---
export EDITOR='nano'       # Default editor
export VISUAL='code'

# --- Aliases ---
alias ls='ls --color=auto'
alias ll='ls -alF'
alias gs='git status'
alias gd='git diff'

# --- Syntax Highlighting (must be last) ---
source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$HOME/flutter/bin:$PATH"

#autoload -U add-zsh-hook
#load-nvmrc() {
#  local node_version="$(nvm version)"
#  local nvmrc_path="$(nvm_find_nvmrc)"
#
#  if [ -n "$nvmrc_path" ]; then
#    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
#
#    if [ "$nvmrc_node_version" = "N/A" ]; then
#      nvm install
#    elif [ "$nvmrc_node_version" != "$node_version" ]; then
#      nvm use
#    fi
#  elif [ "$node_version" != "$(nvm version default)" ]; then
#    echo "Reverting to nvm default version"
#    nvm use default
#  fi
#}
#add-zsh-hook chpwd load-nvmrc
#load-nvmrc
