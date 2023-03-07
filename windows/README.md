# Windows Customization

## Notice

- Do not forget to change the computer name and my personal name to whatever you like in the config files by searching and replacing `<name>` to your name and `<pc-name>` to your user's pc name.
- [Here is a link to view all the windows commands inclduing documentations.](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands)

## Utility Apps/Installation

- [**Chocolatey**](https://chocolatey.org/install#individual)
- [**Scoop.sh**](https://scoop.sh/) and here is [**Scoop Documentation**](https://scoop-docs.vercel.app/docs/).
  - You may also have to add other repositories such as `extras` and `versions` with the following command:

    ```bash
    scoop bucket list # Check current lists
    scoop bucket add extras
    scoop bucket add versions
    ```

- [**WizTree**](https://diskanalyzer.com/)
- [**TCPView**](https://learn.microsoft.com/en-us/sysinternals/downloads/tcpview)
- [**Process Explorer**](https://learn.microsoft.com/en-us/sysinternals/downloads/process-explorer)
- [**autoruns**](https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns)
- [**Revo Uninstaller**](https://www.revouninstaller.com/)
- [**CPU-z**](https://www.cpuid.com/softwares/cpu-z.html)
- [**ThrottleStop**](https://www.techpowerup.com/download/techpowerup-throttlestop/)
- [**WinDbg**](https://apps.microsoft.com/store/detail/windbg-preview/9PGJGD53TN86)
- [**Many More SysInternal Utilities**](https://learn.microsoft.com/en-us/sysinternals/downloads/)

---

## Choco

```bash
choco install -y git notepadplusplus sharex ueli oh-my-posh laragon.install 7zip winrar avidemux hxd javaruntime gnupg tor-browser coretemp curl neovim discord powertoys winaero-tweaker sqlite
```

---

## Scoop

```bash
scoop install 7zip deno gh mingw openssl rustup wireshark zoom
```

---

## Windows Terminal

- Don't forget to change the GUID to your GUID Appliations.
- You can generate GUID by creating a new profile, then use it to your customization.

### Enable systemd in WSL

```bash
# Make sure WSL: Version 0.67.6 and above
wsl --version
wsl --update

# Open /etc/wsl.conf and add the following code
[boot]
systemd=true

# Shutdown the WSL instance.
wsl --shutdown

# Now run WSL, and check systemd
systemctl list-unit-files --type=service
```

---

### [Ueli App](https://ueli.app/)

- Put the **ueli_config.json** contents to `C:\Users\%USERPROFILE%\AppData\Roaming\ueli\config.json`
- [Dracula Theme Pink Version](https://github.com/dracula/ueli)
- Icons for ueli:

  <img src="https://user-images.githubusercontent.com/30084112/174482271-c8de6e19-74bb-40ab-b85d-70d8a17fc29d.png" width="50" height="50" />
  <img src="https://user-images.githubusercontent.com/30084112/174482278-ff08492d-c6ff-408a-ad06-1b7280591567.png" width="50" height="50" />

---

### [ShareX](https://getsharex.com/downloads/)

- Put the **sharex_*.json** contents to `C:\Users\%USERPROFILE%\Documents\ShareX`

---

### [Winaero Tweaker](https://winaero.com/winaero-tweaker/)

- Import the file in the application.

---

### Powershell Profile

- Put the config file to `C:\Users\%USERPROFILE%\Documents\PowerShell`
