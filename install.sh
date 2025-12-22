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

  # delete existing partition table.
  wipefs -a -f /dev/nvme0n1

  # create partitions :
  # 1. /dev/nvme0n1p1 for efi  partition taking +512M.
  # 2. /dev/nvme0n1p2 for swap partition taking half of RAM.
  # 3. /dev/nvme0n1p3 for root partition taking rest of the disk.

  (
    echo n     # create new partition (for EFI).
    echo p     # set partition type to primary.
    echo       # set default partition number.
    echo       # set default first sector.
    echo +512M # set +512 as last sector.

    echo n # create new partition (for SWAP).
    echo p # set partition type to primary.
    echo   # set default partition number.
    echo   # set default first sector.
    echo +$(free -g | grep Mem | awk '{print int($2 / 2)}')G

    echo n # create new partition (for Root).
    echo p # set partition type to primary.
    echo   # set default partition number.
    echo   # set default first sector.
    echo   # set default last sector (use rest of the disk).

    echo w # write changes.
  ) | fdisk /dev/nvme0n1 -w always -W always

  # format the created paritions :

  mkfs.fat -F32 /dev/nvme0n1p1 # efi partion.
  mkswap /dev/nvme0n1p2        # swap partion.
  mkfs.ext4 /dev/nvme0n1p3     # root partition.

  # efi partition i.e /dev/nvme0n1p1 will be mounted later to /boot/efi

  # enable swap.
  swapon /dev/nvme0n1p2

  # mount the filesystem.
  mount /dev/nvme0n1p3 /mnt

}

install_essentials() {

  # install essential packages.
  pacstrap -K /mnt amd-ucode base linux linux-firmware linux-firmware-marvell sof-firmware neovim

  # generate fstab file.
  genfstab -U /mnt >>/mnt/etc/fstab

}

setup_arch() {

  # move setup script into /mnt.
  mv ./hope/setup.sh /mnt/setup.sh

  # move config files to /mnt.
  mv ./hope/.config /mnt/

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
