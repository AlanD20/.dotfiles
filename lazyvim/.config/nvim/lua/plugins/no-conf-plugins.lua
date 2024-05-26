return {
  {
    -- Add blade indentations
    "jwalton512/vim-blade",
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
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
  {
    -- Move between tmux panes and vim windows with Ctrl-<jkhl>
    "christoomey/vim-tmux-navigator",
  },
  -- Database querying UI
  -- { "tpope/vim-dadbod" },
  -- { "kristijanhusak/vim-dadbod-completion" },
  -- { "kristijanhusak/vim-dadbod-ui" },
}
