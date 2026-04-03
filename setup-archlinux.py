#!/usr/bin/env python3
"""
Arch Linux setup script with optional desktop environments.

Replaces both setup-arch-sway.sh and sway-install-profile.zsh.
Must be run as root (sudo). User-level operations are delegated
via ``su <user> -c "..."`` to preserve correct home/env context.

Usage:
    sudo python3 setup-archlinux.py --user <username> [flags]

Flags:
    --user             (required) The login username for user-level operations
    --sway             Install Sway compositor and Wayland desktop packages
    --kde              Install KDE Plasma desktop packages
    --nvidia           Install Nvidia GPU drivers and utilities
    --asus             Install ASUS ROG laptop tools (asusctl, rog-control-center, supergfxctl)
    --ssh              Enable SSH configuration (uncomment Port 22 / ListenAddress)
    --php              Install Composer, fix xdebug.ini, modify php.ini extensions
    --stow             Stow dotfiles, cache fonts, configure zsh shell
    --nvm [VERSION]    Install/upgrade nvm and install node (default: lts/krypton)
    --go               Install Go + gopls, configure GOMODCACHE
    --rust             Install rustup and set nightly as default toolchain
    --k9s-theme        Download and extract catppuccin k9s theme
    --resticprofile [VERSION]  Download and extract resticprofile binary (default: 0.32.0)
    --pyenv [VERSION]  Install Python via pyenv (default: 3.13)
    --font             Install DankMono Nerd Font from saifulapm/my-fonts
    --services         Enable user-level systemd services
    --skip-pacman      Skip installing pacman packages (does not affect --kde, --nvidia, etc.)
    --skip-aur         Skip installing AUR packages via yay
    --skip-shared-pacman  Skip shared GUI pacman packages (used by --sway/--kde)
    --skip-shared-aur  Skip shared GUI AUR packages (used by --sway/--kde)
    --manual           Run package installs interactively (remove --noconfirm, allow user intervention)
"""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

NODE_VERSION = "lts/krypton"
PYENV_VERSION = "3.13"
RESTICPROFILE_VERSION = "0.32.0"
NVM_VERSION = "v0.40.1"

PIP3_PKGS: list[str] = [
    "build",
    "installer",
    "wheel",
    "setuptools_scm",
]

PIP3_PKGS_EXTRA: list[str] = [
    "uv",
]

UV_TOOLS: list[str] = [
    "mycli",
]

# ---------------------------------------------------------------------------
# Service definitions
# ---------------------------------------------------------------------------

# System services to stop before starting new ones (conflict prevention)
SYSTEM_SERVICES_STOP: list[str] = [
    "php-fpm",
    "nginx",
    "sshd",
]

# System services to enable and start (--now)
SYSTEM_SERVICES: list[str] = [
    "bluetooth",
    "docker",
    "containerd",
]

# User-level services to enable and start (--now)
USER_SERVICES: list[str] = [
    "ydotool",
    "pipewire",
    "wireplumber",
    "redshift",
    "ssh-agent.service",
]

STOW_DIRS: list[str] = [
    "alacritty",
    "albert",
    "atuin",
    "bin",
    "common",
    "containers",
    "gnupg",
    "lazygit",
    "lazyvim",  # Choose between nvchad or lazyvim
    # "nvchad",
    "oh-my-posh",
    # "p10k",
    "redshift",
    "systemd",
    # "thunar",
    "tmux",
    "zsh",
]

STOW_DIRS_GUI: list[str] = [
    "wallpapers",
    "easyeffects",
    "onedrive",
]

STOW_DIRS_SWAY: list[str] = [
    "mako",
    "swappy",
    "sway",
    "swaylock",
    "waybar",
    "wofi",
]

STOW_DIRS_KDE: list[str] = [
    "flameshot",
]

