# remove duplicate entries from $PATH
typeset -U PATH path

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Vi keybinding
# bindkey -v

# Fix Shift + arrows to move
bindkey "^[[1;2C" forward-word
bindkey "^[[1;2D" backward-word

# Fix Ctrl + arrows to move
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word

# History file
export HISTFILE="$ZDOTDIR/.zhistory"
HISTSIZE=1000
SAVEHIST=1000

# Export vscode bin path for WSL
# export PATH="$PATH:/mnt/c/Program Files/Microsoft VS Code/bin"

# Export term colors
export TERM="xterm-256color"

# You may need to manually set your language environment
export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Export nvm completion settings for lukechilds/zsh-nvm plugin
# Note: This must be exported before the plugin is bundled
export NVM_DIR="$XDG_DATA_HOME/nvm"
export NVM_COMPLETION=true
# export NVM_LAZY_LOAD=true # If enabled, the npm bin path will not be added

# GPG
export GPG_TTY=$(tty)

# Bat Customization
# Get the list of available themes
# bat --list-themes
export BAT_THEME="ansi"

# FZF
# Use @@ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='@@'
export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!{.git,.cache}'"
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --margin=1 --padding=1"
# export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard | fd --type f --type l $FD_OPTIONS"

# Preview file content using bat (https://github.com/sharkdp/fd)
export FZF_CTRL_T_OPTS="
--preview 'bat -n --color=always {}'
--bind 'ctrl-/:change-preview-window(down|hidden|)'"

export FZF_CTRL_R_OPTS="
--preview 'echo {}' --preview-window up:3:hidden:wrap
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
--color header:italic
--header 'Press CTRL-Y to copy command into clipboard'"

export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

# Bun
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
# export PATH="$PATH:$CARGO_HOME/bin"

# Go
export GO11MODULE=on

# autoload -Uz compinit && compinit
setopt autocd beep extendedglob nomatch notify

ZSH_WEB_SEARCH_ENGINES=(yt "https://www.youtube.com/results?search_query=")
ZSH_WEB_SEARCH_ENGINES=(yth "https://www.youtube.com/")


[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"
[ -f "$ZDOTDIR/helpers.sh" ] && source "$ZDOTDIR/helpers.sh"
[ -f "$ZDOTDIR/aliases.sh" ] && source "$ZDOTDIR/aliases.sh"
[ -f "$CARGO_HOME/env" ] && source "$CARGO_HOME/env"

# To customize prompt, run `p10k configure` or edit $HOME/.p10k.zsh.
# [[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

eval "$(oh-my-posh init zsh --config $XDG_CONFIG_HOME/oh-my-posh/themes/aland20-custom-theme.omp.json)"

# source antidote
# source ${ZDOTDIR:-}/.antidote/antidote.zsh
source '/usr/share/zsh-antidote/antidote.zsh'

# initialize plugins statically with ${ZDOTDIR:-$HOME}/zsh_plugins.txt
antidote load "$ZDOTDIR/.zsh_plugins.txt"

source "$ZDOTDIR/.zsh_plugins.zsh"

# bun completions
[ -s "$XDG_DATA_HOME/.bun/_bun" ] && source "$XDG_DATA_HOME/.bun/_bun"

# evaluate direnv
eval "$(direnv hook zsh)"

# Evaluate ssh-agent
# eval "$(ssh-agent -s)"

# Add private key to keychain, require SSH passphrase when logging in.
eval "$(keychain --quiet --nogui --eval --agents ssh $HOME/.ssh/id_ed25519)"
eval "$(keychain --quiet --nogui --eval --agents ssh $HOME/.ssh/id_rsa)"


# Source all files in 'includes' directory and has to have files
if [ -d "$ZDOTDIR/includes" ] && [ -n "$(\ls -A --ignore '.*' $ZDOTDIR/includes)" ]; then
  for src in $ZDOTDIR/includes/*; do
    source $src;
  done
fi

#
# Run/Start
#

gpgconf --launch gpg-agent
neofetch
