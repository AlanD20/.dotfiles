#!/usr/bin/env python3
"""
macOS 26/27 setup script using Homebrew. Requires Python 3.9 or newer.

Mirrors setup-archlinux.py for macOS environments. Homebrew is the primary
package manager; casks are used for GUI applications and fonts,
and background services via brew services / launchctl.

Does NOT require root (Homebrew is user-level by design), though a few
operations (SSH, shell) prompt for sudo when needed.

Running without flags asks yes/no questions before making changes. Flags answer
the corresponding question: --brew selects installation, while keyboard skip
flags leave those settings unchanged. Unanswered options prompt with a default
of no. Log out and back in after changing keyboard preferences.

Usage:
    python3 setup-macos.py [flags]

Flags:
    --brew             Install the base Homebrew CLI formulae
    --skip-disable-macos-shortcuts  Leave the current keyboard shortcuts unchanged
    --skip-fast-key-repeat         Leave the current repeat/delay settings unchanged
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
    --manual           Run package installs interactively (no --noconfirm equivalent)
"""

from __future__ import annotations

import argparse
import getpass
import json
import os
import platform
import plistlib
import re
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

NODE_VERSION = "lts/krypton"
PYENV_VERSION = "3.13"
NVM_VERSION = "v0.40.7"

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
    "ghostty",
    "atuin",
    "containers",
    "git",
    "gnupg",
    "htop",
    "keepassxc",
    "k9s",
    "lazygit",
    "lazyvim",
    "mpv",
    "oh-my-posh",
    "herdr",
    "tmux",
    "wallpapers",
    "zsh",
]

# ---------------------------------------------------------------------------
# Homebrew formula packages (CLI tools)
# ---------------------------------------------------------------------------

# Added by --brew before updating and installing formulae.
BREW_TAPS: list[str] = [
    "hashicorp/tap",
]

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
    "herdr",
    # CLI tools
    "k9s",
    "colima",
    "docker",
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
    "unar",
    "exiftool",
    "imagemagick",
    "mpv",
    "mupdf",
    # Dev & build
    "lua",
    "hashicorp/tap/terraform",
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
    # Font utilities
    "woff2",
]

# ---------------------------------------------------------------------------
# Homebrew cask packages (GUI applications)
# ---------------------------------------------------------------------------

