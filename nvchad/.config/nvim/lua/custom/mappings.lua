---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<C-d>"] = { "<C-d>zz", "moving down, keep cursor in middle", opts = { nowait = true } },
    ["<C-u>"] = { "<C-u>zz", "moving up, keep cursor in middle", opts = { nowait = true } },
    ["n"] = { "nzzzv", "when searching, keep cursor in middle", opts = { nowait = true } },
    ["N"] = { "Nzzzv", "when searching, keep cursor in middle", opts = { nowait = true } },
    ["<C-w>b"] = { ":bufdo bd<CR>", "Close all open buffers", opts = { nowait = true } },
    ["<C-S-A>"] = { ":wa<CR>", "Save all open buffers", opts = { nowait = true } },
  },
}

-- more keybinds!
M.git = {
  n = {
    ["<leader>gi"] = { ":silent execute '!git init'<CR>", "Initialize git repository" },
    ["<leader>gg"] = { ":LazyGit<CR>", "Open lazy git" },
  },
}

M.gopher = {
  plugin = true,
  n = {
    ["<leader>sgsj"] = {
      "<cmd> GoTagAdd json <CR>",
      "Add json struct tags",
    },
    ["<leader>sgsy"] = {
      "<cmd> GoTagAdd yaml <CR>",
      "Add yaml struct tags",
    },
  },
}

-- text transformation
M.text_case = {
  v = {
    ["gat"] = { ":lua require('textcase').current_word('to_title_case)<CR>", "Transform text to Title Case" },
    ["gau"] = { ":lua require('textcase').current_word('to_upper_case')<CR>", "Transform text to UPPERCASE" },
    ["gal"] = { ":lua require('textcase').current_word('to_lower_case')<CR>", "Transform text to lowercase" },
    ["gas"] = { ":lua require('textcase').current_word('to_snake_case')<CR>", "Transform text to snake_case" },
    ["gac"] = { ":lua require('textcase').current_word('to_camel_case)<CR>", "Transform text to camelCase" },
    ["gak"] = { ":lua require('textcase').current_word('to_dash_case')<CR>", "Transform text to kebab-case" },
    ["gap"] = { ":lua require('textcase').current_word('to_pascal_case)<CR>", "Transform text to PascalCase" },
    ["gad"] = { ":lua require('textcase').current_word('to_dot_case)<CR>", "Transform text to dot.case" },
    ["gaC"] = { ":lua require('textcase').current_word('to_constant_case')<CR>", "Transform text to CONSTANT_CASE" },
    ["gaP"] = { ":lua require('textcase').current_word('to_path_case)<CR>", "Transform text to path/case" },
  },
}
return M
