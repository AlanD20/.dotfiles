#!/usr/bin/env python3
"""
macOS setup script using Homebrew.

Mirrors setup-archlinux.py for macOS environments. Homebrew is the primary
package manager; casks are used for GUI applications, fonts via homebrew/cask-fonts,
and background services via brew services / launchctl.

Does NOT require root (Homebrew is user-level by design), though a few
operations (SSH, shell) prompt for sudo when needed.

Usage:
    python3 setup-macos.py [flags]

Flags:
    --stow             Stow dotfiles, configure zsh shell
    --nvm [VERSION]    Install/upgrade nvm and install node (default: lts/krypton)
    --go               Install Go + gopls, configure GOMODCACHE
    --rust             Install rustup and set nightly as default toolchain
    --k9s-theme        Download and extract catppuccin k9s theme
    --resticprofile [VERSION]  Download and extract resticprofile binary (default: 0.32.0)
    --pyenv [VERSION]  Install Python via pyenv (default: 3.13)
    --font             Install Nerd Fonts via homebrew/cask-fonts
    --ssh              Enable SSH (Remote Login)
    --php              Install PHP, Composer, configure php.ini extensions
    --services         Enable background services (docker, php)
    --gui              Install GUI applications (browsers, editors, media, office)
    --mas              Install Mac App Store apps via mas (requires prior iCloud sign-in)
    --skip-brew        Skip Homebrew formula/cask installation
    --manual           Run package installs interactively (no --noconfirm equivalent)
"""

import argparse
import os
import platform
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
DANKMONO_VERSION = "1.2.0"

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
    "sqlit-tui",
]

STOW_DIRS: list[str] = [
    "aerospace",
    "alacritty",
    "atuin",
    "bin",
    "common",
    "containers",
    "gnupg",
    "lazygit",
    "lazyvim",
    "oh-my-posh",
    "opencode",
    "systemd",
    "tmux",
    "zsh",
]

STOW_DIRS_GUI: list[str] = [
    "wallpapers",
    "onedrive",
]

# ---------------------------------------------------------------------------
# Homebrew formula packages (CLI tools)
# ---------------------------------------------------------------------------

BREW_FORMULAE: list[str] = [
    # Essentials
    "git",
    "curl",
    "wget",
    "neovim",
    "vim",
    "nano",
    "openssh",
    "jq",
    "yq",
    "bind",
    "less",
    "lsof",
    "htop",
    # Shell & terminal
    "zsh",
    "tmux",
    "stow",
    "fzf",
    "eza",
    "ripgrep",
    "bat",
    "direnv",
    "lf",
    "lazygit",
    "fd",
    "git-delta",
    "entr",
    "gdu",
    "ncdu",
    "fastfetch",
    "tldr",
    # CLI tools
    "k9s",
    "lazydocker",
    "restic",
    "resticprofile",
    "asciinema",
    "atuin",
    "bmon",
    "oh-my-posh",
    "go-task",
    "jqp",
    "code-minimap",
    # Media
    "ffmpeg",
    "unrar",
    "exiftool",
    "imagemagick",
    "mpv",
    "mupdf",
    # Dev & build
    "python",
    "php",
    "lua",
    "go",
    "terraform",
    "ansible",
    "meson",
    "cmake",
    "ninja",
    "llvm",
    "tree-sitter",
    "mise",
    "ripgrep-all",
    "sqlite",
    "docker",
    "docker-compose",
    "helm",
    "zig",
    "squashfs",
    "cdrtools",
    "netcat",
    # Libraries
    "gnupg",
    # Albert/Qt deps — not needed on macOS
    # "libqalculate",
    # "muparser",
    # "tcl-tk",
    # "pyqt@5",
    # "pyqt@6",
    # Font utilities
    "woff2",
]

# ---------------------------------------------------------------------------
# Homebrew cask packages (GUI applications)
# ---------------------------------------------------------------------------

BREW_CASKS: list[str] = [
    "alacritty",
    "firefox",
    "google-chrome",
    "visual-studio-code",
    "discord",
    "spotify",
    "obs",
    "keepassxc",
    "postman",
    "anydesk",
    "onedrive",
    # Window manager
    "nikitabobko/tap/aerospace",
]

# ---------------------------------------------------------------------------
# Homebrew cask-fonts (Nerd Fonts)
# ---------------------------------------------------------------------------

