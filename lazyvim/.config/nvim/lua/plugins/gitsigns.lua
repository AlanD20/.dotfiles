return {
  "lewis6991/gitsigns.nvim",
  enabled = true,
  opts = {
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      -- Navigation
      vim.keymap.set("n", "]h", gs.next_hunk, { buffer = bufnr, desc = "Next Hunk" })
      vim.keymap.set("n", "[h", gs.prev_hunk, { buffer = bufnr, desc = "Prev Hunk" })

      -- Actions
      vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { buffer = bufnr, desc = "Gitsigns: Stage hunk" })
      vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { buffer = bufnr, desc = "Gitsigns: Reset hunk" })
      vim.keymap.set("n", "<leader>gS", gs.stage_buffer, { buffer = bufnr, desc = "Gitsigns: Stage buffer" })
      vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Gitsigns: Undo stage hunk" })
      vim.keymap.set("n", "<leader>gR", gs.reset_buffer, { buffer = bufnr, desc = "Gitsigns: Reset buffer" })
      vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr, desc = "Gitsigns: Preview hunk" })
      vim.keymap.set("n", "<leader>gb", function()
        gs.blame_line({ full = true })
      end, { buffer = bufnr, desc = "Gitsigns: Blame line" })
      vim.keymap.set("n", "<leader>gd", gs.diffthis, { buffer = bufnr, desc = "Gitsigns: Diff this" })
      vim.keymap.set("n", "<leader>gD", function()
        gs.diffthis("~")
      end, { buffer = bufnr, desc = "Gitsigns: Diff this ~" })

      -- Visual mode: stage selection (stages the hunk(s) intersecting selection)
      vim.keymap.set("v", "<leader>gs", ":Gitsigns stage_hunk<cr>", { buffer = bufnr, desc = "Gitsigns: Stage selection" })

      -- Visual mode: discard selection (resets the hunk(s) intersecting selection)
      vim.keymap.set("v", "<leader>gd", ":Gitsigns reset_hunk<cr>", { buffer = bufnr, desc = "Gitsigns: Discard selection" })

      -- Text object
      vim.keymap.set({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { buffer = bufnr, desc = "Gitsigns: Select hunk" })
    end,
  },
}
