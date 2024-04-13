#!/bin/sh

# Custom git
clone_single_branch() {
  git clone --single-branch --branch "$@"
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

fetch_origin_branch() {
  git fetch origin "$1:$1"
}
