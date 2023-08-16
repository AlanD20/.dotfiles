-- globals options
--

-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/globals.lua
-- Useful to print and debug
P = function(...)
  print(vim.inspect({ ... }))
  return ...
end

-- Return if given item exists, otherwise, return fallback.
-- @param item string: The flie to search for or expand.
-- @param fallback string: The fallback value if the file is not found.
-- @param opts table (optional): Options for the search, passed to `vim.fs.find` options
-- @return string: The target path or fallback value.
FindOrFallback = function(file, fallback, opts)
  opts = opts or {}

  file = vim.fn.expand(file)

  local target = ""

  local files = vim.fs.find(file, opts)

  if files[1] ~= nil then
    -- if path exists, concat it, otherwise, return file alone
    target = opts["path"] and opts.path .. "/" .. file or file
  else
    target = vim.fn.expand(fallback)
  end

  return target
end

-- Return true if file exists, otherwise false
-- @param item string: The file to search for or expand.
-- @param opts table (optional): Options for the search, passed to `vim.fs.find` options
-- @return boolean
FileExists = function(file, opts)
  opts = opts or {}

  local files = vim.fs.find(file, opts)

  return files[1] ~= nil
end
