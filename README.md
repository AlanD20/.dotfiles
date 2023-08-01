# AlanD20 Dot Files

My personal dotfiles. It includes Arch configs and my windows configs and
suggestions.

- Windows: Suggestions, config files
- Arch
- Ubuntu

## Desktop Environment Setup

- Scripts start with `setup-*` are suppose to install essential apps, and
  `*-install-profile` are intended to be installed with user privileges.

## Database & Email With Docker

Checkout [docker/db](docker/db) directory to quickly setup database and a
testing email service with a single command.

You can configure the docker-compose file to your needs.

## Screen sharing on Wayland

To share your screen on Wayland, install `obs-studio` then use `pipewire` window
capture to share your screen.

---

## Resources

- Licensed fonts such as `Dank Mono`.
- ZSH Plugin Descriptions
  - `zsh-nvm` plugin installs `nvm`.
- Find WSL IP address for SSH access:

  ```bash
  ip addr | grep eth0
  ```