PACMAN_PKGS: list[str] = [
    #
    # Essentials
    "git",
    "dos2unix",
    "net-tools",
    "curl",
    "neovim",
    "vim",
    "nano",
    "wget",
    "ca-certificates",
    "openssh",
    "zip",
    "unzip",
    "jq",  # CLI json processor
    "yq",  # CLI yaml processor
    "bind",  # dig CLI
    "less",
    "lsof",
    "strace",
    "htop",
    #
    # Base
    "bluez",  # Bluetooth daemon
    "bluez-utils",  # Bluetooth utilities
    #
    # Vulkan with Nvidia
    "vulkan-intel",
    "vulkan-headers",
    "vulkan-validation-layers",
    #
    # CLI Utils
    "tmux",  # Terminal multiplexer
    "zsh",  # Main shell instead of bash
    "stow",  # easily manage .dot files
    "fzf",  # fuzzy finder for files and directories
    "eza",  # better ls command (exa is unmaintained)
    "ripgrep",  # Better grep
    "bat",  # Better cat command
    "direnv",  # Loading env variables for current working directory
    "lf",  # CLI File manager
    "lazygit",  # TUI for git
    "fd",  # Quick file finder
    "git-delta",  # git pager
    "perl-image-exiftool",  # Show image and file metadata
    "entr",  # Rerun scripts or commands after file changes
    "gdu",  # Fast and easy analyzer to cleanup files
    "ffmpeg",  # Video & Audio converter
    "unrar",  # Unrar a rar file
    "woff2",  # Support for woff2 font
    "k9s",  # TUI for Kubernetes
    "tldr",  # tldr for man pages
    "ncdu",  # Disk analyzer cleanup
    "pyenv",  # Python version manager
    "fastfetch",  # neofetch but faster
    "asciinema",  # Ascii to record shell session
    "atuin",  # Powerful TUI sqlite db to store command history
    "bmon",  # bandwidth monitor and rate estimator
    "restic",  # Backup CLI Util
    "man-db",
    "squashfs-tools",
    "cdrtools",
    "openbsd-netcat",
    #
    # Network
    "dhcpcd",
    "netctl",
    "iptables",
    "nftables",
    "ufw",
    "reflector",
    "tigervnc",
    "gnupg",
    #
    # Dev & Build Tools
    "bash-completion",
    "meson",
    "cmake",
    "ninja",
    "clang",
    "lld",
    "ripgrep-all",
    "opencv",
    "python",
    "qemu-base",
    "virtiofsd",
    #
    # Filesystem & Storage
    "btrfs-progs",
    #
    # languages
    "php",
    "lua",
    "terraform",
    #
    # Language packages
    "python-pip",  # Python package manager
    "python-setuptools",
    "python-requests",
    "python-pyqt5",
    "python-pyqt6",
    "tk",  # needed for pyenv install
    #
    #
    # Dev tools
    "sqlite",  # Lightweight file database
    "nginx",  # Web server
    "docker",  # Manage Containers
    "containerd",
    "docker-compose",  # manage multiple containers within a single file
    "ansible",
    "tree-sitter-cli",  # needed for lazyvim
    #
    # Fonts
    "woff2-font-awesome",
    "ttf-meslo-nerd",
    "ttf-jetbrains-mono-nerd",
    "ttf-anonymouspro-nerd",
    "ttf-cascadia-code-nerd",
    "ttf-dejavu-nerd",
    "otf-droid-nerd",
    "ttf-firacode-nerd",
    "ttf-hack-nerd",
    "ttf-roboto",
    "ttf-sourcecodepro-nerd",
    "noto-fonts-emoji",  # Emoji Set
    # libraries
    "gpsd",
]

AUR_PKGS: list[str] = [
    "downgrade",  # Easily downgrade packages from A.L.A or cache
    "openssl-1.1",  # OpenSSL 1.1 (removed from official repos)
    "go-task",  # Taskfile is a task runner/build tool like GNU Make
    "oh-my-posh-bin",
    "tmux-plugin-manager",  # tpm for tmux
    "code-minimap",  # Required for minimap-vim
    "lazydocker",
    "zig-bin",
    "metadata-cleaner",
    "jqp",  # A TUI playground for jq
    "resticprofile-bin",  # Wrapper for restic with ease of configuration
]

# ---------------------------------------------------------------------------
# Desktop environment package tiers
# ---------------------------------------------------------------------------

# Shared GUI packages — needed by any desktop (Sway or KDE)
GUI_PKGS: list[str] = [
    # Terminal
    "alacritty",
    # Desktop controls
    "brightnessctl",
    "playerctl",
    "acpi",
    # "redshift",
    # Desktop frontends
    # "blueman",                    # KDE uses bluedevil
    # "network-manager-applet",     # KDE uses plasma-nm
    # "lxappearance",               # GTK config, KDE handles this
    # "pavucontrol",                # KDE uses plasma-pa
    # Secrets and passwords
    # "gnome-keyring",              # KDE uses kwallet
    "keychain",  # SSH agent
    # "libsecret",                  # KDE uses kwallet
    # "seahorse",                   # KDE uses kwallet frontend
    "keepassxc",  # Password manager
    # "qtkeychain-qt5",             # KDE uses kwallet
    # Desktop infrastructure
    "polkit",
    "gvfs",
    "ntfs-3g",
    # Desktop apps
    # "feh",                        # KDE has Gwenview
    # "dolphin",                    # KDE-specific
    # "kdf",                        # KDE-specific
    "kde-cli-tools",
    "mpv",
    "mpv-mpris",
    "mupdf",
    # Audio effects
    "easyeffects",
    "calf",
    "lsp-plugins",
    "mda.lv2",
    "zam-plugins",
    # Theming
    # "gnome-themes-extra",         # GTK themes, not needed for KDE
    # "gtk-engines",
    # "gtk-engine-murrine",
    "papirus-icon-theme",
    "breeze",
    "breeze-icons",
    # Albert Plugins
    "libqalculate",
    "imagemagick",
    "python-pint",
    "muparser",
    # Apps
    "flatpak",
    "discord",
    "firefox",
    "obs-studio",
    "gimp",
    "libreoffice-fresh",
    "pika-backup",
]

# Sway compositor + Wayland-specific tools
SWAY_PKGS: list[str] = [
    "sway",
    "swaylock",
    "waybar",
    "wofi",
    "mako",
    "dmenu",
    "grim",
    "slurp",
    "swappy",
    "wf-recorder",
    "wl-clipboard",
    "ydotool",
]

