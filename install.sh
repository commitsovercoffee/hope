#!/bin/bash
# This script installs the base arch system.

check_uefi() {

	# check if system is booted in UEFI mode.
	if [ ! -d "/sys/firmware/efi/efivars" ]; then
		# if not, display error & exit.
		echo "[Error!] Reboot in UEFI mode and try again."
		exit 1
	fi

}

prepare_disk() {

	# Change to optimal logical sector size
	nvme format --lbaf=1 /dev/nvme0n1

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

	# efi partition ~ /dev/nvme0n1p1
	# will be mounted later to /boot/efi

	# enable swap.
	swapon /dev/nvme0n1p2

	# mount the filesystem.
	mount /dev/nvme0n1p3 /mnt

}

install() {

	# install essential packages.
	pacstrap -K /mnt linux linux-firmware base base-devel

	# generate fstab file.
	genfstab -U /mnt >>/mnt/etc/fstab

}

setup() {

	# move setup script into /mnt.
	mv ./hope/setup.sh /mnt/setup.sh

	# move config files to /mnt.
	mv ./hope/.config /mnt/

	# run the setup script from /mnt with arch-chroot.
	arch-chroot /mnt bash setup.sh

}

# Install arch linux :

check_uefi   # verify boot mode.
timedatectl  # update system clock.
prepare_disk # partition & format disk.
install      # install vanilla arch.
setup        # setup system.

# unmount paritions & reboot.
umount -R /mnt
reboot