BREW_FONTS: list[str] = [
    "font-meslo-lg-nerd-font",
    "font-jetbrains-mono-nerd-font",
    "font-fira-code-nerd-font",
    "font-cascadia-code-nerd-font",
    "font-hack-nerd-font",
    "font-anonymous-pro-nerd-font",
    "font-droid-nerd-font",
    "font-source-code-pro-nerd-font",
    "font-dejavu-nerd-font",
    "font-noto-emoji",
]

# ---------------------------------------------------------------------------
# macOS system preferences (defaults write)
# ---------------------------------------------------------------------------

MACOS_DEFAULTS: list[tuple[str, str, str, str]] = [
    # (domain, key, type, value)
    ("NSGlobalDomain", "ApplePressAndHoldEnabled", "-bool", "false"),
    ("NSGlobalDomain", "KeyRepeat", "-int", "2"),
    ("NSGlobalDomain", "InitialKeyRepeat", "-int", "15"),
    ("NSGlobalDomain", "AppleShowAllExtensions", "-bool", "true"),
    ("NSGlobalDomain", "AppleShowAllFiles", "-bool", "true"),
    ("NSGlobalDomain", "NSDocumentSaveNewDocumentsToCloud", "-bool", "false"),
    ("NSGlobalDomain", "NSTableViewDefaultSizeMode", "-int", "2"),
    ("NSGlobalDomain", "NSWindowShouldDragOnGesture", "-bool", "true"),
    ("com.apple.finder", "FXPreferredViewStyle", "-string", "Nlsv"),
    ("com.apple.finder", "FXShowPosixPathInTitle", "-bool", "true"),
    ("com.apple.finder", "ShowPathbar", "-bool", "true"),
    ("com.apple.finder", "ShowStatusBar", "-bool", "true"),
    ("com.apple.dock", "autohide", "-bool", "true"),
    ("com.apple.dock", "show-recents", "-bool", "false"),
    ("com.apple.dock", "mru-spaces", "-bool", "false"),
    ("com.apple.dock", "orientation", "-string", "bottom"),
]

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------


def get_brew_prefix() -> str:
    """Return Homebrew prefix, detecting Apple Silicon vs Intel."""
    if os.path.exists("/opt/homebrew/bin/brew"):
        return "/opt/homebrew"
    return "/usr/local"


def get_brew_bin() -> str:
    return f"{get_brew_prefix()}/bin/brew"


def run_cmd(args: list[str], *, cwd: str | None = None, sudo: bool = False) -> None:
    """Run a command. Optionally prefix with sudo."""
    cmd = ["sudo"] + args if sudo else args
    subprocess.run(cmd, check=True, cwd=cwd)


def run_cmd_manual(
    args: list[str], *, cwd: str | None = None, sudo: bool = False
) -> None:
    """Run a command interactively (for --manual mode)."""
    cmd = ["sudo"] + args if sudo else args
    subprocess.run(cmd, check=False, cwd=cwd)


def run_as_user(cmd: str, *, cwd: str | None = None) -> None:
    """Run *cmd* via a login shell (respects user env)."""
    subprocess.run(cmd, shell=True, check=True, cwd=cwd, executable="/bin/zsh")


def command_exists(name: str) -> bool:
    """Return True if *name* resolves to an executable on PATH."""
    return shutil.which(name) is not None


def print_step(title: str) -> None:
    """Print a section header."""
    print("=" * 50)
    print(title)
    print("=" * 50)


# ---------------------------------------------------------------------------
# Homebrew operations
# ---------------------------------------------------------------------------


def ensure_homebrew(manual: bool = False) -> None:
    """Install Homebrew if not already present."""
    if command_exists("brew"):
        print("Homebrew already installed.")
        return
    print_step("Installing Homebrew")
    cmd = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    subprocess.run(cmd, shell=True, check=not manual)


def install_brew_packages(skip_brew: bool = False, manual: bool = False) -> None:
    """Install Homebrew formula packages."""
    if skip_brew:
        return

    ensure_homebrew(manual)

    install_cmd = ["brew", "install"]
    if not manual:
        install_cmd += ["--quiet", "--no-ask"]

    print_step("Installing Homebrew formulae (CLI tools)")
    for pkg in BREW_FORMULAE:
        subprocess.run(install_cmd + [pkg], check=False)


def install_brew_casks(manual: bool = False) -> None:
    """Install GUI applications via Homebrew casks."""
    ensure_homebrew(manual)

    install_cmd = ["brew", "install", "--cask"]
    if not manual:
        install_cmd += ["--quiet", "--no-ask"]

    print_step("Installing GUI applications (casks)")
    for cask in BREW_CASKS:
        subprocess.run(install_cmd + [cask], check=False)


