# Dot Files

This repository is a starter setup for new linux environment.

---

## Configs

Here are a few configuration to do before running the script.

---

### Add user

```bash
useradd -s /bin/bash -m -g users -G sudo,www-data myuser
```

---

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

### Run Script

1. Change `install.sh` file to executable

    ```bash
    chmod +x ./install.sh
    ```

2. Run the script without `sudo`.

    ```bash
    ./install.sh
    ```

---

## ZSH Plugins

- `zsh-nvm` plugin installs `nvm`.
- `fzf` plugin is required to enable shortcuts if we install `fzf` through `nix`.

---

## Resources

- (Find more about WSL configs](https://learn.microsoft.com/en-us/windows/wsl/wsl-config)

- **Notice**: Global configuration options with `.wslconfig` is only available for distributions running as WSL 2.

- [Download LSP](https://github.com/helix-editor/helix/wiki/How-to-install-the-default-language-servers)

- Using neovim? Here is a [kickstart](https://github.com/nvim-lua/kickstart.nvim) if you want to extend, or [Another great starter config by nexxeln](https://github.com/nexxeln/nvim)

- [Install LSP for neovim](https://github.com/williamboman/mason.nvim)

```bash
:MasonInstall cssls
```

- Adding custom language to Helix Editor

```toml
# npm install blade-formatter --location=global 

[[language]]
name = "blade-formatter"
scope = "source.blade-formatter" 
roots = []
file-types = ["blade.php"]
language-server = { command = "blade-formatter" , args = ["--write"] }
formatter = { command = "blade-formatter" , args = ["--write"] }

```
