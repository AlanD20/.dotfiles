#!/bin/bash

# Pass the user so it installs on behalf of the user
user="$1"
pwd="$PWD"
temp="/home/$user/temp"

if [ "$user" = "" ]; then
  echo "User is required!"
  exit 0
fi

echo "USE SUDO TO RUN THIS SCRIPT NOT ROOT!! AND Pass Your user login to first arg"

read -r -p "y to continue, any key to cancel: "

if [ "${REPLY:0:1}" != 'y' ]; then
  exit 1
fi

# Create a temporary directory
mkdir "$temp"
sudo chown "$user" -R "$user"
cd "$temp" || exit

check_failure() {
  if [ "$?" -ne 0 ]; then
    echo "Error: $1"
    echo "Please re-run the script, exiting..."
    exit 1
  fi
}

pacman_pkgs=(
  #
  # Essentials
  git
  dos2unix
  net-tools
  curl
  neovim
  vim
  nano
  wget
  curl
  ca-certificates
  openssh
  zip
  unzip
  jq   # CLI json processor
  yq   # CLI yaml processor
  bind # dig CLI
  less
  lsof
  strace
  htop

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
  ydotool      # similar to xdotool for wayland, programmatically send events and inputs
  mako         # Wayland notification
  lxappearance # Modify GTK+ appearance
  redshift

  gnome-keyring # Keychain to store secrets and passwords
  keychain      # Store ssh private key for ssh agent
  libsecret     # Dependency for gnome-keyring
  seahorse      # Frontend gnome-keyring control
  keepassxc     # Frontend for keepass, a password manager, you could use this instead of gnome-keyring

  #
  # Vulkan with Nvidia
  #
  vulkan-intel
  vulkan-headers
  vulkan-validation-layers

  #
  # CLI Utils
  #
  tmux                # Terminal multiplexer
  zsh                 # Main shell instead of bash
  stow                # easily manage .dot files
  fzf                 # fuzzy finder for files and directories
  eza                 # better ls command (exa is unmaintained)
  ripgrep             # Better grep
  bat                 # Better cat command
  direnv              # Loading env variables for current working directory
  lf                  # CLI File manager
  lazygit             # TUI for git
  fd                  # Quick file finder
  git-delta           # git pager
  perl-image-exiftool # Show image and file metadata
  feh                 # Image viewer
  # thunar            # File Explorer
  dolphin       # File Explorer
  kdf           # Show disk space
  kde-cli-tools # Better tooling for dolphin
  wf-recorder   # Screen recorder
  ffmpeg        # Video & Audio converter
  grim          # Screenshot tool
  slurp         # get x, y screen. used with grim
  swappy        # Editing tool for screenshot
  mpv           # Video&Audio Player
  mpv-mpris     # MPV plugin to control player through MPRIS D-bus interface
  mupdf         # View pdf and other files
  # pandoc-cli  # Convert files from one markup format into another
  entr # Rerun scripts or commands after file changes
  gdu  # Fast and easy analyzer to cleanup files
  dmenu
  gvfs
  pavucontrol # GUI to control audio devices
  unrar       # Unrar a rar file
  woff2       # Support for woff2 font
  k9s         # TUI for Kubernetes
  fff         # Fast file-manager
  tldr        # tldr for man pages
  ncdu        # Disk analyzer cleanup
  pyenv       # Python version manager
  fastfetch
  # kmon      # Linux Kernel Manager and Activity Monitor

  #
  # languages
  #
  go
  gopls
  php
  lua
  terraform

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
  xdebug     # PHP Debugger
  python-pip # Python package manager
  python-setuptools
  python-requests

  #
  # Albert Plugins
  #
  libqalculate
  imagemagick
  python-pint
  muparser

  #
  # App Services
  #
  pipewire       # Audio manager
  pipewire-alsa  # Support for alsa
  pipewire-pulse # Support for pulse
  pipewire-jack  # Support for jack
  libpulse       # Sound server
  wireplumber    # Pipewire session/policy manager

  #
  # Dev tools
  #
  sqlite # Lightweight file database
  nginx  # Web server
  docker # Manage Containers
  containerd
  docker-compose # manage multiple containers within a single file
  # redis          # Caching database
  ansible
  # mitmproxy # powerful HTTP proxy

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
  flatpak # package manager
  discord
  # flameshot
  firefox
  obs-studio
  gimp # Image editing
  libreoffice-fresh

  #
  #
  # Easy Effects - Audio controller
  easyeffects
  calf
  lsp-plugins
  mda.lv2
  zam-plugins

  #
  # Qt & GTK Dark Mode
  #
  gnome-themes-extra
  gtk-engines
  gtk-engine-murrine
  papirus-icon-theme # Icons

  breeze
  breeze-icons
)

