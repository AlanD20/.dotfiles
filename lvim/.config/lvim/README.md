# LunarVim Config

## Go IDE

Run the following command in LunarVim

```bash
:MasonInstall gopls golangci-lint-langserver delve goimports gofumpt gomodifytags gotests impl
```

## PHP IDE

Run the following command in LunarVim

```bash
:MasonInstall intelephense php-debug-adapter phpcs php-cs-fixer
```

After this go into the folder that mason downloaded `php-debug-adapter` (normally would be in `$HOME/.local/share/nvim/mason/packages/php-debug-adapter/`), then after that go into the `extensions` folder and run the following commands:

```bash
npm install
npm run build
```
