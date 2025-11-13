# Comprehensive Guide to Install Arch Linux with/out Dual Booting

This guide assumes you have booted to arch linux and you are ready to install
archlinux.

## Resources

- **[Official Archlinux Installation Guide](https://wiki.archlinux.org/title/installation_guide)**
- **[Official Archlinux General Recommendation Wiki](https://wiki.archlinux.org/title/General_recommendations)**
- [**Configure Bluetooth Wiki**](https://wiki.archlinux.org/title/Bluetooth)

- You made a mistake during installation? Forgot to install a package such as
  network? Go back to your arch installt and mount your arch root drive, then
  use `pacstrap` to install any additional packages you would like.

---

<details>
<summary>

## Connecting To Internet (Wifi)

</summary>

- **[IWD Official Wiki](https://wiki.archlinux.org/title/iwd)**
- Arch comes with `iwd` package where it can automatically setup DHCP, but you
  have to enable DHCP because by default it's disabled.
- Another thing to keep in mind is that, by default arch uses `systemd-resolved`
  DNS manager. This can work without any issue but in certain circumstances (in
  my case, it wasn't working properly) it doesn’t work as intended especially
  with DHCP. In order to fix this, we have another option for DNS management
  which is switching to `resolvconf`.
- Make/modify the config file at `/etc/iwd/main.conf`, put the following config:

  ```bash
  [General]
  EnableNetworkConfiguration=true # Enable DHCP

  [Network]
  EnableIPv6=true                 # Enable acquiring IPv6
  RoutePriorityOffset=300         # Set route metric to choose better routing

  # If systemd-resolved doesn't work, then you may switch
  NameResolvingService=resolvconf # Switch to resolvconf from systemd-resolved
  ```

- After the configuration is set, restart `iwd` service, then connect to your
  wifi using `iwctl`.

  ```bash
  # Restart iwd service to apply configs
  systemctl restart iwd

  # Enter iwctl
  iwctl

  # 1. Get device/interface name
  [iwctl] device list

  # 2. Make sure it's poewered on
  [iwctl] device <dev-name> set-property Poewered on
  [iwctl] adapter <adapter-name> set-property Poewered on

  # 3. scan then get nearby networks
  [iwctl] station <dev-name> scan
  [iwctl] station <dev-name> get-networks

  # 4. Connect to your wifi
  [iwctl] station <dev-name> connect "SSID"

  # 5. quit iwctl and now you are connected!
  [iwctl] quit

  # Test your internet connection
  ping archlinux.org
  ```

</details>

<details>
<summary>

## Archlinux Base Installation

</summary>

Make sure to follow the steps and do necessary research if you don't understand
a step. You may occasionally encounter small notes that gives more clarification
as needed.

1. Try to connect to Wifi. (if not, follow the previous step)
2. To verify the boot mode, check the UEFI bitness. If it’s 64 then the system
   is booted in UEFI mode and has a 64-bit x64 UEFI. And if it’s 32 then the
   system is booted in UEFI mode and has a 32-bit IA32 UEFI. It’s always better
   to boot into 64-bit.

   ```bash
   cat /sys/firmware/efi/fw_platform_size
   ```

3. Verify EFI boot. **You should see several files there**. Make sure you are
   booting EFI mode and you are ready to install Arch.

   ```bash
   ls /sys/firmware/efi/efivars
   ```

4. Update system clock and set timezone. Also, update pacman keys

   ```bash
   timedatectl  # Info about DateTime

   #####
   # Automatic setup - Requires internet
   #####
   timedatectl set-ntp true

   #####
   # Manually setting Timezone
   #####
   # 1. Get your timezone
   timedatectl list-timezones

   # 2. Set timezone
   timedatectl set-time America/New_York

   ####
   # Update Pacman keys
   ####
   pacman-key --init
   pacman-key --populate archlinux
   pacman-key --populate archlinuxarm # For ARM Architecture
   ```

5. **Partitioning, Formatting, Swap:**

   1. Use `lsblk` to look at the connected devices in order to find your hard
      drive.

      ```bash
      # List connected devices, find your hard drive
      lsblk
      ```

   2. After that, you can create, modify, or delete partitions using `cfdisk`
      which is very easy to use. When entering `cfdisk`, you have to create
      `EFI System` (Not required for dual booting with Windows), `Linux Swap`,
      and `Linux Filesystem`, partitions. Don't forget when you are dual
      booting, you have access to Windows' EFI System partition, therefore, you
      don't need to create it if you have already installed Windows.

      ```bash
      cfdisk <device>     # Use lsblk to find the device
      cfdisk /dev/nvme0n1 # Example having NVMe as hard drive
      ```

   3. After partitioning, use `mkfs` to format the partitions. Use `ext4` for
      linux filesystem. And follow the commands to create a swap (Do your own
      research to choose the amount of disk for swap partition).

      ```bash
      ###
      # Format Linux Filesystem Partition
      ###
      # nvme0n1 is the hard drive, p5 is the file system partition for the hard drive.
      mkfs.ext4 /dev/nvme0n1p5

      ###
      # Format EFI Filesystem Partition
      ###
      # SKIP THIS STEP IF YOU ARE DUAL BOOTING
      # YOU LOSE WINDOWS BOOTLOADER IF YOU ARE DUAL BOOTING.
      # If you have a clean EFI System partition, Format it.
      # nvme0n1 is the hard drive, p1 is the EFI system partition.
      mkfs.fat -F32 /dev/nvme0n1p1

      ###
      # Make the swap
      ###
      # nvme0n1 is the hard drive, p6 is the swap partition.
      mkswap /dev/nvme0n1p6
      swapon /dev/nvme0n1p6
      ```

6. Mount your root (Linux Filesystem) partition to `/mnt` (this can be any where
   but this is the most popular one) and boot (EFI Filesystem) partition to
   `/mnt/efi` or `/mnt/boot`.
   [Read this official documentation](https://wiki.archlinux.org/title/EFI_system_partition#Mount_the_partition)
   to whether choose `/mnt/efi` or `/mnt/boot`. For this guide, I will be using
   `/mnt/efi`.

   ```bash
   # nvme0n1 is hard drive, p5 is the file system partition
   mount /dev/nvme0n1p5 /mnt

   # nvme0n1 is hard drive, p1 is the EFI Filesystem partition
   # --mkdir will create /mnt/efi dir using mkdir if doesnt exist.
   mount --mkdir /dev/nvme0n1p1 /mnt/efi
   ```

   - **Note**: the given documentation link or some usually enter into
     `arch-chroot` mode then mounts `EFI`. They usually refer it as `/efi` or
     `/boot`. In this guide, we do it before entering `arch-chroot`. Since we
     use `/mnt` as the root partition, we have to put the `EFI` within the root
     partition. Since `arch-chroot` mode simply switches our root to `/mnt` or
     the mounted point you have created. So, basically when you enter
     arch-chroot, you are referring to `/boot` or `/efi` for the EFI, but when
     you do it before entering arch-chroot, you are referring to `/mnt/boot` or
     `/mnt/efi`.

7. Update pacman to top 10 fastest servers. Here are two ways to achieve this.

   - First, you have to backup `/etc/pacman.d/mirrorlist` then use one of the
     following methods:

     ```bash
     # Backupi existing mirror list
     cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
     ```

   1. `rankmirrors`: pick top 10. To rank top 10, we need to install
      `pacman-contrib` package.

      ```bash
      # Install pacman-contrib to rank servers
      pacman -Sy pacman-contrib

      # Using rankmirrors with mirrorlist.bak to pick top 10
      rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist
      ```

   2. `Reflector`: install `reflector` and sort by the fastest one.

      ```bash
      sudo pacman -Sy reflector

      # Sort top 10 servers for someone who lives in Poland
      reflector -c Poland --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
      ```

8. Enable parallel downloading for pacman. Add or uncomment the following line
   at `/etc/pacman.conf`.

   ```bash
   [options]
   ParallelDownloads=5
   ```

9. Using `pacstrap` to Install essential packages to the root partition which
   was mounted at `/mnt` or whatever point you have chosen. These packages will
   be accessible when you enter arch-chroot mode, make sure to install all the
   necessary packages you need, such as network manager, DHCP, editors, etc.
   Make sure packages exist in
   [Arch Repository](https://archlinux.org/packages/).

   ```bash
   pacstrap -K /mnt <packages>

   # Install linux base packages and necessary tools
   pacstrap -K /mnt base base-devel linux-lts linux-firmware linux-headers intel-ucode networkmanager dhcpcd pipewire wpa_supplicant netctl ntfs-3g bluez bluez-utils

   # Install necessary applications
   pacstrap -K /mnt inetutils net-tools sudo htop openssh ufw git nano vim neovim fastfetch cups dialog

   # Extra if you need
   pacstrap -K /mnt 
   ```

   - Basic Arch Linux installation: `base`
   - Tools to build Arch Linux packages. i.e, dev tools: `base-devel`
   - Linux kernels: `linux-lts`, `linux-headers`, (want latest kernel? install
     `linux` instead of `linux-lts`)
   - Microcode: `intel-ucode` or `amd-ucode`
   - Bluetooth utilities: `bluez`, `bluez-utils`
   - Network managers: `netctl`
   - Mount NTFS disk: `ntfs-3g`
   - DNS managers: `networkmanager` (includes nmcli), `dhcpcd`
   - Network utilities: `inetutils`, `net-tools`
   - Printing: `cups`
   - Dialog in CLI: `dialog`

10. Generate UUID for partitions. the `/mnt` is our root partition

    ```bash
    genfstab -U /mnt >> /mnt/etc/fstab
    ```

    - **Note**: using `-U` flag will use UUID of the partition instead of using
      the partition name. This is useful when you swap to another hard drive,
      where the UUID is fixed but the hard drive name could change. For this
      reason, we use `-U` to generate the fs tabs.

11. Now enter arch-chroot where `/mnt` is the root partition.

    ```bash
    # Make sure home directory exists in root partition
    mkdir /mnt/home

    # Enter arch-chroot
    arch-chroot /mnt
    ```

</details>

<details>
<summary>

## Entering arch-chroot

</summary>

- Fun Note: you have several ttys, you can switch between them using
  `Alt + arrows` or `Ctrl + Alt + <F1, F2, etc…>`
- Make sure to follow the steps and do necessary research if you don't
  understand a step.

1. We have to set up the basics of the system such as, date time, hostname,
   sudo, users, etc..

   ```bash
   # Update packages
   pacman -Syu

   # Change root password
   passwd

   # Change hostname
   echo "ArchLinux" >> /etc/hostname

   # If sudo  group is not there, create it
   groupadd sudo

   # Add users with home directory
   useradd -G sudo,wheel,storage,power,audio,video,input -m <user>
   passwd <user>      # Set user password

   # Edit visudo, default editor is vim
   EDITOR=nvim visudo
   # Uncomment %sudo ALL=(ALL) ALL
   # You could add timeout when user is required to enter their password, below the previous line, add the following line to prompt user after certain time to enter their password again, if it's 0, it asks for every single operation. (asking for every operation could be annoying!)
   Defaults timestamp_timeout=0

   # Set locale by uncomment the locale and then generate
   vim /etc/locale.gen # Example: en_US.UTF-8
   locale-gen
   echo LANG=en_US.UTF-8 > /etc/locale.conf
   export LANG=en_US.UTF-8

   # Edit hosts file
   vim /etc/hosts
   # Put the following there:
   127.0.0.1         localhost
   ::1               localhost
   127.0.1.1         <your-host>.localdomain        <host>

   # Set local time
   ln -sf /usr/share/zoneinfo/<Region/City> /etc/localtime
   ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
   hwclock --systohc # Sync time

   # Add multilib repository to pacman
   # Uncomment the following at /etc/pacman.conf
   [multilib]
   Include = /etc/pacman.d/mirrorlist

   # Enable pacman parallel downloading
   # Add or uncomment the following in /etc/pacman.conf
   [options]
   ParallelDownloads=5
   ```

2. Install necessary applications

   - **[List of Applications](https://wiki.archlinux.org/title/List_of_applications/Utilities)**
   - Here are a few programs that may get you started with Arch Linux:
     ```bash
     pacman -S firefox libsecret brightnessctl playerctl acpi pipewire pipewire-alsa pipewire-pulse wireplumber mupdf ydotool

     # Extra apps if using Tiling Window Managers
     pacman -S  gnome-keyring seahorse blueman qtkeychain-qt5 openssl-1.1 feh thunar grim slurp mako gvfs
     ```
     - Stores passwords and encryption keys: `gnome-keyring`, `libsecret`,
       `seahorse` (GUI for gnome-keyring), perhaps you may go for `keepassxc`
     - Bluetooth GUI: `blueman`
     - Network Manager GUI: `network-manager-applet`
     - Brightness & Audio Control: `brightnessctl`, `playerctl`
     - device configuration and power management: `acpi`
     - Audio: `pipewire`, `pipewire-alsa`, `pipewire-pulse`, `wireplumber`
     - image Viewer: `feh`
     - File Explorer: `thunar` (gvfs to have more control)
     - Document Viewer: `mupdf`
     - Snipping & Screenshot: `grim` (also install `slurp`)
     - Notification: `mako`
     - Change Appearance: `lxappearance` (Xorg)
     - Send Programmatic Input Events: `xdotool` (Xorg), `ydotool` (Wayland)
     - Debugging Key events: `wev` (Wayland), `xev` (Xorg), `showkeys`

3. Setting up grub boot loader.
   **[Read More At Arch Wiki Documentation](https://wiki.archlinux.org/title/GRUB)**.

   ```bash
   # 1. Install packages
   pacman -Syu grub efibootmgr dosfstools mtools os-prober

   # 2. Edit default grub file, if you are using dual boot
   vim /etc/default/grub
   # Uncomment
   GRUB_DISABLE_OS_PROBER=false

   # 3. Install grub for x86 architecture CPU
   grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB-UEFI --recheck

   # 4. Generate Grub Configurations
   grub-mkconfig -o /boot/grub/grub.cfg

   # If for some reasons, it couldn't detect other boot loaders on dual booting
   # Try to manually add them at /etc/grub.d/40_custom (require re-generating Grub config)
   # Or you can create /boot/grub/custom.cfg and add them there (Does not require re-generate Grub config)

   # Config Example to add Windows bootloader to Grub list:
   # 1. Get your EFI UUID partition. nvme0n1 is the hard disk, p1 is EFI System partition
   sudo blkid /dev/nvme0n1p1

   # 2. Here is the config for /etc/grub.d/40_custom or /boot/grub/custom.cfg
   menuentry 'Windows 10' {
       search --fs-uuid --no-floppy --set=root <EFI-UUID-HERE>
       chainloader (${root})/EFI/Microsoft/Boot/bootmgfw.efi
   }

   # Note: 'grub-update' is just a wrapper around 'grub-mkconfig'
   # 3. run this to generate the /boot/grub/menu.cfg file
    grub-mkconfig -o /boot/grub/grub.cfg
   # or, since update-grub calls grub-mkconfig
    update-grub
   ```

4. Don’t forget to Enable your services.

   ```bash
   systemctl enable dhcpcd
   systemctl enable NetworkManager
   systemctl enable docker
   systemctl enable containerd
   systemctl enable sshd
   systemctl enable acpid
   systemctl enable bluetooth

   systemctl --user enable gnmoe-keyring-daemon    # You may need to start the daemon: gnmoe-keyring-daemon --start -d
   systemctl --user enable ydotool
   systemctl --user enable pipewire
   systemctl --user enable pipewire-pulse
   systemctl --user enable wireplumber
   systemctl --user enable redshift

   # This is good for SSD drives
   systemctl enable fstrim.timer
   ```

5. Finally, exit from arch-chroot then reboot safely.

   ```bash
   # Exit from arch-chroot
   exit

   # Unmount safely, This helps to notice any "busy" partitions, and finding the cause fuser before booting to arch.
   umount -R /mnt

   # Reboot if everything is okay.
   reboot
   ```

</details>

<details>
<summary>

## Internet Connection Issue After Reboot

</summary>

- If for some reasons it fails to connect to internet after rebooting, or the
  service fails to retrieve an IP address. There are two ways to do:
- **First Method**: Using `nmcli` to connect to WIFI.

  ```bash
  # Find wifi
  nmcli device wifi list

  # Connect
  nmcli dev wifi connect "SSID" password "pwd"
  ```

- **Second Method**: Using `netctl` to connect to WIFI. this must be installed
  before exiting EFI mode.

  ```bash
  # 1. Copy an example at /etc/netctl/examples
  sudo cp /etc/netctl/examples/wireless-wpa /etc/netctl/wireless-wpa

  # 2. Uncomment the following line at /etc/netctl/wireless-wpa
  # Make sure it's pointing to a correct interface
  DHCPClient=dhcpcd

  # 3. Enable and start dhcpcd
  sudo systemctl enable dhcpcd
  sudo systemctl start dhcpcd
  ```

</details>
