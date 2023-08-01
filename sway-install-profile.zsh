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
  lazygit
  mako
  nvim
  p10k
  redshift
  sway
  swaylock
  thunar
  tmux
  wallpapers
  waybar
  wofi
  zsh
)

echo "=========================================="
echo "Installing nvchad"
echo "=========================================="
# git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
git clone https://github.com/NvChad/NvChad $HOME/.config/nvim --depth 1

echo "=========================================="
echo "🔗 Stowing dot files"
echo "=========================================="
# To fix perl locale warning
export LC_ALL=C

for dir in ${stow_dirs[@]}; do
  echo "Stowing $dir"
  stow $dir
done

echo "=========================================="
echo "Caching fonts - important whenever you put new fonts at .local/share/fonts"
echo "=========================================="

fc-cache -rv

# Load profile for antidote
source "$HOME/.zshrc"

# bundle zsh plugins
antidote bundle <"$HOME/.zsh_plugins.txt" >"$HOME/.zsh_plugins.zsh"

# Install ohmyzsh
yes no | sh -c "$HOME/.cache/antidote/*ohmyzsh*/tools/install.sh"

# add zsh to valid login shell
command -v zsh | sudo tee -a /etc/shells

# Use zsh as default shell
sudo usermod --shell $(which zsh) $USER

# Remove auto-generated .zshrc by ohmyzsh
rm "$HOME/.zshrc"

# create a new symlink
stow zsh

# Loads plugins and nvm
source "$HOME/.zshrc"

# Update nvm to latest
nvm upgrade

echo "=========================================="
echo "Installing node"
echo "=========================================="
nvm install $node_version
nvm alias default $node_version
nvm use default
npm install npm@latest yarn@latest pnpm@latest --location=global

# Make GNUPG to cache the entered passphrase for 8 hours
mkdir -p $HOME/.gnupg && echo "default-cache-ttl 28800" >>$HOME/.gnupg/gpg-agent.conf

echo "=========================================="
echo "🔃 System Service"
echo "=========================================="
systemctl --user enable gnmoe-keyring-daemon
systemctl --user enable ydotool
systemctl --user enable pipewire
systemctl --user enable wireplumber
systemctl --user enable redshift