# KDE Plasma desktop
# Info at https://community.kde.org/Distributions/Packaging_Recommendations
KDE_PKGS: list[str] = [
    "plasma-meta",
    "plasma-desktop",
    "sddm",
    "sddm-kcm",
    "ffmpegthumbs",
    "kde-inotify-survey",
    "dolphin",
    "dolphin-plugins",
    "kdegraphics-thumbnailers",
    "kdenetwork-filesharing",
    "kimageformats",
    "kio-extras",
    "kio-fuse",
    "kwalletmanager",
    "qqc2-desktop-style",
    "qrca",
    "fwupd",
    "xsettingsd",
    "kdf",
    "spectacle",
    "kate",
    "elisa",
    "ark",
    "filelight",
    "krdp",
    "kcalc",
    "konsole",
    "plasma-login-manager",
    "plasma-systemmonitor",
    "kdeplasma-addons",
    "plasma-vault",
    "discover",
    # KDE connectivity & hardware
    "bluedevil",
    "kscreen",
    "kscreenlocker",
    "print-manager",
    "powerdevil",
    "kwrited",
    "milou",
    # KDE gateway & theming
    "xdg-desktop-portal-kde",
    "xdg-desktop-portal-gtk",
    "polkit-kde-agent",
    # KDE flatpak integration
    "flatpak-kcm",
]

# Shared GUI AUR packages
GUI_AUR_PKGS: list[str] = [
    "albert",
    "lightly-qt",
    "nordic-theme",
    "adwaita-qt5",
    "adwaita-qt6",
    "google-chrome",
    "spotify",
    "visual-studio-code-bin",
    "anydesk-bin",  # Remote desktop
    "postman-bin",  # API testing
    "onedrive-abraunegg",  # Onedrive sync for keepass db
    "onedrivegui-git",  # OneDrive GUI
]

# Nvidia GPU drivers and utilities
NVIDIA_PKGS: list[str] = [
    "nvidia-open-dkms",
    "nvidia-utils",
    "nvidia-settings",
    "lib32-nvidia-utils",
    "libva-nvidia-driver",
    "linux-firmware-nvidia",
]

# ASUS ROG laptop tools
ASUS_PKGS: list[str] = [
    "asusctl",
    "rog-control-center",
    "supergfxctl",
]

# Pipewire audio stack
PIPEWIRE_PKGS: list[str] = [
    "pipewire",  # Audio manager
    "pipewire-alsa",  # Support for alsa
    "pipewire-pulse",  # Support for pulse
    "pipewire-jack",  # Support for jack
    "libpulse",  # Sound server
    "wireplumber",  # Pipewire session/policy manager
]

# Go development tools (gated behind --go flag)
GO_PKGS: list[str] = [
    "go",
    "gopls",
]

# Rust development tools (gated behind --rust flag)
RUST_PKGS: list[str] = [
    "rustup",
]

# PHP stack
PHP_PKGS: list[str] = [
    "php",
    "php-cgi",
    "php-fpm",
    "php-gd",
    "php-embed",
    "php-intl",
    "php-redis",
    "php-snmp",
    "php-sqlite",
    "php-sodium",
    "php-xsl",
    "php-pgsql",
    "xdebug",
]


# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------


def run_cmd(args: list[str], *, cwd: str | None = None) -> None:
    """Run a root-level command. Raises CalledProcessError on non-zero exit."""
    subprocess.run(args, check=True, cwd=cwd)


def run_cmd_manual(args: list[str], *, cwd: str | None = None) -> None:
    """Run a root-level command interactively (for --manual mode)."""
    subprocess.run(args, check=False, cwd=cwd)


def run_as_user(user: str, cmd: str, *, cwd: str | None = None) -> None:
    """Run *cmd* as *user* via ``su user -c cmd`` (non-login shell)."""
    subprocess.run(["su", user, "-c", cmd], check=True, cwd=cwd)


def run_as_user_shell(user: str, cmd: str, *, cwd: str | None = None) -> None:
    """Run *cmd* as *user* via ``su user -l -c cmd`` (login shell).

    Use this for commands that depend on the user's login environment (nvm,
    pyenv shims, etc.).
    """
    subprocess.run(["su", user, "-l", "-c", cmd], check=True, cwd=cwd)


def command_exists(name: str) -> bool:
    """Return True if *name* resolves to an executable on PATH."""
    return shutil.which(name) is not None


def capture_env_as_user(
    user: str, script: str, *, cwd: str | None = None
) -> dict[str, str]:
    """Run *script* as *user* (non-login shell), capture ``env`` output.

    Appends ``; env`` to *script*, runs it via ``su user -c``, and parses the
    KEY=VALUE output into a dictionary.  Values that span multiple lines (rare
    but possible) are handled by only splitting on the first ``=``.
    """
    result = subprocess.run(
        ["su", user, "-c", f"{script}; env"],
        check=True,
        capture_output=True,
        text=True,
        cwd=cwd,
    )
    env_vars: dict[str, str] = {}
    for line in result.stdout.splitlines():
        if "=" in line:
            key, _, value = line.partition("=")
            env_vars[key] = value
    return env_vars


# ---------------------------------------------------------------------------
# Root-level operations
# ---------------------------------------------------------------------------


