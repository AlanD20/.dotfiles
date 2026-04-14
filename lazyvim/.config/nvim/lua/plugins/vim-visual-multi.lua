return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    init = function()
      vim.cmd("let g:VM_maps = {}")
      vim.cmd("let g:VM_maps['Find Under'] = '<C-n>'")
      vim.cmd("let g:VM_maps['Find Subword Under'] = '<C-n>'")
      vim.cmd("let g:VM_maps['Add Cursor Down'] = '<M-Down>'")
      vim.cmd("let g:VM_maps['Add Cursor Up'] = '<M-Up>'")
      vim.cmd("let g:VM_maps['Find Next'] = 'n'")
      vim.cmd("let g:VM_maps['Find Prev'] = 'N'")
      vim.cmd("let g:VM_maps['Skip Region'] = 'q'")
      vim.cmd("let g:VM_maps['Remove Region'] = 'Q'")
    end,
    keys = {
      { "<C-n>", mode = { "n", "v" }, desc = "Find Under (Multi-cursor)" },
      { "<M-Down>", mode = { "n", "v" }, desc = "Add Cursor Down" },
      { "<M-Up>", mode = { "n", "v" }, desc = "Add Cursor Up" },
    },
  },
}
