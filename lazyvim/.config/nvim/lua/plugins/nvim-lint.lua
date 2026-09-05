local phpstan_configs = { "phpstan.neon", "phpstan.neon.dist", "phpstan.dist.neon" }

return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- External tools run after saving; LSP diagnostics remain available while
      -- editing. Keep the other linters provided by language extras.
      opts.events = { "BufWritePost" }
      opts.linters_by_ft.python = {} -- Ruff already runs as an LSP.
      opts.linters_by_ft.sh = { "shellcheck" }
      opts.linters_by_ft.php = { "phpstan" }
      opts.linters_by_ft.yaml = { "yamllint" }
      opts.linters_by_ft.terraform = { "tflint" }
      opts.linters_by_ft.tf = { "tflint" }
      opts.linters_by_ft["*"] = { "typos" }

      -- Keep nvim-lint's JSON parser and --force-exclude support for typos.
      opts.linters.typos = {
        condition = function(ctx)
          return vim.bo.buftype == "" and vim.uv.fs_stat(ctx.filename) ~= nil
        end,
      }
      opts.linters.phpstan = {
        condition = function(ctx)
          return vim.fs.root(ctx.dirname, phpstan_configs) ~= nil
        end,
        cmd = function()
          local root = vim.fs.root(0, phpstan_configs)
          local bin = root and (root .. "/vendor/bin/phpstan") or "phpstan"
          return vim.fn.executable(bin) == 1 and bin or "phpstan"
        end,
        args = {
          "analyze",
          "--error-format=json",
          "--no-progress",
          function()
            local config = vim.fs.find(phpstan_configs, {
              path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
              upward = true,
              type = "file",
            })[1]
            return "--configuration=" .. config
          end,
        },
      }
    end,
  },
}
