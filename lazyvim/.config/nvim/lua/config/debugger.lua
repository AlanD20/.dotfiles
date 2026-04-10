-- Debugger configurations

local dap = require("dap")

-- Ensure Go DAP configuration table exists before adding custom config
if dap.configurations.go then
  table.insert(dap.configurations.go, {
    type = "delve",
    name = "Custom: Launch Debug",
    request = "launch",
    -- start the debugger in the entry file or you can have entry file here.
    -- program = "main.go",
    program = "${file}",
    args = {},
  })
end

-- Ensure PHP DAP configuration table exists before adding custom config
if dap.configurations.php then
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
end
