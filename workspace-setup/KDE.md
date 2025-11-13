# KDE

## KDE Installation

1. We need to install the following packages. [More additional recommendation can be found here](https://community.kde.org/Distributions/Packaging_Recommendations)

   ```bash
   # Base layer
   sudo pacman -S plasma-meta sddm

   # Extra applications
   sudo pacman -S dolphin dolphin-plugins ark gwenview okular spectacle kate filelight konsole kcalc kio-extras ffmpegthumbs kdegraphics-thumbnailers qt6-imageformats kimageformats elisa kdialog baloo-widgets kde-inotify-survey kdeconnect power-profiles-daemon xdg-desktop-portal-gtk

   yay -S xwaylandvideobridge
   ```

2. Enable `sddm` service. Then reboot. After that, KDE plasma should load.

   ```bash
   sudo systemctl enable sddm

   reboot
   ```

## Programs

- `Flameshot Screen Capture`: To set shortcut, search for shortcut in KDE
  settings, then add `flameshot` application, then set a shortcut for
  `Take Screenshot` command.

- To add Startup Programs: First, search for `Autostart` and add your
  applications there.

## Ulauncher

- [[Theme] Gruvbox for Ulauncher](https://github.com/SylEleuth/ulauncher-gruvbox)
- [Extensions](https://ext.ulauncher.io/)
- To set a shortcut, in the application's settings.

## KDE Plasma Theme

- **Global Theme**: Aritim-dark (primary), Otto, Breeze Dark
- **Cursor**: [Sweet Cursors](https://store.kde.org/p/1393084),
  [Sanity-cursors](https://store.kde.org/p/1703043)
- **Plasma Style**: Aritim-dark, Pax-Plasma
- **Task Switcher**: [Medium Rounded By adhe](https://store.kde.org/p/1327319)
- **Icons**: [Papirus](https://store.kde.org/p/1166289),
  [Mojave-circle](https://store.kde.org/p/1305429)
- **Terminal**: Aritim-dark
- **Desktop Widgets**: Modern Clock
- **Taskbar Widgets**: Memory Color Picker, Trash, Memory Usage, Timer,
  Clipboard, Battery & Brightness, Audio Volume
- **Boot Splash Screen**: Arch logo plymouth

## Troubleshooting

- To customize konsole, create/edit your own profile.
