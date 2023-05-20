-- run the following command: :MasonInstall intelephense php-debug-adapter phpcs php-cs-fixer

-- After this go into the folder that mason downloaded php-debug-adapter (normally would be in $HOME/.local/share/nvim/mason/packages/php-debug-adapter/), then after that go into the extentension folder and run the following commands:

-- npm install
-- npm run build

------------------------
-- Treesitter
------------------------
lvim.builtin.treesitter.ensure_installed = {
	"php",
  "phpdoc",
}

------------------------
-- Plugins
------------------------
lvim.plugins = {}

------------------------
-- Formatting
------------------------
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "phpcsfixer", filetypes = { "php" } },
}

lvim.format_on_save = {
  pattern = { "*.php" },
}

------------------------
-- Linting
------------------------
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "phpcs", filetypes = { "php" } },
}

------------------------
-- LSP
------------------------
local lsp_manager = require("lvim.lsp.manager")
lsp_manager.setup("intelephense")


------------------------
-- LSP
------------------------
-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#PHP
local dap = require("dap")
local mason_path = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/")
dap.adapters.php = {
	type = "executable",
	command = "node",
	args = { mason_path .. "packages/php-debug-adapter/extension/out/phpDebug.js" },
}
dap.configurations.php = {
  {
    name = "Listen for Xdebug",
		type = "php",
		request = "launch",
		port = 9003,
  },
  {
    name = "Debug currently open script",
		type = "php",
		request = "launch",
		port = 9003,
    cwd = "${fileDirname}",
    program = "${file}",
    runtimeExecutable = "php",
  },
}


