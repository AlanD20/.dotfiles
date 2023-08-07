return {

  {
    -- Neovim file explorer: edit your filesystem like a buffer
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = false,
        ["<C-s>"] = false,
        ["<C-h>"] = false,
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["q"] = "actions.close",
        ["Y"] = "actions.copy_entry_path",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["H"] = "actions.toggle_hidden",
      },
      float = {
        -- Padding around the floating window
        padding = 2,
        max_width = 50,
        max_height = 25,
        win_options = {
          winblend = 0, -- Make floating window transparent
        },

        -- This is the config that will be passed to nvim_open_win.
        -- Change values here to customize the layout
        override = function(conf)
          conf = vim.tbl_deep_extend("force", {
            title = "Oil: File System Editor",
            title_pos = "left",
            relative = "editor",
            style = "minimal",
            height = 25,
            width = 50,
            row = 10,
            col = 2,
            zindex = 45,
          }, conf or {})

          return conf
        end,
      },
    },
  },
}
