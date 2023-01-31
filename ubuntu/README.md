# Ubuntu Customization

---

## GNOME Extensions

- Install the following packages:

```bash
sudo apt install gnome-tweaks gnome-shell-extensions
sudo apt-get install chrome-gnome-shell # Only Chromium Browsers
```

- Install [GNOME Shell integration](https://chrome.google.com/webstore/detail/gnome-shell-integration/gphhapmejobijbbhgpjhcjognlahblep) in browser's extension store.

[GNOME Extensions](https://extensions.gnome.org/):

- [**Dim On Battery Power**](https://extensions.gnome.org/extension/947/dim-on-battery-power/) Lower brightness when low in battery.
- [**OpenWeather**](https://extensions.gnome.org/extension/750/openweather/) To show current weather.
- [**Sound Input & Output Device Chooser**](https://extensions.gnome.org/extension/906/sound-output-device-chooser/) Allows to choose inputs & outputs in status bar.
- [**Vitals**](https://extensions.gnome.org/extension/1460/vitals/) System Monitoring
- [**ArcMenu**](https://extensions.gnome.org/extension/3628/arcmenu/) Accessible start menu.
- [**Blur my Shell**](https://extensions.gnome.org/extension/3193/blur-my-shell/)
- [**Dash to Panel by charlesg99**](https://extensions.gnome.org/extension/1160/dash-to-panel/)
- [**Try Icons: Reloaded**](https://extensions.gnome.org/extension/2890/tray-icons-reloaded/) - Works with Dash to Panel. Shows system icon trays.
- [**Nothing To Say**](https://extensions.gnome.org/extension/1113/nothing-to-say/) - Easily system-wide mute/unmute with keyboard shortcut.
- [**Impatience**](https://extensions.gnome.org/extension/277/impatience/) - Change default speed animations.
- [**User Themes**](https://extensions.gnome.org/extension/19/user-themes/) - Change system theme.
- [**Switcher**](https://extensions.gnome.org/extension/973/switcher/)- Switch windows quickly with a simple search.

---

## Flameshot Screen Capture

- [Download Flameshot Screen Capture](https://flameshot.org/)
- To set shortcut, go to settings > keyboard > view and customize shortcut > at the bottom select custom shortcut > Add new shortcut and fill the name, set the command to `flameshot gui`

---

## Ulauncher

- [Download Ulauncher](https://ulauncher.io/)

- [[Theme] Gruvbox for Ulauncher](https://github.com/SylEleuth/ulauncher-gruvbox)

[Extensions](https://ext.ulauncher.io/):

- Requires the following Python packages:

```bash
pip3 install fuzzywuzzy faker requests pint simpleeval parsedatetime
```

- Put The Configuration Files at ~/.config/ulauncher/
- Remove the `ulauncher_` prefix from the files.
- To set shortcut, set it in the application settings, then go to settings > keyboard > view and customize shortcut > at the bottom select custom shortcut > Add new shortcut and fill the name, set the command to `ulauncher-toggle`

---
