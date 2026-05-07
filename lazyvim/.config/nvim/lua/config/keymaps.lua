-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<C-d>", "<C-d>zz", { silent = true, desc = "moving down, keep cursor in middle" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { silent = true, desc = "moving up, keep cursor in middle" })
vim.keymap.set({ "n", "v" }, "E", "$", { silent = true, desc = "Move to beginning of the line" })
vim.keymap.set({ "n", "v" }, "B", "^", { silent = true, desc = "Move to end of the line" })
vim.keymap.set("n", "n", "nzzzv", { silent = true, desc = "when searching, keep cursor in middle" })
vim.keymap.set("n", "N", "Nzzzv", { silent = true, desc = "when searching, keep cursor in middle" })
vim.keymap.set("n", "<leader>bda", "<cmd>%bd!<CR>", { silent = true, desc = "Close all open buffers" })
vim.keymap.set("n", "<leader>bsa", "<cmd>wa<CR>", { silent = true, desc = "Save all open buffers" })
vim.keymap.set("n", "<leader>fx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })
vim.keymap.set(
  "n",
  "<leader>bcr",
  "<cmd>ColorizerReloadAllBuffers<CR>",
  { silent = true, desc = "Colorizer: Reload all buffers" }
)

-- Toggle between regex and literal search for snacks grep
vim.g.snacks_grep_regex = vim.g.snacks_grep_regex ~= false -- default true

local function toggle_grep_regex()
  vim.g.snacks_grep_regex = not vim.g.snacks_grep_regex
  local mode = vim.g.snacks_grep_regex and "regex" or "literal"
  vim.notify("Grep search mode: " .. mode, vim.log.levels.INFO)
end

local function live_grep_with_toggle(opts)
  opts = vim.deepcopy(opts or {})
  opts.regex = vim.g.snacks_grep_regex
  if not opts.cwd and opts.root ~= false then
    opts.cwd = LazyVim.root()
  end
  Snacks.picker.grep(opts)
end

vim.keymap.set("n", "<leader>ugr", toggle_grep_regex, { desc = "Toggle grep regex/literal" })
vim.keymap.set("n", "<leader>sg", function() live_grep_with_toggle() end, { desc = "Grep (Root Dir)" })
vim.keymap.set("n", "<leader>sG", function() live_grep_with_toggle({ root = false }) end, { desc = "Grep (cwd)" })
vim.keymap.set("n", "<leader>/", function() live_grep_with_toggle() end, { desc = "Grep (Root Dir)" })

vim.keymap.set(
  "n",
  "gat",
  "<cmd>lua require('textcase').current_word('to_title_case)<CR>",
  { silent = true, desc = "Transform text to Title Case" }
)
vim.keymap.set(
  "n",
  "gau",
  "<cmd>lua require('textcase').current_word('to_upper_case')<CR>",
  { silent = true, desc = "Transform text to UPPERCASE" }
)
vim.keymap.set(
  "n",
  "gal",
  "<cmd>lua require('textcase').current_word('to_lower_case')<CR>",
  { silent = true, desc = "Transform text to lowercase" }
)
vim.keymap.set(
  "n",
  "gas",
  "<cmd>lua require('textcase').current_word('to_snake_case')<CR>",
  { silent = true, desc = "Transform text to snake_case" }
)
vim.keymap.set(
  "n",
  "gac",
  "<cmd>lua require('textcase').current_word('to_camel_case)<CR>",
  { silent = true, desc = "Transform text to camelCase" }
)
vim.keymap.set(
  "n",
  "gak",
  "<cmd>lua require('textcase').current_word('to_dash_case')<CR>",
  { silent = true, desc = "Transform text to kebab-case" }
)
vim.keymap.set(
  "n",
  "gap",
  "<cmd>lua require('textcase').current_word('to_pascal_case)<CR>",
  { silent = true, desc = "Transform text to PascalCase" }
)
vim.keymap.set(
  "n",
  "gad",
  "<cmd>lua require('textcase').current_word('to_dot_case)<CR>",
  { silent = true, desc = "Transform text to dot.case" }
)
vim.keymap.set(
  "n",
  "gaC",
  "<cmd>lua require('textcase').current_word('to_constant_case')<CR>",
  { silent = true, desc = "Transform text to CONSTANT_CASE" }
)
vim.keymap.set(
  "n",
  "gaP",
  "<cmd>lua require('textcase').current_word('to_path_case)<CR>",
  { silent = true, desc = "Transform text to path/case" }
)