aur_pkgs=(
  downgrade # Easily downgrade packages from A.L.A or cache
  albert
  oh-my-zsh-git
  oh-my-posh-bin
  tmux-plugin-manager # tpm for tmux
  code-minimap        # Required for minimap-vim
  mycli
  lazydocker
  visual-studio-code-bin
  google-chrome
  spotify
  postman-agent
  anydesk-bin  # Remote desktop
  zsh-antidote # Manag zsh plugins
  xdman8       # Download Manager
  lightly-qt   # Modern style for qt applications
  nordic-theme # GTK3 theme
  zig-bin
  metadata-cleaner
  onedrive-abraunegg # Onedrive sync for keepass db
  jqp-bin            # A TUI playground for jq

  adwaita-qt5 # Theme for qt5
  adwaita-qt6 # Theme for qt6
)

echo "=========================================="
echo "Install yay"
echo "=========================================="
sudo pacman -S --noconfirm git base-devel # Make sure they are installed

# Change clone directory to user's owner
su "$user" -c "cd /home/$user && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm"

check_failure "yay installation failed, you have to manually go to $HOME/yay-bin then run 'makepkg -si' then comment yay install in this script"

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
  su "$user" -c "yay -Sy $package"
done

check_failure "Most probably yay failed to install packages, please install them manually."

# Fix debug file
sudo sed 's/;//' -i xdebug.ini

echo "=========================================="
echo "Installing Composer"
echo "=========================================="
curl -sS https://getcomposer.org/installer | php && sudo mv composer.phar /usr/local/bin/composer

check_failure "Composer installation"

echo "=========================================="
echo "🖼️ Configuring zsh"
echo "=========================================="

# Load the profile script with zsh
cd "$pwd" || exit 1
su "$user" -c "$(which zsh) $pwd/sway-install-profile.zsh"

check_failure "running user profile script"

echo "=========================================="
echo "Configure SSH"
echo "=========================================="

sed -i 's/#Port 22/Port 22/I' /etc/ssh/sshd_config
sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/I' /etc/ssh/sshd_config

echo "=========================================="
echo "Install SpotX For Spotify"
echo "=========================================="
bash <(curl -sSL https://raw.githubusercontent.com/SpotX-CLI/SpotX-Linux/main/install.sh) -ce

check_failure "SpotX installation"

echo "=========================================="
echo "Setup PHP"
echo "=========================================="
sed -i 's/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/I' /etc/php/php.ini
sed -i 's/;extension=bcmath/extension=bcmath/I' /etc/php/php.ini
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

# Make sure docker group exists
groupadd docker

# If adding user to docker doesn't fix it, use this but it's not safe!
# chmod 666 /var/run/docker.sock

# Adding user to the group
usermod -a -g docker,flatpak,redis "$user"

check_failure "Adding User to docker, flatpak, redis groups"

bat <<MANUAL_TASKS
==============================================
            Remaining Manual Tasks....
==============================================

- Change root password, if you want to:
sudo passwd root

MANUAL_TASKS
