return {
  {
    "stevearc/conform.nvim",
    opts = function()
      ---@class ConformOpts
      local opts = {
        -- LazyVim will use these options when formatting with the conform.nvim formatter
        format = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_fallback = true, -- not recommended to change
        },
        ---@type table<string, conform.FormatterUnit[]>
        formatters_by_ft = {
          -- Use the "*" filetype to run formatters on all filetypes.
          ["*"] = { "codespell", "typos" },
          -- Use the "_" filetype to run formatters on filetypes that don't
          -- have other formatters configured.
          lua = { "stylua" },
          sh = { "shfmt", "shellharden" },
          -- Conform will run multiple formatters sequentially
          python = { "isort", "black" },
          -- Use a sub-list to run only the first available formatter
          html = { { "prettierd", "prettier" } },
          css = { { "prettierd", "prettier" } },
          javascript = { { "prettierd", "prettier" } },
          typescript = { { "prettierd", "prettier" } },
          typescriptreact = { { "prettierd", "prettier" } },
          javascriptreact = { { "prettierd", "prettier" } },
          php = {
            "pint",
            --   "phpcsfixer",
          },
          blade = { "blade_formatter" },
          go = {
            -- they are included with lazyvim golang plugin
            -- "gofmt",
            -- "gofumpt",
            { "goimports_reviser", "goimports" },
            "golines",
          },
          json = { "fixjson" },
          yaml = {
            "yamlfmt",
            "yamlfix",
          },
        },
        -- The options you set here will be merged with the builtin formatters.
        -- You can also define any custom formatters here.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          -- injected = { options = { ignore_errors = true, timeout_ms = 1000 } },
          typos = {
            condition = function(_)
              return true
            end,
            command = "typos",
            args = {
              "-w",
              "$FILENAME",
            },
          },
          pint = {
            cwd = require("conform.util").root_file({ "pint.json" }),
            require_cwd = true,
          },
          blade_formatter = {
            command = "blade-formatter",
            args = {
              "--write",
              "$FILENAME",
              "--wrap-attributes",
              "force-expand-multiline",
              -- "--sort-tailwindcss-classes",
            },
            stdin = false,
          },
          fixjson = {
            condition = function(_)
              return true
            end,
            command = "fixjson",
            args = {
              "-w",
              "$FILENAME",
            },
            stdin = false,
          },
          -- dprint = {
          --   condition = function(ctx)
          --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
          --   end,
          -- },
          --
          -- # Example of using shfmt with extra args
          -- shfmt = {
          --   prepend_args = { "-i", "2", "-ci" },
          -- },
        },
      }

      return opts
    end,
  },
}
