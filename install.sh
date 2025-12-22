#!/bin/bash

preflight() {

  # verify boot mode.
  [[ "$(cat /sys/firmware/efi/fw_platform_size)" == "64" ]] || {
    echo "Not a 64-bit EFI system. Exiting..."
    exit 1
  }

  # verify internet.
  curl -Is https://archlinux.org >/dev/null ||
    {
      echo "No internet connection. Exiting..."
      exit 1
    }
}

prepare_disks() {

  sgdisk --zap-all /dev/nvme0n1
  sgdisk -n 1:0:+512M -t 1:ef00 /dev/nvme0n1
  sgdisk -n 2:0:+$(free -g | awk '/Mem:/ {print int($2/2)}')G -t 2:8200 /dev/nvme0n1
  sgdisk -n 3:0:0 -t 3:8300 /dev/nvme0n1

  # format the created paritions :

  mkfs.fat -F32 /dev/nvme0n1p1 # efi partion.
  mkswap /dev/nvme0n1p2        # swap partion.
  mkfs.ext4 /dev/nvme0n1p3     # root partition.

  # mount the filesystem.
  mount /dev/nvme0n1p3 /mnt

  # mount efi.
  mount --mkdir /dev/nvme0n1p1 /mnt/boot

  # enable swap.
  swapon /dev/nvme0n1p2

}

install_essentials() {

  # refresh database.
  pacman -Syy reflector --noconfirm
  reflector --country India --protocol https --save /etc/pacman.d/mirrorlist

  # install essential packages.
  pacstrap -K /mnt amd-ucode base base-devel linux linux-firmware linux-firmware-marvell sof-firmware neovim

  # generate fstab file.
  genfstab -U /mnt >>/mnt/etc/fstab

}

setup_arch() {

  # move payload into /mnt.
  mv ./setup.sh /mnt/setup.sh
  mv ./.config /mnt/
  mv ./.settings /mnt/

  # run the setup script from /mnt with arch-chroot.
  arch-chroot /mnt bash setup.sh

}

# Install arch linux :

setfont ter-132b   # set font size.
preflight          # verify booot mode.
prepare_disks      # partition, format & mount disks.
install_essentials # install essential packages.
setup_arch         # setup the arch installation.

if mountpoint -q /mnt; then
  umount -R /mnt || {
    msg "Failed to unmount /mnt"
    exit 1
  }
fi
echo "Remove installation media and press Enter to reboot." && read -r && reboot
