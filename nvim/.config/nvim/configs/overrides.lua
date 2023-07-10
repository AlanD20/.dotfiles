local M = {}

M.treesitter = {
  ensure_installed = {
    -- "c",
    -- "cpp",
    -- "graphql",
    -- "java",
    "bash",
    "comment",
    "css",
    "dockerfile",
    "git_rebase",
    "gitattributes",
    "gitignore",
    "go",
    "gomod",
    "html",
    "http",
    "javascript",
    "json",
    "lua",
    "markdown_inline",
    "markdown",
    "php",
    "phpdoc",
    "prisma",
    "python",
    "rust",
    "scss",
    "sql",
    "svelte",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "yaml",
    "zig",
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
  highlight = {
    enable = true,
  },

  -- ignore_install = { "haskell" }
}

M.mason = {
  ensure_installed = {

    -- Scripting
    "bash-language-server",

    -- lua
    "lua-language-server",
    "stylua",

    -- web dev
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "prettier",

    -- c/cpp
    "clangd",
    "clang-format",

    -- go
    "gopls",
    "golangci-lint-langserver",
    "golangci-lint",
    "delve",
    "goimports-reviser",
    "golines",
    "gofumpt",
    "gomodifytags",
    "gotests",
    "impl",

    -- php
    "pint",
    "intelephense",
    "php-debug-adapter",
    "php-cs-fixer",
    "phpstan",
    "blade-formatter",

    -- python
    "python-lsp-server",
    "flake8",

    -- sql
    "sqlls",

    -- yaml
    "yaml-language-server",
    "yamllint",
    "yamlfmt",

    -- zig
    "zls",
  },
}

-- git support in nvimtree
M.nvimtree = {

  view = {
    side = "left",
  },

  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

return M
