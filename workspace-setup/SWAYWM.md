# Swaywm

- [**Sway**](https://wiki.archlinux.org/title/sway) is a tiling Wayland
  compositor and a drop-in replacement for the i3 window manager for X11. It
  works with your existing i3 configuration and supports most of i3's features,
  plus a few extras.

  ```bash
  sudo pacman -S sway swaylock swayidle swaybg polkit

  # Since it has breaking changes, use latest commits
  yay -S waybar-git
  ```

  - `Sway Lock`: to lock your screen.
  - `Sway Idle`: set up an idle manager.
  - `Sway Bg`: to set wallpapers.
  - `Polkit`: used to control system-wide privileges.
  - `waybar`: A highly customizable status bar.

- Sway can be started by adding the following to your shell initialization file
  (login shell file `/etc/profile` or `~/.profile`). Using `dbus-run-session`
  allows you to connect to audio.

  ```bash
  if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    exec dbus-run-session sway
  fi
  ```

  - `dbus-run-session` is used to start a session bus instance of `dbus-daemon`
    from a shell script, and start a specified program in that session. The
    `dbus-daemon` will run for as long as the program does, after which it will
    terminate. One use is to run a shell with its own `dbus-daemon` in a
    text-mode or SSH session, and have the `dbus-daemon` terminate automatically
    on leaving the sub-shell, like it's used in the above command.

- Copy the config example from `/etc/sway/config` to `~/.config/sway/config`.
  From the config, you can change the default terminal emulator which foot is
  the default terminal emulator. Or you could start with
  [my configuration](../sway/).
- You could set the following environment variables before sway initialization
  at ~/.profile

  ```bash
  export XDG_CURRENT_DESKTOP="sway"
  export XDG_SESSION_DESKTOP="sway"
  export XCURSOR_THEME="Sweet-cursors"
  export XCURSOR_SIZE=28
  export GTK_USE_PORTAL=0
  export GTK_THEME="Nordic:dark"
  export GTK2_RC_FILES=/usr/share/themes/Nordic/gtk-2.0/gtkrc
  export QT_QPA_PLATFORM="xcb"
  export QT_QPA_PLATFORMTHEME="qt5ct"
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  export QT_STYLE_OVERRIDE=Nordic
  export MOZ_ENABLE_WAYLAND=1
  ```

## Configuration

- **[Here are a few collection plugins for sway.](https://github.com/swaywm/sway/wiki/Useful-add-ons-for-sway)**
- Pro tip: when you use `exec` command in your sway config, you can pass a
  custom `app_id` to the application in order to adjust it to your needs by
  adding `--class` then followed by your custom name. This will make it easy to
  track the app window when using `swaymsg`. But some applications don't take
  this custom class, i.e, spotify, google-chrome, etc..
  ```bash
  exec thunar --class thunar-2
  ```
- If GTK applications takes a while to open, you may only uninstall
  `xdg-desktop-portal-gnome`.
- Waybar is slow to load? Remove the following packages:

  ```bash
  sudo pacman -Rs xdg-desktop-portal-gtk xdg-desktop-portal-wlr xdg-desktop-portal flatpak xdg-desktop-portal-kde
  ```
