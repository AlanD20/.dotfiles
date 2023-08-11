# Theme

- Download the following packages to change GTK and qt application themes.

  ```bash
  sudo pacman -S lxappearance qt5ct gnome-themes-extra gtk-engines gtk-engine-murrine

  # Theme
  sudo pacman -S papirus-icon-theme adwaita-qt6
  yay -S lightly-qt nordic-theme
  ```

- Export these values in your login shell.

  ```bash
  export XDG_CURRENT_DESKTOP="sway"
  export XDG_SESSION_DESKTOP="sway"
  export XCURSOR_THEME="Sweet-cursors"
  export XCURSOR_PATH="${XCURSOR_PATH}:~/.icons"
  export XCURSOR_SIZE=28
  export GTK_USE_PORTAL=0
  export GTK_THEME="Nordic"
  export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
  export QT_QPA_PLATFORM="xcb"
  export QT_QPA_PLATFORMTHEME="qt5ct"
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  # export QT_STYLE_OVERRIDE=adwaita-dark
  ```
