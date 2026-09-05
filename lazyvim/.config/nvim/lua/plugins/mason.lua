return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Others
        "nginx-language-server",
        "emmet-language-server",
        -- "ruff",
        "typos",
        "puppet-editor-services",

        -- Shell scripts
        -- "shfmt",
        "shellcheck",
        "bash-language-server",

        -- lua
        "lua-language-server",
        -- "stylua",

        -- web dev
        "css-lsp",
        "html-lsp",
        "js-debug-adapter",
        "tailwindcss-language-server",
        "eslint-lsp",
        "prettierd",
        "vue-language-server",

        -- c/cpp
        "clangd",
        "clang-format",

        -- go
        "gopls",
        -- "delve",
        -- "goimports",
        "golines",

        -- php
        "pint",
        "intelephense",
        "php-debug-adapter",
        "phpstan",
        "blade-formatter",

        -- python
        "pyright",
        "ruff",
        "debugpy",

        -- sql
        "sqlls",

        -- JSON
        "json-lsp",
        "fixjson",

        -- rust
        "rust-analyzer",

        -- yaml
        "yaml-language-server",
        "yamllint",
        "yamlfmt",

        -- Docker
        "dockerfile-language-server",
        "docker-compose-language-service",

        -- Terraform
        "terraform-ls",
        -- "tflint",

        -- Ansible
        "ansible-language-server",
        -- "ansible-lint",

        -- zig
        "zls",
      },
    },
  },
}
