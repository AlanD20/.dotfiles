
#
# This has to be here unfortunately for zsh to read environment variables.
# Credit: https://gist.github.com/fredjoseph/e81be37b8605590ef7f4cfaef1f476d2
#

# In Sway, spawning a new terminal does not source this file.
# You have to exit sway session in order to re-source this file.

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_RUNTIME_DIR="/run/user/$UID"

export ZSH_ENV_HOME="$HOME"
export ZSH_CACHE_DIR=$XDG_CACHE_HOME/oh-my-zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export DOTFILES="$HOME/.dotfiles"

# Export user bin dir
export PATH="$PATH:$HOME/.local/bin"

# User configuration
export MANPATH="/usr/local/man:$MANPATH"

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Path to your oh-my-zsh installation.
export ZSH="/usr/share/oh-my-zsh"
export EDITOR="nvim"
export VISUAL="nvim"

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi
