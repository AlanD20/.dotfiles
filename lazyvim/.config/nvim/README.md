# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim). Refer to
the [documentation](https://lazyvim.github.io/installation) to get started.

## Resources

- [Available LSPs](https://mason-registry.dev/registry/list)
- [LSP Configs](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
- [null-ls build-in sources](https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md)
- [Setup blade treesitter](https://github.com/EmranMR/tree-sitter-blade/discussions/19)
  and don't forget to install
  [vim-blade](https://github.com/jwalton512/vim-blade) for indentation.
- To add Alpinejs highlighting, edit html query and add the following injection,
  `TSEditQuery injections html`:
  ```bash
  ; AlpineJS attributes
  (attribute
    (attribute_name) @_attr
      (#lua-match? @_attr "^x%-%l")
    (quoted_attribute_value
      (attribute_value) @injection.content)
    (#set! injection.language "javascript"))
  ```
