return {
  {
    "plasticboy/vim-markdown",
    dependencies = {
      "godlygeek/tabular",
      "vim-pandoc/vim-pandoc-syntax",
    },
    init = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal = 0
      vim.g.tex_conceal = ""
      vim.g.vim_markdown_math = 1
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_toml_frontmatter = 1
      vim.g.vim_markdown_json_frontmatter = 1

      vim.cmd([[
        augroup pandoc_syntax
          au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
        augroup END
      ]])

      vim.g.vim_markdown_fenced_languages = {
        "php=php",
        "javascript=js",
        "js=js",
      }
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
    -- Available commands
    -- cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
    init = function()
      vim.g.mkdp_auto_close = 0
    end,
  },
}
