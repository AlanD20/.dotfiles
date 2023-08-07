return {
  {
    "akinsho/bufferline.nvim",
    keys = {
      { "<leader>bdd", "<cmd>bdelete<CR>", desc = "Close current buffer" },
      { "<leader>bdr", "<cmd>BufferLineCloseRight<CR>", desc = "Close all buffers to the right" },
      { "<leader>bdl", "<cmd>BufferLineCloseLeft<CR>", desc = "Close all buffers to the left" },
      { "<leader>bdo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close all other buffers" },
    },
  },
}
