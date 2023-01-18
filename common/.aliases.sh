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

alias rr="source ~/.zshrc; pwd";

# Bundle zsh plugins via antidote
alias update-ad='antidote bundle < $HOME/.zsh_plugins.txt > $HOME/.zsh_plugins.zsh';

# Editor
alias ef='hx `fzf`';
alias vf='lvim `fzf`';

# Apt
alias apti="sudo apt-get -y install";
alias aptr="sudo apt-get -y remove";
alias aptud="sudo apt-get -y update";
alias aptug="sudo apt-get -y upgrade";

# Nix
alias ni='nix-env -iA'
alias nr='nix-env --uninstall'
alias nix-clean='sudo nix-collect-garbage -d'

# GPG
alias rgpg="gpg-connect-agent RELOADAGENT /bye"; # Reload gpg
alias tgpg="echo test | gpg --clearsign"; # Test gpg

# System
alias cls="clear";
alias mkp="mkdir -pv";
alias ss="sudo systemctl";
alias sr="ss restart";

# Exa
# More flags at https://github.com/ogham/exa#command-line-options
alias ls='exa -a --icons --git --group-directories-first';
alias lls="ls -l";
alias la="lls --git-ignore";
alias lta="lls --tree --git-ignore";

# Custom Service Control
alias ss-redis="ss start redis-server";

# PHP
alias pa="php artisan";

# Custom git
function clone_single_branch () {
  git clone --single-branch --branch $@
}

alias gcls="clone_single_branch"
