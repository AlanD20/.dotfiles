#!/bin/sh

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

alias rr="source ~/.zshrc; pwd"

# Bundle zsh plugins via antidote
alias update-ad='antidote bundle < $HOME/.zsh_plugins.txt > $HOME/.zsh_plugins.zsh'

# Editor
alias ef='hx `fzf`'
# alias vf='lvim `fzf`';

# Apt
alias apti="sudo apt-get -y install"
alias aptr="sudo apt-get -y remove"
alias aptrp="sudo apt-get -y --purge remove"
alias aptud="sudo apt-get -y update"
alias aptug="sudo apt-get -y upgrade"

# Nix
alias ni="nix-env -iA"
alias nr="nix-env --uninstall"
alias nud="nix-channel --update"
alias nug="nix-env -u '*'"
alias nix-clean="nix-collect-garbage -d"

# Pacman
alias paci="sudo pacman -S --noconfirm"
alias pacr="sudo pacman -R --noconfirm"
alias pacrp="sudo pacman -Rs --noconfirm"
alias pacud="sudo pacman -Sy --noconfirm"
alias pacug="sudo pacman -Su --noconfirm"

# Pamac
alias pai="pamac install --no-confirm"
alias par="pamac remove --no-confirm"
alias paud="pamac update -a"
alias paug="pamac upgrade -a --no-confirm"

# GPG
alias rgpg="gpg-connect-agent RELOADAGENT /bye" # Reload gpg
alias tgpg="echo test | gpg --clearsign"        # Test gpg

# System
alias cls="clear"
alias mkp="mkdir -pv"
alias ss="sudo systemctl"
alias sr="ss restart"

# Exa
# More flags at https://github.com/ogham/exa#command-line-options
alias ls='exa -a --icons --git --group-directories-first'
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
alias cdo="composer dump-autoload -o"

# Custom git
function clone_single_branch() {
  git clone --single-branch --branch $@
}

alias gcls="clone_single_branch"
alias lz="lazygit"
