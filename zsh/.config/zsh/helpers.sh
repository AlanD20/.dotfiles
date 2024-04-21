#!/bin/sh

# Clone single branch
clone_single_branch() {
  git clone --single-branch --branch "$@"
}

# https://github.com/jqlang/jq/issues/884#issuecomment-525574290
jjq() {
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
