export XDG_CURRENT_DESKTOP="sway"
export XDG_SESSION_DESKTOP="sway"
export XCURSOR_THEME="Sweet-cursors"
export XCURSOR_PATH="${XCURSOR_PATH}:$HOME/.icons"
export XCURSOR_SIZE=28
export GTK_USE_PORTAL=0
export GTK_THEME="Nordic"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export QT_QPA_PLATFORM="xcb"
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
# export QT_STYLE_OVERRIDE=adwaita-dark

# Wayland Specifics
# export WLR_BACKENDS=wayland # comma-separated list of backends to use (available backends: libinput, drm, wayland, x11, headless, noop)
# export WAYLAND_DISPLAY=wayland-1
export WLR_NO_HARDWARE_CURSORS=1     # set to 1 to use software cursors instead of hardware cursors
export WLR_RENDERER_ALLOW_SOFTWARE=1 # Enable 3d rendering
export WLR_DIRECT_TTY='alacritty'    # Specifies the tty to be used (instead of using /dev/tty)
export MOZ_ENABLE_WAYLAND=1          # Enable wayland for mozilla

if [ "$WAYLAND_DISPLAY" = "" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec dbus-run-session sway
fi
