# Desktop Env
export XDG_CURRENT_DESKTOP="plasma" # Choices: sway, plasma
export XDG_SESSION_DESKTOP="plasma" # Choices: sway, plasma
export XDG_SESSION_TYPE=wayland

# Cursor
export XCURSOR_THEME="Sweet-cursors"
export XCURSOR_PATH="${XCURSOR_PATH}:$HOME/.icons"
export XCURSOR_SIZE=28

# GTK & QT Theme
export GTK_USE_PORTAL=0
export GTK_THEME="Nordic"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# QT Related
export QT_QPA_PLATFORM="wayland" # Choices: wayland, xcb (x11)
export QT_QPA_PLATFORMTHEME="qt5ct"
#export QT_WAYLAND_DISABLE_WINDOWDECORATION=1 # Comment if using KDE Plasma
# export QT_STYLE_OVERRIDE=adwaita-dark

# Important if you want to utilize hardware acceleration:
# https://wiki.archlinux.org/title/Hardware_video_acceleration
export LIBVA_DRIVER_NAME=nvidia
export VDPAU_DRIVER=nvidia
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export GBM_BACKEND=nvidia-drm

# Firefox
export MOZ_DISABLE_RDD_SANDBOX=1
export MOZ_ENABLE_WAYLAND=1 # Enable wayland for mozilla

# Wayland/x11 Specifics
# export WLR_BACKENDS=wayland # comma-separated list of backends to use (available backends: libinput, drm, wayland, x11, headless, noop)
# export WAYLAND_DISPLAY=wayland-1
export CLUTTER_BACKEND=wayland # Choices: x11, wayland
export SDL_VIDEODRIVER=wayland # Choices: x11, wayland
export EGL_PLATFORM=wayland # Choices: x11, wayland
export XWAYLAND_NO_GLAMOR=1 # Fix flickering for apps running under xwayland

# wlroot
export WLR_NO_HARDWARE_CURSORS=1     # set to 1 to use software cursors instead of hardware cursors
export WLR_RENDERER=vulkan           # Fix screen flickering, requires vulkan-validation-layers
export WLR_RENDERER_ALLOW_SOFTWARE=1 # Enable 3d rendering
export WLR_DIRECT_TTY='alacritty'    # Specifies the tty to be used (instead of using /dev/tty)
export WLR_DRM_NO_ATOMIC=1           # Fix sway freezing during startup
# export WLR_DRM_DEVICES=/dev/dri/card1 # Force specific GPU device

if [ "$WAYLAND_DISPLAY" = "" ] && [ "$XDG_VTNR" -eq 1 ]; then
  # dbus-run-session sway --unsupported-gpu # With nvidia drivers, omit exec
  # exec dbus-run-session sway --unsupported-gpu
  /usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland # Plasma
fi