def install_brew_fonts(manual: bool = False) -> None:
    """Install Nerd Fonts via homebrew/cask-fonts."""
    ensure_homebrew(manual)

    install_cmd = ["brew", "install", "--cask"]
    if not manual:
        install_cmd += ["--quiet", "--no-ask"]

    print_step("Installing Nerd Fonts")
    for font in BREW_FONTS:
        subprocess.run(install_cmd + [font], check=False)


# ---------------------------------------------------------------------------
# macOS system configuration
# ---------------------------------------------------------------------------


def configure_macos_defaults() -> None:
    """Apply macOS system preferences via defaults write."""
    print_step("Configuring macOS system preferences")

    # Kill affected apps first to avoid conflicts
    for app in ["Finder", "Dock"]:
        subprocess.run(["killall", app], check=False)

    for domain, key, typ, value in MACOS_DEFAULTS:
        subprocess.run(["defaults", "write", domain, key, typ, value], check=False)

    # Restart affected apps
    subprocess.run(["killall", "Finder"], check=False)
    subprocess.run(["killall", "Dock"], check=False)


def configure_ssh() -> None:
    """Enable SSH Remote Login on macOS."""
    print_step("Enabling SSH (Remote Login)")
    subprocess.run(
        ["sudo", "launchctl", "load", "-w", "/System/Library/LaunchDaemons/ssh.plist"],
        check=False,
    )
    subprocess.run(
        ["sudo", "systemsetup", "-setremotelogin", "on"],
        check=False,
    )


# ---------------------------------------------------------------------------
# Service management (brew services / launchctl)
# ---------------------------------------------------------------------------

BREW_SERVICES: list[str] = [
    "docker",
    "php",
]


def enable_services(manual: bool = False) -> None:
    """Start and enable background services via brew services."""
    print_step("Enabling background services")

    for service in BREW_SERVICES:
        print(f"  Starting {service}...")
        subprocess.run(
            ["brew", "services", "start", service],
            check=False,
        )


# ---------------------------------------------------------------------------
# Language runtimes
# ---------------------------------------------------------------------------


def install_node_via_nvm(node_version: str) -> None:
    """Install/upgrade nvm and install node."""
    print_step(f"Installing Node via nvm ({node_version})")

    nvm_dir = os.path.expanduser("~/.nvm")
    nvm_sh = os.path.join(nvm_dir, "nvm.sh")

    if not os.path.exists(nvm_sh):
        subprocess.run(
            f"curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/{NVM_VERSION}/install.sh | bash",
            shell=True,
            check=True,
        )

    nvm_cmds = (
        f". {nvm_sh} && "
        f"nvm install {node_version} && "
        f"nvm alias default {node_version} && "
        f"nvm use default && "
        f"npm install npm@latest yarn@latest pnpm@latest --location=global"
    )
    subprocess.run(nvm_cmds, shell=True, check=True, executable="/bin/zsh")


def configure_go() -> None:
    """Set GOMODCACHE to the XDG cache directory."""
    if not command_exists("go"):
        print("  go not found — skipping. Install with: brew install go")
        return
    print_step("Configuring Go")
    run_as_user('go env -w GOMODCACHE="$XDG_CACHE_HOME/go/pkg/mod"')


def configure_rust() -> None:
    """Install rustup if missing and set nightly as default."""
    print_step("Configuring Rust")

    if not command_exists("rustup"):
        subprocess.run(
            "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y",
            shell=True,
            check=False,
        )

    if command_exists("rustup"):
        run_as_user("rustup toolchain install nightly && rustup default nightly")


def install_python_via_pyenv(pyenv_version: str) -> None:
    """Install Python via pyenv, set global, install pip and uv packages."""
    print_step(f"Installing Python {pyenv_version} via pyenv")

    if not command_exists("pyenv"):
        subprocess.run(["brew", "install", "pyenv"], check=True)

    run_as_user(f"pyenv install {pyenv_version}")
    run_as_user(f"pyenv global {pyenv_version}")

    pip_core = " ".join(PIP3_PKGS)
    run_as_user(f"pip3 install {pip_core}")

    pip_extra = " ".join(PIP3_PKGS_EXTRA)
    run_as_user(f"pip3 install {pip_extra}")

    for tool in UV_TOOLS:
        run_as_user(f"uv tool install {tool}")


