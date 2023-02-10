# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# If not running interactively, don"t do anything
case $- in
*i*) ;;
*) return ;;
esac

#######################___Default_CHECKS___#########################

export PATH=$HOME/bin:$PATH
HISTCONTROL=ignoreboth

# append to the history file, don"t overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check if the user isn't root
if [ "$UID" != 0 ]; then
  # case-insensitive globbing (used in pathname expansion)
  shopt -s nocaseglob
  # autocorrect typos in path names when using `cd`
  shopt -s cdspell
fi

# Do not autocomplete when accidentally pressing Tab on an empty line. (It takes
# forever and yields "Display all 15 gazillion possibilites?")
shopt -s no_empty_cmd_completion

# Check the window size after each command and, if necessary,
# update the values of lines and columns.
shopt -s checkwinsize

# Number of trailing directory components to retain when expanding the
# \w and \W prompt string escapes. Characters removed are replaced
# with an ellipsis.
PROMPT_DIRTRIM=7

# the search path for the cd command
CDPATH=.:$HOME

#######################___END_Default_CHECKS___#####################

#######################___tput_Variables___#########################
user=$(tput setaf 34)
at=$(tput setaf 227)
txt=$(tput setaf 255)
yellow=$(tput setaf 220)
lpath=$(tput setaf 214)
arrow=$(tput setaf 160)
main=$(tput setaf 198)
cmdtext=$(tput setaf 82)
dir=$(tput setaf 27)
lines=$(tput setaf 38)
arr_com=$(tput setaf 118)
black=$(tput setaf 233)
reset=$(tput sgr0)

#######################___END_tput_Variables___#####################

PS1="${txt}Current Path: \[${lpath}\]\w\n" #Title usage
PS1+="\[${user}\]\u"                       #user color
PS1+="\[${at}\]@"                          #@
PS1+="\[${txt}\]\h"                        #host color
PS1+="\[${arrow}\] ->"                     #Arrow color
PS1+="\[${dir}\] \W\n"                     #Location color
PS1+="\[${arr_com}\]>=>\[${reset}\] "      #Command color

export PS1

#######################___ALIASS___################################

alias ll="ls -l"
alias la="ls -a"
alias lla="ls -al"
alias rr="source ~/.bashrc; ls -l"
alias cls="clear"
alias t="tree"
alias install="sudo apt-get -y install"
alias remove="sudo apt-get -y remove"
alias update="sudo apt-get -y update"
alias upgrade="sudo apt-get -y upgrade"
alias g="git"
alias g.="git add ."
alias ga="git add"
alias gc="git commit"
alias gcm="git commit -m"
alias gb="git branch"
alias gd="git diff"
alias gi="git init"
alias gm="git merge"
alias gmma="git merge origin/master"
alias gpu="git push"
alias gpl="git pull"
alias gl="git log"
alias glo="git log --oneline"
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

#######################___END_ALIASS___############################

# Bash completion.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
  fi
fi

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ -x /usr/bin/dircolors ]; then
  #test -r $LS_COLORS && eval "$(dircolors -b $LS_COLORS)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Source aliases
if [ -e ~/.aliases.sh ]; then . ~/.aliases.sh; fi
