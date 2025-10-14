# Secure Boot with Self-enroll Keys

## References

- [Arch Wiki - UEFI/Secure Boot](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot)
- [Man Page - sbctl](https://man.archlinux.org/man/sbctl.8#USAGE)
- [GitHub - Secure Boot on Arch with Grub](https://github.com/fumofumoenjoyer/secureboot-grub-arch-artix)

## 1. Before Everything

1. You need the following packages to install:
  ```bash
  sudo pacman -Sy efitools sbctl
  ```
2. Backup your existing EFI variables, just in case something happens, and keep them safe somewhere. It will put the existing EFI variables in its own files.
  ```bash
  for var in PK KEK db dbx ; do efi-readvar -v $var -o old_${var}.esl ; done
  ```
3. Put your computer into **Setup Mode** by going into BIOS and then reset the Platform keys. It's fine to reset or delete them! Usually you'd have to enable secure boot to reset the PK (Platform Keys), therefore, you need to enable secure boot and enter the OS while secure boot enabled with PK being reset to factory.


## 2. Grub

Re-install GRUB to utilize Microsoft's CA certificates (as opposed to shim) -- replace 'esp' with your EFI system partition (in most standard systems is either `/boot/efi` or `/efi`):
```bash
sudo grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 3. sbctl

1. Verify you are in **Setup Mode**:
  ```bash
  sudo sbctl status
  ```
2. Create your own custom keys:
  ```bash
  sudo sbctl create-keys
  ```
3. Enroll your own keys. The `-m` flag stands for Microsoft, and `-f` flag stands for firmware builtin.
  ```bash
  sudo sbctl enroll-keys -m -f
  ```
  - **BE CAREFUL!!** Some firmware is signed and verified with Microsoft's keys when secure boot is enabled. Not validating devices could brick the whole computer. To enroll your keys without enrolling Microsoft's, run: `sbctl enroll-keys`. Only do this if you know what you are doing. In the majority of the cases, don't do it unless you are willing to take the risks.
4. Check what files needs to be signed with the new key:
  ```bash
  sudo sbctl verify
  ```
5. You might see a lot of files especially with dual-booting, therefore, simply use the following `sed` command to sign everything.
  ```bash
  sudo sbctl verify | sudo sed -E 's|^.* (/.+) is not signed$|sbctl sign -s "\1"|e'
  ```
6. Don't forget to sign the kernels as well, they are located at `/boot` and they start with `vmlinuz-`.
  ```bash
  sudo sbctl sign -s /boot/vmlinuz-linux
  sudo sbctl sign -s /boot/vmlinuz-linux-g14
  ```
7. Verify everything is signed and status is good.
  ```bash
  sudo sbctl verify
  sudo sbctl status
  ```