def install_yay(user: str, temp_dir: str, *, manual: bool = False) -> None:
    """Install yay AUR helper if not already present."""
    print("==========================================")
    print("Install yay")
    print("==========================================")

    if command_exists("yay"):
        print("yay is already installed. continue...")
        return

    pacman_cmd = ["pacman", "-S", "--noconfirm"] if not manual else ["pacman", "-S"]
    # Ensure git and base-devel are available before cloning
    run_cmd(pacman_cmd + ["git", "base-devel"])

    makepkg_flag = "" if manual else "--noconfirm"
    run_as_user(
        user,
        (
            f"cd {temp_dir} "
            "&& git clone https://aur.archlinux.org/yay-bin.git "
            "&& cd yay-bin "
            f"&& makepkg -si {makepkg_flag}"
        ),
    )


def install_pacman_packages(*, manual: bool = False) -> None:
    """Install all pacman packages."""
    pacman_cmd = ["pacman", "-S", "--noconfirm"] if not manual else ["pacman", "-S"]
    print("==========================================")
    print("💽 Install pacman packages")
    print("==========================================")

    run_cmd(pacman_cmd + PACMAN_PKGS)


def install_aur_packages(user: str, *, manual: bool = False) -> None:
    """Install all AUR packages via yay as the target user."""
    confirm = (
        "--noconfirm --answerdiff None --answerclean None --removemake --diffmenu=false --cleanmenu=false"
        if not manual
        else ""
    )
    print("==========================================")
    print("💽 Install AUR packages using yay")
    print("==========================================")

    pkg_list = " ".join(AUR_PKGS)
    run_as_user(
        user,
        f"yay -Sy {confirm} {pkg_list}" if confirm else f"yay -Sy {pkg_list}",
    )


def install_desktop_packages(
    user: str,
    sway: bool,
    kde: bool,
    *,
    manual: bool = False,
    skip_shared_pacman: bool = False,
    skip_shared_aur: bool = False,
) -> None:
    """Install desktop environment packages based on flags."""
    pacman_cmd = ["pacman", "-S", "--noconfirm"] if not manual else ["pacman", "-S"]
    yay_confirm = (
        "--noconfirm --answerdiff None --answerclean None --removemake --diffmenu=false --cleanmenu=false"
        if not manual
        else ""
    )
    # Shared GUI packages — needed by any desktop
    if sway or kde:
        if not skip_shared_pacman:
            print("==========================================")
            print("🖥️  Install shared GUI packages")
            print("==========================================")
            run_cmd(pacman_cmd + GUI_PKGS)

        if not skip_shared_aur:
            pkg_list = " ".join(GUI_AUR_PKGS)
            yay_cmd = (
                f"yay -Sy {yay_confirm} {pkg_list}"
                if yay_confirm
                else f"yay -Sy {pkg_list}"
            )
            run_as_user(user, yay_cmd)

    if sway:
        print("==========================================")
        print("🖥️  Install Sway desktop packages")
        print("==========================================")
        run_cmd(pacman_cmd + SWAY_PKGS)

    if kde:
        print("==========================================")
        print("🖥️  Install KDE desktop packages")
        print("==========================================")
        run_cmd(pacman_cmd + KDE_PKGS)

        # Enable SDDM display manager for KDE
        print("\n  Enabling sddm display manager ...")
        subprocess.run(["systemctl", "enable", "sddm"], check=False)


def install_nvidia_packages(*, manual: bool = False) -> None:
    """Install Nvidia GPU drivers and utilities."""
    pacman_cmd = ["pacman", "-S", "--noconfirm"] if not manual else ["pacman", "-S"]
    print("==========================================")
    print("🎮 Install Nvidia packages")
    print("==========================================")
    run_cmd(pacman_cmd + NVIDIA_PKGS)


def install_asus_packages(*, manual: bool = False) -> None:
    """Install ASUS ROG laptop tools."""
    pacman_cmd = ["pacman", "-S", "--noconfirm"] if not manual else ["pacman", "-S"]
    print("==========================================")
    print("🎮 Install ASUS ROG packages")
    print("==========================================")
    run_cmd(pacman_cmd + ASUS_PKGS)


def install_pipewire_packages(*, manual: bool = False) -> None:
    """Install Pipewire audio stack."""
    pacman_cmd = ["pacman", "-S", "--noconfirm"] if not manual else ["pacman", "-S"]
    print("==========================================")
    print("🎵 Install Pipewire audio packages")
    print("==========================================")
    run_cmd(pacman_cmd + PIPEWIRE_PKGS)


def install_php_packages(*, manual: bool = False) -> None:
    """Install PHP and all PHP extensions."""
    pacman_cmd = ["pacman", "-S", "--noconfirm"] if not manual else ["pacman", "-S"]
    print("==========================================")
    print("🐘 Install PHP packages")
    print("==========================================")
    run_cmd(pacman_cmd + PHP_PKGS)


def install_go_packages(*, manual: bool = False) -> None:
    """Install Go and gopls."""
    pacman_cmd = ["pacman", "-S", "--noconfirm"] if not manual else ["pacman", "-S"]
    print("==========================================")
    print("🐹 Install Go packages")
    print("==========================================")
    run_cmd(pacman_cmd + GO_PKGS)


