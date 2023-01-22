# tmux Config

- The config is by [gpakosz](https://github.com/gpakosz/.tmux)
- Checkout [awesome-tmux](https://github.com/rothgar/awesome-tmux) repository for more about tmux & plugins.
- Color problems? [Check out these solutions](https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95)
- [Tmux Shortcuts Cheatsheet](https://tmuxcheatsheet.com/)

**Default Shortcuts:**

- `Ctrl + b`: Enable tmux prefix mode.
- `prefix + c`: Create a new window.
- `prefix + w`: Tmus session manager.
- `prefix + d`: Detach from current session.
- `prefix + x`: Kill current tmux pane.
- `prefix + Shift + "`: Create a new horizontal pane.
- `prefix + Shift + %`: Create a new vertical pane.
- `prefix + h/j/k/l`: Move focus to another pane.
- `prefix + Shift + h/j/k/l`: Resize current pane.
- `prefix + ,`: Rename current pane.
- `prefix + .`: Move current pane to another session.

- `prefix + Shift + I`: Install plugins.
- `prefix + Shift + U`: Update plugins.
- `prefix + r`: Reload tmux.

## Oh-my-zsh tmux plugin

- [Read the plugin's README file](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/tmux)

**Aliases:**

| Alias      | Command                    | Description                                              |
| ---------- | -------------------------- | -------------------------------------------------------- |
| `ta`       | tmux attach -t             | Attach new tmux session to already running named session |
| `tad`      | tmux attach -d -t          | Detach named tmux session                                |
| `ts`       | tmux new-session -s        | Create a new named tmux session                          |
| `tl`       | tmux list-sessions         | Displays a list of running tmux sessions                 |
| `tksv`     | tmux kill-server           | Terminate all running tmux sessions                      |
| `tkss`     | tmux kill-session -t       | Terminate named running tmux session                     |
| `tmux`     | `_zsh_tmux_plugin_run`     | Start a new tmux session                                 |
| `tmuxconf` | `$EDITOR $ZSH_TMUX_CONFIG` | Open .tmux.conf file with an editor                      |

## fzf Session Switch

- [Read more](https://github.com/thuanOwa/tmux-fzf-session-switch)

**Alias:**

- `prefix + Ctrl + f`: To open session switcher with fzf.

## Tmux Sessionist

- [Read more about Tmux Sessionist](https://github.com/tmux-plugins/tmux-sessionist)

**Aliases:**

- `prefix + g` - prompts for session name and switches to it. Performs 'kind-of'
  name completion.
  Faster than the built-in `prefix + s` prompt for long session lists.
- `prefix + C` (shift + c) - prompt for creating a new session by name.
- `prefix + X` (shift + x) - kill current session without detaching tmux.
- `prefix + S` (shift + s) - switches to the last session.
  The same as built-in `prefix + L` that everyone seems to override with
  some other binding.
- `prefix + @` - promote current pane into a new session.
  Analogous to how `prefix + !` breaks current pane to a new window.
- `prefix + t<secondary-key>` - join currently marked pane (`prefix + m`) to current session/window, and switch to it
  - secondary-keys
    - `h`, `-`, `"`: join horizontally
    - `v`, `|`, `%`: join vertically
    - `f`, `@`: join full screen
