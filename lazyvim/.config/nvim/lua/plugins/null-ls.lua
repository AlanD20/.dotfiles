local nls = require("null-ls")
return {
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = {
      -- debounce = 250,
      -- debug = true,
      sources = {
        nls.builtins.formatting.shfmt,

        -- webdev stuff
        nls.builtins.formatting.deno_fmt, -- choosed deno for ts/js files cuz its very fast!
        nls.builtins.formatting.prettierd,

        -- Lua
        nls.builtins.formatting.stylua,

        -- cpp
        nls.builtins.formatting.clang_format,

        -- php
        nls.builtins.formatting.pint.with({
          condition = function(utils)
            return utils.root_has_file({ "pint.json" })
          end,
        }),
        nls.builtins.formatting.phpcsfixer.with({
          timeout = 10000,
        }),
        nls.builtins.diagnostics.php,
        -- nls.builtins.diagnostics.phpstan.with({
        --   temp_dir = "/tmp",
        -- }),
        nls.builtins.formatting.blade_formatter,

        -- go, two of following disabled as it's included with lazyvim go plugin
        -- nls.builtins.formatting.gofumpt,
        -- nls.builtins.formatting.goimports_reviser,
        nls.builtins.formatting.golines,

        -- python
        nls.builtins.diagnostics.flake8,
        nls.builtins.formatting.black,

        -- yaml
        nls.builtins.formatting.yamlfmt,
        nls.builtins.diagnostics.yamllint,
      },
      on_attach = function(client, bufnr)
        local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({
            group = augroup,
            buffer = bufnr,
          })
          -- vim.api.nvim_create_autocmd("BufWritePre", {
          --   group = augroup,
          --   buffer = bufnr,
          --   callback = function()
          --     vim.lsp.buf.format({ bufnr = bufnr })
          --   end,
          -- })
        end
      end,
    },
  },
}
