-- blazingly fast minmap to scroll
return {
  {
    "wfxr/minimap.vim",
    build = "cargo install --locked code-minimap",
    cmd = { "Minimap", "MinimapClose", "MinimapToggle", "MinimapRefresh", "MinimapUpdateHighlight" },
    keys = {
      { "<leader>umt", "<cmd>MinimapToggle<CR>", desc = "Toggle Minimap" },
      { "<leader>umr", "<cmd>MinimapRefresh<CR>", desc = "Force Refresh Minimap" },
      { "<leader>ums", "<cmd>MinimapRescan<CR>", desc = "Force recalculation of minimap scaling ratio" },
      { "<leader>umu", "<cmd>MinimapUpdateHighlight<CR>", desc = "Force Update Minimap Highlights" },
    },
    init = function()
      vim.cmd("let g:minimap_width = 10")
      vim.cmd("let g:minimap_auto_start = 1")
      vim.cmd("let g:minimap_auto_start_win_enter = 1")
      vim.cmd("let g:minimap_highlight_search = 1")
      vim.cmd("let g:minimap_git_colors = 1")
    end,
  },
}
