# remove duplicate entries from $PATH
typeset -U PATH path

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Vi keybinding
# bindkey -v

# emacs keybinding
bindkey -e

# Fix Shift + arrows to move
bindkey "^[[1;2C" forward-word
bindkey "^[[1;2D" backward-word

# Fix Ctrl + arrows to move
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word

# History file
export HISTFILE="$ZDOTDIR/.zhistory"
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups
setopt hist_ignore_space # Commands starting with space won't be saved
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# ZSH Styling
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# preview directory's content with eza when completing cd
zstyle ':fzf-tab:completion:cd:*' fzf --preview 'ls $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
# default fzf flags
zstyle ':fzf-tab:*' fzf-flags '--height=65%' '--layout=reverse' '--border' '--margin=1' '--padding=1'


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
export FZF_DEFAULT_OPTS="--height=65% --layout=reverse --border --margin=1 --padding=1"
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

# fff
export FFF_FAV1=$HOME/dev
export FFF_FAV2=$HOME/temp
export FFF_FAV3=$HOME/.local/bin
export FFF_FAV4=$HOME/.dotfiles
export FFF_FAV5=
export FFF_FAV6=
export FFF_FAV7=
export FFF_FAV8=
export FFF_FAV9=/

# Bun
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export PATH="$PATH:$CARGO_HOME/bin"

# Go
export GO11MODULE=on

# Yaml Fix
export YAMLFIX_LINE_LENGTH=140
export YAMLFIX_COMMENTS_REQUIRE_STARTING_SPACE='true'
export YAMLFIX_EXPLICIT_START='false'
export YAMLFIX_SEQUENCE_STYLE='keep_style'
export YAMLFIX_quote_basic_values='false'
export YAMLFIX_quote_representation='"'
export YAMLFIX_COMMENTS_WHITELINES="1"
export YAMLFIX_preserve_quotes="true"

# Mason binaries
export PATH="$PATH:$XDG_DATA_HOME/nvim/mason/bin"

# pyenv
if command -v pyenv &>/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# Zinit - zsh plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Load plugins
source "$ZDOTDIR/zsh_plugins"

# Load autocompletion
autoload -Uz compinit && compinit
setopt autocd beep extendedglob nomatch notify

# replay autocompletions
zinit cdreplay -q

ZSH_WEB_SEARCH_ENGINES=(yt "https://www.youtube.com/results?search_query=")
ZSH_WEB_SEARCH_ENGINES=(yth "https://www.youtube.com/")

# Uncomment if oh-my-zsh is necessary
# [ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"
[ -f "$ZDOTDIR/helpers.sh" ] && source "$ZDOTDIR/helpers.sh"
[ -f "$ZDOTDIR/aliases.sh" ] && source "$ZDOTDIR/aliases.sh"
[ -f "$CARGO_HOME/env" ] && source "$CARGO_HOME/env"

eval "$(oh-my-posh init zsh --config $XDG_CONFIG_HOME/oh-my-posh/themes/aland20-custom-theme.omp.json)"

# Antidote setup, source antidote
# source ${ZDOTDIR:-}/.antidote/antidote.zsh
# source '/usr/share/zsh-antidote/antidote.zsh'

# initialize plugins statically with ${ZDOTDIR:-$HOME}/zsh_plugins.txt
# antidote load "$ZDOTDIR/.zsh_plugins.txt"
# source "$ZDOTDIR/.zsh_plugins.zsh"


# bun completions
[ -s "$XDG_DATA_HOME/.bun/_bun" ] && source "$XDG_DATA_HOME/.bun/_bun"

# evaluate direnv
# eval "$(direnv hook zsh)"

# We have to set SSH_AUTH_SOCK at user session level
# to allow KeepassXC load the keys once and reuse
# the same agent for the entire user session.
# * KeepassXC already manages adding/deleting the keys when db locked.
# * Keep in mind that ssh-agent for the user has to be enabled at /run/user/*.
# * You have to run 'keepassxc &' to set '$SSH_AUTH_SOCK' variable, or you
# * confirm that you have installed a 'passphrase dialog' on your machine or
# uncheck 'require user confirmation' for the key in KeepassXC.
# * * ref: https://github.com/keepassxreboot/keepassxc/issues/2606
# * * ref: https://wiki.archlinux.org/title/SSH_keys#Alternative_passphrase_dialogs
# may override it on KeepassXC app.
# ref: https://stackoverflow.com/a/38980986/13362195
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Evaluate ssh-agent per profile
#eval "$(ssh-agent -s)"

# Automatically add keys to keychain, require SSH passphrase when logging in.
#eval "$(keychain --quiet --nogui --eval --agents ssh $HOME/.ssh/id_ed25519)"
#eval "$(keychain --quiet --nogui --eval --agents ssh $HOME/.ssh/id_rsa)"

# Source all files in 'includes' directory and has to have files
if [ -d "$ZDOTDIR/includes" ] && [ -n "$(\ls -A --ignore '.*' $ZDOTDIR/includes)" ]; then
  for src in $ZDOTDIR/includes/*; do
    source $src;
  done
fi


#
# Startups
#

gpgconf --launch gpg-agent
fastfetch
