
###
# Configs
###
node_version="16.19.0"


source ~/.zshrc

# add zsh to valid login shell
command -v zsh | sudo tee -a /etc/shells

# Use zsh as default shell
sudo chsh -s $(which zsh) $USER
# usermod --shell /bin/zsh $USER

# bundle zsh plugins
antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh

# echo "Installing neovim plugins"
# nvim --headless +PlugInstall +qall

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
