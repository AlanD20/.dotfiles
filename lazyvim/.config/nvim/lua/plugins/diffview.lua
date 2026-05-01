return {
  "sindrets/diffview.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewFileHistory",
  },
  keys = {
    { "<leader>gm", "<cmd>DiffviewOpen<cr>", desc = "DiffView: Open (merge/diff)" },
    { "<leader>gM", "<cmd>DiffviewClose<cr>", desc = "DiffView: Close" },
    { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "DiffView: Repo file history" },
    { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "DiffView: Current file history" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = {
        -- Show side-by-side by default for diffs
        layout = "diff2_horizontal",
      },
      merge_tool = {
        -- Use a 3-way layout for merge conflicts
        layout = "diff3_horizontal",
        disable_diagnostics = true,
      },
    },
  },
}