BREW_CASKS: list[str] = [
    "ghostty",
    "alacritty",
    "firefox",
    "google-chrome",
    "visual-studio-code",
    "discord",
    "spotify",
    "obs",
    "vorssaint",
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
# Homebrew font casks (Nerd Fonts)
# ---------------------------------------------------------------------------

BREW_FONTS: list[str] = [
    "font-meslo-lg-nerd-font",
    "font-jetbrains-mono-nerd-font",
    "font-fira-code-nerd-font",
    "font-hack-nerd-font",
    "font-noto-emoji",
]

# ---------------------------------------------------------------------------
# macOS system preferences (defaults write)
# ---------------------------------------------------------------------------

KEYBOARD_DEFAULTS: list[tuple[str, str, str, str]] = [
    ("NSGlobalDomain", "ApplePressAndHoldEnabled", "-bool", "false"),
    ("NSGlobalDomain", "KeyRepeat", "-int", "2"),
    ("NSGlobalDomain", "InitialKeyRepeat", "-int", "15"),
]

MACOS_DEFAULTS: list[tuple[str, str, str, str]] = [
    # (domain, key, type, value)
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

# System action IDs, independent of the assigned key combination. Include the
# clipboard, Touch Bar, recording, and visual-intelligence capture variants.
# Source: https://gist.github.com/stephancasas/2c8e8f71e23ec7221495d7f4b9efb794
# Show Apps: https://git.billygeorge.net/billy.george/dotfiles/commit/c37c58cb78ba7c9fc9b29d0649654ced77e65ab7
MACOS_SHORTCUTS: dict[str, str] = {
    "28": "Save picture of screen",
    "29": "Copy picture of screen",
    "30": "Save picture of selected area",
    "31": "Copy picture of selected area",
    "181": "Save picture of Touch Bar",
    "182": "Copy picture of Touch Bar",
    "184": "Screenshot and recording options",
    "185": "Screenshot and recording clipboard variant",
    "261": "Capture for visual intelligence",
    "262": "Copy capture for visual intelligence",
    "263": "Capture top window for visual intelligence",
    "264": "Copy top window for visual intelligence",
    "160": "Show Apps",
    "64": "Show Spotlight search",
    "190": "Quick Note",
}

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


def run_as_user(
    cmd: str, *, cwd: str | None = None, env: dict[str, str] | None = None
) -> None:
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
    """Install Homebrew if absent and expose its tools to this setup process."""
    try:
        brew_bin = get_brew_bin()
    except RuntimeError:
        print_step("Installing Homebrew")
        # Keep the official installer's confirmation/password prompts. A failed
        # download must stop here, before attempting to execute the installer.
        with tempfile.TemporaryDirectory(prefix="homebrew-install-") as temp_dir:
            installer = os.path.join(temp_dir, "install.sh")
            subprocess.run(
                [
                    "/usr/bin/curl",
                    "-fsSL",
                    "--output",
                    installer,
                    "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh",
                ],
                check=True,
            )
            subprocess.run(["/bin/bash", installer], check=True)
        brew_bin = get_brew_bin()
    else:
        print("Homebrew already installed.")

    prefix = subprocess.check_output([brew_bin, "--prefix"], text=True).strip()
    if not os.path.isabs(prefix):
        raise RuntimeError(f"Homebrew returned an invalid prefix: {prefix!r}")
    brew_paths = [os.path.join(prefix, "bin"), os.path.join(prefix, "sbin")]
    other_paths = [
        path
        for path in os.environ.get("PATH", "").split(os.pathsep)
        if path not in brew_paths
    ]
    os.environ["HOMEBREW_PREFIX"] = prefix
    os.environ["PATH"] = os.pathsep.join(brew_paths + other_paths)


def install_brew_packages(manual: bool = False) -> None:
    """Install Homebrew formula packages."""
    ensure_homebrew(manual)

    for tap in BREW_TAPS:
        print_step(f"Adding Homebrew tap: {tap}")
        run_brew(["tap", tap])

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
    """Install Nerd Fonts via Homebrew casks."""
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


def read_preferences(domain: str) -> dict:
    """Read through defaults so cached preferences and fresh accounts work."""
    result = subprocess.run(
        ["/usr/bin/defaults", "export", domain, "-"],
        capture_output=True,
        env={**os.environ, "LC_ALL": "C"},
    )
    if result.returncode:
        # A fresh account may not have any overrides in this domain yet.
        if b"does not exist" in result.stderr:
            return {}
        raise RuntimeError(
            f"Cannot read {domain}: {result.stderr.decode(errors='replace').strip()}"
        )
    preferences = plistlib.loads(result.stdout)
    if not isinstance(preferences, dict):
        raise RuntimeError(f"Expected a preference dictionary for {domain}")
    return preferences


def preference_dictionary(preferences: dict, key: str) -> dict:
    value = preferences.get(key, {})
    if not isinstance(value, dict):
        raise RuntimeError(f"Expected a dictionary for {key}; no changes made")
    return value


def plist_argument(value: object) -> str:
    """Serialize a defaults value without shell interpolation or a plist wrapper."""
    return ET.tostring(ET.fromstring(plistlib.dumps(value))[0], encoding="unicode")


def logout_menu_titles() -> list[str]:
    """Resolve Log Out titles using AppKit and the account's display name."""
    # Loading AppKit/Foundation does not require Accessibility or Automation
    # access. No UI scripting, keystrokes, or logout actions are performed.
    script = r"""
ObjC.import('AppKit');
var bundle = $.NSBundle.bundleWithIdentifier('com.apple.AppKit');
var fullName = ObjC.unwrap($.NSFullUserName());
var titles = [];
['Log Out', 'Log Out %@', 'Log Out…', 'Log Out...', 'Log Out %@…', 'Log Out %@...'].forEach(function(key) {
    var localized = ObjC.unwrap(bundle.localizedStringForKeyValueTable(
        key, key, 'MenuCommands'));
    [key, localized].forEach(function(title) {
        title = title.replace('%@', fullName);
        // Menu resources may add the ellipsis after substituting the name.
        if (!/[….]$/.test(title)) title += '…';
        if (titles.indexOf(title) === -1) titles.push(title);
    });
});
JSON.stringify(titles);
"""
    titles = json.loads(
        subprocess.check_output(
            ["/usr/bin/osascript", "-l", "JavaScript", "-e", script],
            text=True,
        )
    )
    if (
        not isinstance(titles, list)
        or not titles
        or any(not isinstance(title, str) or not title for title in titles)
    ):
        raise RuntimeError("Could not resolve the Log Out menu title")
    return titles


def disable_macos_shortcuts() -> None:
    """Disable the selected actions, preserving unrelated keys and bindings."""
    print_step("Disabling macOS shortcuts (opt out: --skip-disable-macos-shortcuts)")
    domain = "com.apple.symbolichotkeys"
    preferences = read_preferences(domain)
    hotkeys = preference_dictionary(preferences, "AppleSymbolicHotKeys")
    updates = {}
    for hotkey_id, label in MACOS_SHORTCUTS.items():
        current = preference_dictionary(hotkeys, hotkey_id)
        if current.get("enabled") is not False:
            # Keep custom key combinations and any future fields on the entry.
            updates[hotkey_id] = {**current, "enabled": False}
        print(f"  {label}")

    global_preferences = read_preferences("NSGlobalDomain")
    equivalents = preference_dictionary(global_preferences, "NSUserKeyEquivalents")
    # A non-keyboard character removes Cmd+Shift+Q while retaining the menu
    # action. Do not disable ForceLogout or remove Log Out from the Apple menu.
    logout_updates = {
        title: "\u200b"
        for title in logout_menu_titles()
        if equivalents.get(title) != "\u200b"
    }
    if not updates and not logout_updates:
        print("  Shortcut preferences already configured.")
        return

    backup_root = os.path.expanduser("~/Library/Application Support/dotfiles/backups")
    os.makedirs(backup_root, mode=0o700, exist_ok=True)
    backup_dir = tempfile.mkdtemp(prefix="macos-shortcuts-", dir=backup_root)
    for name, original in [
        (domain, preferences),
        ("NSGlobalDomain", global_preferences),
    ]:
        path = os.path.join(backup_dir, f"{name}.plist")
        with open(path, "xb") as backup:
            os.chmod(path, 0o600)
            plistlib.dump(original, backup)
    print(f"  Preference snapshots: {backup_dir}")

    if updates:
        command = [
            "/usr/bin/defaults",
            "write",
            domain,
            "AppleSymbolicHotKeys",
            "-dict-add",
        ]
        for hotkey_id, entry in updates.items():
            command.extend([hotkey_id, plist_argument(entry)])
        subprocess.run(command, check=True)
    if logout_updates:
        command = [
            "/usr/bin/defaults",
            "write",
            "NSGlobalDomain",
            "NSUserKeyEquivalents",
            "-dict-add",
        ]
        for title, value in logout_updates.items():
            # Quote the value as a plist string, not as shell code.
            command.extend([title, plist_argument(value)])
        subprocess.run(command, check=True)

    saved = preference_dictionary(read_preferences(domain), "AppleSymbolicHotKeys")
    saved_equivalents = preference_dictionary(
        read_preferences("NSGlobalDomain"), "NSUserKeyEquivalents"
    )
    if any(saved.get(key) != value for key, value in updates.items()) or any(
        saved_equivalents.get(key) != value for key, value in logout_updates.items()
    ):
        raise RuntimeError(
            f"Shortcut preferences did not persist; backups: {backup_dir}"
        )
    print("  Preferences saved. Log out and back in to activate all shortcut changes.")


def configure_macos_defaults() -> None:
    """Apply macOS system preferences via defaults write."""
    print_step("Configuring macOS system preferences")

    for domain, key, typ, value in MACOS_DEFAULTS:
        subprocess.run(["defaults", "write", domain, key, typ, value], check=True)

    # Screenshot location
    screenshots_dir = os.path.expanduser("~/Pictures/Screenshots")
    os.makedirs(screenshots_dir, exist_ok=True)
    subprocess.run(
        [
            "defaults",
            "write",
            "com.apple.screencapture",
            "location",
            "-string",
            screenshots_dir,
        ],
        check=True,
    )

    # Trackpad: tap to click
    subprocess.run(
        [
            "defaults",
            "write",
            "com.apple.AppleMultitouchTrackpad",
            "Clicking",
            "-bool",
            "true",
        ],
        check=True,
    )

    # Restart affected apps
    subprocess.run(["killall", "Finder"], check=False)
    subprocess.run(["killall", "Dock"], check=False)


def configure_fast_key_repeat() -> None:
    """Use fast repeat and a short initial delay instead of press-and-hold accents."""
    print_step("Configuring fast key repeat (KeyRepeat=2, InitialKeyRepeat=15)")
    for domain, key, typ, value in KEYBOARD_DEFAULTS:
        subprocess.run(
            ["/usr/bin/defaults", "write", domain, key, typ, value], check=True
        )


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
    content = ""
    if os.path.exists(pam_path):
        with open(pam_path) as f:
            content = f.read()
            if re.search(
                r"^\s*auth\s+\S+\s+pam_tid\.so(?:\s|$)", content, re.MULTILINE
            ):
                print("  Touch ID already configured")
                return
    tmp = tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".pam")
    tmp.write("auth       sufficient     pam_tid.so\n" + content)
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
    node_version = require_version(
        node_version, r"(?:lts/[a-z]+|v?\d+(?:\.\d+){0,2})", "--nvm"
    )
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
        f'nvm alias default "$(nvm version {node_version})" && '
        f"nvm use default && "
        f"npm install npm@latest yarn@latest pnpm@latest --location=global"
    )
    subprocess.run(nvm_cmds, shell=True, check=True, executable="/bin/zsh", env=nvm_env)


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

    subprocess.run(
        [rustup_bin, "toolchain", "install", "nightly"], check=True, env=rust_env
    )
    subprocess.run([rustup_bin, "default", "nightly"], check=True, env=rust_env)


def install_python_via_pyenv(pyenv_version: str) -> None:
    """Install Python via pyenv, set global, install pip and uv packages."""
    pyenv_version = require_version(pyenv_version, r"\d+\.\d+(?:\.\d+)?", "--pyenv")
    print_step(f"Installing Python {pyenv_version} via pyenv")

    ensure_homebrew()
    if not command_exists("pyenv"):
        run_brew(["install", "pyenv"])

    pyenv_bin = shutil.which("pyenv")
    if not pyenv_bin:
        raise RuntimeError("pyenv was installed but is not available on PATH")
    subprocess.run([pyenv_bin, "install", "--skip-existing", pyenv_version], check=True)
    subprocess.run([pyenv_bin, "global", pyenv_version], check=True)
    python_bin = subprocess.check_output(
        [pyenv_bin, "which", "python"], text=True
    ).strip()

    subprocess.run([python_bin, "-m", "pip", "install", *PIP3_PKGS], check=True)
    subprocess.run([python_bin, "-m", "pip", "install", *PIP3_PKGS_EXTRA], check=True)

    for tool in UV_TOOLS:
        subprocess.run([python_bin, "-m", "uv", "tool", "install", tool], check=True)


def install_php() -> None:
    """Match Arch's PHP extensions using Homebrew PHP and PECL."""
    ensure_homebrew()
    print_step("Installing PHP and extensions")
    run_brew(["install", "php", "composer"])

    # Do not accidentally build extensions against another PHP on PATH.
    prefix = run_brew(
        ["--prefix", "php"], capture_output=True, text=True
    ).stdout.strip()
    php_bin = os.path.join(prefix, "bin", "php")
    pecl_bin = os.path.join(prefix, "bin", "pecl")
    env = os.environ.copy()
    env["PATH"] = os.path.join(prefix, "bin") + os.pathsep + env.get("PATH", "")
    env["PHP_PEAR_PHP_BIN"] = php_bin
    # Configure this Homebrew installation, independent of shell INI overrides.
    env.pop("PHPRC", None)
    env.pop("PHP_INI_SCAN_DIR", None)

    def loaded_extensions() -> set[str]:
        return set(
            subprocess.check_output([php_bin, "-m"], text=True, env=env)
            .lower()
            .splitlines()
        )

    paths = json.loads(
        subprocess.check_output(
            [
                php_bin,
                "-r",
                'echo json_encode([ini_get("extension_dir"), PHP_CONFIG_FILE_SCAN_DIR]);',
            ],
            text=True,
            env=env,
        )
    )
    extension_dir, scan_dir = paths
    if not os.path.isabs(extension_dir) or not os.path.isabs(scan_dir):
        raise RuntimeError(f"Unexpected Homebrew PHP extension/config paths: {paths!r}")
    os.makedirs(scan_dir, exist_ok=True)

    # Homebrew compiles the standard extensions into PHP. Only these need PECL.
    # Arch's Redis package depends on igbinary; load it before Redis here too.
    for name, directive, options in (
        ("igbinary", "extension", []),
        ("redis", "extension", ["--configureoptions=enable-redis-igbinary='yes'"]),
        ("xdebug", "zend_extension", []),
    ):
        if name in loaded_extensions():
            continue
        if not os.path.isfile(os.path.join(extension_dir, f"{name}.so")):
            subprocess.run(
                [pecl_bin, "install", "--force", *options, name],
                input="\n" * 20,
                text=True,
                check=True,
                env=env,
            )
        # PECL may enable the module itself. Avoid adding a duplicate directive.
        if name not in loaded_extensions():
            with open(
                os.path.join(scan_dir, f"{name}.ini"), "a", encoding="utf-8"
            ) as f:
                f.write(f"\n{directive}={name}.so\n")

    required = {
        "bcmath",
        "exif",
        "fileinfo",
        "gd",
        "iconv",
        "igbinary",
        "intl",
        "mbstring",
        "mysqli",
        "openssl",
        "pdo_mysql",
        "pdo_pgsql",
        "pdo_sqlite",
        "pgsql",
        "redis",
        "snmp",
        "sockets",
        "sodium",
        "sqlite3",
        "xdebug",
        "xsl",
    }
    missing = required - loaded_extensions()
    if missing:
        raise RuntimeError(
            f"PHP extensions failed to load: {', '.join(sorted(missing))}"
        )


# ---------------------------------------------------------------------------
# Dotfiles (stow)
# ---------------------------------------------------------------------------


def stow_dotfiles(script_path: str, extra_dirs: list[str] | None = None) -> None:
    """Create required local dirs and stow all dotfile directories."""
    print_step("Stowing dotfiles")

    if not command_exists("stow"):
        ensure_homebrew()
        if not command_exists("stow"):
            run_brew(["install", "stow"])

    os.makedirs(os.path.expanduser("~/.local/bin"), exist_ok=True)
    os.makedirs(os.path.expanduser("~/.local/share/fonts"), exist_ok=True)
    os.makedirs(os.path.expanduser("~/.gnupg"), mode=0o700, exist_ok=True)

    all_dirs = [directory for directory in STOW_DIRS if directory != "zsh"] + (
        extra_dirs or []
    )

    target = os.path.expanduser("~")
    # Keep directories real so new keys, caches, histories, and app state remain
    # in HOME rather than being created under a directory symlink into the repo.
    stow = ["stow", "--target", target, "--no-folding", "--restow"]
    subprocess.run(
        [*stow, "--simulate", *all_dirs, "zsh"],
        check=True,
        cwd=script_path,
    )

    for stow_dir in all_dirs:
        print(f"  Stowing {stow_dir}")
        subprocess.run(
            [*stow, stow_dir],
            check=True,
            cwd=script_path,
        )

    # Link zsh config last after env is loaded
    subprocess.run(
        [*stow, "zsh"],
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
            [
                "git",
                "clone",
                "--no-checkout",
                "https://github.com/catppuccin/k9s.git",
                repository_dir,
            ],
            check=True,
        )
        subprocess.run(
            ["git", "-C", repository_dir, "checkout", "--detach", revision], check=True
        )
        shutil.copytree(
            os.path.join(repository_dir, "dist"), output_dir, dirs_exist_ok=True
        )


