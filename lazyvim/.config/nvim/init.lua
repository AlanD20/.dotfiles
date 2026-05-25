-- Must run before LSP starts: prevent LSP from attaching to diffview:// buffers.
-- diffview sets buftype=nil for stage-0 files, making them look like normal
-- buffers, but their URIs (diffview://...) choke gopls.  We restore buftype
-- before vim.lsp.enable's FileType handler can see the buffer.
-- Registered early (during init) so it runs before LSP's own FileType autocmd.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    if vim.api.nvim_buf_get_name(args.buf):match("^diffview://") then
      vim.bo[args.buf].buftype = "nowrite"
    end
  end,
})

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.globals")

require("config.lazy")

require("config.after")

require("config.debugger")
