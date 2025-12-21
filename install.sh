#!/bin/bash

# installation config ----------------------------------------------------------

disk="nvme0n1"  # or nvme1n1.
country="India" # for reflector mirrorlist.

# helper functions -------------------------------------------------------------

msg() {
  clear
  echo -e "\n$1\n"
  sleep 2
}

# arch install -----------------------------------------------------------------

preflight() {

  # verify boot mode.
  [[ "$(cat /sys/firmware/efi/fw_platform_size)" == "64" ]] || {
    msg "Not a 64-bit EFI system. Exiting..."
    exit 1
  }

  # verify internet connection.
  curl -Is https://archlinux.org >/dev/null ||
    {
      msg "No internet connection. Exiting..."
      exit 1
    }
}

prepare_disks() {

  wipefs -a -f /dev/${disk} || {
    msg "Failed to wipe filesystem signatures on /dev/${disk}"
    exit 1
  }

  # create partitions :
  # 1. /dev/${disk}p1 i.e EFI  (+512M)
  # 2. /dev/${disk}p2 i.e Swap (half of RAM)
  # 3. /dev/${disk}p3 i.e Root (rest of disk)

  swap_size="$(free -g | awk '/Mem:/ {print int($2/2)}')"

  sgdisk --zap-all /dev/${disk} || exit 1

  sgdisk \
    -n 1:0:+512M -t 1:ef00 \
    -n 2:0:+"${swap_size}"G -t 2:8200 \
    -n 3:0:0 -t 3:8300 \
    /dev/${disk} || {
    msg "Partitioning failed"
    exit 1
  }

  partprobe /dev/${disk}

  # format the created partitions:

  mkfs.ext4 /dev/${disk}p3 || {
    msg "Failed to format root partition"
    exit 1
  }
  mkswap /dev/${disk}p2
  mkfs.fat -F 32 /dev/${disk}p1

  # mount created partitions:

  mount /dev/${disk}p3 /mnt || {
    msg "Failed to mount root partition"
    exit 1
  }
  mount --mkdir /dev/${disk}p1 /mnt/boot
  swapon /dev/${disk}p2

}

install_essentials() {

  # create (geographically closest) mirrorlist.
  pacman -S reflector --noconfirm
  reflector --country ${country} --protocol https --save /etc/pacman.d/mirrorlist

  # install essential packages
  pacstrap -K /mnt amd-ucode base linux linux-firmware linux-firmware-marvell sof-firmware

}

setup_arch() {

  # generate fstab file to get filesystems mounted on startup.
  genfstab -U /mnt >>/mnt/etc/fstab

  # move payload into /mnt.
  mv ./hope/setup.sh /mnt/setup.sh
  mv ./hope/.config /mnt/

  # run the setup script from /mnt with arch-chroot.
  arch-chroot /mnt bash setup.sh
}

setfont ter-132b
preflight
prepare_disks
install_essentials
setup_arch

if mountpoint -q /mnt; then
  umount -R /mnt || {
    msg "Failed to unmount /mnt"
    exit 1
  }
fi
echo "Remove installation media and press Enter to reboot." && read -r && reboot
