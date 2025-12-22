#!/bin/bash

sync() {
  pacman -S --noconfirm --needed "$@"
}

multilib() {

  # enable multi-lib for 32-bit apps.
  echo "" >>/etc/pacman.conf
  echo "[multilib]" >>/etc/pacman.conf
  echo "Include = /etc/pacman.d/mirrorlist" >>/etc/pacman.conf
  pacman -Syu

}

users() {

  # set the root password.
  echo "Specify password for root user. This will be used to authorize root commands."
  passwd

  # add regular user.
  useradd -m -G wheel -s /bin/bash "hope"

  # set password for new user.
  echo "Specify password for regular user."
  passwd "hope"

  # enable sudo for wheel group.
  sed -i 's/# %wheel ALL=(ALL:ALL) ALL/ %wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

}

localization() {

  # set timezone.
  ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

  # generate /etc/adjtime.
  hwclock --systohc

  # uncomment required locales from '/etc/locale.gen'.
  sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen

  # generate locale.
  locale-gen

  # create 'locale.conf'.
  localectl set-locale LANG=en_US.UTF-8

  # install fonts.
  sync ttf-firacode-nerd nerd-fonts noto-fonts noto-fonts-extra noto-fonts-emoji

}

connectivity() {

  # install packages.
  sync networkmanager network-manager-applet ufw bluez bluez-utils blueman

  # create the hostname file.
  echo "arch" >/etc/hostname

  # enable services.
  systemctl enable NetworkManager
  systemctl enable ufw.service
  systemctl enable bluetooth.service

  # allow outgoing & reject incoming.
  ufw default allow outgoing
  ufw default deny incoming

}

audio() {

  # install packages.
  sync sof-firmware pipewire lib32-pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber pavucontrol alsa-utils

}

graphics() {

  # install packages.
  sync mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver

  # create xorg config.
  mkdir -p /etc/X11/xorg.conf.d
  cp ./.settings/20-amdgpu.conf /etc/X11/xorg.conf.d/

}

terminal() {

  # install terminal packages.
  sync ghostty fish starship exa bat cowsay

  # set starship.
  starship preset nerd-font-symbols -o /home/hope/.config/starship.toml

  # set fish as default shell.
  chsh --shell /bin/fish hope

}

desktop() {

  # install display server & utils.
  sync xorg-server xorg-xinit xorg-xrandr xorg-xclipboard xclip picom dunst libnotify xbindkeys brightnessctl lxrandr cbatticon slock feh gnome-themes-extra papirus-icon-theme lxappearance xfce4-appfinder xdg-user-dirs

  # clone my pre-patched dwm repo.
  git clone https://github.com/commitsovercoffee/dwm-remix.git /home/hope/.config/suckless/dwm-remix

  # install dynamic window manager.
  cd /home/hope/.config/suckless/dwm-remix
  make clean install
  cd "$current_dir"

  # set xinitrc.
  mv ./.settings/.xinitrc /home/hope/.xinitrc

  # set dpi.
  mv ./.settings/.Xresources /home/hope/.Xresources

  # set key bindings.
  mv ./.settings/.xbindkeysrc /home/hope/.xbindkeysrc
  mv ./.settings/.get-vol.sh /home/hope/.get-vol.sh
  chmod u+x /home/hope/.get-vol.sh

  # set touchpad.
  mkdir -p /etc/X11/xorg.conf.d
  cp ./.settings/30-touch.conf /etc/X11/xorg.conf.d/

  # create home directories.
  mkdir -p /home/hope/{Desktop,Documents,Downloads,Music,Pictures,Sync,Videos,Zion}

  # copy dot files.
  mkdir -p /home/hope/.config
  cp -a ./.config/. /home/hope/.config/

  # set wallpaper.
  mv ./.settings/wallpaper.jpg /home/hope/Pictures/wallpaper.jpg

  # reset permissions.
  chown -R hope /home/hope/
  chown -R :hope /home/hope/

  # enable TRIM for SSDs.
  systemctl enable fstrim.timer

}

grub() {

  # install required packages.
  pacman -S grub efibootmgr --noconfirm

  # install grub.
  grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot --recheck

  # enable logs.
  sed -i 's/loglevel=3 quiet/loglevel=3/' /etc/default/grub

  # generate grub config.
  grub-mkconfig -o /boot/grub/grub.cfg

}

# setup...

current_dir=$PWD

multilib     # enable 32-bit apps.
users        # create users.
localization # set time & locale.
connectivity # set network & bluetooth.
audio        # set audio.
graphics     # set video.
terminal     # set terminal.
desktop      # set dwm.
grub         # set bootloader.

# graceful exit ...

rm setup.sh
rm -r .config
rm -r .settings
