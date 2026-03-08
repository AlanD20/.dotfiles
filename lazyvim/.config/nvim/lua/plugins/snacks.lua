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
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      picker = {
        enabled = true,
        sources = {},
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
            winhighlight = "Normal:Normal,FloatBorder:Normal",
          },
        },
      },
    },
  },
}
