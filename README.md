# Dot Files

My personal dotfiles (configuration files) for new sysmten environment.

It works for:

- Windows: Suggestions, config files
- WSL: Full setup
- Ubuntu Gnome: Full setup
- Manjaro KDE Plasma: Full setup

**Notice:** Do not forget to change my personal name to whatever you like in the config files by searching and replacing `<name>` to your name.

Run the script as a normal user with sudo permission. Here is how you may add a new user in Linux:

```bash
useradd -s /bin/bash -m -g users -G sudo,www-data myuser
```

## Running Installation Scripts

1. Add/Edit/Delete anything that is not needed for the setup, in the `install.sh` and `install-profile.zsh` files. Including packages.

2. Change script files to executable

    ```bash
    chmod +x ./*.sh 
    ```

3. Run the script without `sudo`.

    ```bash
    ./install.sh
    ```

## Desktop Environment Setup

- **After you have ran the `install.sh` and `install-profile.sh` at the root project, run the following scripts to setup Linux environment.**
- Using `apt` on Ubuntu gnome? Use `apt.sh` script, after that, you may run `setup.sh` script inside `ubuntu` direcotry.
- Using `pacman` On Manjaro KDE Plasma? Use `pacman.sh` script, after that, you may run `setup.sh` script inside `manjaro` directory.

## Database & Email With Docker

Checkout [db](db) directory to quickly setup database and a testing email service with a single command.

You can configure the docker-compose file to your needs.

---

## Resources

- Licensed fonts such as `Dank Mono`, `Bosan`.
- ZSH Plugin Descriptions
  - `zsh-nvm` plugin installs `nvm`.
  - `fzf` plugin is required to enable shortcuts if we install `fzf` through `nix`.

- Find WSL IP address for SSH access:

    ```bash
    ip addr | grep eth0
    ```

- [Download LSP For Helix](https://github.com/helix-editor/helix/wiki/How-to-install-the-default-language-servers)

- Using **neovim**? Here are a few starter configs:
  - [LunarVim](https://www.lunarvim.org/)
  - [SpiceVim](https://spacevim.org/)
  - [NvChad](https://nvchad.com/)
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
