#!/usr/bin/env zsh
# On-demand recursive candidates; no filesystem scan during shell startup.
emulate -L zsh
setopt pipefail
local action=$1 kind=$2 root=${3:-.} mode=${4:-normal}

if [[ $action == cycle ]]; then
  local label='Files' hidden=off ignored=off
  [[ $kind == dir ]] && label='Directories'
  case ${FZF_PROMPT-} in
    *+hidden*) mode=all; hidden=on; ignored=on; label+=' +ignored' ;;
    *+ignored*) mode=normal ;;
    *) mode=hidden; hidden=on; label+=' +hidden' ;;
  esac
  # The final colon-delimited action permits parentheses in filesystem paths.
  print -r -- "change-prompt($label > )+change-header(Hidden: $hidden | Ignored: $ignored | Ctrl-G: cycle | Ctrl-/: preview)+reload:zsh -f ${(q)0:A} list $kind ${(q)root} $mode"
  exit 0
fi

local finder=fd
(( $+commands[fd] )) || finder=fdfind
local -a opts
opts=(--color=never --exclude .git)
if [[ $kind == dir ]]; then
  opts+=(--type d)
else
  opts+=(--type f --type d --type l)
fi
[[ $mode != normal ]] && opts+=(--hidden)
[[ $mode == all ]] && opts+=(--no-ignore)
command "$finder" "${opts[@]}" -- . "$root" | command sed 's#^\./##'
