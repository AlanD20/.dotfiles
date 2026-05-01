return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
  },
  config = function()
    require("neogit").setup({
      -- Use diffview for diffs instead of neogit's built-in inline diff
      integrations = {
        diffview = true,
      },
      -- Show commits in diffview when you press Enter on a commit
      commit_view = {
        kind = "tab",
      },
      -- Show stash in diffview
      stash = {
        kind = "tab",
      },
      -- Remap close/back to q for consistency (q already closes status buffer)
      mappings = {
        commit_editor = {
          ["q"] = "Close",
          ["<c-c><c-c>"] = "Submit", -- Alternative submit to avoid ESC
          ["<c-c><c-k>"] = "Abort",
        },
        rebase_editor = {
          ["q"] = "Close",
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
        },
        finder = {
          ["q"] = "Close",
          ["<cr>"] = "Select",
          ["<c-n>"] = "Next",
          ["<c-p>"] = "Previous",
        },
      },
    })
  end,
  keys = {
    { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit: Open status" },
    { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit: Commit popup" },
    { "<leader>gl", "<cmd>Neogit log<cr>", desc = "Neogit: Log popup" },
    { "<leader>gp", "<cmd>Neogit pull<cr>", desc = "Neogit: Pull popup" },
    { "<leader>gP", "<cmd>Neogit push<cr>", desc = "Neogit: Push popup" },
  },
}
