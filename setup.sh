#!/bin/bash

# installation config ----------------------------------------------------------

disk="nvme0n1"          # or nvme1n1.
timezone="Asia/Kolkata" # for timezone. duh.
locale="en_US.UTF-8"    # for locale. cough, cough.
username="hope"         # or snowball or whatever.
passwd="changethis"     # for the user.
super="changethistoo"   # for the super user.

# helper functions -------------------------------------------------------------

sync() {
  pacman -S --noconfirm --needed "$@"
}

# arch setup -------------------------------------------------------------------

multilib() {

  # Enable multilib repository for 32-bit applications
  cat >>/etc/pacman.conf <<'EOF'

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

  pacman -Syy

}

users() {

  # set the passwords.
  echo "root:${super}" | chpasswd
  useradd -m -G wheel -s /bin/bash ${username}
  echo "${username}:${passwd}" | chpasswd

  # enable sudo for wheel group.
  sed -i 's/# %wheel ALL=(ALL:ALL) ALL/ %wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

  # create user dirs.
  su - ${username} -c "xdg-user-dirs-update"
  su - ${username} -c "mkdir -p Batcave Sync Zion"

}

localization() {

  # set timezone.
  ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime

  # generate /etc/adjtime.
  hwclock --systohc

  # uncomment required locales from '/etc/locale.gen'.
  sed -i "s/#${locale}/${locale}/" /etc/locale.gen

  # generate locale.
  locale-gen

  # create 'locale.conf'.
  localectl set-locale LANG=${locale}

  # install fonts.
  sync ttf-firacode-nerd nerd-fonts noto-fonts noto-fonts-extra noto-fonts-emoji

}

connectivity() {

  # install packages.
  sync networkmanager network-manager-applet ufw bluez bluez-utils blueman

  # enable services.
  systemctl enable NetworkManager
  systemctl enable ufw.service
  systemctl enable bluetooth.service

  # create the hostname file.
  echo ${username} >/etc/hostname

  # update firewall rules.
  ufw default allow outgoing
  ufw default deny incoming

}

audio() {

  # install audio packages.
  sync sof-firmware pipewire lib32-pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber pavucontrol alsa-utils

}

video() {

  # install video packages.
  sync mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver
}

terminal() {

  # install packages.
  sync ghostty fish starship exa bat btop git neovim rsync cmus

  # set fish as default shell.
  chsh --shell /bin/fish ${username}

}

desktop() {

  # install display server & utils.
  sync xorg-server xorg-xinit xorg-xrandr xorg-xclipboard xclip picom dunst libnotify xbindkeys brightnessctl lxrandr cbatticon slock feh gnome-themes-extra papirus-icon-theme lxappearance xfce4-appfinder xdg-user-dirs

  # install my custom tiling window manager.
  git clone https://github.com/commitsovercoffee/dwm-remix.git /home/${username}/.config/suckless/dwm-remix
  cd /home/${username}/.config/suckless/dwm-remix
  make clean install
  cd "$current_dir"
}

grub() {

  sync grub efibootmgr
  mkdir -p /boot/efi
  if ! mountpoint -q /boot/efi; then
    mount /dev/${disk}p1 /boot/efi || {
      echo "Failed to mount EFI."
      exit 1
    }
  fi
  grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi

  sed -i 's/loglevel=3 quiet/loglevel=3/' /etc/default/grub
  sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub

  grub-mkconfig -o /boot/grub/grub.cfg
}

config() {

  # '20-amdgpu.conf'
  mv .config/20-amdgpu.conf /etc/X11/xorg.conf.d/20-amdgpu.conf

  # 'xinitrc'
  mv .config/.xinitrc /home/${username}/.xinitrc

  # '.xbindkeysrc'
  mv .config/.xbindkeysrc /home/${username}/.xbindkeysrc
  mv .config/.get-vol.sh /home/${username}/.get-vol.sh
  chmod u+x /home/${username}/.get-vol.sh

  # 'Xresources'
  mv .config/.Xresources /home/${username}/.Xresources

  # 'picom'
  mkdir -p /home/${username}/.config/picom
  mv .config/picom.conf /home/${username}/.config/picom/picom.conf

  # 'dunst'
  mkdir -p /home/${username}/.config/dunst
  mv .config/dunstrc /home/${username}/.config/dunst/dunstrc

  # 'lxappearance'
  mkdir -p /home/${username}/.config/gtk-3.0
  mv .config/settings.ini /home/${username}/.config/gtk-3.0

  # wallpaper for 'feh'
  mkdir -p /home/${username}/Pictures
  mv .config/wallpaper.jpg /home/${username}/Pictures/wallpaper.jpg

  # 'touchpad'
  mv .config/30-touch.conf /etc/X11/xorg.conf.d/30-touch.conf

  # 'ghostty'
  mkdir -p /home/${username}/.config/ghostty/themes
  mv .config/config /home/${username}/.config/ghostty/config
  mv .config/0x96f /home/${username}/.config/ghostty/themes/0x96f

  # 'fish'
  mkdir -p /home/${username}/.config/fish/functions
  mv .config/config.fish /home/${username}/.config/fish/config.fish
  mv fish_greeting.fish /home/${username}/.config/fish/functions/fish_greeting.fish

  # 'starship'
  mv .config/starship.toml /home/${username}/.config/starship.toml

  # 'neovim'
  mkdir -p /home/${username}/.config/nvim
  mv .config/init.lua /home/${username}/.config/nvim/init.lua

  # 'zed'
  mkdir -p /home/${username}/.config/zed
  mv .config/keymap.json /home/${username}/.config/zed/keymap.json
  mv .config/settings.json /home/${username}/.config/zed/settings.json

  # 'obs'
  mkdir -p /home/${username}/.config/obs-studio
  mv .config/basic /home/${username}/.config/obs-studio

  # 'cmus  theme'
  mkdir -p /home/${username}/.config/cmus
  mv .config/catppuccin.theme /home/${username}/.config/cmus/catppuccin.theme

  # reset permissions.
  chown -R ${username} /home/${username}/
  chown -R :${username} /home/${username}/

}

current_dir=$PWD

# setup...

multilib     # enable 32 bit apps.
users        # set user accounts.
localization # set timezone & languages.
connectivity # set wifi & bluetooth.
audio        # set audio drivers.
video        # set video drivers.
terminal     # set terminal interface.
desktop      # for graphical interface.
grub         # set bootloader.
config       # set dot files.

# clean dir & exit.

rm -r .config
rm setup.sh
