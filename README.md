# AlanD20 Dot Files

My personal dotfiles. It includes Arch configs and my windows configs and
suggestions.

- Windows: Suggestions, config files
- Arch

## Desktop Environment Setup

- **After you have ran the `install.sh` and `install-profile.sh` at the root
  project, run the following scripts to setup Linux environment.**
- Using `apt` on Ubuntu gnome? Use `apt.sh` script, after that, you may run
  `setup.sh` script inside `ubuntu` direcotry.
- Using `pacman` On Manjaro KDE Plasma? Use `pacman.sh` script, after that, you
  may run `setup.sh` script inside `manjaro` directory.

## Database & Email With Docker

Checkout [db](db) directory to quickly setup database and a testing email
service with a single command.

You can configure the docker-compose file to your needs.

---

## Resources

- Licensed fonts such as `Dank Mono`.
- ZSH Plugin Descriptions
  - `zsh-nvm` plugin installs `nvm`.
- Find WSL IP address for SSH access:

  ```bash
  ip addr | grep eth0
  ```
