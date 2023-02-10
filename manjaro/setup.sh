#!/bin/bash

aur_pkgs=()

flatpak_pkgs=(
  kolourpaint
  com.github.ryonakano.reco
)

pamac_pkgs=(
  knotes
  google-chrome
  spotify
  discord
  postman-agent
  ulauncher
  visual-studio-code-bin
  anydesk-bin
)

echo "=========================================="
echo "Install yay"
echo "=========================================="
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm

echo "=========================================="
echo "Install AUR packages"
echo "=========================================="
for package in ${aur_pkgs[@]}; do
  echo "📦 Installing $package"
  pacman -S --noconfirm $package
done

echo "=========================================="
echo "Install flatpak packages"
echo "=========================================="
for package in ${flatpak_pkgs[@]}; do
  echo "📦 Installing $package"
  flatpak install -y $package
done

echo "=========================================="
echo "Install pamac packages"
echo "=========================================="
for package in ${pamac_pkgs[@]}; do
  echo "📦 Installing $package"
  flatpak install -y $package
done

echo "=========================================="
echo "Install SpotX"
echo "=========================================="
bash <(curl -sSL https://raw.githubusercontent.com/SpotX-CLI/SpotX-Linux/main/install.sh) -ce
