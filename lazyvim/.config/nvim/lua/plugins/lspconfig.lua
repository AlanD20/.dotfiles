return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- installed servers
        html = {
          init_options = {
            autoClosingTags = true,
            format = {
              wrapAttributes = "force-expand-multiline",
              templating = true,
              wrapLineLength = 120,
            },
            hover = {
              documentation = true,
              references = true,
            },
          },
        },
        cssls = {},
        -- clang = {},
        denols = {},
        emmet_ls = {
          includeLanguages = {
            javascript = "javascriptreact",
            plaintext = "javascript",
          },
          syntaxProfiles = {
            javascript = "jsx",
          },
        },
        intelephense = {
          completion = {
            fullyQualifyGlobalConstantsAndFunctions = true,
          },
          environment = {
            shortOpenTag = true,
          },
          files = {
            exclude = {
              "**/node_modules/**",
            },
          },
        },
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
        sqlls = {},
        lua_ls = {},
        yamlls = {},
        zls = {},
      },
    },
  },
}
