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
    --brew             Install the base Homebrew CLI formulae
    --stow             Stow dotfiles without adopting conflicting local files
    --brew-zsh         Set Homebrew zsh as the login shell
    --xcode            Validate full Xcode for native/iOS development
    --nvm [VERSION]    Install NVM if needed and install Node (default: lts/krypton)
    --go               Install Go + gopls, configure GOMODCACHE
    --rust             Install rustup and set nightly as default toolchain
    --k9s-theme SHA    Install Catppuccin k9s theme from an immutable Git commit
    --resticprofile    Install resticprofile through Homebrew
    --pyenv [VERSION]  Install Python via pyenv (default: 3.13)
    --font             Install Nerd Fonts via Homebrew casks
    --ssh              Enable SSH (Remote Login)
    --php              Install PHP, Composer, configure php.ini extensions
    --services         Enable Colima; PHP is started only with --php
    --gui              Install GUI applications (browsers, editors, media, office)
    --mas              Install Mac App Store apps via mas (requires prior iCloud sign-in)
    --skip-brew        Skip Homebrew formula/cask installation
    --manual           Run package installs interactively (no --noconfirm equivalent)
"""

import argparse
import getpass
import os
import platform
import re
import shutil
import subprocess
import sys
import tempfile

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

NODE_VERSION = "lts/krypton"
PYENV_VERSION = "3.13"
NVM_VERSION = "v0.40.3"

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
    "jq",
    "yq",
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
    "lua",
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
    "helm",
    "zig",
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
    # Productivity
    "raycast",
    "alt-tab",
    "stats",
    # System audio EQ (replaces easyeffects on macOS)
    # "eqmac",
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
    ("com.apple.finder", "AppleShowAllFiles", "-bool", "true"),
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


def get_brew_bin() -> str:
    """Return Homebrew's executable without relying on the caller's PATH."""
    if brew_bin := shutil.which("brew"):
        return brew_bin
    for candidate in ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]:
        if os.path.isfile(candidate):
            return candidate
    raise RuntimeError("Homebrew is not installed or its executable cannot be found")



def run_as_user(cmd: str, *, cwd: str | None = None, env: dict[str, str] | None = None) -> None:
    """Run a shell command with an explicit environment."""
    subprocess.run(cmd, shell=True, check=True, cwd=cwd, executable="/bin/zsh", env=env)


def command_exists(name: str) -> bool:
    """Return True if *name* resolves to an executable on PATH."""
    return shutil.which(name) is not None


def require_version(value: str, pattern: str, flag: str) -> str:
    """Reject shell metacharacters in user-provided version arguments."""
    if not re.fullmatch(pattern, value):
        raise ValueError(f"{flag} has an unsupported version format: {value}")
    return value


def xdg_environment() -> dict[str, str]:
    """Return a process environment consistent with the shared dotfiles."""
    env = os.environ.copy()
    home_dir = os.path.expanduser("~")
    data_home = env.setdefault("XDG_DATA_HOME", f"{home_dir}/.local/share")
    env.setdefault("XDG_CONFIG_HOME", f"{home_dir}/.config")
    env.setdefault("XDG_CACHE_HOME", f"{home_dir}/.cache")
    env["CARGO_HOME"] = f"{data_home}/cargo"
    env["RUSTUP_HOME"] = f"{data_home}/rustup"
    env["PATH"] = f"{env['CARGO_HOME']}/bin:{env['PATH']}"
    return env


def run_brew(args: list[str], **kwargs: object) -> subprocess.CompletedProcess[bytes]:
    """Run Homebrew using its resolved executable path."""
    return subprocess.run([get_brew_bin(), *args], check=True, **kwargs)


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
    try:
        get_brew_bin()
    except RuntimeError:
        pass
    else:
        print("Homebrew already installed.")
        return
    print_step("Installing Homebrew")
    cmd = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    subprocess.run(cmd, shell=True, check=True)
    get_brew_bin()


def install_brew_packages(skip_brew: bool = False, manual: bool = False) -> None:
    """Install Homebrew formula packages."""
    if skip_brew:
        return

    ensure_homebrew(manual)

    print_step("Updating Homebrew")
    run_brew(["update"])

    install_cmd = ["install"]
    if not manual:
        install_cmd += ["--quiet", "--no-ask"]

    print_step("Installing Homebrew formulae (CLI tools)")
    run_brew(install_cmd + BREW_FORMULAE)


def install_brew_casks(manual: bool = False) -> None:
    """Install GUI applications via Homebrew casks."""
    ensure_homebrew(manual)

    install_cmd = ["install", "--cask"]
    if not manual:
        install_cmd += ["--quiet", "--no-ask"]

    print_step("Installing GUI applications (casks)")
    run_brew(install_cmd + BREW_CASKS)


def install_brew_fonts(manual: bool = False) -> None:
    """Install Nerd Fonts via homebrew/cask-fonts."""
    ensure_homebrew(manual)

    install_cmd = ["install", "--cask"]
    if not manual:
        install_cmd += ["--quiet", "--no-ask"]

    print_step("Installing Nerd Fonts")
    run_brew(install_cmd + BREW_FONTS)


# ---------------------------------------------------------------------------
# macOS system configuration
# ---------------------------------------------------------------------------


def ensure_xcode_cli_tools() -> None:
    """Install Xcode Command Line Tools if not already present."""
    if subprocess.run(["xcode-select", "-p"], capture_output=True).returncode != 0:
        print_step("Installing Xcode Command Line Tools")
        subprocess.run(["xcode-select", "--install"], check=False)
        print("  Please complete the installation and re-run this script.")
        sys.exit(0)


def ensure_full_xcode() -> None:
    """Validate that full Xcode, not only Command Line Tools, is active."""
    developer_dir = subprocess.check_output(["xcode-select", "-p"], text=True).strip()
    if not developer_dir.endswith("/Contents/Developer"):
        raise RuntimeError(
            "Full Xcode is required. Install it from the App Store, then run "
            "sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer."
        )
    subprocess.run(["xcodebuild", "-version"], check=True)


def configure_macos_defaults() -> None:
    """Apply macOS system preferences via defaults write."""
    print_step("Configuring macOS system preferences")

    for domain, key, typ, value in MACOS_DEFAULTS:
        subprocess.run(["defaults", "write", domain, key, typ, value], check=True)

    # Screenshot location
    screenshots_dir = os.path.expanduser("~/Pictures/Screenshots")
    os.makedirs(screenshots_dir, exist_ok=True)
    subprocess.run(
        ["defaults", "write", "com.apple.screencapture", "location", "-string", screenshots_dir],
        check=True,
    )

    # Trackpad: tap to click
    subprocess.run(
        ["defaults", "write", "com.apple.AppleMultitouchTrackpad", "Clicking", "-bool", "true"],
        check=True,
    )

    # Restart affected apps
    subprocess.run(["killall", "Finder"], check=False)
    subprocess.run(["killall", "Dock"], check=False)


def configure_ssh() -> None:
    """Enable SSH Remote Login on macOS."""
    print_step("Enabling SSH (Remote Login)")
    subprocess.run(
        ["sudo", "systemsetup", "-setremotelogin", "on"],
        check=True,
    )


def configure_touchid_sudo() -> None:
    """Enable Touch ID for sudo authentication (macOS Sonoma+)."""
    print_step("Configuring Touch ID for sudo")
    pam_path = "/etc/pam.d/sudo_local"
    if os.path.exists(pam_path):
        with open(pam_path) as f:
            if "pam_tid.so" in f.read():
                print("  Touch ID already configured")
                return
    tmp = tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".pam")
    tmp.write("# sudo_local: local config for sudo\n")
    tmp.write("auth       sufficient     pam_tid.so\n")
    tmp.close()
    try:
        subprocess.run(["sudo", "cp", tmp.name, pam_path], check=True)
        subprocess.run(["sudo", "chmod", "444", pam_path], check=True)
    finally:
        os.unlink(tmp.name)


# ---------------------------------------------------------------------------
# Service management (brew services / launchctl)
# ---------------------------------------------------------------------------

BREW_SERVICES: list[str] = [
    "php",
    "colima",
]


def configure_colima() -> None:
    """Switch Docker context to colima so docker CLI works."""
    subprocess.run(
        ["docker", "context", "use", "colima"],
        check=True,
        capture_output=True,
    )


def enable_services(services: list[str]) -> None:
    """Start and enable background services via brew services."""
    print_step("Enabling background services")

    for service in services:
        print(f"  Starting {service}...")
        run_brew(["services", "start", service])


# ---------------------------------------------------------------------------
# Language runtimes
# ---------------------------------------------------------------------------


def install_node_via_nvm(node_version: str) -> None:
    """Install/upgrade nvm and install node."""
    node_version = require_version(node_version, r"(?:lts/[a-z]+|v?\d+(?:\.\d+){0,2})", "--nvm")
    print_step(f"Installing Node via nvm ({node_version})")

    # Keep NVM aligned with the shared XDG-based zsh configuration.
    xdg_data_home = os.environ.get(
        "XDG_DATA_HOME", os.path.expanduser("~/.local/share")
    )
    nvm_dir = os.path.join(xdg_data_home, "nvm")
    nvm_sh = os.path.join(nvm_dir, "nvm.sh")
    nvm_env = os.environ.copy()
    nvm_env["NVM_DIR"] = nvm_dir

    if not os.path.exists(nvm_sh):
        subprocess.run(
            f"curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/{NVM_VERSION}/install.sh | bash",
            shell=True,
            check=True,
            env=nvm_env,
        )

    nvm_cmds = (
        f". {nvm_sh} && "
        f"nvm install {node_version} && "
        # Store the resolved semantic version, not a shorthand such as 24.18.
        f"nvm alias default \"$(nvm version {node_version})\" && "
        f"nvm use default && "
        f"npm install npm@latest yarn@latest pnpm@latest --location=global"
    )
    subprocess.run(
        nvm_cmds, shell=True, check=True, executable="/bin/zsh", env=nvm_env
    )


def configure_go() -> None:
    """Install gopls and set GOMODCACHE to the XDG cache directory."""
    if not command_exists("go"):
        ensure_homebrew()
        run_brew(["install", "go"])
    print_step("Configuring Go")
    go_env = xdg_environment()
    run_as_user("go install golang.org/x/tools/gopls@latest", env=go_env)
    run_as_user('go env -w GOMODCACHE="$XDG_CACHE_HOME/go/pkg/mod"', env=go_env)


def configure_rust() -> None:
    """Install rustup if missing and set nightly as default."""
    print_step("Configuring Rust")

    rust_env = xdg_environment()
    rustup_bin = os.path.join(rust_env["CARGO_HOME"], "bin", "rustup")
    if not os.path.exists(rustup_bin):
        subprocess.run(
            "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y",
            shell=True,
            check=True,
            env=rust_env,
        )

    subprocess.run([rustup_bin, "toolchain", "install", "nightly"], check=True, env=rust_env)
    subprocess.run([rustup_bin, "default", "nightly"], check=True, env=rust_env)


def install_python_via_pyenv(pyenv_version: str) -> None:
    """Install Python via pyenv, set global, install pip and uv packages."""
    pyenv_version = require_version(pyenv_version, r"\d+\.\d+(?:\.\d+)?", "--pyenv")
    print_step(f"Installing Python {pyenv_version} via pyenv")

    if not command_exists("pyenv"):
        run_brew(["install", "pyenv"])

    pyenv_bin = shutil.which("pyenv")
    if not pyenv_bin:
        raise RuntimeError("pyenv was installed but is not available on PATH")
    subprocess.run([pyenv_bin, "install", "--skip-existing", pyenv_version], check=True)
    subprocess.run([pyenv_bin, "global", pyenv_version], check=True)
    python_bin = subprocess.check_output([pyenv_bin, "which", "python"], text=True).strip()

    subprocess.run([python_bin, "-m", "pip", "install", *PIP3_PKGS], check=True)
    subprocess.run([python_bin, "-m", "pip", "install", *PIP3_PKGS_EXTRA], check=True)

    for tool in UV_TOOLS:
        subprocess.run([python_bin, "-m", "uv", "tool", "install", tool], check=True)


def install_php() -> None:
    """Install PHP extensions via pecl and configure php.ini."""
    if not command_exists("php"):
        ensure_homebrew()
        run_brew(["install", "php"])

    print_step("Configuring PHP")

    if not command_exists("composer"):
        run_brew(["install", "composer"])

    subprocess.run(["pecl", "install", "xdebug"], check=True)

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
                check=True,
            )


# ---------------------------------------------------------------------------
# Dotfiles (stow)
# ---------------------------------------------------------------------------


def stow_dotfiles(script_path: str, extra_dirs: list[str] | None = None) -> None:
    """Create required local dirs and stow all dotfile directories."""
    print_step("Stowing dotfiles")

    os.makedirs(os.path.expanduser("~/.local/bin"), exist_ok=True)
    os.makedirs(os.path.expanduser("~/.local/share/fonts"), exist_ok=True)

    all_dirs = [directory for directory in STOW_DIRS if directory != "zsh"] + (extra_dirs or [])

    for stow_dir in all_dirs:
        print(f"  Stowing {stow_dir}")
        subprocess.run(
            ["stow", "--restow", stow_dir],
            check=True,
            cwd=script_path,
        )

    # Link zsh config last after env is loaded
    subprocess.run(
        ["stow", "--restow", "zsh"],
        check=True,
        cwd=script_path,
    )


# ---------------------------------------------------------------------------
# Theme / misc
# ---------------------------------------------------------------------------


def install_k9s_theme(revision: str) -> None:
    """Install the Catppuccin k9s skins from an immutable Git revision."""
    revision = require_version(revision, r"[0-9a-f]{40}", "--k9s-theme")
    print_step(f"Installing k9s catppuccin theme ({revision[:12]})")
    output_dir = os.path.join(
        os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config")),
        "k9s",
        "skins",
    )
    with tempfile.TemporaryDirectory(prefix="k9s-theme-") as temp_dir:
        repository_dir = os.path.join(temp_dir, "k9s")
        subprocess.run(
            ["git", "clone", "--no-checkout", "https://github.com/catppuccin/k9s.git", repository_dir],
            check=True,
        )
        subprocess.run(["git", "-C", repository_dir, "checkout", "--detach", revision], check=True)
        shutil.copytree(os.path.join(repository_dir, "dist"), output_dir, dirs_exist_ok=True)


def install_resticprofile() -> None:
    """Install resticprofile through Homebrew to avoid duplicate binaries."""
    print_step("Installing resticprofile")
    ensure_homebrew()
    run_brew(["install", "resticprofile"])


# ---------------------------------------------------------------------------
# Mac App Store (mas)
# ---------------------------------------------------------------------------

MAS_APPS: dict[str, int] = {
    "Xcode": 497799835,
    "Amphetamine": 937984704,
    "DaVinci Resolve": 571213070,
}


def install_mas_apps() -> None:
    """Install Mac App Store apps via mas."""
    print_step("Installing Mac App Store apps")

    if not command_exists("mas"):
        ensure_homebrew()
        run_brew(["install", "mas"])

    for name, app_id in MAS_APPS.items():
        print(f"  Installing {name}...")
        subprocess.run(["mas", "install", str(app_id)], check=True)


# ---------------------------------------------------------------------------
# Shell setup
# ---------------------------------------------------------------------------


def configure_shell() -> None:
    """Set Homebrew zsh as the default shell if not already."""
    brew_zsh = os.path.join(os.path.dirname(get_brew_bin()), "zsh")

    if not os.path.exists(brew_zsh):
        print("  brew zsh not found, skipping shell change.")
        return

    # Check if brew zsh is in /etc/shells
    with open("/etc/shells") as f:
        shells = f.read().splitlines()

    if brew_zsh not in shells:
        print(f"  Adding {brew_zsh} to /etc/shells...")
        subprocess.run(
            f"echo '{brew_zsh}' | sudo tee -a /etc/shells > /dev/null",
            shell=True,
            check=True,
        )

    # Change shell if not already brew zsh
    current_shell = subprocess.check_output(
        ["dscl", ".", "-read", f"/Users/{getpass.getuser()}", "UserShell"], text=True
    ).split()[-1]
    if current_shell != brew_zsh:
        print(f"  Changing default shell to {brew_zsh}...")
        subprocess.run(["chsh", "-s", brew_zsh], check=True)


# ---------------------------------------------------------------------------
# Orchestration
# ---------------------------------------------------------------------------


def run_setup(args: argparse.Namespace, script_path: str) -> None:
    """Execute all setup steps, gated by flags."""

    # Xcode CLI tools (prerequisite for most things)
    ensure_xcode_cli_tools()

    if args.xcode:
        ensure_full_xcode()

    # macOS defaults
    if args.defaults:
        configure_macos_defaults()

    if args.touchid_sudo:
        configure_touchid_sudo()

    # Base formulae are opt-in. Languages and containers are installed only by
    # their matching flags below.
    if args.brew and not args.skip_brew:
        install_brew_packages(skip_brew=False, manual=args.manual)

    # GUI applications
    if args.gui:
        install_brew_casks(manual=args.manual)

    # Fonts
    if args.font:
        install_brew_fonts(manual=args.manual)

    # Stow dotfiles
    if args.stow:
        extra_dirs = list(STOW_DIRS_GUI) if args.gui else []
        stow_dotfiles(script_path, extra_dirs)

    # Shell
    if args.brew_zsh:
        ensure_homebrew(args.manual)
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
        install_k9s_theme(args.k9s_theme)

    if args.resticprofile:
        install_resticprofile()

    # Services
    if args.services:
        ensure_homebrew(args.manual)
        run_brew(["install", "docker", "colima"])
        services = ["colima"]
        if args.php:
            services.insert(0, "php")
        enable_services(services)
        configure_colima()

    # SSH
    if args.ssh:
        configure_ssh()

    # Mac App Store
    if args.mas:
        install_mas_apps()

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
        "--brew",
        action="store_true",
        help="Install the base Homebrew CLI formulae.",
    )
    parser.add_argument(
        "--defaults",
        action="store_true",
        help="Apply macOS system preferences (Finder, Dock, etc.).",
    )
    parser.add_argument(
        "--stow",
        action="store_true",
        help="Stow dotfiles without adopting conflicting local files.",
    )
    parser.add_argument(
        "--brew-zsh",
        action="store_true",
        help="Set Homebrew zsh as the login shell.",
    )
    parser.add_argument(
        "--xcode",
        action="store_true",
        help="Validate that full Xcode is installed and selected.",
    )
    parser.add_argument(
        "--nvm",
        type=str,
        nargs="?",
        const=NODE_VERSION,
        default=None,
        help=f"Install NVM if needed and install Node (default: {NODE_VERSION}).",
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
        dest="k9s_theme",
        metavar="SHA",
        help="Install Catppuccin k9s theme from an immutable 40-character Git SHA.",
    )
    parser.add_argument(
        "--resticprofile",
        action="store_true",
        help="Install resticprofile through Homebrew.",
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
        help="Install Nerd Fonts via Homebrew casks.",
    )
    parser.add_argument(
        "--touchid-sudo",
        action="store_true",
        dest="touchid_sudo",
        help="Enable Touch ID authentication for sudo.",
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
        help="Enable Colima; PHP is started only when --php is also given.",
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
        help="Deprecated compatibility flag; base formulae are opt-in via --brew.",
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