def install_resticprofile() -> None:
    """Install resticprofile through Homebrew to avoid duplicate binaries."""
    print_step("Installing resticprofile")
    ensure_homebrew()
    run_brew(["install", "resticprofile"])


# ---------------------------------------------------------------------------
# Mac App Store (mas)
# ---------------------------------------------------------------------------

# Find IDs with: mas search "App Name" (or mas list for installed apps).
# Alternatively, copy the number after "id" in the app's App Store URL.
MAS_APPS: dict[str, int] = {
    "Xcode": 497799835,
    # "DaVinci Resolve": 571213070,
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
        run_brew(["install", "zsh"])

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

    if not args.skip_disable_macos_shortcuts:
        disable_macos_shortcuts()
    if not args.skip_fast_key_repeat:
        configure_fast_key_repeat()

    # Preference-only runs need neither Homebrew nor developer tools.
    if any(
        (
            args.brew,
            args.gui,
            args.font,
            args.brew_zsh,
            args.xcode,
            args.nvm,
            args.go,
            args.rust,
            args.pyenv,
            args.php,
            args.k9s_theme,
            args.resticprofile,
            args.services,
            args.mas,
        )
    ):
        ensure_xcode_cli_tools()

    if args.xcode:
        ensure_full_xcode()

    # macOS defaults
    if args.defaults:
        configure_macos_defaults()

    if args.touchid_sudo:
        configure_touchid_sudo()

    # Base formulae are selected via --brew or its prompt.
    if args.brew:
        install_brew_packages(manual=args.manual)

    # GUI applications
    if args.gui:
        install_brew_casks(manual=args.manual)

    # Fonts
    if args.font:
        install_brew_fonts(manual=args.manual)

    # Stow dotfiles
    if args.stow:
        stow_dotfiles(script_path)

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
    if not args.skip_disable_macos_shortcuts or not args.skip_fast_key_repeat:
        print("  4. Log out and back in to activate keyboard preference changes.")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


# Each option supplies both its command-line help and its yes/no question.
SETUP_OPTIONS: list[tuple[str, str]] = [
    ("brew", "Install the base Homebrew CLI formulae"),
    ("gui", "Install GUI applications, including Vorssaint"),
    ("font", "Install Nerd Fonts"),
    ("stow", "Stow the repository dotfiles"),
    ("brew-zsh", "Set Homebrew zsh as the login shell"),
    ("defaults", "Apply macOS system preferences (Finder, Dock, etc.)"),
    ("xcode", "Validate that full Xcode is installed and selected"),
    ("go", "Install Go + gopls and configure GOMODCACHE"),
    ("rust", "Install rustup and set nightly as the default toolchain"),
    ("php", "Install Composer and configure PHP extensions"),
    ("resticprofile", "Install resticprofile"),
    ("services", "Install and start Colima (also start PHP if selected)"),
    ("touchid-sudo", "Enable Touch ID authentication for sudo"),
    ("ssh", "Enable SSH Remote Login"),
    ("mas", "Install Mac App Store apps (requires an iCloud sign-in)"),
    ("manual", "Run package installers interactively"),
]

VERSION_OPTIONS: list[tuple[str, str, str | None, str]] = [
    (
        "nvm",
        "Install Node via NVM",
        NODE_VERSION,
        r"(?:lts/[a-z]+|v?\d+(?:\.\d+){0,2})",
    ),
    ("pyenv", "Install Python via pyenv", PYENV_VERSION, r"\d+\.\d+(?:\.\d+)?"),
    ("k9s-theme", "Install the Catppuccin k9s theme", None, r"[0-9a-f]{40}"),
]


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "macOS 26/27 setup using Homebrew (Python 3.9+). "
            "Prompts for unanswered options before making changes. "
            "Existing flags answer their questions; all yes/no prompts default to no."
        )
    )
    for flag, help_text in SETUP_OPTIONS:
        parser.add_argument(
            f"--{flag}",
            action="store_true",
            default=None,
            help=help_text + ". Prompts if omitted (default: no).",
        )
    for flag, help_text, default, pattern in VERSION_OPTIONS:
        value_options = {"nargs": "?", "const": default} if default else {}
        parser.add_argument(
            f"--{flag}",
            metavar="VERSION" if default else "SHA",
            default=None,
            help=help_text
            + (
                f" (default: {default})."
                if default
                else " from a 40-character Git SHA."
            ),
            **value_options,
        )
    for flag in ("skip-disable-macos-shortcuts", "skip-fast-key-repeat"):
        parser.add_argument(
            f"--{flag}",
            action="store_true",
            default=None,
            help="Leave the current settings unchanged without prompting.",
        )
    args = parser.parse_args(argv)
    # Validate explicit values before asking questions or changing the machine.
    for flag, _, _, pattern in VERSION_OPTIONS:
        value = getattr(args, flag.replace("-", "_"))
        if value:
            try:
                require_version(value, pattern, f"--{flag}")
            except ValueError as error:
                parser.error(str(error))
    return args


