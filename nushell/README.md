# Nushell

Nushell 0.115.1 configuration matching the daily Zsh setup. Install `nushell`
with Pacman, then run `stow --target="$HOME" nushell` from the dotfiles root.
Existing config files must be backed up first; retain any history files.
Launch with `nu`; `rr` replaces the current Nu process to reload cleanly.

## What carries over

- The existing Oh My Posh theme and Fastfetch startup display.
- Atuin with the existing config and database (`$ZDOTDIR/atuin-history.db`).
  Native Nu history uses SQLite, shares between sessions, keeps 10,000 entries,
  and ignores commands beginning with a space.
- Emacs editing, gray history suggestions, native syntax highlighting,
  case-sensitive fuzzy completion, Neovim as the editor.
- Eza aliases (`ls`, `lls`, `la`, `tree`), editor/TUI, Git, Docker, PHP,
  OneDrive and GPG shortcuts. `nu-ls` is the original structured Nushell `ls`:
  `nu-ls | where type == file | sort-by size`.
- FZF helpers `fp`, `vfp`, `vfd`, `cdf`; cancellation is harmless and filenames
  containing whitespace are preserved.
- `econf`, `gcls`, `gfo`, `jql`, `jqq`, `dssh`, `viewdoc`, `viewimg`, `f`,
  and `keepass`. `pa-clear` fixes the invalid `artisan clear`/`&&-` sequence
  in the Zsh alias and stops at the first failing Artisan command.
- Rust/Cargo, Bun, Mason, pyenv/rbenv shims, locale, FFF favorites, YAML formatting
  settings and Linux SSH-agent socket configuration.
- `nvm` passes arguments to the existing Bash NVM implementation and imports the
  selected Node binary directory. Fresh shells use the default Node version;
  inherited selections are retained. `nvm use` reads `.nvmrc`, and failed
  selections preserve PATH. No automatic version installation on directory changes.
- `z` and directory tracking use the existing rupa/z script and `~/.z` database.
  This requires the Zsh-installed `zinit/plugins/rupa---z/z.sh` under XDG_DATA_HOME.

## Keys

| Key | Action |
| --- | --- |
| Tab | Native fuzzy completion |
| Ctrl-R / Up | Atuin history search |
| Ctrl-P / Ctrl-N | Native previous/next history navigation |
| Right / Ctrl-Right | Accept suggestion / next word |
| Ctrl-Left, Shift-Left/Right | Move by word |
| Ctrl-O | Edit current command in Neovim (Zsh uses Ctrl-X Ctrl-E) |
| Ctrl-T | Pick a file with preview and insert its quoted path |
| Alt-C | Pick and change directory |

## Differences and optional tools

Zinit, Zsh widgets, the `@@` FZF completion trigger and Oh My Zsh plugins cannot
be sourced directly in Nu. The common Git/Tmux shortcuts are defined explicitly;
this is not the entire Oh My Zsh alias catalog. Shell-specific snippets under
Zsh's `includes/` are not sourced. Native Nu completion replaces fzf-tab; installing
`carapace` enables external command/flag completion on the next launch.

Oh My Posh and Atuin initialize automatically when installed. Their generated
scripts are stored under Nushell's cache/data directories, outside the repo.
The same supporting applications used by Zsh (eza, fzf, fd, rg, bat, nvim, etc.)
are needed for the corresponding shortcuts. pyenv/rbenv shims support ordinary
project/global versions; their Bash/Zsh `shell` activation commands are not ported.

Zsh config, the default login shell and terminal launch settings are unchanged.
On macOS, set XDG_CONFIG_HOME to `~/.config` before launching Nu to use this Stow
layout. Windows is not covered by these Unix helpers.

Validated with Nushell 0.115.1: startup, integrations, PATH uniqueness, native
listings, NVM default/failed selection, existing z rankings, and FZF selection and
cancellation. References: [Nushell configuration](https://www.nushell.sh/book/configuration),
[Reedline keys](https://www.nushell.sh/book/line_editor.html),
[Oh My Posh](https://ohmyposh.dev/docs/installation/prompt),
[Atuin initialization](https://docs.atuin.sh/main/reference/init/).