def install_php() -> None:
    """Install PHP extensions via pecl and configure php.ini."""
    if not command_exists("php"):
        print("  php not found — skipping. Install with: brew install php")
        return

    print_step("Configuring PHP")

    if not command_exists("composer"):
        subprocess.run(["brew", "install", "composer"], check=False)

    subprocess.run(
        ["pecl", "install", "xdebug"],
        check=False,
    )

    # Enable common PHP extensions in php.ini
    ini_path = None
    for candidate in [
        "/opt/homebrew/etc/php/*/php.ini",
        "/usr/local/etc/php/*/php.ini",
    ]:
        import glob

        files = glob.glob(candidate)
        if files:
            ini_path = files[0]
            break

    if ini_path:
        extensions = [
            "bcmath",
            "gd",
            "intl",
            "mbstring",
            "mysqli",
            "pdo_mysql",
            "pdo_sqlite",
            "sockets",
            "sodium",
            "exif",
            "fileinfo",
            "openssl",
            "sqlite3",
        ]
        for ext in extensions:
            subprocess.run(
                ["sed", "-i", "", f"s/;extension={ext}/extension={ext}/", ini_path],
                check=False,
            )


# ---------------------------------------------------------------------------
# Dotfiles (stow)
# ---------------------------------------------------------------------------


def stow_dotfiles(script_path: str, extra_dirs: list[str] | None = None) -> None:
    """Create required local dirs and stow all dotfile directories."""
    print_step("Stowing dotfiles")

    os.makedirs(os.path.expanduser("~/.local/bin"), exist_ok=True)
    os.makedirs(os.path.expanduser("~/.local/share/fonts"), exist_ok=True)

    all_dirs = STOW_DIRS + (extra_dirs or [])

    for stow_dir in all_dirs:
        print(f"  Stowing {stow_dir}")
        subprocess.run(
            ["stow", stow_dir, "--adopt"],
            check=False,
            cwd=script_path,
        )

    # Link zsh config last after env is loaded
    subprocess.run(
        ["stow", "zsh", "--adopt"],
        check=False,
        cwd=script_path,
    )

    # Source .zshrc to load plugins
    subprocess.run(
        "zsh -c 'source $ZDOTDIR/.zshrc'",
        shell=True,
        check=False,
    )


# ---------------------------------------------------------------------------
# Theme / misc
# ---------------------------------------------------------------------------


def install_k9s_theme() -> None:
    """Download and extract the catppuccin k9s skin theme."""
    print_step("Installing k9s catppuccin theme")

    install_cmd = (
        'OUT="${XDG_CONFIG_HOME:-$HOME/.config}/k9s/skins"; '
        'mkdir -p "$OUT"; '
        "curl -L https://github.com/catppuccin/k9s/archive/main.tar.gz "
        '| tar xz -C "$OUT" --strip-components=2 k9s-main/dist'
    )
    run_as_user(install_cmd)


def install_resticprofile(version: str) -> None:
    """Download and extract the resticprofile binary to ~/.local/bin."""
    print_step(f"Installing resticprofile {version}")

    install_cmd = (
        'OUT="$HOME/.local/bin"; '
        'mkdir -p "$OUT"; '
        f"curl -L https://github.com/creativeprojects/resticprofile/releases/download/"
        f"v{version}/resticprofile_{version}_darwin_$(uname -m).tar.gz "
        '| tar xz -C "$OUT" --strip-components=1 resticprofile'
    )
    run_as_user(install_cmd)


def install_dankmono_font() -> None:
    """Download and install DankMono Nerd Font."""
    print_step("Installing DankMono Nerd Font")

    install_cmd = (
        'FONT_DIR="$HOME/Library/Fonts"; '
        'mkdir -p "$FONT_DIR/DankMono-Nerd-Font"; '
        "curl -sL https://github.com/saifulapm/my-fonts/archive/refs/heads/main.tar.gz "
        '| tar xz -C "$FONT_DIR/DankMono-Nerd-Font" --strip-components=2 '
        "'my-fonts-main/DankMono Nerd Font'"
    )
    run_as_user(install_cmd)


# ---------------------------------------------------------------------------
# Mac App Store (mas)
# ---------------------------------------------------------------------------

MAS_APPS: dict[str, int] = {
    "Xcode": 497799835,
    "Amphetamine": 937984704,
    "DaVinci Resolve": 571213070,
}


def install_mas_apps(manual: bool = False) -> None:
    """Install Mac App Store apps via mas."""
    print_step("Installing Mac App Store apps")

    if not command_exists("mas"):
        subprocess.run(["brew", "install", "mas"], check=True)

    for name, app_id in MAS_APPS.items():
        print(f"  Installing {name}...")
        subprocess.run(["mas", "install", str(app_id)], check=False)


# ---------------------------------------------------------------------------
# Shell setup
# ---------------------------------------------------------------------------


