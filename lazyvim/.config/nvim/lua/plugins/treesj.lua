return {
  {
    -- Neovim plugin for splitting/joining blocks of code
    "Wansmer/treesj",
    keys = {
      { "<C-m>", "<cmd>TSJToggle<CR>", desc = "Toggle between split/join" },
    },
    cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
    },
  },
}
