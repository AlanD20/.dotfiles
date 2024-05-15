-- After lazyvim loads

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

parser_config.blade = {
  install_info = {
    url = "https://github.com/EmranMR/tree-sitter-blade",
    files = { "src/parser.c" },
    branch = "main",
  },
  filetype = "blade",
}

vim.treesitter.language.register("blade", "blade")

-- Enable autocompletion for vim-dadbod
-- local cmp = require("cmp")
-- cmp.setup.filetype({ "sql" }, {
--   sources = {
--     { name = "vim-dadbod-completion" },
--     { name = "buffer" },
--   },
-- })
