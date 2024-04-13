return {

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
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
        bind_to_cwd = true,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          -- You could comment out the following lines to show hidden files by default.
          show_hidden_count = true,
          hide_dotfiles = false, --  Files starting with dot should be visible!!!!!
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
            ["Y"] = {
              function(state)
                local node = state.tree:get_node()
                local path = node:get_id()
                vim.fn.setreg("+", path, "c")
              end,
              desc = "Copy Path to Clipboard",
            },
            ["O"] = {
              function(state)
                require("lazy.util").open(state.tree:get_node().path, { system = true })
              end,
              desc = "Open with System Application",
            },
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
        default_component_configs = {
          indent = {
            with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
          },
        },
      },
    },
  },
}
