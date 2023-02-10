###
# Configs
###
node_version="16.19.0"

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

# echo "Call neovim commands headlessly"
# nvim --headless +PlugInstall +qall

# Update nvm to latest
nvm upgrade

echo "=========================================="
echo "Installing node"
echo "=========================================="
nvm install $node_version
nvm alias default $node_version
nvm use default
npm install npm@latest --location=global
npm install yarn pnpm --location=global

echo "=========================================="
echo "Installing LSP Through npm for Helix"
echo "=========================================="

npm install -g @tailwindcss/language-server blade-formatter vscode-langservers-extracted bash-language-server dockerfile-language-server-nodejs intelephense typescript typescript-language-server @prisma/language-server pyright yaml-language-server

pip install -U 'python-lsp-server[all]'

echo "=========================================="
echo "Installing lunarvim"
echo "=========================================="
LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/fc6873809934917b470bff1b072171879899a36b/utils/installer/install.sh)

# Make GNUPG to cache the entered passphrase for 8 hours
mkdir -p $HOME/.gnupg && echo "default-cache-ttl 28800" >>~/.gnupg/gpg-agent.conf
