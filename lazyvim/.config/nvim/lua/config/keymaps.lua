-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<C-d>", "<C-d>zz", { silent = true, desc = "moving down, keep cursor in middle" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { silent = true, desc = "moving up, keep cursor in middle" })
vim.keymap.set("n", "n", "nzzzv", { silent = true, desc = "when searching, keep cursor in middle" })
vim.keymap.set("n", "N", "Nzzzv", { silent = true, desc = "when searching, keep cursor in middle" })
vim.keymap.set("n", "<C-w>b", ":bufdo bd<CR>", { silent = true, desc = "Close all open buffers" })
vim.keymap.set("n", "<C-S-A>", ":wa<CR>", { silent = true, desc = "Save all open buffers" })

vim.keymap.set(
  "n",
  "gat",
  ":lua require('textcase').current_word('to_title_case)<CR>",
  { silent = true, desc = "Transform text to Title Case" }
)
vim.keymap.set(
  "n",
  "gau",
  ":lua require('textcase').current_word('to_upper_case')<CR>",
  { silent = true, desc = "Transform text to UPPERCASE" }
)
vim.keymap.set(
  "n",
  "gal",
  ":lua require('textcase').current_word('to_lower_case')<CR>",
  { silent = true, desc = "Transform text to lowercase" }
)
vim.keymap.set(
  "n",
  "gas",
  ":lua require('textcase').current_word('to_snake_case')<CR>",
  { silent = true, desc = "Transform text to snake_case" }
)
vim.keymap.set(
  "n",
  "gac",
  ":lua require('textcase').current_word('to_camel_case)<CR>",
  { silent = true, desc = "Transform text to camelCase" }
)
vim.keymap.set(
  "n",
  "gak",
  ":lua require('textcase').current_word('to_dash_case')<CR>",
  { silent = true, desc = "Transform text to kebab-case" }
)
vim.keymap.set(
  "n",
  "gap",
  ":lua require('textcase').current_word('to_pascal_case)<CR>",
  { silent = true, desc = "Transform text to PascalCase" }
)
vim.keymap.set(
  "n",
  "gad",
  ":lua require('textcase').current_word('to_dot_case)<CR>",
  { silent = true, desc = "Transform text to dot.case" }
)
vim.keymap.set(
  "n",
  "gaC",
  ":lua require('textcase').current_word('to_constant_case')<CR>",
  { silent = true, desc = "Transform text to CONSTANT_CASE" }
)
vim.keymap.set(
  "n",
  "gaP",
  ":lua require('textcase').current_word('to_path_case)<CR>",
  { silent = true, desc = "Transform text to path/case" }
)