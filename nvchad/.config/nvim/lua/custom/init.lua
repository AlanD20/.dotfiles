-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

-- Only accepts terminal font!
-- vim.opt.guifont = { "MesloLGM Nerd Font", ":h16" }
vim.opt.relativenumber = true
vim.opt.wrap = true
vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.mousehide = true -- Hide mouse cursor/pointer when typing.
vim.opt.grepprg = "rg\\ --vimgrep\\ --noheading\\ --smart-case" -- Use ripgrep.
vim.opt.colorcolumn = "120"
vim.opt.updatetime = 50
