###
# Configs
###

node_version="lts/hydrogen"

stow_dirs=(
  alacritty
  albert
  bin
  common
  docker
  easyeffects
  # flameshot
  gnupg
  lazygit
  mako
  nvim
  p10k
  redshift
  sway
  swaylock
  # thunar
  tmux
  wallpapers
  waybar
  wofi
  zsh
)

echo "=========================================="
echo "Installing antidote"
echo "=========================================="
# git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote

echo "=========================================="
echo "🔗 Stowing dot files"
echo "=========================================="

for dir in ${stow_dirs[@]}; do
  echo "Stowing $dir"
  # LC_ALL=C fixes perl locale warning
  LC_ALL=C stow $dir
done

echo "=========================================="
echo "Caching fonts - important whenever you put new fonts at .local/share/fonts"
echo "=========================================="

fc-cache -rv

# Load profile for antidote
source "$ZDOTDIR/.zshrc"

# bundle zsh plugins
antidote bundle <"$ZDOTDIR/.zsh_plugins.txt" >"$ZDOTDIR/.zsh_plugins.zsh"

# Install ohmyzsh - installed from AUR
# yes no | sh -c "$XDG_CACHE_HOME/antidote/*ohmyzsh*/tools/install.sh"

# add zsh to valid login shell
command -v zsh | sudo tee -a /etc/shells

# Use zsh as default shell
sudo usermod --shell $(which zsh) $USER

# Remove auto-generated .zshrc by ohmyzsh
rm "$ZDOTDIR/.zshrc"

# create a new symlink
stow zsh

# Loads plugins and nvm
source "$ZDOTDIR/.zshrc"

# Change go mod path
go env -w GOMODCACHE="$XDG_CACHE_HOME/go/pkg/mod"

# Update nvm to latest
nvm upgrade

echo "=========================================="
echo "Installing node"
echo "=========================================="
nvm install $node_version
nvm alias default $node_version
nvm use default
npm install npm@latest yarn@latest pnpm@latest --location=global

echo "=========================================="
echo "🔃 System Service"
echo "=========================================="
systemctl --user enable gnmoe-keyring-daemon
systemctl --user enable ydotool
systemctl --user enable pipewire
systemctl --user enable wireplumber
systemctl --user enable redshift
