-- the function returns path to `$HOME/.local/share/nvim`, then concatenates `lazy/lazy.nvim`
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end

-- Add lazy to the `runtimepath`, this allows us to `require` it.
-- learn more at `:help runtimepath`.
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import any extras modules here

    -- Coding
    { import = "lazyvim.plugins.extras.coding.luasnip" },
    { import = "lazyvim.plugins.extras.coding.yanky" },
    { import = "lazyvim.plugins.extras.coding.neogen" }, -- Better annotation

    -- Dap
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.dap.nlua" },

    -- Editor
    { import = "lazyvim.plugins.extras.editor.aerial" }, -- Show file symbols overveiw
    { import = "lazyvim.plugins.extras.editor.harpoon2" }, -- Bookmark files
    { import = "lazyvim.plugins.extras.editor.illuminate" }, -- highlight words when cursor is on a word
    { import = "lazyvim.plugins.extras.editor.leap" }, -- use 's' to quickly jump around words
    { import = "lazyvim.plugins.extras.editor.mini-diff" }, -- <leader>go to show git diff within buffer
    { import = "lazyvim.plugins.extras.editor.mini-files" }, -- <leader>fm to open quick file explorer and open files
    { import = "lazyvim.plugins.extras.editor.mini-move" }, -- Alt+<jklh> to move around line(s)
    { import = "lazyvim.plugins.extras.editor.navic" }, -- Shows quick symbol overview for current context
    { import = "lazyvim.plugins.extras.editor.outline" }, -- Similar to aerial
    { import = "lazyvim.plugins.extras.coding.mini-surround" }, -- Add/Replace/Delete surrounding 'gz<a,r,d>'
    { import = "lazyvim.plugins.extras.editor.refactoring" }, -- Refactoring util

    -- Formatting
    { import = "lazyvim.plugins.extras.formatting.black" },
    { import = "lazyvim.plugins.extras.formatting.prettier" },

    -- Languages
    { import = "lazyvim.plugins.extras.lang.ansible" },
    { import = "lazyvim.plugins.extras.lang.clangd" },
    { import = "lazyvim.plugins.extras.lang.cmake" },
    { import = "lazyvim.plugins.extras.lang.docker" },
    { import = "lazyvim.plugins.extras.lang.git" },
    { import = "lazyvim.plugins.extras.lang.go" },
    -- { import = "lazyvim.plugins.extras.lang.helm" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.php" },
    -- { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.sql" },
    { import = "lazyvim.plugins.extras.lang.tailwind" },
    { import = "lazyvim.plugins.extras.lang.terraform" },
    { import = "lazyvim.plugins.extras.lang.toml" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    --{ import = "lazyvim.plugins.extras.lang.vue" },
    { import = "lazyvim.plugins.extras.lang.yaml" },

    -- Linting
    { import = "lazyvim.plugins.extras.linting.eslint" },

    -- LSP
    -- { import = "lazyvim.plugins.extras.lsp.none-ls" }, -- null-ls migrate

    -- Test
    { import = "lazyvim.plugins.extras.test.core" },

    -- UI
    { import = "lazyvim.plugins.extras.ui.mini-indentscope" }, -- Shows start/end of a scope
    { import = "lazyvim.plugins.extras.ui.treesitter-context" }, -- Sticky function/class names while in scope
    -- { import = "lazyvim.plugins.extras.ui.treesitter-rewrite" }, -- TODO: disable for now...
    -- { import = "lazyvim.plugins.extras.ui.mini-animate" },

    -- Utils
    { import = "lazyvim.plugins.extras.util.dot" }, -- Shell scripting utilities
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" }, -- show hex or texts with background colors?
    { import = "lazyvim.plugins.extras.util.project" },

    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
