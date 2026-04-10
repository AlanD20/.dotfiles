return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost" },
      linters_by_ft = {
        -- Use the "*" filetype to run linters on all filetypes.
        -- ['*'] = { 'global linter' },
        -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
        -- ['_'] = { 'fallback linter' },
        sh = { "shellcheck" },
        python = { "ruff" },
        php = { "phpstan" },
        yaml = { "yamllint" },
        tf = { "tfsec", "tflint" },
        markdown = { "markdownlint" },
        -- Run typos on all filetypes to catch spelling errors
        ["*"] = { "typos" },
      },
      -- LazyVim extension to easily override linter options
      -- or add custom linters.
      ---@type table<string,table>
      linters = {
        typos = {
          args = { "$FILENAME" },
          stream = "stderr",
          ignore_exitcode = true,
          parser = require("lint.parser").from_pattern(
            "error: (.*)\\s*-->\\s*(.+):(%d+):(%d+)",
            { "file", "lnum", "col" },
            nil,
            { "source", "typos" }
          ),
        },
      },
    },
  },
}
