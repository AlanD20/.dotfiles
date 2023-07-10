---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<C-d>"] = { "<C-d>zz", "moving down, keep cursor in middle", opts = { nowait = true } },
    ["<C-u>"] = { "<C-u>zz", "moving up, keep cursor in middle", opts = { nowait = true } },
    ["n"] = { "nzzzv", "when searching, keep cursor in middle", opts = { nowait = true } },
    ["N"] = { "Nzzzv", "when searching, keep cursor in middle", opts = { nowait = true } },
  },
}

-- more keybinds!
M.git = {
  n = {
    ["<leader>gi"] = { ":terminal git init <CR>", "initialize git repository" },
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

return M
