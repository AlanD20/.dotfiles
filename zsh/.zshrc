# remove duplicat entries from $PATH
typeset -U PATH path

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export VISUAL="nvim"

# Export term colors
export TERM="xterm-256color"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# Default zsh configs
HISTFILE=$HOME/.histfile
HISTSIZE=1000
SAVEHIST=1000

# autoload -Uz compinit && compinit
setopt autocd beep extendedglob nomatch notify

# Export vscode bin path for WSL
# export PATH="$PATH:/mnt/c/Program Files/Microsoft VS Code/bin"

# Export bin dir
export PATH="$PATH:$HOME/.local/bin"

# Export nvm completion settings for lukechilds/zsh-nvm plugin
# Note: This must be exported before the plugin is bundled
export NVM_DIR=${HOME}/.nvm
export NVM_COMPLETION=true
# export NVM_LAZY_LOAD=true # If enabled, the npm bin path will not be added

ZSH_WEB_SEARCH_ENGINES=(yt "https://www.youtube.com/results?search_query=")

ZSH_WEB_SEARCH_ENGINES=(yth "https://www.youtube.com/")

source $ZSH/oh-my-zsh.sh

# User configuration
export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Vi keybinding
# bindkey -v

# Fix Shift + arrows to move
bindkey "^[[1;2C" forward-word
bindkey "^[[1;2D" backward-word

# Fix Ctrl + arrows to move
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word

# GPG
export GPG_TTY=$(tty)

# Bat Customization
# Get the list of available themes
# bat --list-themes
export BAT_THEME="ansi"

# FZF
# Use @@ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='@@'
# export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!{.git,.cache}'"
export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard | fd --type f --type l $FD_OPTIONS"
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --margin=1 --padding=1"

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

# Source aliases
if [ -e $HOME/.aliases.sh ]; then . $HOME/.aliases.sh; fi

# To customize prompt, run `p10k configure` or edit $HOME/.p10k.zsh.
# [[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/custom-theme.omp.json)"


# source antidote
# source ${ZDOTDIR:-}/.antidote/antidote.zsh
source '/usr/share/zsh-antidote/antidote.zsh'

# initialize plugins statically with ${ZDOTDIR:-$HOME}/.zsh_plugins.txt
antidote load

source $HOME/.zsh_plugins.zsh


export GPG_TTY=$(tty)
gpgconf --launch gpg-agent

neofetch

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
