-- Register before LSP's FileType handler: index buffers have virtual paths
-- that gopls cannot open. acwrite keeps Diffview's BufWriteCmd staging intact
-- while excluding these buffers from automatic LSP attachment.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("diffview_lsp", { clear = true }),
  pattern = "*",
  callback = function(args)
    if vim.api.nvim_buf_get_name(args.buf):match("^diffview://") and vim.bo[args.buf].buftype == "" then
      vim.bo[args.buf].buftype = "acwrite"
      vim.b[args.buf].autoformat = false
    end
  end,
})

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.globals")

require("config.lazy")

require("config.after")

require("config.debugger")
