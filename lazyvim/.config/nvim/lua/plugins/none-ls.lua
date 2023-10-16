local async_formatting = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  vim.lsp.buf_request(bufnr, "textDocument/formatting", vim.lsp.util.make_formatting_params({}), function(err, res, ctx)
    if err then
      local err_msg = type(err) == "string" and err or err.message
      -- you can modify the log message / level (or ignore it completely)
      vim.notify("formatting: " .. err_msg, vim.log.levels.WARN)
      return
    end

    -- don't apply results if buffer is unloaded or has been modified
    if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, "modified") then
      return
    end

    if res then
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("silent noautocmd update")
      end)
    end
  end)
end

local nls = require("null-ls")
return {
  {
    "nvimtools/none-ls.nvim",
    opts = {
      -- debounce = 250,
      -- debug = true,
      sources = {
        -- shell & bash
        nls.builtins.formatting.shfmt,
        nls.builtins.formatting.beautysh.with({
          extra_args = {
            "-i",
            "2",
          },
        }),
        nls.builtins.formatting.shellharden,

        -- webdev stuff
        nls.builtins.formatting.deno_fmt, -- choosed deno for ts/js files cuz its very fast!
        nls.builtins.formatting.prettierd,

        -- Lua
        nls.builtins.formatting.stylua,

        -- cpp
        nls.builtins.formatting.clang_format,

        -- php
        nls.builtins.formatting.pint.with({
          timeout = 10000000,
          command = "pint",
          condition = function(utils)
            if utils.root_has_file({ ".php-cs-fixer.php" }) then
              return false
            end

            return utils.has_file({ vim.fn.expand("~/.pint.json") }) or utils.root_has_file({ "pint.json" })
          end,
          extra_args = function(params)
            local conf = FindOrFallback("pint.json", "~/.pint.json", {
              path = params.root,
              type = "file",
            })

            return params.options and {
              "--config",
              conf,
            }
          end,
        }),
        nls.builtins.formatting.phpcsfixer.with({
          timeout = 10000,
          extra_args = function(params)
            return params.options and {
              "--allow-risky",
              "yes",
            }
          end,
        }),
        nls.builtins.diagnostics.php,
        -- nls.builtins.diagnostics.phpstan.with({
        --   temp_dir = "/tmp",
        -- }),
        nls.builtins.formatting.blade_formatter.with({
          timeout = 100000,
          command = "blade-formatter",
          args = {
            "--write",
            "$FILENAME",
            "--wrap-attributes",
            "force-expand-multiline",
            -- "--sort-tailwindcss-classes",
          },
        }),

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
        local augroup = vim.api.nvim_create_augroup("null-ls_lsp_formatting", { clear = true })

        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({
            group = augroup,
            buffer = bufnr,
          })

          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              async_formatting(bufnr)
              -- vim.lsp.buf.format({
              --   timeout_ms = 100000,
              --   filter = function(client)
              --     return client.name == "null-ls"
              -- end
              -- })
            end,
          })
        end
      end,
    },
  },
}
