return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          Snacks.scratch.select()
        end,
        desc = "Select Scratch Buffer",
      },
    },
    opts = {
      bigfile = {
        enabled = true,
        size = 10 * 1024 * 1024,
        line_length = 10000,
      },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      picker = {
        enabled = true,
        sources = {},
        limit_live = 10000,
        matcher = {
          fuzzy = true,
          smartcase = true,
          cwd_bonus = false,
          frecency = false,
          history_bonus = false,
        },
        files = {
          follow = false,
          exclude = {
            "**/__pycache__",
            "**/.venv",
            "**/venv",
            "**/.pytest_cache",
            "**/.mypy_cache",
            "**/node_modules",
            "**/.git",
          },
        },
        grep = {
          limit = 10000,
        },
      },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      scratch = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true }, -- wrap notifications
        },
        picker = {
          backdrop = false,
          border = "rounded",
          width = 0.8,
          height = 0.8,
          wo = {
            winblend = 0, -- 0 = fully transparent, increase for more opacity
          },
        },
      },
    },
  },
}
