return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Others
        "shellcheck",
        "shfmt",
        "nginx-language-server",
        "emmet-language-server",
        "emmet-ls",
        "bash-language-server",
        "ruff-lsp",

        -- lua
        "lua-language-server",
        "stylua",

        -- web dev
        "css-lsp",
        "html-lsp",
        "js-debug-adapter",
        "typescript-language-server",
        "tailwindcss-language-server",
        "eslint-lsp",
        "deno",
        "prettier",
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
        "pyright",
        "python-lsp-server",
        "flake8",
        "black",
        "debugpy",

        -- sql
        "sqlls",

        -- JSON
        "json-lsp",

        -- yaml
        "yaml-language-server",
        "yamllint",
        "yamlfmt",

        -- Docker
        "dockerfile-language-server",
        "docker-compose-language-service",

        -- zig
        "zls",
      },
    },
  },
}