def ask_yes_no(question: str) -> bool:
    while True:
        answer = input(f"{question}? [y/N]: ").strip().lower()
        if not answer:
            return False
        if answer in ("y", "yes"):
            return True
        if answer in ("n", "no"):
            return False
        print("Please answer yes or no.")


def prompt_unanswered(args: argparse.Namespace) -> None:
    """Collect all missing answers before any setup step runs."""
    for flag, question in SETUP_OPTIONS:
        dest = flag.replace("-", "_")
        if getattr(args, dest) is None:
            setattr(args, dest, ask_yes_no(question))
    for flag, question, default, pattern in VERSION_OPTIONS:
        dest = flag.replace("-", "_")
        if getattr(args, dest) is not None:
            continue
        if not ask_yes_no(question):
            setattr(args, dest, False)
            continue
        label = f"Version [{default}]" if default else "40-character Git commit SHA"
        while True:
            value = input(f"{label}: ").strip() or default or ""
            try:
                require_version(value, pattern, f"--{flag}")
            except ValueError as error:
                print(error)
            else:
                setattr(args, dest, value)
                break
    for dest, question in [
        (
            "skip_disable_macos_shortcuts",
            "Disable Quick Note, Screenshots, Show Apps, Spotlight search, and Log Out shortcuts",
        ),
        (
            "skip_fast_key_repeat",
            "Enable fast key repeat, a short initial delay, and repeating held letters",
        ),
    ]:
        if getattr(args, dest) is None:
            setattr(args, dest, not ask_yes_no(question))


def main() -> None:
    args = parse_args()

    if platform.system() != "Darwin":
        sys.exit(f"This script requires macOS. Detected: {platform.system()}")
    if os.geteuid() == 0:
        sys.exit(
            "Run as your login user, without sudo; individual steps request sudo if needed."
        )
    try:
        prompt_unanswered(args)
    except (EOFError, KeyboardInterrupt):
        sys.exit("\nSetup canceled before making changes.")

    selected = any(
        value
        for name, value in vars(args).items()
        if not name.startswith("skip_") and name != "manual"
    ) or not (args.skip_disable_macos_shortcuts and args.skip_fast_key_repeat)
    if not selected:
        print("No setup steps selected.")
        return

    script_path = os.path.dirname(os.path.abspath(__file__))
    run_setup(args, script_path)


if __name__ == "__main__":
    main()
