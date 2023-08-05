return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    init = function()
      vim.cmd("let g:VM_maps = {}")
      vim.cmd("let g:VM_maps['Add Cursor Down'] = '<M-Down>'")
      vim.cmd("let g:VM_maps['Add Cursor Up'] = '<M-Up>'")
    end,
  },
}
