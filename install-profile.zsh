
###
# Configs
###
node_version="16.19.0"

# bundle zsh plugins
antidote bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.zsh

source ~/.zshrc

# add zsh to valid login shell
command -v zsh | sudo tee -a /etc/shells

# Use zsh as default shell
sudo chsh -s $(which zsh) $USER

# Loads plugins and nvm
source ~/.zshrc

# Update nvm to latest
nvm upgrade

echo "=========================================="
echo "Installing node"
echo "=========================================="
nvm install $node_version
nvm alias default $node_version
nvm use default
npm install npm@latest --location=global
npm install yarn --location=global


echo "=========================================="
echo "Installing LSP Through npm for Helix"
echo "=========================================="

npm install -g @tailwindcss/language-server blade-formatter vscode-langservers-extracted bash-language-server dockerfile-language-server-nodejs intelephense typescript typescript-language-server @prisma/language-server pyright yaml-language-server

pip install -U 'python-lsp-server[all]'
