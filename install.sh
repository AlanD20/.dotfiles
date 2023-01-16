#!/bin/bash

###
# Configs
###
php_version="8.2"

packages=(
  apt-transport-https
  ca-certificates
  curl
  fonts-powerline
  build-essential
  software-properties-common
  unattended-upgrades
  php$php_version
  php$php_version-{common,cgi,fpm,mbstring,curl,gd,imagick,intl,memcached,snmp,xml,zip,opcache,pgsql,mysql,psr,redis}
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
  helix
  nginx
  dos2unix
  unzip
  antibody
  meslo-lgs-nf
  redis
  sqlite

  # Language Servers
  # gopls
  # sqls
  # marksman
  # nodePackages_latest.intelephense
  # python-language-server
  # nodePackages_latest.yaml-language-server
  # nodePackages_latest.vscode-json-languageserver
  # nodePackages_latest.vscode-langservers-extracted
  # nodePackages_latest.typescript-language-server
  # nodePackages_latest.svelte-language-server
  # nodePackages_latest.dockerfile-language-server-nodejs
  # nodePackages_latest.bash-language-server
)

stow_dirs=(
  common
  git
  helix
  tmux
  zsh
  p10k
)

echo "========================================================"
echo "  💻  System Wide Installation"
echo "========================================================"

read -p "Type of System? (WSL | *Linux): " sys;

# Linux flag
nix_flag="--daemon"

if [ "$sys" == "wsl" ]
then
    # WSL flag
    nix_flag="--no-daemon"
fi

function update_upgrade () {
  sudo apt -y update && sudo apt -y upgrade
}


###
# Start installation
###

echo "🌎 Generate locale language"
sudo locale-gen

echo "Update System"
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
echo "Updating kernals..."
echo "=========================================="
sudo apt -y install linux-headers-$(uname -r) build-essential dkms
echo "=========================================="
echo "Kernal updated successfully!"
echo "=========================================="


echo "Initial system update"

for package in ${packages[@]}
do
  sudo apt -y install $package
done


echo "=========================================="
echo "Installing Composer"
echo "=========================================="

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer


echo "=========================================="
echo "Installing NIX"
echo "=========================================="
sh <(curl -k -L https://nixos.org/nix/install) $nix_flag

echo "Source nix"
. ~/.nix-profile/etc/profile.d/nix.sh


echo "=========================================="
echo "Installing packages using NIX"
echo "=========================================="

for package in ${nix_pkgs[@]}
do
	echo "📦 Installing $package"
	NIXPKGS_ALLOW_UNFREE=1 nix-env -iA nixpkgs.$package
done


echo "=========================================="
echo "Enabling auto updates"
echo "=========================================="
sudo dpkg-reconfigure -f noninteractive --priority=low unattended-upgrades


echo "=========================================="
echo "Uninstalling Apache2..."
echo "=========================================="
sudo systemctl stop apache2 -f
sudo apt remove -y apache2 --purge


echo "=========================================="
echo 'Fixing php.ini File...'
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
echo "Stowing dot files"
echo "=========================================="

for dir in ${stow_dirs[@]}
do
  echo "Stowing $dir"
  stow $dir
done


echo "=========================================="
echo "Configuring zsh"
echo "=========================================="

# source .proflie for nix-env that installed zsh
source ~/.profile

$(which zsh) ./install-profile.zsh


echo "=========================================="
echo "Finishing installation script..."
echo "=========================================="
sudo systemctl restart php$php_version-fpm
sudo systemctl restart nginx
yes | sudo apt autoremove
update_upgrade


bat<< MANUAL_TASKS
==============================================
            Remaining Manual Tasks....
==============================================

- Change root password, if you want to:
sudo passwd root

- Configure p10k style:
p10k configure

MANUAL_TASKS
