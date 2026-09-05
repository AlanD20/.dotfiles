-- Language extras own their servers and defaults. Only local preferences and
-- languages without an enabled extra belong here.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        bashls = {
          -- nvim-lint owns ShellCheck diagnostics on save.
          settings = { bashIde = { shellcheckPath = "" } },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "basic",
              },
            },
          },
        },
        intelephense = {
          settings = {
            intelephense = {
              files = {
                exclude = {
                  "**/.git/**",
                  "**/node_modules/**",
                  "**/.idea/**",
                  "**/.vscode/**",
                  "**/storage/**",
                  "**/bootstrap/cache/**",
                },
              },
            },
          },
        },
        clangd = {
          -- Keep standalone C/C++ files useful outside a project.
          workspace_required = false,
          root_markers = {
            ".clangd",
            ".clang-tidy",
            ".clang-format",
            "compile_commands.json",
            "compile_flags.txt",
            "configure.ac",
            "configure.in",
            "config.h.in",
            "Makefile",
            "meson.build",
            "meson_options.txt",
            "build.ninja",
            ".git",
          },
        },
        tailwindcss = {
          filetypes_include = { "blade" },
          settings = {
            tailwindCSS = {
              includeLanguages = { blade = "html" },
              classAttributes = { "class", "className", ":class", "class:list", "classList", "ngClass" },
            },
          },
        },
        emmet_language_server = {
          filetypes = {
            "astro",
            "blade",
            "css",
            "eruby",
            "html",
            "htmlangular",
            "htmldjango",
            "javascript",
            "javascriptreact",
            "less",
            "php",
            "sass",
            "scss",
            "svelte",
            "typescript",
            "typescriptreact",
            "vue",
          },
        },
        html = {},
        cssls = {},
        nginx_language_server = {},
        puppet = {},
        sqlls = {},
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              check = { command = "clippy" },
            },
          },
        },
        -- Mason may still have these installed. Do not auto-enable competing
        -- servers; the extras select vtsls, Pyright/Ruff, Intelephense and neocmake.
        ts_ls = { enabled = false },
        denols = { enabled = false },
        pylsp = { enabled = false },
        emmet_ls = { enabled = false },
        typos_lsp = { enabled = false }, -- nvim-lint owns spelling diagnostics.
        cmake = { enabled = false },
        golangci_lint_ls = { enabled = false },
      },
    },
  },
}
