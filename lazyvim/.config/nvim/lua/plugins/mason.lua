return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Others
        "nginx-language-server",
        "emmet-language-server",
        "emmet-ls",
        "ruff-lsp",
        "markdownlint",
        "markdownlint-cli2",
        "codespell",
        "typos",
        "typos-lsp",

        -- Shell scripts
        "shfmt",
        "beautysh",
        "shellcheck",
        "shellharden",
        "bash-language-server",

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
        "prettierd",
        "vue-language-server",

        -- c/cpp
        "clangd",
        "clang-format",

        -- go
        "gopls",
        "golangci-lint-langserver",
        "golangci-lint",
        "delve",
        "goimports",
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
        "fixjson",
        "jq",
        "jq-lsp",

        -- yaml
        "yaml-language-server",
        "yamllint",
        "yamlfmt",
        "yamlfix",

        -- Docker
        "dockerfile-language-server",
        "docker-compose-language-service",

        -- Code scans for vulnerabilities
        "snyk",

        -- Terraform
        "terraform-ls",
        "tflint",
        "tfsec",

        -- Ansible
        "ansible-language-server",
        "ansible-lint",

        -- zig
        "zls",
      },
    },
  },
}
