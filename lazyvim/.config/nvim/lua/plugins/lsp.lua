-- Comprehensive LSP Configuration for All Languages
-- This file contains optimized LSP settings for all enabled languages in LazyVim
-- Optimizations applied:
--   - Single LSP per language (no duplicates)
--   - Performance-tuned settings (reduced indexing, disabled unused features)
--   - Disabled slow/duplicate servers explicitly
--   - Configured for fast startup and responsive editing

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- ========================================================================
        -- PYTHON - Optimized for performance
        -- Using pyright (fast type checker) + ruff (fast linter/formatter)
        -- Disabled: pylsp, python-lsp-server (slower alternatives)
        -- ========================================================================
        pyright = {
          settings = {
            python = {
              analysis = {
                diagnosticMode = "openFilesOnly",
                autoSearchPaths = false,
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
                diagnosticSeverityOverrides = {
                  reportGeneralTypeIssues = "warning",
                  reportPossiblyUnbound = "warning",
                  reportUnusedExpression = "warning",
                  reportUndefinedVariable = "warning",
                },
                ignore = {
                  "**/node_modules",
                  "**/__pycache__",
                  "**/.venv",
                  "**/venv",
                  "**/.git",
                  "**/.pytest_cache",
                  "**/.mypy_cache",
                },
              },
            },
          },
        },
        ruff = {
          init_options = {
            settings = {
              logLevel = "error",
              lint = {
                run = "onSave", -- Only lint on save, not on every keystroke
              },
            },
          },
        },
        -- Explicitly disable slower Python LSP alternatives
        pylsp = { enabled = false },
        ruff_lsp = { enabled = false },
        python_lsp_server = { enabled = false },

        -- ========================================================================
        -- PHP - Using intelephense (fast, feature-rich)
        -- Disabled: phpactor (duplicate, slower)
        -- ========================================================================
        intelephense = {
          enabled = true,
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000,
                exclude = {
                  "**/.git/**",
                  "**/node_modules/**",
                  "**/.idea/**",
                  "**/.vscode/**",
                  "**/storage/**",
                  "**/bootstrap/cache/**",
                },
              },
              completion = {
                fullyQualifyGlobalConstantsAndFunctions = false,
                triggerParameterHints = false,
              },
              diagnostics = {
                enable = true,
              },
            },
          },
        },
        phpactor = { enabled = false },

        -- ========================================================================
        -- JAVASCRIPT/TYPESCRIPT - Using ts_ls (official TypeScript LSP)
        -- Optimized: disabled inlay hints and snippet completions for speed
        -- Disabled: denols (conflicts with ts_ls)
        -- ========================================================================
        ts_ls = {
          enabled = true,
          settings = {
            typescript = {
              preferences = {
                -- Disable snippet completions for faster completion
                includeCompletionsWithSnippetText = false,
                includeCompletionsWithInsertText = false,
              },
              inlayHints = {
                -- Disable all inlay hints (can slow down editor)
                includeInlayParameterNameHints = "none",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = false,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = false,
                includeInlayFunctionLikeReturnTypeHints = false,
                includeInlayEnumMemberValueHints = false,
              },
            },
            javascript = {
              preferences = {
                includeCompletionsWithSnippetText = false,
                includeCompletionsWithInsertText = false,
              },
              inlayHints = {
                includeInlayParameterNameHints = "none",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = false,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = false,
                includeInlayFunctionLikeReturnTypeHints = false,
                includeInlayEnumMemberValueHints = false,
              },
            },
          },
        },
        eslint = {
          settings = {
            workingDirectory = { mode = "auto" },
            useFlatConfig = false,
          },
        },
        denols = { enabled = false },

        -- ========================================================================
        -- GO - Using gopls (official Go LSP)
        -- Optimized: disabled unused analyses and all inlay hints
        -- Disabled: golangci-lint-ls (slow, use gopls built-in linting instead)
        -- ========================================================================
        gopls = {
          settings = {
            gopls = {
              build = {
                allowModfileModifications = false,
                allowModfileModifications1 = false,
              },
              ui = {
                semanticTokens = true,
              },
              analyses = {
                unusedparams = true,
                shadow = false, -- Disabled for performance
              },
              staticcheck = false, -- Disabled for performance
              hints = {
                -- All hints disabled for performance
                assignVariableTypes = false,
                compositeLiteralFields = false,
                compositeLiteralTypes = false,
                constantValues = false,
                functionTypeParameters = false,
                parameterNames = false,
                rangeVariableTypes = false,
              },
            },
          },
        },
        golangci_lint_ls = { enabled = false },

        -- ========================================================================
        -- C/C++ - Using clangd with performance optimizations
        -- Optimized: background indexing, PCH in memory, bundled completions
        -- ========================================================================
        clangd = {
          keys = {
            { "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
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
          -- Allow clangd to start even when no project marker is found
          -- (e.g. a single standalone C file)
          workspace_required = false,
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          cmd = {
            "clangd",
            "--background-index", -- Index in background for faster startup
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=bundled", -- Faster completion
            "--pch-storage=memory", -- Store PCH in memory for speed
            "--cross-file-rename",
          },
        },

        -- ========================================================================
        -- YAML - Using yamlls with schemastore integration
        -- Features: Schema validation, auto-completion for Kubernetes, GitHub Actions, etc.
        -- ========================================================================
        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
              },
              schemas = require("schemastore").yaml.schemas(),
              validate = true,
              format = { enable = true },
              hover = true,
              completion = true,
            },
          },
        },

        -- ========================================================================
        -- JSON - Using jsonls with schemastore integration
        -- Features: Schema validation for package.json, tsconfig.json, etc.
        -- ========================================================================
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },

        -- ========================================================================
        -- ANSIBLE - Using ansible-language-server
        -- Features: Playbook validation, linting integration
        -- ========================================================================
        ansiblels = {
          settings = {
            ansible = {
              validation = {
                enabled = true,
                lint = {
                  enabled = true,
                },
              },
            },
          },
        },

        -- ========================================================================
        -- DOCKER - Using dockerls + docker-compose-language-service
        -- Features: Dockerfile and docker-compose.yml validation
        -- ========================================================================
        dockerls = {},
        docker_compose_language_service = {},

        -- ========================================================================
        -- TERRAFORM - Using terraformls
        -- Features: HCL validation, resource completion
        -- ========================================================================
        terraformls = {},

        -- ========================================================================
        -- TAILWIND CSS - Using tailwindcss-language-server
        -- Optimized: Configured for Blade templates and web frameworks
        -- ========================================================================
        tailwindcss = {
          settings = {
            tailwindCSS = {
              classAttributes = {
                "class",
                "className",
                ":class",
                "class:list",
                "classList",
                "ngClass",
              },
              emmetCompletions = true,
              includeLanguages = {
                javascript = "javascript",
                javascriptreact = "html",
                typescriptreact = "html",
                html = "HTML",
                blade = "HTML",
                plaintext = "javascript",
              },
            },
          },
        },

        -- ========================================================================
        -- CMAKE - Using neocmake (modern CMake LSP)
        -- Disabled: cmake (older alternative)
        -- ========================================================================
        neocmake = {},
        cmake = { enabled = false },

        -- ========================================================================
        -- TOML - Using taplo for TOML files
        -- Features: Cargo.toml, pyproject.toml validation
        -- ========================================================================
        taplo = {},

        -- ========================================================================
        -- SQL - Using sqlls for SQL files
        -- ========================================================================
        sqlls = {},

        -- ========================================================================
        -- ZIG - Using zls (Zig Language Server)
        -- ========================================================================
        zls = {},

        -- ========================================================================
        -- NUSHELL - Using nushell LSP
        -- ========================================================================
        nushell = {},

        -- ========================================================================
        -- PUPPET - Using puppet-editor-services
        -- Features: Puppet manifest validation, syntax highlighting
        -- ========================================================================
        puppet = {},

        -- ========================================================================
        -- EMMET - Using emmet-ls for HTML/CSS expansion
        -- Features: Expand abbreviations like `div.container` to full HTML
        -- Configured for Blade templates and web development
        -- ========================================================================
        emmet_ls = {
          filetypes = {
            "html",
            "css",
            "scss",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
            "svelte",
            "blade",
            "php",
          },
          init_options = {
            html = {
              options = {
                ["bem.enabled"] = true,
              },
            },
          },
        },

        -- ========================================================================
        -- RUST - Using rust-analyzer (official Rust LSP)
        -- Features: Full Rust support - completion, goto-def, refactoring, diagnostics
        -- Optimized: Disabled inlay hints for performance, kept essential features
        -- ========================================================================
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              -- Cargo configuration
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              -- Check configuration (clippy for linting)
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              -- Completion configuration
              completion = {
                postfix = {
                  enable = true,
                },
                autoimport = {
                  enable = true,
                },
              },
              -- Diagnostics configuration
              diagnostics = {
                enable = true,
                experimental = {
                  enable = false, -- Disabled for performance
                },
              },
              -- Inlay hints - disabled for performance (can slow down editor)
              inlayHints = {
                bindingModeHints = {
                  enable = false,
                },
                chainingHints = {
                  enable = false,
                },
                closingBraceHints = {
                  enable = false,
                  minLines = 25,
                },
                closureReturnTypeHints = {
                  enable = false,
                },
                lifetimeElisionHints = {
                  enable = false,
                  useParameterNames = false,
                },
                maxLength = 25,
                parameterHints = {
                  enable = false,
                },
                reborrowHints = {
                  enable = false,
                },
                renderColons = true,
                typeHints = {
                  enable = false,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },
              -- Proc macro support
              procMacro = {
                enable = true,
                ignored = {
                  -- Known problematic macros can be listed here
                },
              },
              -- Workspace configuration
              workspace = {
                symbol = {
                  search = {
                    scope = "workspace_and_dependencies",
                  },
                },
              },
            },
          },
        },
      },

      -- ========================================================================
      -- SETUP HOOKS - For per-server customizations
      -- ========================================================================
      setup = {
        -- Ruff: Disable hover in favor of Pyright (avoid duplicate hover info)
        ruff = function()
          Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
            client.server_capabilities.hoverProvider = false
          end)
        end,
      },
    },
  },
}
