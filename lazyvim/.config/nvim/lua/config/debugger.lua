-- Debugger configurations

local dap = require("dap")

table.insert(dap.configurations.go, {
  type = "delve",
  name = "Custom: Launch Debug",
  request = "launch",
  -- start the debugger in the entry file or you can have entry file here.
  -- program = "main.go",
  program = "${file}",
  args = {},
})

table.insert(dap.configurations.php, {
  name = "Custom: Listen for Xdebug",
  type = "php",
  request = "launch",
  port = 9003,
  -- Mapping paths for remote debugging
  -- pathMappings = {
  --   ["/var/www/webapp"] = "${workspaceFolder}",
  -- },
})
