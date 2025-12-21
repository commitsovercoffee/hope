#!/bin/bash
set -euo pipefail

#########################
# EXPRESS INSTALL VARIABLES
#########################

# User & passwords
USERNAME="hope"
USER_PASS="changeme123"
ROOT_PASS="rootpass123"

# Hostname
HOSTNAME="arch"

# Timezone & locale
TIMEZONE="Asia/Kolkata"
LOCALE="en_US.UTF-8"

#########################
# Enable multilib
#########################
multilib() {
  if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    cat <<'EOF' >>/etc/pacman.conf

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
    echo "Multilib repository enabled."
  else
    echo "Multilib already enabled."
  fi
}

#########################
# Timezone
#########################
timezone() {
  ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
  hwclock --systohc
  echo "Timezone set to $TIMEZONE."
}

#########################
# Locale & fonts
#########################
locale() {
  sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
  locale-gen
  echo "LANG=${LOCALE}" >/etc/locale.conf

  pacman -S --noconfirm --needed aspell-en ttf-firacode-nerd noto-fonts noto-fonts-extra noto-fonts-emoji font-manager
  echo "Locale and fonts configured."
}

#########################
# Network
#########################
network() {
  echo "$HOSTNAME" >/etc/hostname

  cat >/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

  pacman -S --noconfirm --needed networkmanager network-manager-applet traceroute linux-firmware linux-firmware-marvell ufw syncthing
  systemctl enable NetworkManager.service
  systemctl enable ufw.service
  systemctl enable "syncthing@${USERNAME}.service"

  ufw --force reset
  ufw default deny incoming
  ufw default allow outgoing

  echo "Network configured."
}

#########################
# Bluetooth
#########################
bluetooth() {
  pacman -S --noconfirm --needed bluez bluez-utils blueman
  systemctl enable bluetooth.service
  rfkill unblock bluetooth || true
  echo "Bluetooth configured."
}

#########################
# Audio
#########################
audio() {
  pacman -S --noconfirm --needed sof-firmware pipewire pipewire-alsa pipewire-pulse wireplumber lib32-pipewire pavucontrol alsa-utils
  echo "Audio stack installed."
}

#########################
# Webcam
#########################
webcam() {
  pacman -S --noconfirm --needed cameractrls
  echo "Webcam utilities installed."
}

#########################
# GPU
#########################
gpu() {
  pacman -S --noconfirm --needed mesa lib32-mesa
  if lspci | grep -qi "VGA.*AMD\|3D.*AMD"; then
    pacman -S --noconfirm --needed xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver
    echo "AMD GPU detected and drivers installed."
  else
    echo "Non-AMD GPU detected, skipping AMD drivers."
  fi
}

#########################
# TUI environment
#########################
tui() {
  local apps=(ghostty fish fisher starship man-db tldr cowsay eza bat btop ncdu git rsync cmus mpv)
  pacman -S --noconfirm --needed "${apps[@]}"

  install -d -o "$USERNAME" -g "$USERNAME" /home/"$USERNAME"/.config
  starship preset nerd-font-symbols -o /home/"$USERNAME"/.config/starship.toml

  sudo -u "$USERNAME" fish -c "fisher install --yes catppuccin/fish"
  sudo -u "$USERNAME" fish -c "fish_config theme save --yes 'Catppuccin Mocha'"

  chsh -s /bin/fish "$USERNAME"
  echo "TUI environment configured."
}

#########################
# GUI environment
#########################
gui() {
  local apps=(xorg-server xorg-xinit xorg-xrandr xclip xorg-xclipboard picom dunst libnotify xbindkeys brightnessctl lxrandr-gtk3 cbatticon xautolock seahorse slock feh gnome-themes-extra papirus-icon-theme gnome-disk-utility dosfstools xfce4-appfinder lxappearance-gtk3 lxinput-gtk3 galculator gnome-screenshot flameshot peek gcolor3 firefox firefox-developer-edition torbrowser-launcher chromium ghostty xfce4-terminal zed mousepad evince foliate ristretto celluloid pavucontrol blueman catfish bitwarden qbittorrent nicotine+ pcmanfm-gtk3 unzip file-roller mtpfs libmtp gvfs gvfs-mtp android-tools android-udev obsidian kolourpaint kdenlive obs-studio steam steam-native-runtime)
  pacman -S --noconfirm --needed "${apps[@]}"

  install -d -o "$USERNAME" -g "$USERNAME" /home/"$USERNAME"/.config/suckless
  git clone https://github.com/commitsovercoffee/dwm-remix.git /home/"$USERNAME"/.config/suckless/dwm-remix
  pushd /home/"$USERNAME"/.config/suckless/dwm-remix
  make clean install
  popd
  chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.config

  echo "GUI environment installed."
}

#########################
# Development environment
#########################
dev() {
  local apps=(zed neovim tree-sitter git github-cli fd ripgrep jq nodejs npm go gopls gofumpt)
  pacman -S --noconfirm --needed "${apps[@]}"
  echo "Development environment installed."
}

#########################
# Users
#########################
users() {
  echo "root:${ROOT_PASS}" | chpasswd

  if ! id -u "$USERNAME" &>/dev/null; then
    useradd -m -G wheel -s /bin/bash "$USERNAME"
  fi
  echo "${USERNAME}:${USER_PASS}" | chpasswd

  sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

  pacman -S --noconfirm --needed xdg-user-dirs
  sudo -u "$USERNAME" xdg-user-dirs-update
  mkdir -p /home/"$USERNAME"/{Batcave,Sync,Zion}
  touch /home/"$USERNAME"/memo.md
  chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"

  echo "User setup completed."
}

#########################
# GRUB & boot
#########################
grub() {
  local EFI_PART
  if [[ -b /dev/nvme0n1 ]]; then
    EFI_PART="/dev/nvme0n1p1"
  elif [[ -b /dev/sda ]]; then
    EFI_PART="/dev/sda1"
  else
    echo "ERROR: No EFI partition detected."
    exit 1
  fi

  pacman -S --noconfirm --needed grub efibootmgr
  mkdir -p /boot/efi
  mount "$EFI_PART" /boot/efi

  grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
  sed -i 's/loglevel=3 quiet/loglevel=3/' /etc/default/grub || true
  sed -i 's/GRUB_TIMEOUT=[0-9]\+/GRUB_TIMEOUT=0/' /etc/default/grub
  grub-mkconfig -o /boot/grub/grub.cfg

  mkinitcpio -P
  systemctl enable fstrim.timer

  echo "GRUB and boot setup completed."
}

#########################
# Execute all steps
#########################
multilib
timezone
locale
network
bluetooth
audio
webcam
gpu
tui
gui
dev
users
grub
