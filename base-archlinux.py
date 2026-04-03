#!/usr/bin/env python3
"""
Base Arch Linux installation script.

Runs from the Arch Linux live ISO. Guides through the complete installation
process: WiFi, partitioning, pacstrap, arch-chroot setup, GRUB, services.

Usage:
    python3 base-archlinux.py [--dry-run]

Flags:
    --dry-run    Print commands without executing them
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import time

# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

# Default packages for pacstrap
BASE_PACKAGES: list[str] = [
    "base",
    "base-devel",
    "linux-firmware",
    "intel-ucode",
    "networkmanager",
    "dhcpcd",
    "pipewire",
    "wpa_supplicant",
    "netctl",
    "ntfs-3g",
    "bluez",
    "bluez-utils",
]

EXTRA_PACKAGES: list[str] = [
    "inetutils",
    "net-tools",
    "sudo",
    "htop",
    "openssh",
    "ufw",
    "git",
    "nano",
    "vim",
    "neovim",
    "fastfetch",
    "cups",
    "dialog",
    # CLI essentials
    "tmux",
    "zsh",
    "fzf",
    "eza",
    "ripgrep",
    "bat",
    "direnv",
    "lf",
    "fd",
    "git-delta",
    "jq",
    "yq",
    "less",
    "lsof",
    "wget",
    "curl",
    "zip",
    "unzip",
    "bind",
    "strace",
    "man-db",
    "dos2unix",
    "stow",
    "ca-certificates",
    "gnupg",
    # Dev & Build
    "bash-completion",
    "meson",
    "cmake",
    "ninja",
    "clang",
    "lld",
    "github-cli",
    "python",
    "python-pip",
    "python-setuptools",
    "go",
    "gopls",
    "lua",
    "rustup",
    "sqlite",
    # Network
    "iptables",
    "nftables",
    "reflector",
    "pacman-contrib",
    # Filesystem
    "btrfs-progs",
    # System
    "lvm2",
]

EXTRA_APPS: list[str] = [
    "firefox",
    "libsecret",
    "brightnessctl",
    "playerctl",
    "acpi",
    "pipewire",
    "pipewire-alsa",
    "pipewire-pulse",
    "wireplumber",
    "ydotool",
]

# System services to enable (system-level)
SYSTEM_SERVICES: list[str] = [
    "dhcpcd",
    "NetworkManager",
    "sshd",
    "bluetooth",
    "fstrim.timer",
]

# User-level services
USER_SERVICES: list[str] = [
    "pipewire",
    "pipewire-pulse",
    "wireplumber",
]

# ─────────────────────────────────────────────────────────────────────────────
# Helper Functions
# ─────────────────────────────────────────────────────────────────────────────


def run_cmd(
    args: list[str],
    *,
    check: bool = True,
    dry_run: bool = False,
    capture_output: bool = False,
) -> subprocess.CompletedProcess:
    """Run a command, optionally in dry-run mode."""
    print(f"  $ {' '.join(args)}")
    if dry_run:
        return subprocess.CompletedProcess(args, returncode=0, stdout=b"", stderr=b"")
    return subprocess.run(
        args, check=check, capture_output=capture_output, text=capture_output
    )


def run_in_chroot(cmd: str, *, dry_run: bool = False) -> subprocess.CompletedProcess:
    """Run a command inside arch-chroot /mnt."""
    full_cmd = ["arch-chroot", "/mnt", "/bin/bash", "-c", cmd]
    print(f"  [chroot] $ {cmd}")
    if dry_run:
        return subprocess.CompletedProcess(full_cmd, returncode=0, stdout="", stderr="")
    return subprocess.run(full_cmd, check=True)


def confirm(prompt: str) -> bool:
    """Ask y/n confirmation, return True if yes."""
    while True:
        answer = input(f"{prompt} [y/N]: ").strip().lower()
        if answer in ("y", "yes"):
            return True
        if answer in ("", "n", "no"):
            return False
        print("  Please enter y or n.")


def edit_file(
    filepath: str,
    replacements: list[tuple[str, str]],
    *,
    dry_run: bool = False,
) -> None:
    """Apply sed-like replacements in a file."""
    print(f"  Editing {filepath}")
    if dry_run:
        for old, new in replacements:
            print(f"    replace: {old!r} → {new!r}")
        return
    with open(filepath, "r") as fh:
        content = fh.read()
    for old, new in replacements:
        content = content.replace(old, new)
    with open(filepath, "w") as fh:
        fh.write(content)


def banner(title: str) -> None:
    """Print a prominent section banner."""
    width = 72
    print()
    print("═" * width)
    print(f"  {title}")
    print("═" * width)


def ask(prompt: str, default: str = "") -> str:
    """Prompt the user for input with an optional default."""
    if default:
        answer = input(f"{prompt} [{default}]: ").strip()
        return answer if answer else default
    while True:
        answer = input(f"{prompt}: ").strip()
        if answer:
            return answer
        print("  Value cannot be empty.")


def _version_prompt(prompt: str, default: str) -> str:
    """Prompt for a version string. Enter for default, -1 to skip."""
    answer = input(f"{prompt} [{default}, -1 to skip]: ").strip()
    if answer == "-1":
        return ""
    return answer if answer else default


# ─────────────────────────────────────────────────────────────────────────────
# Step 1: Verify UEFI
# ─────────────────────────────────────────────────────────────────────────────


def verify_uefi(*, dry_run: bool = False) -> None:
    """Check /sys/firmware/efi/fw_platform_size and /sys/firmware/efi/efivars.
    Abort if not UEFI."""
    banner("STEP 1 — Verify UEFI Boot Mode")

    fw_size_path = "/sys/firmware/efi/fw_platform_size"
    efivars_path = "/sys/firmware/efi/efivars"

    if dry_run:
        print("  [dry-run] Skipping UEFI check.")
        return

    if not os.path.exists(fw_size_path):
        print(f"  ERROR: {fw_size_path} does not exist.")
        print("  The system does not appear to be booted in UEFI mode.")
        print("  Please reboot with UEFI enabled and try again.")
        sys.exit(1)

    with open(fw_size_path) as fh:
        fw_size = fh.read().strip()

    print(f"  EFI firmware platform size: {fw_size}-bit")

    if fw_size == "64":
        print("  ✔  System is booted in 64-bit UEFI mode — OK")
    elif fw_size == "32":
        print("  ⚠  System is booted in 32-bit IA32 UEFI mode.")
        print("     This script targets x86_64-efi GRUB — proceed with caution.")
        if not confirm("Continue anyway?"):
            sys.exit(1)
    else:
        print(f"  WARNING: Unexpected fw_platform_size value: {fw_size!r}")
        if not confirm("Continue anyway?"):
            sys.exit(1)

    if not os.path.isdir(efivars_path) or not os.listdir(efivars_path):
        print(f"  ERROR: {efivars_path} is empty or does not exist.")
        print("  EFI variables are not accessible. Cannot continue.")
        sys.exit(1)

    print(f"  ✔  EFI variables present at {efivars_path} — OK")
    print()
    print("  UEFI verification passed.")


# ─────────────────────────────────────────────────────────────────────────────
# Step 2: Setup WiFi
# ─────────────────────────────────────────────────────────────────────────────


def setup_wifi(*, dry_run: bool = False) -> None:
    """Automated WiFi setup using iwd / iwctl."""
    banner("STEP 2 — Connect to the Internet (WiFi)")

    # Pre-check: already connected?
    if not dry_run:
        result = subprocess.run(
            ["ping", "-c", "1", "-W", "2", "archlinux.org"],
            capture_output=True,
            check=False,
        )
        if result.returncode == 0:
            print("  ✔  Internet connection already detected — skipping WiFi setup.")
            return

    if not confirm("Do you need to set up WiFi? (skip if using a wired connection)"):
        print("  WARNING: No internet detected and WiFi setup skipped.")
        if not confirm("Continue anyway?"):
            sys.exit(1)
        return

    # Write iwd config
    iwd_conf_dir = "/etc/iwd"
    iwd_conf_path = "/etc/iwd/main.conf"
    iwd_conf_content = """\
