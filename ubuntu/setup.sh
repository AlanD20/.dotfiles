#!/bin/bash

apt_pkgs=(
  gnome-tweaks
  gnome-shell-extensions
  chrome-gnome-shell
)

pkgs=(
  code
  spotify
  discord
  postman
)

echo "=========================================="
echo "Installing packages using Apt"
echo "=========================================="

for package in ${packages[@]}; do
  sudo apt -y install $package
done

echo "=========================================="
echo "Installing packages using Snapd"
echo "=========================================="

for package in ${pkgs[@]}; do
  echo "📦 Installing $package"
  sudo snap install $package --classic
done

echo "=========================================="
echo "Installing python modules"
echo "=========================================="

pip3 install fuzzywuzzy faker requests pint simpleeval parsedatetime

echo "=========================================="
echo "Unbind/Bind necessary keybindings"
echo "=========================================="

# You can switch between workspace with Super + Alt + Left/Right arrows

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Super><Alt>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super><Alt>Right']"

mkdir -p ~/.config/ulauncher/user-themes
git clone https://github.com/SylEleuth/ulauncher-gruvbox ~/.config/ulauncher/user-themes/gruvbox-ulauncher
