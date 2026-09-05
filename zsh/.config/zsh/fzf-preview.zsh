#!/usr/bin/env zsh
# Invoked by fzf, not sourced during interactive startup.
emulate -L zsh
local mode=$1 target=$2

case $mode in
  ssh)
    [[ -n $target && $target != -* ]] || exit 0
    # Evaluate configuration without opening an SSH connection. Print only
    # connection metadata, never identity-file contents.
    command ssh -G -- "$target" 2>/dev/null | command awk '
      $1 == "hostname" || $1 == "user" || $1 == "port" ||
      $1 == "identityfile" || $1 == "proxyjump" {
        key = $1; sub(/^[^ ]+ +/, ""); printf "%-14s %s\n", key, $0
      }
    '
    ;;
  metadata)
    command ls -ld -- "$target" 2>/dev/null
    ;;
  path)
    if [[ -d $target ]]; then
      if (( $+commands[eza] )); then
        command eza --all --color=always --group-directories-first -- "$target" | command head -100
      else
        command ls -A -p -- "$target" | command head -100
      fi
    elif [[ -f $target ]]; then
      if (( $+commands[bat] )); then
        command bat --color=always --style=numbers --paging=never --line-range=:160 -- "$target"
      else
        command head -c 16384 -- "$target" | command cat -v | command head -160
      fi
    fi
    ;;
esac