def install_rust_packages(*, manual: bool = False) -> None:
    """Install rustup and set nightly as default toolchain."""
    pacman_cmd = ["pacman", "-S", "--noconfirm"] if not manual else ["pacman", "-S"]
    print("==========================================")
    print("🦀 Install Rust packages")
    print("==========================================")
    run_cmd(pacman_cmd + RUST_PKGS)


def install_composer(temp_dir: str) -> None:
    """Download and install Composer globally (only if php is available)."""
    print("==========================================")
    print("Installing Composer")
    print("==========================================")

    if not command_exists("php"):
        print("php command is not found, skipping composer installation.")
        return

    run_cmd(
        [
            "php",
            "-r",
            "copy('https://getcomposer.org/installer', 'composer-setup.php');",
        ],
        cwd=temp_dir,
    )
    run_cmd(
        [
            "php",
            "composer-setup.php",
            "--install-dir=/usr/local/bin",
            "--filename=composer",
        ],
        cwd=temp_dir,
    )


def install_spotx() -> None:
    """Install SpotX ad-block patch for Spotify if spotify binary is present."""
    if not command_exists("spotify"):
        return

    print("==========================================")
    print("Install SpotX For Spotify")
    print("==========================================")

    curl_result = subprocess.run(
        [
            "curl",
            "-sSL",
            "https://raw.githubusercontent.com/SpotX-CLI/SpotX-Linux/main/install.sh",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    subprocess.run(
        ["bash", "-s", "--", "-ce"], input=curl_result.stdout, check=True, text=True
    )


def configure_ssh() -> None:
    """Uncomment Port 22 and ListenAddress 0.0.0.0 in sshd_config."""
    print("------------------------------------------")
    print("Enabling SSH")
    print("------------------------------------------")

    run_cmd(["sed", "-i", "s/#Port 22/Port 22/I", "/etc/ssh/sshd_config"])
    run_cmd(
        [
            "sed",
            "-i",
            "s/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/I",
            "/etc/ssh/sshd_config",
        ]
    )


def configure_php(temp_dir: str) -> None:
    """Fix xdebug.ini and uncomment PHP extensions in php.ini / redis.ini."""
    if not command_exists("php"):
        return

    # Fix debug file — xdebug.ini is expected in the temp working directory
    run_cmd(["sed", "s/;//", "-i", "xdebug.ini"], cwd=temp_dir)

    print("==========================================")
    print("Modify php.ini file")
    print("==========================================")

    php_ini = "/etc/php/php.ini"

    # Each entry: (commented form, uncommented replacement)
    php_ini_subs: list[tuple[str, str]] = [
        (";cgi.fix_pathinfo=0", "cgi.fix_pathinfo=1"),
        (";extension=bcmath", "extension=bcmath"),
        (";extension=fileinfo", "extension=fileinfo"),
        (";extension=gd", "extension=gd"),
        (";extension=imap", "extension=imap"),
        (";extension=mbstring", "extension=mbstring"),
        (";extension=exif", "extension=exif"),
        (";extension=mysqli", "extension=mysqli"),
        (";extension=sqlite3", "extension=sqlite3"),
        (";extension=openssl", "extension=openssl"),
        (";extension=pdo_mysql", "extension=pdo_mysql"),
        (";extension=pdo_sqlite", "extension=pdo_sqlite"),
        (";extension=sockets", "extension=sockets"),
        (";extension=intl", "extension=intl"),
        (";extension=sodium", "extension=sodium"),
        (";extension=igbinary.so", "extension=igbinary.so"),
        (";igbinary.compact_strings=On", "igbinary.compact_strings=On"),
        (";extension=redis", "extension=redis"),
        (";extension=iconv", "extension=iconv"),
    ]

    for old, new in php_ini_subs:
        run_cmd(["sed", "-i", f"s/{old}/{new}/I", php_ini])

    # redis.ini also gets the redis extension uncommented
    run_cmd(
        [
            "sed",
            "-i",
            "s/;extension=redis/extension=redis/I",
            "/etc/php/conf.d/redis.ini",
        ]
    )


def configure_system_services(user: str) -> None:
    """Manage system-level systemd services, docker group, and group membership."""
    print("==========================================")
    print("🔃 System Service")
    print("==========================================")

    for service in SYSTEM_SERVICES_STOP:
        subprocess.run(["systemctl", "stop", service], check=False)

    for service in SYSTEM_SERVICES:
        subprocess.run(["systemctl", "start", service], check=False)
        subprocess.run(["systemctl", "enable", service], check=False)

    # Make sure docker group exists — intentionally ignore error if already exists
    subprocess.run(["groupadd", "docker"], check=False)

    # Add user to docker and flatpak groups (supplementary, primary stays as sudo)
    subprocess.run(["gpasswd", "-a", user, "docker"], check=False)
    subprocess.run(["gpasswd", "-a", user, "flatpak"], check=False)

    # Set zsh as default shell if installed
    zsh_path = shutil.which("zsh")
    if zsh_path:
        # Ensure zsh is in /etc/shells
        shells_file = "/etc/shells"
        try:
            with open(shells_file, "r") as f:
                shells_content = f.read()
            if zsh_path not in shells_content:
                with open(shells_file, "a") as f:
                    f.write(f"{zsh_path}\n")
        except FileNotFoundError:
            with open(shells_file, "w") as f:
                f.write(f"{zsh_path}\n")

        # Check and update default shell
        result = subprocess.run(
            ["getent", "passwd", user], capture_output=True, text=True, check=True
        )
        current_shell = result.stdout.strip().split(":")[-1]
        if current_shell != zsh_path:
            subprocess.run(["usermod", "--shell", zsh_path, user], check=True)
            print(f"  ✔  Default shell changed to {zsh_path}")
        else:
            print(f"  ℹ  Default shell is already {zsh_path}")


def print_manual_tasks_banner() -> None:
    """Print the remaining manual tasks that require human action."""
    banner = """
==============================================
            Remaining Manual Tasks....
==============================================

- Change root password, if you want to:
sudo passwd root

"""
    # Use bat if available, otherwise fall back to plain print
    if command_exists("bat"):
        subprocess.run(["bat"], input=banner, text=True, check=False)
    else:
        print(banner)


# ---------------------------------------------------------------------------
# User-level operations  (converted from sway-install-profile.zsh)
# ---------------------------------------------------------------------------


def stow_dotfiles(
    user: str, script_path: str, extra_dirs: list[str] | None = None
) -> None:
    """Create required local dirs, stow all dotfile directories, and cache fonts."""
    print("==========================================")
    print("🔗 Stowing dot files")
    print("==========================================")

    # Make sure required local directories exist before stowing
    run_as_user(user, "mkdir -p ~/.local/bin ~/.local/share/fonts")

    all_dirs = STOW_DIRS + (extra_dirs or [])

    for stow_dir in all_dirs:
        print(f"Stowing {stow_dir}")
        # LC_ALL=C fixes perl locale warning; --adopt gracefully handles existing files
        run_as_user(user, f"LC_ALL=C stow {stow_dir} --adopt", cwd=script_path)

    print("==========================================")
    print(
        "Caching fonts - Run 'fc-cache -rv' any time there is a file change at .local/share/fonts"
    )
    print("==========================================")

    run_as_user(user, "fc-cache -rv")

    # Source env files as the user, capture resulting env vars into os.environ
    # so that subsequent commands using os.environ (e.g. XDG_CONFIG_HOME) are correct
    print("Sourcing zsh environment files...")
    env_script = (
        "zsh -c 'source common/.zshenv; source ~/.zshenv; source $ZDOTDIR/.zshrc; env'"
    )
    captured_env = capture_env_as_user(user, env_script, cwd=script_path)
    os.environ.update(captured_env)

    # Finally link the zsh config after env is loaded
    run_as_user(user, "LC_ALL=C stow zsh --adopt", cwd=script_path)

    # Source .zshrc again to load plugins and nvm
    run_as_user(user, "zsh -c 'source $ZDOTDIR/.zshrc'")


def install_node_via_nvm(user: str, node_version: str) -> None:
    """Upgrade nvm, install node_version, set as default, install global npm packages."""
    print("==========================================")
    print("Installing node")
    print("==========================================")

    # Install nvm if not present
    subprocess.run(
        [
            "su",
            user,
            "-l",
            "-c",
            f"command -v nvm >/dev/null 2>&1 || "
            f"curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/{NVM_VERSION}/install.sh | bash",
        ],
        check=True,
    )

    # Ensure nvm is in .zshrc (idempotent)
    subprocess.run(
        [
            "su",
            user,
            "-l",
            "-c",
            'grep -q "NVM_DIR" ~/.zshrc 2>/dev/null || '
            'echo -e \'\\nexport NVM_DIR="$HOME/.nvm"\\n[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"\\n\' >> ~/.zshrc',
        ],
        check=True,
    )

    # Run nvm commands in an INTERACTIVE shell so .zshrc fully loads
    nvm_commands = (
        f"nvm install {node_version} && "
        f"nvm alias default {node_version} && "
        f"nvm use default && "
        f"npm install npm@latest yarn@latest pnpm@latest --location=global"
    )
    subprocess.run(
        ["su", user, "-l", "-c", f"zsh -ic '{nvm_commands}'"],
        check=True,
    )


def configure_go(user: str) -> None:
    """Set GOMODCACHE to the XDG cache directory."""
    run_as_user(user, 'go env -w GOMODCACHE="$XDG_CACHE_HOME/go/pkg/mod"')


def install_k9s_theme(user: str) -> None:
    """Download and extract the catppuccin k9s skin theme for the user."""
    print("==========================================")
    print("Installing k9s catppuccin theme")
    print("==========================================")

    # Create skins dir and pipe curl into tar — run entirely as user
    install_cmd = (
        'OUT="${XDG_CONFIG_HOME:-$HOME/.config}/k9s/skins"; '
        'mkdir -p "$OUT"; '
        "curl -L https://github.com/catppuccin/k9s/archive/main.tar.gz "
        '| tar xz -C "$OUT" --strip-components=2 k9s-main/dist'
    )
    run_as_user(user, install_cmd)


def install_resticprofile(user: str, version: str) -> None:
    """Download and extract the resticprofile binary to ~/.local/bin."""
    print("==========================================")
    print(f"Installing resticprofile {version}")
    print("==========================================")

    install_cmd = (
        'RESTICPROFILE_OUT="$HOME/.local/bin"; '
        'mkdir -p "$RESTICPROFILE_OUT"; '
        f"curl -L https://github.com/creativeprojects/resticprofile/releases/download/"
        f"v{version}/resticprofile_{version}_linux_amd64.tar.gz "
        '| tar xz -C "$RESTICPROFILE_OUT" --strip-components=1 resticprofile'
    )
    run_as_user(user, install_cmd)


def install_python_via_pyenv(user: str, pyenv_version: str) -> None:
    """Install Python via pyenv, set global, install pip and uv packages."""
    print("==========================================")
    print(f"Installing python {pyenv_version}")
    print("==========================================")

    run_as_user_shell(user, f"pyenv install {pyenv_version}")
    run_as_user_shell(user, f"pyenv global {pyenv_version}")

    # python3 core dependencies
    pip_core = " ".join(PIP3_PKGS)
    run_as_user_shell(user, f"pip3 install {pip_core}")

    # extra pip packages (includes uv)
    pip_extra = " ".join(PIP3_PKGS_EXTRA)
    run_as_user_shell(user, f"pip3 install {pip_extra}")

    # uv tool installs
    for tool in UV_TOOLS:
        run_as_user_shell(user, f"uv tool install {tool}")


def enable_user_services(user: str) -> None:
    """Enable user-level systemd services via systemctl --user."""
    print("==========================================")
    print("🔃 User Services")
    print("==========================================")

    for service in USER_SERVICES:
        run_as_user(user, f"systemctl --user enable --now {service}")


def install_dankmono_font(user: str) -> None:
    """Download and install DankMono Nerd Font from saifulapm/my-fonts."""
    print("==========================================")
    print("🔤 Installing DankMono Nerd Font")
    print("==========================================")

    install_cmd = (
        'FONT_DIR="$HOME/.local/share/fonts"; '
        'mkdir -p "$FONT_DIR/DankMono-Nerd-Font"; '
        "curl -sL https://github.com/saifulapm/my-fonts/archive/refs/heads/main.tar.gz "
        '| tar xz -C "$FONT_DIR/DankMono-Nerd-Font" --strip-components=2 '
        "'my-fonts-main/DankMono Nerd Font' "
        "&& fc-cache -fv"
    )
    run_as_user(user, install_cmd)


# ---------------------------------------------------------------------------
# Orchestration
# ---------------------------------------------------------------------------


def run_root_setup(
    user: str, script_path: str, temp_dir: str, args: argparse.Namespace
) -> None:
    """Execute all root-level operations (always run unless gated by a flag)."""

    # 1. Install yay if missing
    if not args.skip_aur:
        install_yay(user, temp_dir, manual=args.manual)

    # 2. Install pacman packages
    if not args.skip_pacman:
        install_pacman_packages(manual=args.manual)

    # 3. Install AUR packages (non-interactive)
    if not args.skip_aur:
        install_aur_packages(user, manual=args.manual)

    # 4. Install desktop packages (--sway and/or --kde flags)
    if args.sway or args.kde:
        install_desktop_packages(
            user,
            args.sway,
            args.kde,
            manual=args.manual,
            skip_shared_pacman=args.skip_shared_pacman,
            skip_shared_aur=args.skip_shared_aur,
        )

    # 5. Nvidia drivers (--nvidia flag)
    if args.nvidia:
        install_nvidia_packages(manual=args.manual)

    # 6. ASUS ROG tools (--asus flag)
    if args.asus:
        install_asus_packages(manual=args.manual)

    # 7. Pipewire audio stack (--pipewire flag)
    if args.pipewire:
        install_pipewire_packages(manual=args.manual)

    # 8. Go development tools (--go flag)
    if args.go:
        install_go_packages(manual=args.manual)

    # 9. Rust development tools (--rust flag)
    if args.rust:
        install_rust_packages(manual=args.manual)

    # 10. PHP packages + Composer + config (--php flag)
    if args.php:
        install_php_packages(manual=args.manual)
        install_composer(temp_dir)

    # 11. SpotX (conditional on spotify being installed)
    install_spotx()

    print("==========================================")
    print("💽 Configuration Setup")
    print("==========================================")

    # 12. SSH configuration (--ssh flag)
    if args.ssh:
        configure_ssh()

    # 13. PHP configuration (--php flag)
    if args.php:
        configure_php(temp_dir)

    # 11. System services (gated behind --services flag)
    if args.services:
        configure_system_services(user)

    # 12. Manual tasks banner
    print_manual_tasks_banner()


def run_user_setup(user: str, script_path: str, args: argparse.Namespace) -> None:
    """Execute all user-level operations, each gated by the corresponding flag."""

    # --stow: stow dotfiles, cache fonts, configure zsh, source env
    if args.stow:
        extra_dirs = list(STOW_DIRS_GUI) if args.sway or args.kde else []
        if args.sway:
            extra_dirs += STOW_DIRS_SWAY
        if args.kde:
            extra_dirs += STOW_DIRS_KDE
        stow_dotfiles(user, script_path, extra_dirs)

    # --nvm: install/upgrade node via nvm
    if args.nvm:
        install_node_via_nvm(user, args.nvm)

    # --go: configure GOMODCACHE
    if args.go:
        configure_go(user)

    # --rust: set nightly toolchain
    if args.rust:
        subprocess.run(
            [
                "su",
                user,
                "-l",
                "-c",
                f"zsh -ic 'rustup toolchain install nightly && rustup default nightly'",
            ],
            check=True,
        )

    # --k9s-theme: download catppuccin k9s skins
    if args.k9s_theme:
        install_k9s_theme(user)

    # --resticprofile: download resticprofile binary
    if args.resticprofile:
        install_resticprofile(user, args.resticprofile)

    # --pyenv: install Python and pip/uv packages
    if args.pyenv:
        install_python_via_pyenv(user, args.pyenv)

    # --font: install DankMono Nerd Font
    if args.font:
        install_dankmono_font(user)

    # --services: enable user systemd services
    if args.services:
        enable_user_services(user)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Arch Linux + Sway setup script. "
            "Must be run as root (sudo). "
            "Replaces both setup-arch-sway.sh and sway-install-profile.zsh."
        )
    )
    parser.add_argument(
        "--user",
        default=None,
        help="The login username for user-level operations. Defaults to $SUDO_USER.",
    )
    parser.add_argument(
        "--sway",
        action="store_true",
        help="Install Sway compositor and Wayland desktop packages.",
    )
    parser.add_argument(
        "--kde",
        action="store_true",
        help="Install KDE Plasma desktop packages.",
    )
    parser.add_argument(
        "--nvidia",
        action="store_true",
        help="Install Nvidia GPU drivers and utilities.",
    )
    parser.add_argument(
        "--asus",
        action="store_true",
        help="Install ASUS ROG laptop tools (asusctl, rog-control-center, supergfxctl).",
    )
    parser.add_argument(
        "--pipewire",
        action="store_true",
        help="Install Pipewire audio stack.",
    )
    parser.add_argument(
        "--ssh",
        action="store_true",
        help="Enable SSH configuration (uncomment Port 22 / ListenAddress in sshd_config).",
    )
    parser.add_argument(
        "--php",
        action="store_true",
        help="Install Composer, fix xdebug.ini, modify php.ini extensions.",
    )
    parser.add_argument(
        "--stow",
        action="store_true",
        help="Stow dotfiles, cache fonts, configure zsh shell.",
    )
    parser.add_argument(
        "--nvm",
        type=str,
        nargs="?",
        const=NODE_VERSION,
        default=None,
        help=f"Install/upgrade nvm and install node version (default: {NODE_VERSION}).",
    )
    parser.add_argument(
        "--go",
        action="store_true",
        help="Install Go + gopls and configure GOMODCACHE.",
    )
    parser.add_argument(
        "--rust",
        action="store_true",
        help="Install rustup and set nightly as default toolchain.",
    )
    parser.add_argument(
        "--k9s-theme",
        action="store_true",
        dest="k9s_theme",
        help="Download and extract catppuccin k9s theme.",
    )
    parser.add_argument(
        "--resticprofile",
        type=str,
        nargs="?",
        const=RESTICPROFILE_VERSION,
        default=None,
        help=f"Download and extract resticprofile binary (default: {RESTICPROFILE_VERSION}).",
    )
    parser.add_argument(
        "--pyenv",
        type=str,
        nargs="?",
        const=PYENV_VERSION,
        default=None,
        help=f"Install Python via pyenv (default: {PYENV_VERSION}).",
    )
    parser.add_argument(
        "--font",
        action="store_true",
        help="Install DankMono Nerd Font from saifulapm/my-fonts.",
    )
    parser.add_argument(
        "--services",
        action="store_true",
        help="Enable user-level systemd services.",
    )
    parser.add_argument(
        "--skip-pacman",
        action="store_true",
        help="Skip installing pacman packages (does not affect --kde, --nvidia, etc.).",
    )
    parser.add_argument(
        "--skip-aur",
        action="store_true",
        help="Skip installing AUR packages via yay.",
    )
    parser.add_argument(
        "--skip-shared-pacman",
        action="store_true",
        help="Skip installing shared GUI pacman packages (used by --sway/--kde).",
    )
    parser.add_argument(
        "--skip-shared-aur",
        action="store_true",
        help="Skip installing shared GUI AUR packages (used by --sway/--kde).",
    )
    parser.add_argument(
        "--manual",
        action="store_true",
        help="Run all package installs interactively (remove --noconfirm, allow user intervention).",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    user = args.user or os.environ.get("SUDO_USER")
    if not user:
        print("Error: must be run with sudo, or pass --user <username>.")
        sys.exit(1)

    user = user.strip()

    script_path = os.path.dirname(os.path.abspath(__file__))

    # Confirmation gate
    reply = input("y to continue, any key to cancel: ")
    if not reply.startswith("y"):
        print("Script canceled!")
        sys.exit(0)

    # Create a temporary directory, give ownership to the target user
    temp_dir = tempfile.mkdtemp()
    run_cmd(["chown", f"{user}:root", temp_dir])

    # Root-level setup (runs always, some steps gated by flags)
    run_root_setup(user, script_path, temp_dir, args)

    # User-level setup (each section gated by its flag)
    run_user_setup(user, script_path, args)


if __name__ == "__main__":
    main()
