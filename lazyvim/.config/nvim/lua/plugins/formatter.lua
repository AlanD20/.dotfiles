return {
  {
    "mhartington/formatter.nvim",
    enabled = false,
    depdendencies = {
      "jose-elias-alvarez/null-ls.nvim",
    },
    opts = {
      filetype = {
        php = {
          function()
            local util = require("formatter.util")

            local homeOpts = { path = "~", type = "file" }
            local opts = { path = util.get_cwd(), type = "file" }

            -- Make sure configuration exists
            if not (FileExists(".pint.json", homeOpts) or FileExists("pint.json", opts)) then
              return nil
            end

            -- get project config, otherwise global as a fallback
            local conf = FindOrFallback("pint.json", "~/.pint.json", opts)

            return {
              exe = "pint",
              args = {
                "--no-interaction",
                "--quiet",
                "--config",
                conf,
              },
              stdin = false,
              ignore_exitcode = true,
              temp_dir = "/tmp/" .. util.get_current_buffer_file_name(),
            }
          end,
        },
      },
    },
  },
}
