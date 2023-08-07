-- globals options
--

-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/globals.lua
P = function(...)
  print(vim.inspect({ ... }))
  return ...
end