[General]
EnableNetworkConfiguration=true

[Network]
EnableIPv6=true
RoutePriorityOffset=300
NameResolvingService=resolvconf
"""
    print(f"\n  Writing iwd config to {iwd_conf_path} ...")
    if not dry_run:
        os.makedirs(iwd_conf_dir, exist_ok=True)
        with open(iwd_conf_path, "w") as fh:
            fh.write(iwd_conf_content)
        print("  Config written.")
    else:
        print(f"  [dry-run] Would write:\n{iwd_conf_content}")

    # Restart iwd
    print("\n  Restarting iwd service ...")
    run_cmd(["systemctl", "restart", "iwd"], dry_run=dry_run)

    # Discover wireless device
    print("\n  Discovering wireless device ...")
    if not dry_run:
        result = subprocess.run(
            ["iwctl", "device", "list"],
            capture_output=True,
            text=True,
            check=False,
        )
        # Parse device names from output like:
        #   wlan0            wireless              Qualcomm ...
        devices = []
        for line in result.stdout.splitlines():
            parts = line.split()
            if len(parts) >= 2 and "wireless" in parts[1]:
                devices.append(parts[0])

        if not devices:
            print("  ERROR: No wireless device found.")
            if not confirm("Continue without WiFi?"):
                sys.exit(1)
            return

        if len(devices) == 1:
            device = devices[0]
            print(f"  Found device: {device}")
        else:
            print("  Multiple wireless devices found:")
            for i, dev in enumerate(devices, 1):
                print(f"    {i}. {dev}")
            while True:
                choice = input("  Select device number: ").strip()
                if choice.isdigit() and 1 <= int(choice) <= len(devices):
                    device = devices[int(choice) - 1]
                    break
                print("  Invalid selection.")

        # Power on the device
        print(f"  Powering on {device} ...")
        run_cmd(["iwctl", "device", device, "set-property", "Powered", "on"])

        # Scan for networks
        print("  Scanning for networks ...")
        run_cmd(["iwctl", "station", device, "scan"])

        # Give iwd a moment to populate results
        time.sleep(2)

        # Get available networks
        result = subprocess.run(
            ["iwctl", "station", device, "get-networks"],
            capture_output=True,
            text=True,
            check=False,
        )
        networks = []
        for line in result.stdout.splitlines():
            parts = line.split()
            if len(parts) >= 2:
                # Skip header/footer lines
                if parts[0] == "Available" or parts[0] == "----":
                    continue
                ssid = parts[0]
                if ssid and ssid != "Networks":
                    networks.append(ssid)

        if not networks:
            print("  WARNING: No networks found. Trying to connect anyway ...")

        # Show networks and let user pick
        print("\n  Available networks:")
        for i, net in enumerate(networks, 1):
            print(f"    {i}. {net}")

        while True:
            choice = input(
                "  Select network number (or 0 to enter SSID manually): "
            ).strip()
            if choice == "0":
                ssid = input("  Enter SSID: ").strip()
                if ssid:
                    break
                print("  SSID cannot be empty.")
            elif choice.isdigit() and 1 <= int(choice) <= len(networks):
                ssid = networks[int(choice) - 1]
                break
            print("  Invalid selection.")

        # Ask for passphrase
        passphrase = input(
            "  Enter WiFi passphrase (leave empty for open network): "
        ).strip()

        # Connect
        print(f"\n  Connecting to '{ssid}' ...")
        if passphrase:
            run_cmd(
                [
                    "iwctl",
                    "station",
                    device,
                    "connect",
                    ssid,
                    "--passphrase",
                    passphrase,
                ]
            )
        else:
            run_cmd(["iwctl", "station", device, "connect", ssid])

        # Wait for connection
        print("  Waiting for connection ...")
        time.sleep(3)

        # Verify connection
        result = subprocess.run(
            ["iwctl", "station", device, "show"],
            capture_output=True,
            text=True,
            check=False,
        )
        if "connected" in result.stdout.lower():
            print("  ✔  Connected successfully.")
        else:
            print("  WARNING: Connection status unclear.")

    else:
        print(
            "  [dry-run] Would configure iwd, discover device, scan, and connect to WiFi."
        )

    # Test connectivity
    print()
    print("  Testing internet connection with ping archlinux.org ...")
    if not dry_run:
        result = subprocess.run(
            ["ping", "-c", "4", "archlinux.org"],
            check=False,
        )
        if result.returncode != 0:
            print()
            print("  WARNING: ping failed. You may not have an internet connection.")
            if not confirm("Continue anyway?"):
                sys.exit(1)
        else:
            print("  ✔  Internet connection verified.")
    else:
        print("  [dry-run] Would run: ping -c 4 archlinux.org")


# ─────────────────────────────────────────────────────────────────────────────
# Step 3: Setup Clock and Pacman Keys
# ─────────────────────────────────────────────────────────────────────────────


def setup_clock_and_keys(timezone: str, *, dry_run: bool = False) -> None:
    """NTP, timezone selection, pacman-key init/populate."""
    banner("STEP 3 — System Clock & Pacman Keys")

    print("  Current timedatectl status:")
    run_cmd(["timedatectl"], check=False, dry_run=dry_run)

    print(f"\n  Setting NTP on ...")
    run_cmd(["timedatectl", "set-ntp", "true"], dry_run=dry_run)

    print(f"\n  Setting timezone to: {timezone}")
    run_cmd(["timedatectl", "set-timezone", timezone], dry_run=dry_run)

    print("\n  Initializing pacman keyring ...")
    run_cmd(["pacman-key", "--init"], dry_run=dry_run)

    print("\n  Populating archlinux keyring ...")
    run_cmd(["pacman-key", "--populate", "archlinux"], dry_run=dry_run)

    print("\n  ✔  Clock and keys configured.")


# ─────────────────────────────────────────────────────────────────────────────
# Step 4: Partition Disk
# ─────────────────────────────────────────────────────────────────────────────


def partition_disk(*, dry_run: bool = False) -> tuple[bool, str, str, str, str]:
    """Interactive disk partitioning.

    Returns:
        (dual_boot, disk, root_part, efi_part, swap_part)
    """
    banner("STEP 4 — Partition, Format & Mount Disk")

    print("  Current block devices:")
    run_cmd(["lsblk"], check=False, dry_run=dry_run)

    print()
    disk = ask("  Enter the disk device to partition (e.g. /dev/nvme0n1, /dev/sda)")

    dual_boot = confirm(
        "\n  Are you dual-booting with Windows? (EFI partition already exists)"
    )

    print()
    print("  ─────────────────────────────────────────────────────────────")
    print("  We will now open cfdisk to let you create partitions.")
    if dual_boot:
        print("  Since you are dual-booting, create only:")
        print("    - Linux swap  (swap partition)")
        print("    - Linux filesystem  (root partition)")
        print("  DO NOT touch or reformat the existing EFI System partition.")
    else:
        print("  You are doing a CLEAN install (no existing OS).")
        print("  Create the following partitions:")
        print("    - EFI System  (≥ 512 MB, type: EFI System)")
        print("    - Linux swap  (swap partition, e.g. equal to RAM)")
        print("    - Linux filesystem  (root partition, remaining space)")
    print("  Write and quit when done.")
    print("  ─────────────────────────────────────────────────────────────")
    input("  Press ENTER to open cfdisk ...")

    if not dry_run:
        subprocess.run(["cfdisk", disk], check=False)
    else:
        print(f"  [dry-run] Would run: cfdisk {disk}")

    # Show updated partition table
    print("\n  Updated partition table:")
    run_cmd(["lsblk", disk], check=False, dry_run=dry_run)

    print()
    root_part = ask(
        "  Enter the ROOT (Linux filesystem) partition (e.g. /dev/nvme0n1p5)"
    )
    efi_part = ask("  Enter the EFI System partition (e.g. /dev/nvme0n1p1)")
    print()
    if confirm("  Did you create a swap partition?"):
        swap_part = ask("  Enter the SWAP partition (e.g. /dev/nvme0n1p6)")
    else:
        swap_part = ""
        print("  No swap partition — skipping.")

    # ── Format root ──────────────────────────────────────────────────────────
    print(f"\n  Formatting root partition {root_part} as ext4 ...")
    if not confirm(f"  ⚠  This will ERASE all data on {root_part}. Proceed?"):
        print("  Aborted.")
        sys.exit(1)
    run_cmd(["mkfs.ext4", root_part], dry_run=dry_run)

    # ── Format EFI (only if not dual-boot) ───────────────────────────────────
    if not dual_boot:
        print(f"\n  Formatting EFI partition {efi_part} as FAT32 ...")
        print("  This is a clean install — safe to format the EFI partition.")
        if not confirm(f"  ⚠  This will ERASE all data on {efi_part}. Proceed?"):
            print("  Aborted.")
            sys.exit(1)
        run_cmd(["mkfs.fat", "-F32", efi_part], dry_run=dry_run)
    else:
        print(f"\n  Dual-boot mode: skipping format of EFI partition {efi_part}.")
        print("  Your Windows bootloader is preserved.")

    # ── Setup swap ───────────────────────────────────────────────────────────
    if swap_part:
        print(f"\n  Setting up swap on {swap_part} ...")
        run_cmd(["mkswap", swap_part], dry_run=dry_run)
        run_cmd(["swapon", swap_part], dry_run=dry_run)
    else:
        print("\n  No swap partition — skipping.")

    # ── Mount ────────────────────────────────────────────────────────────────
    print(f"\n  Mounting {root_part} to /mnt ...")
    run_cmd(["mount", root_part, "/mnt"], dry_run=dry_run)

    print(f"  Mounting {efi_part} to /mnt/efi ...")
    run_cmd(["mount", "--mkdir", efi_part, "/mnt/efi"], dry_run=dry_run)

    # Ensure /mnt/home exists
    if not dry_run:
        os.makedirs("/mnt/home", exist_ok=True)
    else:
        print("  [dry-run] Would create /mnt/home")

    print("\n  ✔  Partitions formatted and mounted.")
    return dual_boot, disk, root_part, efi_part, swap_part


# ─────────────────────────────────────────────────────────────────────────────
# Step 5: Rank Mirrors
# ─────────────────────────────────────────────────────────────────────────────


def rank_mirrors(*, dry_run: bool = False) -> None:
    """Ask user to choose reflector or rankmirrors, run the chosen tool."""
    banner("STEP 5 — Update Mirror List")

    # Backup existing mirrorlist
    mirrorlist = "/etc/pacman.d/mirrorlist"
    mirrorlist_bak = "/etc/pacman.d/mirrorlist.bak"
    print(f"  Backing up {mirrorlist} to {mirrorlist_bak} ...")
    if not dry_run:
        shutil.copy2(mirrorlist, mirrorlist_bak)
    else:
        print(f"  [dry-run] Would copy {mirrorlist} → {mirrorlist_bak}")

    print()
    print("  Choose mirror ranking tool:")
    print("    1. reflector  (recommended, sorts by speed)")
    print("    2. rankmirrors  (picks top 10 from backup list)")
    choice = ""
    while choice not in ("1", "2"):
        choice = input("  Enter choice [1/2]: ").strip()

    country = ask("  Enter your country name (e.g. United States, Poland, Germany)")

    if choice == "1":
        if not shutil.which("reflector"):
            print("\n  Installing reflector ...")
            run_cmd(["pacman", "-Sy", "--noconfirm", "reflector"], dry_run=dry_run)
        print(f"\n  Running reflector for country: {country} ...")
        run_cmd(
            [
                "reflector",
                "-c",
                country,
                "--latest",
                "10",
                "--sort",
                "rate",
                "--save",
                mirrorlist,
            ],
            dry_run=dry_run,
        )
    else:
        if not shutil.which("rankmirrors"):
            print("\n  Installing pacman-contrib (provides rankmirrors) ...")
            run_cmd(["pacman", "-Sy", "--noconfirm", "pacman-contrib"], dry_run=dry_run)
        print("\n  Running rankmirrors (top 10) — this may take a few minutes ...")
        if not dry_run:
            with open(mirrorlist, "w") as out_fh:
                result = subprocess.run(
                    ["rankmirrors", "-n", "10", mirrorlist_bak],
                    stdout=out_fh,
                    check=True,
                )
        else:
            print(
                f"  [dry-run] Would run: rankmirrors -n 10 {mirrorlist_bak} > {mirrorlist}"
            )

    print("\n  ✔  Mirror list updated.")


# ─────────────────────────────────────────────────────────────────────────────
# Step 6: Enable Parallel Downloads
# ─────────────────────────────────────────────────────────────────────────────


def enable_parallel_downloads(
    pacman_conf: str = "/etc/pacman.conf", *, dry_run: bool = False
) -> None:
    """Uncomment/add ParallelDownloads=5 in pacman.conf."""
    banner(f"STEP 6 — Enable Parallel Downloads ({pacman_conf})")

    if dry_run:
        print(f"  [dry-run] Would enable ParallelDownloads=5 in {pacman_conf}")
        return

    with open(pacman_conf, "r") as fh:
        content = fh.read()

    if "ParallelDownloads = 5" in content or "ParallelDownloads=5" in content:
        # Ensure it's uncommented
        content = re.sub(
            r"^#\s*(ParallelDownloads\s*=\s*5)", r"\1", content, flags=re.MULTILINE
        )
    elif "#ParallelDownloads" in content:
        content = re.sub(
            r"#(ParallelDownloads\s*=\s*\d+)", r"ParallelDownloads = 5", content
        )
    else:
        # Add under [options]
        content = content.replace(
            "[options]\n", "[options]\nParallelDownloads = 5\n", 1
        )

    with open(pacman_conf, "w") as fh:
        fh.write(content)

    print(f"  ✔  ParallelDownloads = 5 enabled in {pacman_conf}")


# ─────────────────────────────────────────────────────────────────────────────
# Step 7: Run pacstrap
# ─────────────────────────────────────────────────────────────────────────────


def run_pacstrap(kernel_pkg: str, *, dry_run: bool = False) -> None:
    """Install BASE_PACKAGES + EXTRA_PACKAGES to /mnt."""
    banner("STEP 7 — Install Base System (pacstrap)")

    all_packages = (
        BASE_PACKAGES + [kernel_pkg, f"{kernel_pkg}-headers"] + EXTRA_PACKAGES
    )
    print(f"  Packages to install ({len(all_packages)} total):")
    for pkg in all_packages:
        print(f"    - {pkg}")

    print()
    if not confirm("  Proceed with pacstrap?"):
        print("  Aborted.")
        sys.exit(1)

    run_cmd(["pacstrap", "-K", "/mnt"] + all_packages, dry_run=dry_run)
    print("\n  ✔  Base system installed.")


# ─────────────────────────────────────────────────────────────────────────────
# Step 8: Generate fstab
# ─────────────────────────────────────────────────────────────────────────────


def generate_fstab(*, dry_run: bool = False) -> None:
    """genfstab -U /mnt >> /mnt/etc/fstab"""
    banner("STEP 8 — Generate fstab")

    print("  Running: genfstab -U /mnt >> /mnt/etc/fstab")
    if not dry_run:
        with open("/mnt/etc/fstab", "a") as fstab_fh:
            subprocess.run(
                ["genfstab", "-U", "/mnt"],
                stdout=fstab_fh,
                check=True,
            )
        print("  Contents of /mnt/etc/fstab:")
        with open("/mnt/etc/fstab") as fh:
            print(fh.read())
    else:
        print("  [dry-run] Would append genfstab -U /mnt output to /mnt/etc/fstab")

    print("  ✔  fstab generated.")


# ─────────────────────────────────────────────────────────────────────────────
# Step 9: arch-chroot Setup
# ─────────────────────────────────────────────────────────────────────────────


def arch_chroot_setup(
    user: str,
    hostname: str,
    timezone: str,
    locale: str,
    default_shell: str,
    pyenv_version: str,
    nvm_version: str,
    rustup_nightly: bool,
    *,
    dry_run: bool = False,
) -> None:
    """All chroot operations: system config, users, locale, GRUB, etc."""
    banner("STEP 9 — Configure System (arch-chroot)")

    # ── Update packages ───────────────────────────────────────────────────────
    print("\n  [9.1] Update packages ...")
    run_in_chroot("pacman -Syu --noconfirm", dry_run=dry_run)

    # ── Root password ─────────────────────────────────────────────────────────
    print("\n  [9.2] Set root password ...")
    print("  You will be prompted to enter the new root password.")
    if not dry_run:
        subprocess.run(["arch-chroot", "/mnt", "passwd"], check=True)
    else:
        print("  [dry-run] Would run: arch-chroot /mnt passwd")

    # ── Hostname ──────────────────────────────────────────────────────────────
    print(f"\n  [9.3] Setting hostname to '{hostname}' ...")
    if not dry_run:
        with open("/mnt/etc/hostname", "w") as fh:
            fh.write(f"{hostname}\n")
    else:
        print(f"  [dry-run] Would write '{hostname}' to /mnt/etc/hostname")

    # ── Create user ───────────────────────────────────────────────────────────
    print(f"\n  [9.4] Creating user '{user}' with {default_shell} shell ...")
    run_in_chroot("groupadd -f sudo", dry_run=dry_run)
    shell_path = "/bin/zsh" if default_shell == "zsh" else "/bin/bash"
    run_in_chroot(
        f"useradd -G sudo,wheel,storage,power,audio,video,input -m {user} "
        f"-s {shell_path}",
        dry_run=dry_run,
    )
    print(f"  Set password for user '{user}':")
    if not dry_run:
        subprocess.run(["arch-chroot", "/mnt", "passwd", user], check=True)
    else:
        print(f"  [dry-run] Would run: arch-chroot /mnt passwd {user}")

    # ── visudo ────────────────────────────────────────────────────────────────
    print("\n  [9.5] Configuring sudoers ...")
    sudoers_patch = (
        r"sed -i 's/^# %sudo ALL=(ALL) ALL/%sudo ALL=(ALL) ALL/' /etc/sudoers && "
        r"sed -i 's/^# %sudo ALL=(ALL:ALL) ALL/%sudo ALL=(ALL:ALL) ALL/' /etc/sudoers"
    )
    if confirm("  Set sudo timestamp_timeout=0 (ask password every time)?"):
        sudoers_patch += (
            r" && grep -q 'Defaults timestamp_timeout' /etc/sudoers || "
            r"echo 'Defaults timestamp_timeout=0' >> /etc/sudoers"
        )
    run_in_chroot(sudoers_patch, dry_run=dry_run)

    # ── Locale ────────────────────────────────────────────────────────────────
    print(f"\n  [9.6] Setting locale to '{locale}' ...")
    locale_gen_path = "/mnt/etc/locale.gen"
    if not dry_run:
        with open(locale_gen_path, "r") as fh:
            locale_gen = fh.read()
        # Uncomment the target locale
        locale_gen = locale_gen.replace(f"#{locale}", locale)
        with open(locale_gen_path, "w") as fh:
            fh.write(locale_gen)
    else:
        print(f"  [dry-run] Would uncomment '{locale}' in /mnt/etc/locale.gen")

    run_in_chroot("locale-gen", dry_run=dry_run)

    lang_value = locale.split()[0]
    if not dry_run:
        with open("/mnt/etc/locale.conf", "w") as fh:
            fh.write(f"LANG={lang_value}\n")
    else:
        print(f"  [dry-run] Would write LANG={lang_value} to /mnt/etc/locale.conf")

    # ── /etc/hosts ────────────────────────────────────────────────────────────
    print(f"\n  [9.7] Writing /etc/hosts ...")
    hosts_content = (
        f"127.0.0.1\tlocalhost\n"
        f"::1\t\tlocalhost\n"
        f"127.0.1.1\t{hostname}.local\t{hostname}\n"
    )
    if not dry_run:
        with open("/mnt/etc/hosts", "w") as fh:
            fh.write(hosts_content)
    else:
        print(f"  [dry-run] Would write:\n{hosts_content}")

    # ── Timezone ──────────────────────────────────────────────────────────────
    print(f"\n  [9.8] Setting timezone symlink to {timezone} ...")
    run_in_chroot(
        f"ln -sf /usr/share/zoneinfo/{timezone} /etc/localtime",
        dry_run=dry_run,
    )
    run_in_chroot("hwclock --systohc", dry_run=dry_run)

    # ── Enable multilib ───────────────────────────────────────────────────────
    print("\n  [9.9] Enabling multilib repository in /etc/pacman.conf ...")
    pacman_conf_chroot = "/mnt/etc/pacman.conf"
    if not dry_run:
        with open(pacman_conf_chroot, "r") as fh:
            content = fh.read()
        content = content.replace(
            "#[multilib]\n#Include = /etc/pacman.d/mirrorlist",
            "[multilib]\nInclude = /etc/pacman.d/mirrorlist",
        )
        # Also handle the case where there may be no comment before Include
        if "[multilib]" not in content:
            content += "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n"
        with open(pacman_conf_chroot, "w") as fh:
            fh.write(content)
    else:
        print("  [dry-run] Would uncomment [multilib] section in /mnt/etc/pacman.conf")

    # ── Enable parallel downloads inside chroot ────────────────────────────────
    print("\n  [9.10] Enabling parallel downloads in chroot pacman.conf ...")
    enable_parallel_downloads(pacman_conf_chroot, dry_run=dry_run)

    # ── Install extra applications ────────────────────────────────────────────
    print(f"\n  [9.11] Installing extra applications: {', '.join(EXTRA_APPS)} ...")
    run_in_chroot(
        f"pacman -Syu --noconfirm {' '.join(EXTRA_APPS)}",
        dry_run=dry_run,
    )

    # ── Install pyenv ─────────────────────────────────────────────────────────
    if pyenv_version:
        print(f"\n  [9.12] Installing pyenv and Python {pyenv_version} ...")
        run_in_chroot(
            "pacman -Syu --noconfirm pyenv openssl readline zlib "
            "bzip2 libffi sqlite lz4 xz tk",
            dry_run=dry_run,
        )
        run_in_chroot(
            f"sudo -u {user} pyenv install {pyenv_version}",
            dry_run=dry_run,
        )
        run_in_chroot(
            f"sudo -u {user} pyenv global {pyenv_version}",
            dry_run=dry_run,
        )

    # ── Install nvm ───────────────────────────────────────────────────────────
    if nvm_version:
        print(f"\n  [9.13] Installing nvm and Node.js {nvm_version} ...")
        run_in_chroot(
            f"sudo -u {user} bash -c '"
            "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'",
            dry_run=dry_run,
        )
        run_in_chroot(
            f"sudo -u {user} bash -c '"
            'export NVM_DIR="$HOME/.nvm"; '
            '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; '
            f"nvm install {nvm_version}; "
            f"nvm alias default {nvm_version}; "
            f"nvm use default'",
            dry_run=dry_run,
        )

    # ── Install Rust nightly toolchain ────────────────────────────────────────
    if rustup_nightly:
        print("\n  [9.14] Installing Rust nightly toolchain via rustup ...")
        run_in_chroot(
            f"sudo -u {user} bash -c '"
            "export RUSTUP_HOME=$HOME/.rustup; "
            "export CARGO_HOME=$HOME/.cargo; "
            "rustup-init -y --default-toolchain nightly; "
            "rustup toolchain install nightly; "
            "rustup default nightly'",
            dry_run=dry_run,
        )

    # ── Write shell environment config ────────────────────────────────────────
    env_filename = ".zshenv" if default_shell == "zsh" else ".profile"
    print(f"\n  [9.15] Writing shell environment config to ~/{env_filename} ...")
    env_lines = [
        "# ── Pyenv ─────────────────────────────────────────────────────────",
        'export PYENV_ROOT="$HOME/.pyenv"',
        '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"',
        "if command -v pyenv &>/dev/null; then",
        '  eval "$(pyenv init -)"',
        "fi",
        "",
        "# ── NVM ───────────────────────────────────────────────────────────",
        'export NVM_DIR="$XDG_DATA_HOME/nvm"',
        "export NVM_COMPLETION=true",
        "",
        "# ── Terminal & Locale ─────────────────────────────────────────────",
        'export TERM="xterm-256color"',
        "",
        "# You may need to manually set your language environment",
        'export LANGUAGE="en_US.UTF-8"',
        'export LANG="en_US.UTF-8"',
        'export LC_ALL="en_US.UTF-8"',
        "",
    ]
    env_content = "\n".join(env_lines)
    env_path = f"/mnt/home/{user}/{env_filename}"
    if not dry_run:
        with open(env_path, "w") as fh:
            fh.write(env_content)
        run_in_chroot(
            f"chown {user}:{user} /home/{user}/{env_filename}", dry_run=dry_run
        )
    else:
        print(f"  [dry-run] Would write to {env_path}:\n{env_content}")

    print("\n  ✔  arch-chroot configuration complete.")


# ─────────────────────────────────────────────────────────────────────────────
# Step 10: Setup GRUB
# ─────────────────────────────────────────────────────────────────────────────


def setup_grub(dual_boot: bool, efi_device: str, *, dry_run: bool = False) -> None:
    """GRUB installation and configuration."""
    banner("STEP 10 — Install & Configure GRUB Bootloader")

    grub_packages = ["grub", "efibootmgr", "dosfstools", "mtools", "os-prober"]
    print(f"  Installing GRUB packages: {', '.join(grub_packages)} ...")
    run_in_chroot(
        f"pacman -Syu --noconfirm {' '.join(grub_packages)}",
        dry_run=dry_run,
    )

    if dual_boot:
        print("\n  Dual-boot: enabling os-prober in /etc/default/grub ...")
        print("  This detects your Windows installation and adds it to the GRUB menu.")
        grub_default = "/mnt/etc/default/grub"
        if not dry_run:
            with open(grub_default, "r") as fh:
                content = fh.read()
            content = content.replace(
                "#GRUB_DISABLE_OS_PROBER=false",
                "GRUB_DISABLE_OS_PROBER=false",
            )
            if "GRUB_DISABLE_OS_PROBER=false" not in content:
                content += "\nGRUB_DISABLE_OS_PROBER=false\n"
            with open(grub_default, "w") as fh:
                fh.write(content)
        else:
            print(
                "  [dry-run] Would set GRUB_DISABLE_OS_PROBER=false in /mnt/etc/default/grub"
            )
    else:
        print("\n  Clean install: os-prober not needed (no other OS to detect).")

    print("\n  Installing GRUB to EFI ...")
    run_in_chroot(
        "grub-install --target=x86_64-efi --efi-directory=/efi "
        "--bootloader-id=GRUB-UEFI --recheck",
        dry_run=dry_run,
    )

    print("\n  Generating GRUB configuration ...")
    run_in_chroot("grub-mkconfig -o /boot/grub/grub.cfg", dry_run=dry_run)

    print("\n  ✔  GRUB installed and configured.")


# ─────────────────────────────────────────────────────────────────────────────
# Step 11: Enable Services
# ─────────────────────────────────────────────────────────────────────────────


def enable_services(user: str, *, dry_run: bool = False) -> None:
    """Enable all SYSTEM_SERVICES + USER_SERVICES."""
    banner("STEP 11 — Enable System & User Services")

    print("  Enabling system-level services ...")
    for svc in SYSTEM_SERVICES:
        print(f"    systemctl enable {svc}")
        run_in_chroot(f"systemctl enable {svc}", dry_run=dry_run)

    print("\n  Enabling user-level services ...")
    for svc in USER_SERVICES:
        print(f"    systemctl --user enable {svc}  (as {user})")
        # Run as the target user inside chroot using machinectl or sudo -u
        run_in_chroot(
            f"sudo -u {user} XDG_RUNTIME_DIR=/run/user/$(id -u {user}) "
            f"systemctl --user enable {svc} || true",
            dry_run=dry_run,
        )

    print("\n  ✔  Services enabled.")


# ─────────────────────────────────────────────────────────────────────────────
# Step 12: Finalize
# ─────────────────────────────────────────────────────────────────────────────


def finalize(*, dry_run: bool = False) -> None:
    """Exit chroot, umount -R /mnt, prompt for reboot."""
    banner("STEP 12 — Finalize & Reboot")

    print("  Unmounting all partitions safely (umount -R /mnt) ...")
    run_cmd(["umount", "-R", "/mnt"], check=False, dry_run=dry_run)

    print()
    print("  ╔══════════════════════════════════════════════════════════════╗")
    print("  ║          Installation complete!  🎉                         ║")
    print("  ║                                                              ║")
    print("  ║  Remove the installation medium and reboot.                 ║")
    print("  ╚══════════════════════════════════════════════════════════════╝")
    print()

    if confirm("  Reboot now?"):
        run_cmd(["reboot"], dry_run=dry_run)
    else:
        print("  You can reboot manually with: reboot")


# ─────────────────────────────────────────────────────────────────────────────
# Gather User Information Upfront
# ─────────────────────────────────────────────────────────────────────────────


def gather_info() -> dict:
    """Collect all required user inputs before starting the installation."""
    banner("Pre-flight: Gather Installation Parameters")

    print("  Please provide the following information.")
    print("  You can press ENTER to accept defaults where shown.\n")

    username = ask("  New user name (e.g. john)")
    hostname = ask("  Hostname for this machine (e.g. archbox)", default="archlinux")

    print()
    print("  Kernel choice:")
    print("    1. linux       (latest mainline)")
    print("    2. linux-lts   (long-term support)")
    kernel_choice = ""
    while kernel_choice not in ("1", "2"):
        kernel_choice = input("  Enter choice [1/2]: ").strip()
    kernel_pkg = "linux" if kernel_choice == "1" else "linux-lts"

    print()
    print("  Default shell:")
    print("    1. zsh  (recommended)")
    print("    2. bash")
    shell_choice = ""
    while shell_choice not in ("1", "2"):
        shell_choice = input("  Enter choice [1/2]: ").strip()
    default_shell = "zsh" if shell_choice == "1" else "bash"

    print()
    print("  Timezone examples: America/New_York, Europe/London, Asia/Tokyo")
    print("  Run 'timedatectl list-timezones' to see all options.")
    timezone = ask("  Timezone", default="UTC")

    print()
    print("  Locale examples: en_US.UTF-8, de_DE.UTF-8")
    locale = ask("  Locale", default="en_US.UTF-8")

    print()
    print("  Python version to install via pyenv")
    print("  Press ENTER for default (3.13), or type -1 to skip")
    pyenv_version = _version_prompt("  Pyenv Python version", default="3.13")

    print()
    print("  Node.js version to install via nvm")
    print("  Press ENTER for default (lts/krypton), or type -1 to skip")
    print("  Examples: lts/krypton, lts/jod, 22.11.0")
    nvm_version = _version_prompt("  NVM Node version", default="lts/krypton")

    print()
    rustup_nightly = confirm("  Install Rust nightly toolchain via rustup?")

    print()
    print(f"\n  ── Summary ─────────────────────────────────────────────────")
    print(f"  Kernel:    {kernel_pkg}")
    print(f"  Shell:     {default_shell}")
    print(f"  User:      {username}")
    print(f"  Hostname:  {hostname}")
    print(f"  Timezone:  {timezone}")
    print(f"  Locale:    {locale}")
    print(f"  Pyenv:     {pyenv_version or 'skip'}")
    print(f"  NVM:       {nvm_version or 'skip'}")
    print(f"  Rust:      {'nightly' if rustup_nightly else 'skip'}")
    print(f"  ────────────────────────────────────────────────────────────")
    print()

    if not confirm("  Confirm these settings and begin installation?"):
        print("  Aborted by user.")
        sys.exit(0)

    return {
        "username": username,
        "hostname": hostname,
        "timezone": timezone,
        "locale": locale,
        "kernel_pkg": kernel_pkg,
        "default_shell": default_shell,
        "pyenv_version": pyenv_version,
        "nvm_version": nvm_version,
        "rustup_nightly": rustup_nightly,
    }


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Base Arch Linux installation script (run from live ISO).",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print commands without executing them.",
    )
    args = parser.parse_args()
    dry_run: bool = args.dry_run

    if dry_run:
        print()
        print("  *** DRY-RUN MODE — no commands will be executed ***")

    banner("Arch Linux Base Installation Script")
    print("  This script guides you through a complete Arch Linux installation.")
    print("  It must be run from the Arch Linux live ISO environment.")
    print()
    print("  Repository: https://github.com/aland20/.dotfiles")
    print()
    print("  Each step will ask for confirmation before proceeding.")
    print("  You can press Ctrl+C at any time to abort.")
    print()

    if not dry_run and os.geteuid() != 0:
        print("  ERROR: This script must be run as root.")
        print(
            "  On the live ISO, you are already root. Try: sudo python3 base-archlinux.py"
        )
        sys.exit(1)

    # ── Gather info upfront ───────────────────────────────────────────────────
    info = gather_info()
    username = info["username"]
    hostname = info["hostname"]
    timezone = info["timezone"]
    locale = info["locale"]
    kernel_pkg = info["kernel_pkg"]

    # ── Step 1: UEFI verification ─────────────────────────────────────────────
    verify_uefi(dry_run=dry_run)

    # ── Step 2: WiFi ──────────────────────────────────────────────────────────
    setup_wifi(dry_run=dry_run)

    # ── Step 3: Clock & keys ──────────────────────────────────────────────────
    setup_clock_and_keys(timezone, dry_run=dry_run)

    # ── Step 4: Partition ─────────────────────────────────────────────────────
    dual_boot, disk, root_part, efi_part, swap_part = partition_disk(dry_run=dry_run)

    # ── Step 5: Mirrors ───────────────────────────────────────────────────────
    rank_mirrors(dry_run=dry_run)

    # ── Step 6: Parallel downloads ────────────────────────────────────────────
    enable_parallel_downloads("/etc/pacman.conf", dry_run=dry_run)

    # ── Step 7: pacstrap ──────────────────────────────────────────────────────
    run_pacstrap(kernel_pkg, dry_run=dry_run)

    # ── Step 8: fstab ─────────────────────────────────────────────────────────
    generate_fstab(dry_run=dry_run)

    # ── Step 9: arch-chroot setup ─────────────────────────────────────────────
    arch_chroot_setup(
        user=username,
        hostname=hostname,
        timezone=timezone,
        locale=locale,
        default_shell=info["default_shell"],
        pyenv_version=info["pyenv_version"],
        nvm_version=info["nvm_version"],
        rustup_nightly=info["rustup_nightly"],
        dry_run=dry_run,
    )

    # ── Step 10: GRUB ─────────────────────────────────────────────────────────
    setup_grub(dual_boot=dual_boot, efi_device=efi_part, dry_run=dry_run)

    # ── Step 11: Services ─────────────────────────────────────────────────────
    enable_services(user=username, dry_run=dry_run)

    # ── Step 12: Finalize ─────────────────────────────────────────────────────
    finalize(dry_run=dry_run)


if __name__ == "__main__":
    main()
