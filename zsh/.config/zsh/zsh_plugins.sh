#!/bin/sh

zinit snippet OMZP::git
zinit snippet OMZP::git-extras
zinit snippet OMZP::fzf
zinit snippet OMZP::tmux
zinit snippet OMZP::gpg-agent
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::command-not-found
zinit snippet OMZP::web-search
zinit snippet OMZP::fancy-ctrl-z
zinit snippet OMZP::history

zinit light rupa/z
zinit light lukechilds/zsh-nvm
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
# zinit light zsh-users/zsh-syntax-highlighting
zinit light zdharma-continuum/fast-syntax-highlighting

zinit snippet 'https://github.com/belak/zsh-utils/blob/main/utility/utility.plugin.zsh'
# zinit snippet 'https://github.com/belak/zsh-utils/blob/main/completion/completion.plugin.zsh'

# CLI Tab completion with fzf
zinit light Aloxaf/fzf-tab
