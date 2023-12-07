# Windows Customization

## Notice

- Do not forget to change the computer name and my personal name to whatever you
  like in the config files by searching and replacing `<name>` to your name and
  `<pc-name>` to your user's pc name.
- [Here is a link to view all the windows commands inclduing documentations.](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands)

## Utility Apps/Installation

- [**Chocolatey**](https://chocolatey.org/install#individual)
- [**Scoop.sh**](https://scoop.sh/) and here is
  [**Scoop Documentation**](https://scoop-docs.vercel.app/docs/).

  - You may also have to add other repositories such as `extras` and `versions`
    with the following command:

    ```bash
    scoop bucket list # Check current lists
    scoop bucket add extras
    scoop bucket add versions
    ```

- [**WizTree**](https://diskanalyzer.com/): Visualizing disk to clear up spaces.
- [**TCPView**](https://learn.microsoft.com/en-us/sysinternals/downloads/tcpview):
  Display running services with ports
- [**Process Explorer**](https://learn.microsoft.com/en-us/sysinternals/downloads/process-explorer):
  Bettter version of task manager
- [**autoruns**](https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns):
  Easily trace down running applications and auto startup apps.
- [**Revo Uninstaller**](https://www.revouninstaller.com/): Uninstall an
  application including its registery values and user prefs.
- [**ThrottleStop**](https://www.techpowerup.com/download/techpowerup-throttlestop/):
  Forcefully run CPU at the highest rate in Laptops or throttled CPUs.
- [**WinDbg**](https://apps.microsoft.com/store/detail/windbg-preview/9PGJGD53TN86):
  Analyze dumped errors or logs.
- [**Many More SysInternal Utilities**](https://learn.microsoft.com/en-us/sysinternals/downloads/)
- [**Bloatbox**](https://github.com/builtbybel/bloatbox): Remove bloated native
  applications.
- [**Windows Optimizer**](https://github.com/hellzerg/optimizer)

---

## Applications w/ Scoop

- CLI Apps

```bash
scoop install git gnupg sqlite curl neovim oh-my-posh nvm deno gh mingw openssl rustup zig-dev vagrant ripgrep git-aliases vcredist2022 delta lazygit
```

- GUI Apps

```bash
scoop install notepadplusplus spotify discord powertoys winaero-tweaker tor-browser coretemp sharex ueli avidemux hxd 7zip winrar laragon wireshark zoom firefox vscode cpu-z postman rainmeter chatterino7 virtualbox-np keepassxc
```

---

## App Configurations

##### Windows Terminal

- Don't forget to change the GUID to your GUID Appliations.
- You can generate GUID by creating a new profile, then use it to your
  customization.

##### Enable systemd in WSL

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

##### [Ueli App](https://ueli.app/)

- Put the **ueli_config.json** contents to
  `C:\Users\%USERPROFILE%\AppData\Roaming\ueli\config.json`
- [Dracula Theme Pink Version](https://github.com/dracula/ueli)
- Icons for ueli:

  <img src="https://user-images.githubusercontent.com/30084112/174482271-c8de6e19-74bb-40ab-b85d-70d8a17fc29d.png" width="50" height="50" />
  <img src="https://user-images.githubusercontent.com/30084112/174482278-ff08492d-c6ff-408a-ad06-1b7280591567.png" width="50" height="50" />

##### [ShareX](https://getsharex.com/downloads/)

- Put the **sharex\_\*.json** contents to
  `C:\Users\%USERPROFILE%\Documents\ShareX`

##### [Winaero Tweaker](https://winaero.com/winaero-tweaker/)

- Import the file in the application.

##### Powershell Profile

- Put the config file to `C:\Users\%USERPROFILE%\Documents\PowerShell`

---

### Scoop Commands

- [Check out more commands](https://github.com/ScoopInstaller/Scoop/wiki/Commands)

```bash
# Check current bucket (source) lists
scoop bucket list

# Add a new bucket to the list
scoop bucket add extras
scoop bucket add versions

# List of installed apps
scoop list

# Install an app
scoop install my-app app2

# Uninstall an app
scoop uninstall my-app
scoop uninstall -p my-app # Clean user prefs

# Update all apps
scoop update *

# Export installed apps
scoop export > "C:/scoop-apps.json"

# Remove old versions
scoop cleanup *
```

### Chocolatey Commands

```bash
# List installed apps
choco list --local

# Install an app
choco install my-app app2
choco install -y my-app3   # Skip confirmation

# Uninstall an app
choco uninstall my-app
choco uninstall my-app3 --purge # Clean user prefs

# Update all apps
choco update all -y

# Export installed apps
choco export "C:/choco-apps.xml" --include-version-numbers
```
