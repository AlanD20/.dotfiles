
#
# This has to be here unfortunately for zsh to read environment variables.
# Credit: https://gist.github.com/fredjoseph/e81be37b8605590ef7f4cfaef1f476d2
#

# In Sway, spawning a new terminal does not source this file.
# You have to exit sway session in order to re-source this file.

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

if [[ "$(uname)" == "Darwin" ]]; then
    export XDG_CONFIG_DIRS="/opt/homebrew/etc:/etc"
    export XDG_DATA_DIRS="/opt/homebrew/share:/usr/local/share:/usr/share"
    export XDG_RUNTIME_DIR="$TMPDIR"
else
    export XDG_CONFIG_DIRS="/etc/xdg"
    export XDG_DATA_DIRS="/usr/local/share:/usr/share"
    export XDG_RUNTIME_DIR="/run/user/$UID"
fi

export ZSH_ENV_HOME="$HOME"
export ZSH_CACHE_DIR=$XDG_CACHE_HOME/oh-my-zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export DOTFILES="$HOME/.dotfiles"

# Export user bin dir
export PATH="$PATH:$HOME/.local/bin"

# Homebrew — Apple Silicon path
if [[ -d /opt/homebrew/bin ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# User configuration
if [[ "$(uname)" == "Darwin" ]]; then
    export MANPATH="/opt/homebrew/share/man:$MANPATH"
else
    export MANPATH="/usr/local/man:$MANPATH"
fi

# Homebrew prefix for Apple Silicon
if [[ "$(uname -m)" == "arm64" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
else
    export HOMEBREW_PREFIX="/usr/local"
fi

# Compilation flags (macOS only)
if [[ "$(uname)" == "Darwin" ]]; then
    export ARCHFLAGS="-arch arm64"
fi

# Path to your oh-my-zsh installation.
if [[ -d "/usr/share/oh-my-zsh" ]]; then
    export ZSH="/usr/share/oh-my-zsh"
elif [[ -d "$HOMEBREW_PREFIX/share/oh-my-zsh" ]]; then
    export ZSH="$HOMEBREW_PREFIX/share/oh-my-zsh"
fi

export EDITOR="nvim"
export VISUAL="nvim"

# Rustup respects these locations on every platform. Keep them here rather
# than sourcing rustup's generated env file, which hardcodes ~/.cargo.
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
[[ -d "$CARGO_HOME/bin" ]] && export PATH="$CARGO_HOME/bin:$PATH"

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi
