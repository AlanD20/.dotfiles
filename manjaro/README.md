# Manjaro KDE Plasma Customization

## Programs

Don't forget to add `flatpak` and `AUR third-party` repositories

- Manual installaton:
  - [Docker Desktop (experimental)](https://docs.docker.com/desktop/install/archlinux/)

## Resources

- To Install `EasyEffects`, install the following packages using `pamac`.

    ```bash
    pamac install manjaro-pipewire plasma-pa lsp-plugins calf
    ```

- `Flameshot Screen Capture`: To set shortcut, search for shortcut and add `flameshot` application, then set shortcut for `Take Screenshot`.

- To add Startup Programs: First, search for `Autostart` and add your applications there.

## Ulauncher

- [[Theme] Gruvbox for Ulauncher](https://github.com/SylEleuth/ulauncher-gruvbox)
- [Extensions](https://ext.ulauncher.io/)
- To set shortcut, open the application and set it from the setting.

## KDE Plasma Theme

- **Global Theme**: Aritim-dark (primary), Otto, Breeze Dark
- **Cursor**: [Sweet Cursors](https://store.kde.org/p/1393084),  [Sanity-curosrs](https://store.kde.org/p/1703043)
- **Plasma Style**: Aritim-dark, Pax-Plasma
- **Task Switcher**: [Medium Rounded By adhe](https://store.kde.org/p/1327319)
- **Icons**: [Papirus](https://store.kde.org/p/1166289), [Mojave-circle](https://store.kde.org/p/1305429)
- **Terminal**: Aritim-dark
- **Desktop Widgets**: Modern Clock
- **Taskbar Widgets**: Memory Color Picker, Trash, Memory Usage, Timer, Clipboard, Battery & Brightness, Audio Volume

## Nginx

- On Arch-distrubuted systems, nginx doesn't have `sites-available` and `sites-enabled`. if you want to set it up this way, you can import the symlinked directory. Or an easier way is to create a conf.d directory in `/etc/nginx` directory then import all the config files.

    ```bash
    # First Method
    mkdir /etc/nginx/sites-enabled/ /etc/nginx/sites-enabled/;
    include /etc/nginx/sites-enabled/*;

    # Second Method (Easier)
    mkdir /etc/nginx/conf.d
    include /etc/nginx/conf.d/*.conf;
    ```

## PHP

- When you install PHP on arch-distributed system, it installs the latest version of PHP, don't put the verison when installing PHP from pacman.
- Because of the previous reason, the PHP paths doesn't contain the version such as `/etc/php/php.ini` or the `php-fpm.sock` is at `/var/run/php-fpm/php-fpm.sock` that has `http` group.

## Troubleshooting

- You may have to install the fonts as personal user so that it could be used in the konsole profile.
