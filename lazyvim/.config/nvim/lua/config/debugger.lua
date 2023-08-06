-- Debugger configurations

local dap = require("dap")

table.insert(dap.configurations.go, {
  type = "delve",
  name = "Custom: Launch Debug",
  request = "launch",
  program = "${file}",
  args = {},
})

table.insert(dap.configurations.php, {
  name = "Custom: Listen for Xdebug",
  type = "php",
  request = "launch",
  port = 9003,
})
