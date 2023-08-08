return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        -- Some are disabled due to comes with lazyvim plugins
        "c",
        "cpp",
        "graphql",
        "java",
        "bash",
        "blade",
        "comment",
        "css",
        "dockerfile",
        "git_rebase",
        "gitattributes",
        "gitignore",
        -- "go",
        -- "gomod",
        -- "gowork",
        -- "gosum",
        "html",
        "http",
        "javascript",
        -- "json",
        "lua",
        "markdown",
        "markdown_inline",
        "php",
        "phpdoc",
        "prisma",
        -- "python",
        "rust",
        "scss",
        "sql",
        "svelte",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "zig",
      })

      opts.playground = vim.tbl_deep_extend("force", {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        query_linter = {
          enable = true,
          use_virtual_text = true,
          lint_events = { "BufWrite", "CursorHold" },
        },
        keybindings = {
          toggle_query_editor = "o",
          toggle_hl_groups = "i",
          toggle_injected_languages = "t",
          toggle_anonymous_nodes = "a",
          toggle_language_display = "I",
          focus_language = "f",
          unfocus_language = "F",
          update = "R",
          goto_node = "<cr>",
          show_help = "?",
        },
      }, opts.playground or {})

      return opts
    end,
  },
  {
    "nvim-treesitter/playground",
  },
}
