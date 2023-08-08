return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "emoji" } }))
    end,
  },
  {
    -- Add blade indentations
    "jwalton512/vim-blade",
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
    },
  },
  {
    -- Makes find & replace easier by preserving original case sensitivity
    -- This works for selection unlike text-case where it globally replaces words
    -- use S instead of s.
    "tpope/vim-abolish",
  },
  {
    -- Toggle text case
    "johmsalas/text-case.nvim",
    config = function()
      require("textcase").setup({})
    end,
  },
  {
    -- Auto closing/renaming HTML tags
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  -- Better quickfix
  {
    "kevinhwang91/nvim-bqf",
  },
  {
    -- Git blame
    "f-person/git-blame.nvim",
    keys = {
      {
        "<leader>gbt",
        "<cmd>GitBlameToggle<CR>",
        desc = "GitBlame: Toggle Virtual Text",
      },
      { "<leader>gbof", "<cmd>GitBlameOpenFileURL<CR>", desc = "GitBlame: Open file URL" },
      { "<leader>gboc", "<cmd>GitBlameOpenCommitURL<CR>", desc = "GitBlame: Open commit URL" },
      { "<leader>gbcf", "<cmd>GitBlameCopyFileURL<CR>", desc = "GitBlame: Copy file URL" },
      { "<leader>gbcc", "<cmd>GitBlameCopyCommitURL<CR>", desc = "GitBlame: Copy commit URL" },
      { "<leader>gbcs", "<cmd>GitBlameCopySHA<CR>", desc = "GitBlame: Copy SHA" },
    },
  },
  {
    -- Better JSON for vim
    "elzr/vim-json",
  },
}
