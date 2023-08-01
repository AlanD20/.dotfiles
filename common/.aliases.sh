#!/bin/sh

source $HOME/.helpers.sh


# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# WINHOME=$(wslpath "$(wslvar USERPROFILE)")

# WSL Aliases
# alias desktop="${WINHOME}/Desktop";

alias rr="source $HOME/.zshrc; pwd"

# Bundle zsh plugins via antidote
alias update-ad="antidote bundle < $HOME/.zsh_plugins.txt > $HOME/.zsh_plugins.zsh"

# Open
alias f="fzf --preview=\"bat --color=always --style=plain {}\" --preview-window=\"border:rounded\" --border=rounded --prompt=\"$ \" --pointer=\"->\""
alias vim="nvim"
alias nvim="nvim"
alias vf='nvim `f`'
alias lz="lazygit"

# GPG
alias rgpg="gpg-connect-agent RELOADAGENT /bye" # Reload gpg
alias tgpg="echo test | gpg --clearsign"        # Test gpg
alias ncrgpg="gpg --encrypt --armor -r"
alias dcrgpg="gpg --decrypt"

# System
alias cls="clear"
alias mkp="mkdir -pv"
alias ss="sudo systemctl"
alias ssu="systemctl --user"
alias sr="ss restart"
alias sj="sudo journalctl"
alias sju="journalctl --user"

# Exa
# More flags at https://github.com/ogham/exa#command-line-options
alias ls="exa -a --icons --git --group-directories-first"
alias lls="ls -l"
alias la="lls --git-ignore"
alias lta="lls --tree --git-ignore"

# Custom Service Control
alias ss-redis="ss start redis-server"

# PHP
alias pa="php artisan"
alias pa-clear="php artisan clear && \
                php artisan clear-compiled && \
                php artisan config:clear && \
                php artisan cache:clear && \
                php artisan view:clear && \
                php artisan route:clear && \
                php artisan optimize && \
                composer dump-autoload -o"
alias cr="composer run"
alias cio="composer install -o"
alias cio="composer update -o"
alias cdo="composer dump-autoload -o"

alias gcls="clone_single_branch"

