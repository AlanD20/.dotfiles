#!/bin/bash

###
# Configs
###

nix_pkgs=(
  git
  zsh
  tmux
  stow
  fzf
  exa
  ripgrep
  bat
  direnv
  helix
  dos2unix
  unzip
  meslo-lgs-nf
  sqlite
  go
  gopls
  lf # File manager
  lazygit
  # lldb   # Debugger
  delta # git pager
)

stow_dirs=(
  common
  fonts
  git
  helix
  lazygit
  lvim
  p10k
  tmux
  zsh
  db
)

echo "========================================================"
echo "  💻  System Wide Installation"
echo "========================================================"

# read -p "Installation for: (wsl | *linux): " sys
sys="linux"
pkg_manager="apt"

[[ $(uname -r) == *"microsoft"* ]] && sys="wsl"
[[ $(uname -r) == *"MANJARO"* ]] && pkg_manager="pacman"

# Multi-user installation for Linux
nix_flag="--daemon"

# Change to Single-user installation for WSL
[ "$sys" == "wsl" ] && nix_flag="--no-daemon"

###
# Start installation
###

echo "🌎 Generate locale language"
sudo locale-gen en_US-UTF-8

echo "=========================================="
echo "Installing Composer"
echo "=========================================="
# Using NIX will source NIX's php version
curl -sS https://getcomposer.org/installer | php && sudo mv composer.phar /usr/local/bin/composer

echo "=========================================="
echo "Installing antidote"
echo "=========================================="
git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

echo "=========================================="
echo "📦 Installing NIX"
echo "=========================================="
sh <(curl -L https://nixos.org/nix/install) $nix_flag

[ "$sys" == "wsl" ] && . ~/.nix-profile/etc/profile.d/nix.sh
[ "$sys" == "linux" ] && . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'

# Enable System support nix shell loader in .zshrc file
[ "$sys" == "wsl" ] && sed -i "/# WSL Nix/{n;s/# //I}" ./zsh/.zshrc
[ "$sys" == "linux" ] && sed -i "/# Linux Nix/{n;s/# //I}" ./zsh/.zshrc

echo "=========================================="
echo "Installing packages using NIX"
echo "=========================================="

# Add unstable channel
nix-channel --add https://nixos.org/channels/nixpkgs-unstable unstable && nix-channel --update unstable

for package in ${nix_pkgs[@]}; do
  echo "📦 Installing $package"
  NIXPKGS_ALLOW_UNFREE=1 nix-env -iA nixpkgs.$package
done

echo "=========================================="
echo "🔗 Stowing dot files"
echo "=========================================="

# Export C locale if env is linux
[ "$sys" == "linux" ] && export LC_ALL=C

# Remove exisitng config
rm $HOME/.config/lvim/config.lua

# To fix perl locale warning
export LC_ALL=C

for dir in ${stow_dirs[@]}; do
  echo "Stowing $dir"
  stow $dir
done

echo "=========================================="
echo "Caching fonts"
echo "=========================================="

fc-cache -rv

echo "=========================================="
echo "🖼️ Configuring zsh"
echo "=========================================="

# source .proflie for nix-env that installed zsh
source ~/.profile

# Load the profile script with zsh
$(which zsh) ./install-profile.zsh

echo "=========================================="
echo "Configure SSH"
echo "=========================================="

sudo sed -i 's/#Port 22/Port 22/I' /etc/ssh/sshd_config
sudo sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/I' /etc/ssh/sshd_config

echo "=========================================="
echo "🔃 System Service"
echo "=========================================="

sudo systemctl start nginx
sudo systemctl restart nginx

sudo systemctl enable ssh
sudo systemctl start ssh

# Clean unnecessary files by nix
nix-collect-garbage -d

echo "=========================================="
echo "🔃 Desktop environment setup"
echo "=========================================="

function desktop_env() {

  if [ "$sys" == "wsl" ]; then
    return 0
  fi

  echo "Install python modules"
  pip3 install fuzzywuzzy faker requests pint simpleeval parsedatetime

  echo "Installing python modules"
  stow ulauncher

  mkdir -p ~/.config/ulauncher/user-themes
  git clone https://github.com/SylEleuth/ulauncher-gruvbox ~/.config/ulauncher/user-themes/gruvbox-ulauncher

  # Fix docker permission
  sudo chmod 666 /var/run/docker.sock

}

bat <<MANUAL_TASKS
==============================================
            Remaining Manual Tasks....
==============================================

- Change root password, if you want to:
sudo passwd root

- Configure p10k style:
p10k configure

MANUAL_TASKS
