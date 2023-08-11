# Display Server Protocols

- **Xorg Instalaltion**

  - Xorg is a legacy display server protocol, the new alternative is wayland.

    ```bash
    sudo pacman -S xorg xorg-xinit
    ```

  - To enable autostarts, create `.initrc` file at the user’s home directory
    (better not to be root). Then, put the WM or DE start up there. Following is
    just an example to start KDE.

    ```bash
    # file at ~/.initrc
    exec startkde
    ```

- **Wayland Instalaltion**

  - install the wayland package and `xwayland` to support X11.

    ```bash
    sudo pacman -S wayland xorg-xwayland wayland-protocols
    ```

  - If you are using QT applications, you may need to install the wayland
    version as well. Also, qt5ct to customize qt applications.

    ```bash
    sudo pacman -S qt5-wayland qt6-wayland
    ```

  - You should export the following environments in your login shell
    `/etc/profile` or `~/.profile`.

    ```bash
    # export WLR_BACKENDS=wayland # comma-separated list of backends to use (available backends: libinput, drm, wayland, x11, headless, noop)
    # export WAYLAND_DISPLAY=wayland-1
    export WLR_NO_HARDWARE_CURSORS=1     # set to 1 to use software cursors instead of hardware cursors
    export WLR_RENDERER_ALLOW_SOFTWARE=1 # Enable 3d rendering
    export WLR_DIRECT_TTY='alacritty'    # Specifies the tty to be used (instead of using /dev/tty)
    export MOZ_ENABLE_WAYLAND=1          # Enable wayland for mozilla
    ```
