#!/usr/bin/env bash
# Run after stowing the herdr and lazyvim packages.
set -euo pipefail

plugins=(
    crierr/herdr-arrange
    zenbu-labs/terminal-browser/herdr-plugin
)

for plugin in "${plugins[@]}"; do
    herdr plugin install "$plugin" --yes
done

# Navigation uses the same plugin checkout as Neovim.
navigation_dir="${XDG_DATA_HOME:-$HOME/.local/share}/${NVIM_APPNAME:-nvim}/lazy/smart-splits.nvim"
if [[ ! -f "$navigation_dir/herdr-plugin.toml" ]]; then
    HERDR_ENV=1 nvim --headless -i NONE \
        '+lua require("lazy").install({plugins={"smart-splits.nvim"}, wait=true})' +qa
fi
herdr plugin link "$navigation_dir" --enabled
herdr config check
herdr server reload-config
