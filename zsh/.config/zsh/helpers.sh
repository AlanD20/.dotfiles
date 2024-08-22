#!/bin/sh

# Clone single branch
clone_single_branch() {
  git clone --single-branch --branch "$@"
}

# https://github.com/jqlang/jq/issues/884#issuecomment-525574290
jql() {
  jq -R -r "${1:-.} as \$line | try fromjson catch \$line"
}

# Previews
viewdoc() {
  if [ "$1" = "" ]; then
    printf "Please specify a file\n"
    false
  else
    mupdf -I "$1"
  fi
}

viewimg() {
  if [ "$1" = "" ]; then
    printf "Please specify a file\n"
    false
  else
    feh "$1"
  fi
}

# fetch and create branch locally without checking out
fetch_origin_branch() {
  git fetch origin "$1:$1"
}

# cd on exist for fff
f() {
  fff "$@"
  cd "$(cat "${XDG_CACHE_HOME:=${HOME}/.cache}/fff/.fff_d")" || exit 1
}

# jqp is a TUI playground for jq
jqq() {
  \jqp -t dracula -f "$@"
}

# Easy docker ssh as user
dssh() {
  if ! command -v docker; then
    exit 1
  fi

  user=${2:-root}
  cmd=${3:-/bin/bash}
  docker exec --user "$user" -it "$1" "$cmd"
}
