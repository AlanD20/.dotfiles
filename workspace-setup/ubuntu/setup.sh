#!/bin/bash

sys=$1
php_version="8.2"

apt_pkgs=(
  git
  dos2unix
  net-tools
  curl
  nvim
  vim
  nano
  wget
  tmux
  zsh
  stow
  fzf
  exa
  ripgrep
  bat
  direnv
  lf # File manager
  lazygit
  go
  gopls
  ttf-meslo-nerd # Nerd Font for terminal
  sqlite
  git-delta # git pager

  dkms
  ca-certificates
  curl
  apt-transport-https
  fonts-powerline
  build-essential
  software-properties-common
  unattended-upgrades
  "php$php_version"
  "php$php_version-{common,cgi,fpm,mbstring,curl,gd,imagick,intl,memcached,snmp,xml,zip,opcache,pgsql,mysql,psr,redis,sqlite}"
  xdebug
  python3-pip
  redis-server
  # Download nginx from ppa:ondrej/nginx repo
  nginx
  openssh-server
)

function update_upgrade() {
  sudo apt -y update && sudo apt -y upgrade
}

echo "💻 Update System"
update_upgrade

# Install apt packages

echo "=========================================="
echo "🧩 Updating kernals..."
echo "=========================================="
sudo apt -y install "linux-headers-$(uname -r)"
echo "=========================================="
echo "✅ Kernal updated successfully!"
echo "=========================================="

###
# Add repositories
###
echo "Adding repositories"
sudo add-apt-repository -y universe
sudo add-apt-repository -y ppa:ondrej/php
sudo add-apt-repository -y ppa:ondrej/nginx

echo "Source new repositores"
update_upgrade

echo "💽 Initial system update"

for package in "${apt_pkgs[@]}"; do
  sudo apt -y install "$package"
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
echo "🔃 System Service"
echo "=========================================="
sudo systemctl start php$php_version-fpm
sudo systemctl restart php$php_version-fpm

yes | sudo apt autoremove
update_upgrade

echo "=========================================="
echo "Installing Docker"
echo "=========================================="

function docker_install() {

  if [ "$sys" == "wsl" ]; then
    nix-env -iA nixpkgs.docker
    return 0
  fi

  sudo mkdir -p /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  update_upgrade

  sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

}

docker_install
