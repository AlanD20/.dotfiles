#!/usr/bin/env zsh

# This script runs by the login user to keep all the permissions

###
# Configs
###

node_version="lts/hydrogen"

fail() {
  echo "Error: $1"
  echo "Please re-run the script, exiting..."
  exit 1
}

should_fail() {
  if [ "$?" -ne 0 ]; then
    fail "$1"
  fi
}

# Make sure this path exist to avoid conflicts and making parent dir linked
mkdir -p $HOME/.local/bin $HOME/.local/share/fonts

stow_dirs=(
  alacritty
  albert
  atuin
  bin
  common
  docker
  easyeffects
  # flameshot
  gnupg
  lazygit
  lazyvim # Choose between nvchad or lazyvim
  mako
  # nvchad
  oh-my-posh
  onedrive
  # p10k
  redshift
  swappy
  sway
  swaylock
  systemd
  # thunar
  tmux
  wallpapers
  waybar
  wofi
  zsh
)

#echo "=========================================="
#echo "Installing antidote"
#echo "=========================================="
# install it from github for non-arch distros
# git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote

echo "=========================================="
echo "🔗 Stowing dot files"
echo "=========================================="

for dir in ${stow_dirs[@]}; do
  echo "Stowing $dir"
  # LC_ALL=C fixes perl locale warning
  # gracefully run stow and adopt
  LC_ALL=C stow $dir --adopt
done

echo "=========================================="
echo "Caching fonts - Run 'fc-cache -rv' any time there is a file change at .local/share/fonts"
echo "=========================================="

fc-cache -rv

# add zsh to valid login shell
command -v zsh | sudo tee -a /etc/shells

should_fail "Adding zsh to valid login shells"

# Use zsh as default shell
sudo usermod --shell $(which zsh) $USER

should_fail "Changing user shell"

source "common/.zshenv"
source "$HOME/.zshenv"

# Load ZSH profile
source "$ZDOTDIR/.zshrc"

should_fail "Sourcing .zshrc shell environment"

# finally, link zsh config
stow zsh

# Loads plugins and nvm
source "$ZDOTDIR/.zshrc"

should_fail "sourcing pre-configured zsh shell environment"

# Change go mod path
go env -w GOMODCACHE="$XDG_CACHE_HOME/go/pkg/mod"

# Update nvm to latest
nvm upgrade

echo "=========================================="
echo "Installing node"
echo "=========================================="
nvm install $node_version
nvm alias default $node_version
nvm use default
npm install npm@latest yarn@latest pnpm@latest --location=global

echo "=========================================="
echo "Installing k9s catppuccin theme"
echo "=========================================="
OUT="${XDG_CONFIG_HOME:-$HOME/.config}/k9s/skins"
curl -L https://github.com/catppuccin/k9s/archive/main.tar.gz | tar xz -C "$OUT" --strip-components=2 k9s-main/dist

echo "=========================================="
echo "Installing python 3.11.7"
echo "=========================================="

pyenv install 3.11.7
pyenv global 3.11.7

echo "=========================================="
echo "🔃 System Service"
echo "=========================================="
systemctl --user enable gnmoe-keyring-gnome
systemctl --user enable ydotool
systemctl --user enable pipewire
systemctl --user enable wireplumber
systemctl --user enable redshift
systemctl --user enable --now ssh-agent.service
