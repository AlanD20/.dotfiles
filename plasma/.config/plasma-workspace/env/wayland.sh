#!/bin/bash
export QT_QPA_PLATFORM="wayland" # Choices: wayland, xcb (x11)
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP="plasma" # Choices: sway, plasma
export XDG_SESSION_DESKTOP="plasma" # Choices: sway, plasma

# Important if you want to utilize hardware acceleration:
# https://wiki.archlinux.org/title/Hardware_video_acceleration
export LIBVA_DRIVER_NAME=nvidia
export VDPAU_DRIVER=nvidia
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export GBM_BACKEND=nvidia-drm

# Firefox
export MOZ_DISABLE_RDD_SANDBOX=1
export MOZ_ENABLE_WAYLAND=1 # Enable wayland for mozilla

# Wayland Specifics
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export EGL_PLATFORM=wayland
export XWAYLAND_NO_GLAMOR=1 # Fix flickering for apps running under xwayland
