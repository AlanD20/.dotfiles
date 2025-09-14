-- Notes
-- More colorschemes: https://dotfyle.com/neovim/colorscheme/top
------------------
return {
  ----
  --- colorscheme
  ----

  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  {
    "catppuccin/nvim",
    opts = {
      transparent_background = true,
      term_colors = true,
      blink_cmp = true,
    },
  },

  {
    "navarasu/onedark.nvim",
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {
      style = "deep",
      transparent = true,
    },
  },

  -- Configure LazyVim to load catppuccin
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
      -- colorscheme = "tokyonight",
      -- colorscheme = "onedark",
    },
  },

  ----
  --- Core options
  ----

  -- Bufferline custom keymaps
  {
    "akinsho/bufferline.nvim",
    -- catppuccin currently broken, merge WIP: https://github.com/LazyVim/LazyVim/pull/6354#issuecomment-3208908984
    init = function()
      local bufline = require("catppuccin.groups.integrations.bufferline")
      function bufline.get()
        return bufline.get_theme()
      end
    end,
    keys = {
      { "<leader>bdd", "<cmd>bdelete<CR>", desc = "Close current buffer" },
      { "<leader>bdr", "<cmd>BufferLineCloseRight<CR>", desc = "Close all buffers to the right" },
      { "<leader>bdl", "<cmd>BufferLineCloseLeft<CR>", desc = "Close all buffers to the left" },
      { "<leader>bdo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close all other buffers" },
    },
  },

  -- yanky
  {
    "gbprod/yanky.nvim",
    opts = {
      highlight = { timer = 150 },
    },
  },

  -- snacks
  {
    "folke/snacks.nvim",
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      picker = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true }, -- wrap notifications
        },
      },
    },
  },

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
