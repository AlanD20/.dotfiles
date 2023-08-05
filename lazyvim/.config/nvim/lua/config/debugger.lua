-- Debugger configurations

local dap = require("dap")

table.insert(dap.configurations.go, {
  type = "delve",
  name = "Custom Debug",
  request = "launch",
  program = "${file}",
  args = {},
})