def configure_shell() -> None:
    """Set Homebrew zsh as the default shell if not already."""
    brew_prefix = get_brew_prefix()
    brew_zsh = f"{brew_prefix}/bin/zsh"

    if not os.path.exists(brew_zsh):
        print("  brew zsh not found, skipping shell change.")
        return

    # Check if brew zsh is in /etc/shells
    with open("/etc/shells") as f:
        shells = f.read()

    if brew_zsh not in shells:
        print(f"  Adding {brew_zsh} to /etc/shells...")
        subprocess.run(
            f"echo '{brew_zsh}' | sudo tee -a /etc/shells > /dev/null",
            shell=True,
            check=True,
        )

    # Change shell if not already brew zsh
    current_shell = os.environ.get("SHELL", "")
    if current_shell != brew_zsh:
        print(f"  Changing default shell to {brew_zsh}...")
        subprocess.run(["chsh", "-s", brew_zsh], check=False)


# ---------------------------------------------------------------------------
# Orchestration
# ---------------------------------------------------------------------------


def run_setup(args: argparse.Namespace, script_path: str) -> None:
    """Execute all setup steps, gated by flags."""

    # macOS defaults
    if args.defaults:
        configure_macos_defaults()

    # Homebrew packages (CLI tools)
    if not args.skip_brew:
        install_brew_packages(skip_brew=False, manual=args.manual)

    # GUI applications
    if args.gui:
        install_brew_casks(manual=args.manual)

    # Fonts
    if args.font:
        install_brew_fonts(manual=args.manual)
        install_dankmono_font()

    # Stow dotfiles
    if args.stow:
        extra_dirs = list(STOW_DIRS_GUI) if args.gui else []
        stow_dotfiles(script_path, extra_dirs)

    # Shell
    if args.stow:
        configure_shell()

    # Language runtimes
    if args.nvm:
        install_node_via_nvm(args.nvm)

    if args.go:
        configure_go()

    if args.rust:
        configure_rust()

    if args.pyenv:
        install_python_via_pyenv(args.pyenv)

    if args.php:
        install_php()

    # Theme / tools
    if args.k9s_theme:
        install_k9s_theme()

    if args.resticprofile:
        install_resticprofile(args.resticprofile)

    # Services
    if args.services:
        enable_services(manual=args.manual)

    # SSH
    if args.ssh:
        configure_ssh()

    # Mac App Store
    if args.mas:
        install_mas_apps(manual=args.manual)

    print_step("Setup complete")
    print("Remember to:")
    print("  1. Restart your terminal or run: exec zsh")
    print("  2. Reload .zshrc: source $ZDOTDIR/.zshrc")
    print("  3. Sign into iCloud for App Store apps (if --mas was used)")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "macOS setup script using Homebrew. "
            "Mirrors setup-archlinux.py for macOS environments."
        )
    )
    parser.add_argument(
        "--defaults",
        action="store_true",
        help="Apply macOS system preferences (Finder, Dock, etc.).",
    )
    parser.add_argument(
        "--stow",
        action="store_true",
        help="Stow dotfiles and configure zsh shell.",
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
        help="Install Nerd Fonts via homebrew/cask-fonts and DankMono.",
    )
    parser.add_argument(
        "--ssh",
        action="store_true",
        help="Enable SSH Remote Login.",
    )
    parser.add_argument(
        "--php",
        action="store_true",
        help="Install Composer and configure PHP extensions.",
    )
    parser.add_argument(
        "--services",
        action="store_true",
        help="Enable background services (docker, php).",
    )
    parser.add_argument(
        "--gui",
        action="store_true",
        help="Install GUI applications (browsers, editors, etc.).",
    )
    parser.add_argument(
        "--mas",
        action="store_true",
        help="Install Mac App Store apps via mas.",
    )
    parser.add_argument(
        "--skip-brew",
        action="store_true",
        help="Skip installing Homebrew packages.",
    )
    parser.add_argument(
        "--manual",
        action="store_true",
        help="Run all package installs interactively.",
    )
    return parser.parse_args()


def main() -> None:
    if platform.system() != "Darwin":
        print(
            f"Warning: This script is designed for macOS. Detected: {platform.system()}"
        )

    args = parse_args()

    reply = input("Continue with setup? [y/N]: ")
    if not reply.lower().startswith("y"):
        print("Setup canceled.")
        sys.exit(0)

    script_path = os.path.dirname(os.path.abspath(__file__))
    run_setup(args, script_path)


if __name__ == "__main__":
    main()
