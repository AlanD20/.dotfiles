# Herdr

Adapted from this repository's tmux config; validated with Herdr 0.8.2.
Install from the repository root with `stow --target="$HOME" herdr`.
The existing `~/.config/herdr` directory keeps logs and session state outside
the repository; only the main config is linked.

Install all three plugins after stowing `herdr` and `lazyvim`:

```sh
./herdr/install-plugins.sh
```

Requires Herdr, Neovim, Git, jq, and Go 1.24.2+ for the Arrange build.
The script installs each Herdr plugin in the list in order, without specifying
commit revisions. It then installs missing smart-splits through Lazy.nvim,
links its Herdr integration, and reloads the running Herdr server.
LazyGit and htop are installed separately with your system package manager.

Configured with Terminal Browser plugin 0.1.1 (browser 0.8.0). Browser graphics
require a Kitty-graphics-capable outer terminal; Herdr's graphics support is
enabled here.

After first enabling graphics, detach with prefix+d and run `herdr` again in
the outer terminal. Herdr 0.8.2 reads the client's graphics capability at
attach time; a server config reload alone leaves an older client unable to
display browser frames (`pane.graphics.info`: `cell_size_unavailable`).

The prefix is **Ctrl+A**. After it, use:

| Key | Action |
| --- | --- |
| `-` / `_` | Split below / right, inheriting the current directory |
| `h/j/k/l` | Focus left/down/up/right |
| `H/J/K/L` | Swap the pane left/down/up/right |
| `r` | Resize mode: `h/j/k/l` to resize, `Esc` to exit |
| `Space` | Arrange popup: `Space` cycles layouts, `e` balances, `Esc` closes |
| `M` | Move-pane tree: choose another tab or workspace |
| `Ctrl+2` | htop popup; `q` closes |
| `Ctrl+1` | LazyGit popup in the current directory; quit LazyGit to close |
| `e` | Open scrollback in Neovim; search with `/`, copy with `"+y`, quit with `:q` |
| `B` | Open Terminal Browser in a right split |
| `Tab` | Return to the last focused pane across tabs/workspaces |
| `n` / `p` | Next / previous agent |
| `z` | Toggle pane zoom |
| `Enter` | Copy mode; `v` selects, `y` copies, `Esc` cancels |
| `c` / `,` / `1..9` | Create, rename, or select a tab |
| `Ctrl+h` / `Ctrl+l` | Move the current tab left / right |
| `X` | Close the current tab |
| `Q` | Close the current workspace |
| `C` / `s` | Create a workspace / open workspace navigation (`j/k`, then Enter) |
| `R` / `d` | Reload config / detach |
| `?` / `Alt+s` | Help / settings |

**Alt+1..9** jumps directly to a workspace without the prefix.
**Alt+Shift+H/L** switches previous/next tabs without the prefix.
**Ctrl+H/J/K/L** moves through Neovim splits first, then into neighboring Herdr
panes at editor edges. Prefix+h/j/k/l always selects Herdr panes directly.
In a shell, a key is passed through when there is no neighboring pane.
They also take precedence over browser Ctrl+L/Ctrl+K; use the browser's Alt+K
command palette or click the URL bar.

Agents with shell access can control an open browser using its CLI:

```sh
terminal-browser ls
terminal-browser action -- snapshot
terminal-browser action -- click @e14
```

Differences from tmux:

- Workspaces provide session-like grouping inside a Herdr session. Creating a
  workspace does not create a separate persistent Herdr server/session.
- Last-window (`a`/Tab) and last-session (Shift+Tab) have no direct configurable
  equivalents in the documented keymap. Prefix+Tab instead returns to the last
  pane; pane-cycling defaults are disabled.
- Swapping is directional rather than tmux's next/previous pane ordering.
  Resizing uses Herdr's step size rather than tmux's explicit two cells; the
  tmux 600 ms repeat timeout is not ported.
- Custom copy-mode keys, fzf URL/copycat helpers, and resurrect save/restore
  shortcuts are not ported.
  Herdr has its own copy mode and persistent sessions.
- Top tabs and Catppuccin are retained. tmux's status modules, pane CWD labels,
  and exact numbering/rename policies are not reproduced. Herdr manages its
  own terminal emulation, so tmux TERM and RGB overrides are not copied.

Reference: https://herdr.dev/docs/configuration/ and
https://herdr.dev/docs/config-reference/.

Seamless Neovim navigation uses `mrjones2014/smart-splits.nvim` (version pinned
in LazyVim's lockfile). `install-plugins.sh` registers its Herdr half automatically.

Requires `jq`. Restart existing Neovim instances to load the mappings. The
Herdr integration is selected explicitly; outside Herdr the existing tmux
navigator remains active. At the outermost editor edge navigation stops.
Upstream: https://github.com/mrjones2014/smart-splits.nvim#herdr

Popup launcher slots use prefix followed by Ctrl+1 through Ctrl+0. Ctrl+1 opens LazyGit and Ctrl+2 opens htop; add more `type = "popup"` commands as needed. Prefix+f
remains free. Modified digits require an outer terminal that reports them
distinctly (such as the current Ghostty with extended keyboard reporting).

In workspace navigation, j/k selects workspaces (arrows also work); Ctrl+j/k
selects panes vertically. Popups run until the app exits or the popup closes;
closing ends the popup terminal rather than keeping a hidden session.
