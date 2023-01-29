# tmux Config

- The config is by [gpakosz](https://github.com/gpakosz/.tmux)
- Checkout [awesome-tmux](https://github.com/rothgar/awesome-tmux) repository for more about tmux & plugins.
- Color problems? [Check out these solutions](https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95)
- [Tmux Shortcuts Cheatsheet](https://tmuxcheatsheet.com/)

**Default Shortcuts:**

- <kbd>Ctrl</kbd> + <kbd>b</kbd>: Enable tmux prefix mode.
- `prefix` + <kbd>c</kbd>: Create a new window.
- `prefix` + <kbd>w</kbd>: Tmus session manager.
- `prefix` + <kbd>d</kbd>: Detach from current session.
- `prefix` + <kbd>x</kbd>: Kill current tmux pane.
- `prefix` + <kbd>Shift</kbd> + <kbd>"</kbd>: Create a new horizontal pane.
- `prefix` + <kbd>Shift</kbd> + <kbd>%</kbd>: Create a new vertical pane.
- `prefix` + <kbd>h/j/k/l</kbd>: Move focus to another pane.
- `prefix` + <kbd>Shift</kbd> + <kbd>h/j/k/l</kbd>: Resize current pane.
- `prefix` + <kbd>,</kbd>: Rename current pane.
- `prefix` + <kbd>.</kbd>: Move current pane to another session.

- `prefix` + <kbd>Shift</kbd> + <kbd>I</kbd>: Install plugins.
- `prefix` + <kbd>Shift</kbd> + <kbd>U</kbd>: Update plugins.
- `prefix` + <kbd>r</kbd>: Reload tmux.

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

- `prefix` + <kbd>Ctrl</kbd> + <kbd>f</kbd>: To open session switcher with fzf.

## Tmux Sessionist

- [Read more about Tmux Sessionist](https://github.com/tmux-plugins/tmux-sessionist)

**Aliases:**

- `prefix` + <kbd>g</kbd> - prompts for session name and switches to it. Performs 'kind-of'
  name completion.
  Faster than the built-in `prefix` + <kbd>s</kbd> prompt for long session lists.
- `prefix` + <kbd>C</kbd>` (shift + c) - prompt for creating a new session by name.
- `prefix` + <kbd>X</kbd>` (shift + x) - kill current session without detaching tmux.
- `prefix` + <kbd>S</kbd>` (shift + s) - switches to the last session.
  The same as built-in `prefix` + <kbd>L</kbd> that everyone seems to override with
  some other binding.
- `prefix` + <kbd>@</kbd> - promote current pane into a new session.
  Analogous to how `prefix` + <kbd>!</kbd> breaks current pane to a new window.
- `prefix` + <kbd>t</kbd><secondary-key> - join currently marked pane (`prefix` + <kbd>m</kbd>) to current session/window, and switch to it
  - secondary-keys
    - <kbd>h</kbd>, <kbd>-</kbd>, <kbd>"</kbd>: join horizontally
    - <kbd>v</kbd>, <kbd>|</kbd>, <kbd>%</kbd>: join vertically
    - <kbd>f</kbd>, <kbd>@</kbd>: join full screen
