-- globals options
--

-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/globals.lua
-- Useful to print and debug
P = function(...)
  print(vim.inspect({ ... }))
  return ...
end

-- Return if given item exists, otherwise, return fallback.
-- @param item string: The item to search for or expand.
-- @param fallback string: The fallback value if the item is not found.
-- @param opts table (optional): Options for the search, passed to `vim.fs.find` options
-- @return string: The target path or fallback value.
FindOrFallback = function(item, fallback, opts)
  opts = opts or {}

  item = vim.fn.expand(item)

  local target = ""

  local files = vim.fs.find(item, opts)

  if files[1] ~= nil then
    -- if path exists, concat it, otherwise, return item alone
    target = opts["path"] and opts.path .. "/" .. item or item
  else
    target = vim.fn.expand(fallback)
  end

  return target
end
