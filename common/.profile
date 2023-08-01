export XDG_CURRENT_DESKTOP="sway"
export XDG_SESSION_DESKTOP="sway"
export XCURSOR_THEME="Adwaita"
export XCURSOR_SIZE=28
export GTK_USE_PORTAL=0
export GTK_THEME="Adwaita:dark"
export GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc
export QT_QPA_PLATFORM="xcb"
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_STYLE_OVERRIDE=adwaita-dark
export MOZ_ENABLE_WAYLAND=1
# export WAYLAND_DISPLAY=wayland-1

if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
  exec dbus-run-session sway
fi
