-- Custom debugger examples. Loaded from init.lua, but DAP is only required
-- after a debugging command/key loads it. Keep language adapters in LazyExtras.
LazyVim.on_load("nvim-dap", function()
  local dap = require("dap")

  -- Add entries under their Neovim filetype. These appear alongside defaults
  -- when you use <leader>dc. Edit program/args/pathMappings for your project.
  local configurations = {
    go = {
      {
        type = "delve",
        name = "Custom: Launch Debug",
        request = "launch",
        -- Use "${workspaceFolder}/main.go" for a fixed entry file.
        program = "${file}",
        args = {},
      },
    },
    php = {
      {
        name = "Custom: Listen for Xdebug",
        type = "php",
        request = "launch",
        port = 9003,
        -- Map the remote/container source directory to your local project.
        -- pathMappings = {
        --   ["/var/www/webapp"] = "${workspaceFolder}",
        -- },
      },
    },
  }

  -- A separate provider keeps adapter setup from overwriting custom entries.
  -- See :help dap-providers-configs and :help dap-configuration.
  dap.providers.configs["custom-debugger"] = function(bufnr)
    return vim.deepcopy(configurations[vim.bo[bufnr].filetype] or {})
  end
end)
