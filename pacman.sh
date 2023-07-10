#!/bin/bash

pacman_pkgs=(
  ca-certificates
  curl
  php
  php-cgi
  php-fpm
  php-gd
  php-embed
  php-intl
  php-redis
  php-snmp
  php-sqlite
  php-sodium
  xdebug
  nginx
  flameshot
  docker
  redis
  openssh
  zip
  unzip
  python-setuptools
  net-tools
  perl-image-exiftool
)

sudo pacman-mirrors --fasttrack && sudo pacman -Syu

echo "💽 Initial system update"

for package in ${pacman_pkgs[@]}; do
  sudo pacman -S --noconfirm $package
done

# Fix debug file
sudo sed 's/;//' -i xdebug.ini

git clone https://aur.archlinux.org/ulauncher.git && cd ulauncher && yes | makepkg -is && cd - && rm -rf ulauncher

echo "=========================================="
echo "Setup PHP"
echo "=========================================="
sudo sed -i 's/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/I' /etc/php/php.ini
sudo sed -i 's/;extension=fileinfo/extension=fileinfo/I' /etc/php/php.ini
sudo sed -i 's/;extension=gd/extension=gd/I' /etc/php/php.ini
sudo sed -i 's/;extension=imap/extension=imap/I' /etc/php/php.ini
sudo sed -i 's/;extension=mbstring/extension=mbstring/I' /etc/php/php.ini
sudo sed -i 's/;extension=exif/extension=exif/I' /etc/php/php.ini
sudo sed -i 's/;extension=mysqli/extension=mysqli/I' /etc/php/php.ini
sudo sed -i 's/;extension=sqlite3/extension=sqlite3/I' /etc/php/php.ini
sudo sed -i 's/;extension=openssl/extension=openssl/I' /etc/php/php.ini
sudo sed -i 's/;extension=pdo_mysql/extension=pdo_mysql/I' /etc/php/php.ini
sudo sed -i 's/;extension=pdo_sqlite/extension=pdo_sqlite/I' /etc/php/php.ini
sudo sed -i 's/;extension=sockets/extension=sockets/I' /etc/php/php.ini
sudo sed -i 's/;extension=intl/extension=intl/I' /etc/php/php.ini
sudo sed -i 's/;extension=sodium/extension=sodium/I' /etc/php/php.ini
sudo sed -i 's/;extension=igbinary.so/extension=igbinary.so/I' /etc/php/php.ini
sudo sed -i 's/;igbinary.compact_strings=On/igbinary.compact_strings=On/I' /etc/php/php.ini
sudo sed -i 's/;extension=redis/extension=redis/I' /etc/php/php.ini
sudo sed -i 's/;extension=redis/extension=redis/I' /etc/php/conf.d/redis.ini
sudo sed -i 's/;extension=iconv/extension=iconv/I' /etc/php/php.ini

echo "=========================================="
echo "🔃 System Service"
echo "=========================================="
sudo systemctl start php-fpm
sudo systemctl restart php-fpm

sudo systemctl enable redis
sudo systemctl start redis

sudo systemctl enable docker
sudo systemctl enable containerd
sudo systemctl start docker
