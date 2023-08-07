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
        window = {
          mappings = {
            ["e"] = "edit_with_oil",
          },
        },
        commands = {
          edit_with_oil = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            path = vim.fn.shellescape(path)
            vim.api.nvim_command(":lua require('oil').open_float(" .. path .. ")")
          end,
        },
      },
    },
  },
}
