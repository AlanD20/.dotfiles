#!/bin/bash

apt_pkgs=(
  gnome-tweaks
  gnome-shell-extensions
  chrome-gnome-shell
  flameshot
)

snap_pkgs=(
  code
  spotify
  discord
  postman
)

echo "=========================================="
echo "Installing packages using Apt"
echo "=========================================="

for package in "${apt_pkgs[@]}"; do
  sudo apt -y install "$package"
done

echo "=========================================="
echo "Installing packages using Snapd"
echo "=========================================="

for package in "${snap_pkgs[@]}"; do
  echo "📦 Installing $package"
  sudo snap install "$package" --classic
done

echo "=========================================="
echo "Unbind/Bind necessary keybindings"
echo "=========================================="

# You can switch between workspace with Super + Alt + Left/Right arrows

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Super><Alt>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super><Alt>Right']"
