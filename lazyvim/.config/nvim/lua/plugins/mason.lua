return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Others
        "shellcheck",
        "shfmt",
        "nginx-language-server",
        "bash-language-server",
        "emmet-language-server",
        "emmet-ls",

        -- lua
        "lua-language-server",
        "stylua",

        -- web dev
        "css-lsp",
        "html-lsp",
        "typescript-language-server",
        "tailwindcss-language-server",
        "deno",
        "prettierd",

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
        "php-debug-adapter",

        -- python
        "python-lsp-server",
        "flake8",
        "black",

        -- sql
        "sqlls",

        -- yaml
        "yaml-language-server",
        "yamllint",
        "yamlfmt",

        -- zig
        "zls",
      },
    },
  },
}
