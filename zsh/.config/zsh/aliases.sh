#!/bin/sh

# WSL
# alias desktop="${WINHOME}/Desktop";
# WINHOME=$(wslpath "$(wslvar USERPROFILE)")

# Bundle zsh plugins via antidote
alias ad-update="antidote bundle < $ZDOTDIR/.zsh_plugins.txt > $ZDOTDIR/.zsh_plugins.zsh"

# Open
alias fp="fzf --preview=\"bat --color=always --style=plain {}\" --preview-window=\"border:rounded\" --border=rounded --prompt=\"$ \" --pointer=\"->\""
alias v="nvim"
alias vff='nvim `fd . --type f | fzf`'
alias lz="lazygit"
alias dz="lazydocker"
alias kz="k9s --readonly"
alias kzf="k9s --write"

# GPG
alias rgpg="gpg-connect-agent RELOADAGENT /bye" # Reload gpg
alias tgpg="echo test | gpg --clearsign"        # Test gpg
alias ncrgpg="gpg --encrypt --armor -r"         # Encrypt file using gpg
alias dcrgpg="gpg --decrypt"                    # Decrypt file using gpg

# System
alias cdf='cd `fd . --type d | fzf`'
alias cls="clear"
alias mkp="mkdir -pv"
alias ss="sudo systemctl"
alias ssu="systemctl --user"
alias sr="sudo systemctl restart"
alias sj="sudo journalctl"
alias sju="journalctl --user"

# Exa
# More flags at https://github.com/ogham/exa#command-line-options
alias ls="exa -a --icons --git --group-directories-first"
alias lls="ls -l"
alias la="lls --git-ignore"
alias tree="lls --tree --git-ignore"

# Custom Service Control
alias ss-redis="ss start redis-server"

# PHP
alias pa="php artisan"
alias pa-clear="php artisan clear && \
                php artisan clear-compiled &&- \
                php artisan config:clear && \
                php artisan cache:clear && \
                php artisan view:clear && \
                php artisan route:clear && \
                php artisan optimize && \
                composer dump-autoload -o"
alias cr="composer run"
alias cio="composer install -o"
alias cuo="composer update -o"
alias cdo="composer dump-autoload -o"

alias gcls="clone_single_branch"
alias gfo="fetch_origin_branch"
alias dc="docker compose"

# Abraunegg OneDrive
alias onesync="onedrive --synchronize --verbose --force"
alias oneup="onedrive --synchronize --verbose --force --upload-only"
alias onedown="onedrive --synchronize --verbose --force --download-only"
alias oneshare="onedrive --create-share-link"
alias onestatus="onedrive --display-sync-status"

# Personal
alias econf="\cd $DOTFILES && $EDITOR"
alias rr="source $ZDOTDIR/.zshrc"
alias keepass="keepassxc &"
