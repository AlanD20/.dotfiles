-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- define a new file type for blade
vim.api.nvim_create_autocmd({ "FileType", "BufRead", "BufNewFile" }, {
  group = augroup("blade-php"),
  pattern = { ".*%.blade%.php" },
  command = " setlocal ts=2 sts=2 sw=2 filetype=blade syntax=blade expandtab",
})
