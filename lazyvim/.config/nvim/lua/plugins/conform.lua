return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Extend the language extras instead of replacing their formatters and
      -- default_format_opts (including LSP fallback and injected languages).
      local util = require("conform.util")
      local fixer_configs = { ".php-cs-fixer.php", ".php-cs-fixer.dist.php" }

      for _, ft in ipairs({
        "css",
        "graphql",
        "handlebars",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "jsonc",
        "less",
        "scss",
        "typescript",
        "typescriptreact",
        "vue",
      }) do
        opts.formatters_by_ft[ft] = { "prettierd", "prettier", stop_after_first = true }
      end

      opts.formatters_by_ft.python = { "ruff_organize_imports", "ruff_format" }
      opts.formatters_by_ft.php = { "pint", "php_cs_fixer", stop_after_first = true }
      opts.formatters_by_ft.blade = { "blade-formatter" }
      opts.formatters_by_ft.yaml = { "yamlfmt" }
      -- Spelling is diagnostic-only; saving must not rename identifiers or
      -- rewrite strings. Shell formatting likewise leaves quoting to the author.

      opts.formatters.pint = {
        cwd = util.root_file({ "pint.json", "composer.json", ".git" }),
        condition = function(_, ctx)
          -- Respect projects that explicitly use PHP-CS-Fixer. Pint otherwise
          -- works with its defaults, including projects without a pint.json.
          return vim.fs.root(ctx.dirname, fixer_configs) == nil
            or vim.fs.root(ctx.dirname, { "pint.json", "vendor/bin/pint" }) ~= nil
        end,
      }
      opts.formatters.php_cs_fixer = {
        cwd = util.root_file({ ".php-cs-fixer.php", ".php-cs-fixer.dist.php", "composer.json" }),
      }
      opts.formatters["blade-formatter"] = {
        prepend_args = { "--wrap-attributes", "force-expand-multiline" },
      }
    end,
  },
}
