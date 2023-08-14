return {

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      auto_reload_on_write = false,
      hijack_cursor = false,
      hijack_unnamed_buffer_when_opening = false,
      root_dirs = {},
      prefer_startup_root = false,
      sync_root_with_cwd = true,
      reload_on_bufenter = false,
      respect_buf_cwd = false,
      hijack_directories = {
        enable = false,
        auto_open = true,
      },
      filesystem = {
        filtered_items = {
          visible = true,
          -- You could comment out the following lines to show hidden files by default.
          show_hidden_count = true,
          hide_dotfiles = false, --  don't hide dot files!!
          hide_gitignored = true, --  we don't need this
          hide_by_name = {
            ".git",
            ".vscode",
            "vendor",
            "node_modules",
          },
          never_show = {},
        },
        window = {
          mappings = {
            ["E"] = "edit_with_oil",
          },
        },
        commands = {
          edit_with_oil = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            path = vim.fn.shellescape(path)
            if node.type == "directory" then
              vim.api.nvim_command(":lua require('oil').open_float(" .. path .. ")")
            end
          end,
        },
      },
    },
  },
}
