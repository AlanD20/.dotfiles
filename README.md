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

### Run Script

1. Add/Edit/Delete anything that is not needed for the setup, in the `install.sh` and `install-profile.zsh` files. Including packages.

2. Change `install.sh` and `install-profile.zsh` files to executable

    ```bash
    chmod +x ./install*
    ```

3. Run the script without `sudo`.

    ```bash
    ./install.sh
    ```

---

## ZSH Plugins

- `zsh-nvm` plugin installs `nvm`.
- `fzf` plugin is required to enable shortcuts if we install `fzf` through `nix`.

---

## Find WSL IP For SSH

```bash
ip addr | grep eth0
```

---

## Resources

- [Download LSP For Helix](https://github.com/helix-editor/helix/wiki/How-to-install-the-default-language-servers)

- Using **neovim**? Here are a few starter configs:
  - [LunarVim](https://www.lunarvim.org/)
  - [SpiceVim](https://spacevim.org/)
  - [kickstart](https://github.com/nvim-lua/kickstart.nvim) supports extendibility
  - [Neovim config by nexxeln](https://github.com/nexxeln/nvim)
  - [A bunch of plugins for neovim](https://github.com/rockerBOO/awesome-neovim)
  - [Cosmic Nvim](https://github.com/CosmicNvim/CosmicNvim/)
  - [Install LSP for neovim](https://github.com/williamboman/mason.nvim)

      ```bash
      :MasonInstall cssls
      ```

- Adding custom LSP to Helix Editor. Here is an example

  ```toml
  # npm install blade-formatter --location=global 

  [[language]]
  name = "blade-formatter"
  scope = "source.blade-formatter"
  roots = []
  file-types = ["blade.php"]
  language-server = { command = "blade-formatter", args = ["--write"] }
  formatter = { command = "blade-formatter", args = ["--write"] }

  ```
