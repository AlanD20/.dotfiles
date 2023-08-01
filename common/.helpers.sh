#!/bin/sh

# Custom git
function clone_single_branch() {
  git clone --single-branch --branch $@
}


# Previews
function viewdoc() {
    if [ -z "$1" ]; then
        printf "Please specify a file\n"
        false
    else
        mupdf -I "$1"
    fi
}

function viewimg() {
    if [ -z "$1" ]; then
        printf "Please specify a file\n"
        false
    else
        feh "$1"
    fi
}

