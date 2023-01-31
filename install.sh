#!/bin/bash

###
# Configs
###
php_version="8.2"

packages=(
  dkms
  apt-transport-https
  ca-certificates
  curl
  fonts-powerline
  build-essential
  software-properties-common
  unattended-upgrades
  php$php_version
  php$php_version-{common,cgi,fpm,mbstring,curl,gd,imagick,intl,memcached,snmp,xml,zip,opcache,pgsql,mysql,psr,redis}
  python3-pip
  redis-server
  # Download nginx from ppa:ondrej/nginx repo
  nginx
  openssh-server
)

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
  neovim
  helix
  dos2unix
  unzip
  meslo-lgs-nf
  sqlite
  go
  gopls
  docker
  lf # File manager
  lazygit
  # lldb   # Debugger
)

stow_dirs=(
  common
  git
  helix
  lazygit
  lvim
  p10k
  tmux
  zsh
)

echo "========================================================"
echo "  💻  System Wide Installation"
echo "========================================================"

read -p "Installation for: (wsl | *linux): " sys

# Multi-user installation for Linux
nix_flag="--daemon"

# Change to Single-user installation for WSL
[ "$sys" == "wsl" ] && nix_flag="--no-daemon"

function update_upgrade() {
  sudo apt -y update && sudo apt -y upgrade
}

###
# Start installation
###

echo "🌎 Generate locale language"
sudo locale-gen

echo "💻 Update System"
update_upgrade

###
# Add repositories
###
echo "Adding repositories"
sudo add-apt-repository -y universe
sudo add-apt-repository -y ppa:ondrej/php
sudo add-apt-repository -y ppa:ondrej/nginx

echo "Source new repositores"
update_upgrade

echo "=========================================="
echo "🧩 Updating kernals..."
echo "=========================================="
sudo apt -y install linux-headers-$(uname -r)
echo "=========================================="
echo "✅ Kernal updated successfully!"
echo "=========================================="

echo "💽 Initial system update"

for package in ${packages[@]}; do
  sudo apt -y install $package
done

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
sh <(curl -L https://nixos.org/nix/install) $nix_flag && . ~/.nix-profile/etc/profile.d/nix.sh

echo "=========================================="
echo "Installing packages using NIX"
echo "=========================================="

for package in ${nix_pkgs[@]}; do
  echo "📦 Installing $package"
  NIXPKGS_ALLOW_UNFREE=1 nix-env -iA nixpkgs.$package
done

echo "=========================================="
echo "⌛ Enabling auto updates"
echo "=========================================="
sudo dpkg-reconfigure -f noninteractive --priority=low unattended-upgrades

echo "=========================================="
echo "❌ Uninstalling Apache2..."
echo "=========================================="
sudo systemctl stop apache2 -f
sudo apt remove -y apache2 --purge

echo "=========================================="
echo '✏️ Fixing php.ini File...'
echo "=========================================="
sudo sed -i 's/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/gI' /etc/php/$php_version/fpm/php.ini
sudo sed -i 's/;extension=fileinfo/extension=fileinfo/gI' /etc/php/$php_version/fpm/php.ini
sudo sed -i 's/;extension=gd/extension=gd/gI' /etc/php/$php_version/fpm/php.ini
sudo sed -i 's/;extension=imap/extension=imap/gI' /etc/php/$php_version/fpm/php.ini
sudo sed -i 's/;extension=mbstring/extension=mbstring/gI' /etc/php/$php_version/fpm/php.ini
sudo sed -i 's/;extension=exif/extension=exif/gI' /etc/php/$php_version/fpm/php.ini
sudo sed -i 's/;extension=mysqli/extension=mysqli/gI' /etc/php/$php_version/fpm/php.ini
sudo sed -i 's/;extension=openssl/extension=openssl/gI' /etc/php/$php_version/fpm/php.ini
sudo sed -i 's/;extension=pdo_mysql/extension=pdo_mysql/gI' /etc/php/$php_version/fpm/php.ini
sudo sed -i 's/;extension=sockets/extension=sockets/gI' /etc/php/$php_version/fpm/php.ini

echo "=========================================="
echo "🔗 Stowing dot files"
echo "=========================================="

for dir in ${stow_dirs[@]}; do
  echo "Stowing $dir"
  stow $dir
done

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
echo "🔃 Finishing installation script..."
echo "=========================================="
sudo systemctl restart php$php_version-fpm
sudo systemctl restart nginx
sudo systemctl start ssh

# Clean unnecessary files by nix
nix-collect-garbage -d

yes | sudo apt autoremove
update_upgrade

bat <<MANUAL_TASKS
==============================================
            Remaining Manual Tasks....
==============================================

- Change root password, if you want to:
sudo passwd root

- Configure p10k style:
p10k configure

MANUAL_TASKS
