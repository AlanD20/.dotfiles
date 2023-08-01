#!/bin/bash

# Pass the user so it installs on behalf of the user
user=$1
temp="/home/$user/temp"

if [ -z "$user" ]; then
  echo "User is required!"
  exit 0
fi

# Create a temporary directory
mkdir "$temp"
sudo chown "$user" -R "$user"
cd "$temp" || exit

pacman_pkgs=(
  #
  # Essentials
  #
  git
  dos2unix
  net-tools
  curl
  nvim
  vim
  nano
  wget
  curl
  ca-certificates
  openssh
  zip
  unzip
  jq

  #
  # Base
  #
  ntfs-3g                # mount NTFS disks
  bluez                  # Bluetooth
  bluez-utils            # Bluetooth
  blueman                # Frontend bluetooth control
  network-manager-applet # Frontend Network control
  polkit
  brightnessctl # Brightness control
  playerctl     # Audio control
  acpi          # Power control
  qtkeychain-qt5
  openssl-1.1
  ydotool      # similar to xdotool for wayland
  mako         # Wayland notification
  lxappearance # Modify GTK+ appearance
  gnome-keyring
  libsecret
  seahorse # Frontend gnome-keyring contorl

  #
  # CLI Utils
  #
  tmux
  zsh
  stow
  fzf
  exa
  ripgrep
  bat
  direnv
  lf # CLI File manager
  lazygit
  fd
  git-delta # git pager
  perl-image-exiftool
  feh         # Image viewer
  thunar      # File Explorer
  wf-recorder # Screen recorder
  ffmpeg
  grim   # Screenshot tool
  slurp  # get x, y screen. used with grim
  swappy # Editing tool for screenshot
  mpv    # Video&Audio Player

  #
  # languages
  #
  go
  gopls
  php

  #
  # Language packages
  #
  php-cgi
  php-fpm
  php-gd
  php-embed
  php-intl
  php-redis # enable /etc/php/conf.d/igbinary.ini
  php-snmp
  php-sqlite
  php-sodium
  xdebug
  python-pip
  python-setuptools
  python-requests

  #
  # Albert
  #
  libqalculate
  imagemagick
  python-pint
  muparser

  #
  # App Services
  #
  pipewire
  pipewire-alsa
  pipewire-pulse
  wireplumber
  sqlite
  nginx
  docker
  containerd
  docker-compose
  redis

  #
  # Fonts
  #
  ttf-font-awesome
  ttf-meslo-nerd
  ttf-jetbrains-mono-nerd
  ttf-anonymouspro-nerd
  ttf-cascadia-code-nerd
  ttf-dejavu-nerd
  otf-droid-nerd
  ttf-firacode-nerd
  ttf-hack-nerd
  ttf-roboto
  ttf-sourcecodepro-nerd
  noto-fonts-emoji # Emoji Set

  #
  # Apps
  #
  flatpak
  discord
  # flameshot
  firefox
  obs-studio

  #
  # Easy Effects
  #
  easyeffects
  calf
  lsp-plugins
  mda.lv2
  zam-plugins

  #
  # Qt Dark Mode
  #
  gnome-themes-extra
  adwaita-qt5
  adwaita-qt6

)

aur_pkgs=(
  visual-studio-code-bin
  google-chrome
  spotify
  postman-agent
  anydesk-bin # Remote desktop
  zsh-antidote
  xdman8 # Download Manager
)

echo "=========================================="
echo "Install yay"
echo "=========================================="
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git

cd yay-bin && su "$user" -c "makepkg -si --noconfirm"

echo "=========================================="
echo "💽 Install pacman packages"
echo "=========================================="

for package in "${pacman_pkgs[@]}"; do
  pacman -S --noconfirm "$package"
done

echo "=========================================="
echo "💽 Install AUR packages using yay"
echo "=========================================="

for package in "${aur_pkgs[@]}"; do
  su "$user" -c "echo y | LANG=C yay --noprovides --answerdiff None --answerclean None --mflags '--noconfirm' $package"
done

# Fix debug file
sudo sed 's/;//' -i xdebug.ini

echo "=========================================="
echo "Installing Composer"
echo "=========================================="
curl -sS https://getcomposer.org/installer | php && sudo mv composer.phar /usr/local/bin/composer

echo "=========================================="
echo "🖼️ Configuring zsh"
echo "=========================================="

# Load the profile script with zsh
su "$user" -c "$(which zsh) ./install-profile.zsh"

echo "=========================================="
echo "Configure SSH"
echo "=========================================="

sed -i 's/#Port 22/Port 22/I' /etc/ssh/sshd_config
sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/I' /etc/ssh/sshd_config

echo "=========================================="
echo "Install SpotX For Spotify"
echo "=========================================="
bash <(curl -sSL https://raw.githubusercontent.com/SpotX-CLI/SpotX-Linux/main/install.sh) -ce

echo "=========================================="
echo "Setup PHP"
echo "=========================================="
sed -i 's/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/I' /etc/php/php.ini
sed -i 's/;extension=fileinfo/extension=fileinfo/I' /etc/php/php.ini
sed -i 's/;extension=gd/extension=gd/I' /etc/php/php.ini
sed -i 's/;extension=imap/extension=imap/I' /etc/php/php.ini
sed -i 's/;extension=mbstring/extension=mbstring/I' /etc/php/php.ini
sed -i 's/;extension=exif/extension=exif/I' /etc/php/php.ini
sed -i 's/;extension=mysqli/extension=mysqli/I' /etc/php/php.ini
sed -i 's/;extension=sqlite3/extension=sqlite3/I' /etc/php/php.ini
sed -i 's/;extension=openssl/extension=openssl/I' /etc/php/php.ini
sed -i 's/;extension=pdo_mysql/extension=pdo_mysql/I' /etc/php/php.ini
sed -i 's/;extension=pdo_sqlite/extension=pdo_sqlite/I' /etc/php/php.ini
sed -i 's/;extension=sockets/extension=sockets/I' /etc/php/php.ini
sed -i 's/;extension=intl/extension=intl/I' /etc/php/php.ini
sed -i 's/;extension=sodium/extension=sodium/I' /etc/php/php.ini
sed -i 's/;extension=igbinary.so/extension=igbinary.so/I' /etc/php/php.ini
sed -i 's/;igbinary.compact_strings=On/igbinary.compact_strings=On/I' /etc/php/php.ini
sed -i 's/;extension=redis/extension=redis/I' /etc/php/php.ini
sed -i 's/;extension=redis/extension=redis/I' /etc/php/conf.d/redis.ini
sed -i 's/;extension=iconv/extension=iconv/I' /etc/php/php.ini

echo "=========================================="
echo "🔃 System Service"
echo "=========================================="
systemctl stop php-fpm
systemctl stop redis
systemctl stop nginx
systemctl stop sshd

systemctl start bluetooth
systemctl start docker

systemctl enable docker
systemctl enable containerd
systemctl enable bluetooth

systemctl --user enable gnmoe-keyring-daemon
systemctl --user enable ydotool
systemctl --user enable pipewire
systemctl --user enable wireplumber
systemctl --user enable redshift

# Fix docker permission
chmod 666 /var/run/docker.sock

# Adding user to the group
usermod -a -g docker,flatpak,redis "$user"

bat <<MANUAL_TASKS
==============================================
            Remaining Manual Tasks....
==============================================

- Change root password, if you want to:
sudo passwd root

- Configure p10k style:
p10k configure

MANUAL_TASKS
