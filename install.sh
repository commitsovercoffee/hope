#!/bin/bash

check_uefi() {
  local fw_size_file="/sys/firmware/efi/fw_platform_size"

  if [[ ! -f "$fw_size_file" ]]; then
    echo "ERROR: System is not booted in UEFI mode (BIOS/CSM detected)."
    echo "Please reboot and select UEFI boot mode in your firmware settings."
    exit 1
  fi

  local fw_size
  fw_size=$(<"$fw_size_file")

  case "$fw_size" in
  64)
    echo "UEFI 64-bit detected. Continuing installation."
    ;;
  32)
    echo "ERROR: UEFI 32-bit detected."
    echo "This installation requires 64-bit UEFI (x64)."
    echo "Bootloader options are limited in 32-bit UEFI."
    exit 1
    ;;
  *)
    echo "ERROR: Unknown UEFI platform size: $fw_size"
    exit 1
    ;;
  esac
}

prepare_disk() {
  set -euo pipefail

  local DISK
  local PART_PREFIX

  # Detect primary disk
  if [[ -b /dev/nvme0n1 ]]; then
    DISK="/dev/nvme0n1"
    PART_PREFIX="p"
    echo "Using NVMe disk: $DISK"

    # Set optimal LBA format (ignore if unsupported)
    nvme format --lbaf=1 "$DISK" || true

  elif [[ -b /dev/sda ]]; then
    DISK="/dev/sda"
    PART_PREFIX=""
    echo "Using SATA disk: $DISK"
  else
    echo "ERROR: No supported disk found (nvme0n1 or sda)."
    exit 1
  fi

  # Calculate swap size (half of RAM, minimum 1G)
  local SWAP_GB
  SWAP_GB=$(free -g | awk '/Mem:/ {print int($2 / 2)}')
  ((SWAP_GB < 1)) && SWAP_GB=1

  echo "Swap size set to ${SWAP_GB}G"

  # Wipe existing partition table and signatures
  wipefs -a -f "$DISK"
  sgdisk --zap-all "$DISK"

  # Create GPT partitions
  sgdisk \
    -n 1:0:+512M -t 1:ef00 -c 1:"EFI System Partition" \
    -n 2:0:+${SWAP_GB}G -t 2:8200 -c 2:"Linux Swap" \
    -n 3:0:0 -t 3:8304 -c 3:"Linux Root (x86-64)" \
    "$DISK"

  # Ensure kernel sees new partitions
  partprobe "$DISK"
  sleep 2

  # Partition paths
  local EFI_PART="${DISK}${PART_PREFIX}1"
  local SWAP_PART="${DISK}${PART_PREFIX}2"
  local ROOT_PART="${DISK}${PART_PREFIX}3"

  # Format filesystems
  mkfs.fat -F 32 "$EFI_PART"
  mkswap "$SWAP_PART"
  mkfs.ext4 -F "$ROOT_PART"

  # Mount filesystems
  mount "$ROOT_PART" /mnt
  mount --mkdir "$EFI_PART" /mnt/boot

  # Enable swap
  swapon "$SWAP_PART"

  echo "Disk preparation completed successfully."
}

install() {
  set -euo pipefail

  # Ensure mirrors are up to date (live environment)
  pacman -Sy --noconfirm reflector
  reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

  # Base package list
  local PKGS=(
    base
    base-devel
    linux
    linux-firmware
  )

  # Detect AMD CPU
  if lscpu | grep -qi "AuthenticAMD"; then
    echo "AMD CPU detected — installing amd-ucode"
    PKGS+=(amd-ucode)
  else
    echo "Non-AMD CPU detected — skipping amd-ucode"
  fi

  # Install base system into /mnt
  pacstrap -K /mnt "${PKGS[@]}"

  genfstab -U /mnt >>/mnt/etc/fstab

  echo "Base system installed successfully."
}

setup() {
  set -euo pipefail

  local SRC_DIR="./hope"
  local TARGET="/mnt"

  # Verify required files exist
  if [[ ! -f "$SRC_DIR/setup.sh" ]]; then
    echo "ERROR: $SRC_DIR/setup.sh not found."
    exit 1
  fi

  if [[ ! -d "$SRC_DIR/.config" ]]; then
    echo "ERROR: $SRC_DIR/.config not found."
    exit 1
  fi

  # Copy files into target system
  install -Dm755 "$SRC_DIR/setup.sh" "$TARGET/setup.sh"
  cp -a "$SRC_DIR/.config" "$TARGET/"

  # Run setup inside chroot
  arch-chroot "$TARGET" /bin/bash /setup.sh

  echo "Chroot setup completed."
}

setfont ter-132b
check_uefi
timedatectl
prepare_disk
install
setup

echo "Installation complete. Unmounting filesystems and rebooting..."

# Ensure all data is written to disk
sync

# Unmount all mounted filesystems under /mnt
umount -R /mnt

# Reboot into the new system
reboot
