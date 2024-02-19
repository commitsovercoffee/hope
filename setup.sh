#!/bin/bash
# This script configures the installed arch linux for daily use.

multilib () {

    # enable multi-lib for 32-bit apps.
    echo "" >> /etc/pacman.conf
    echo "[multilib]" >> /etc/pacman.conf
    echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

    # refresh database.
    pacman -Syy reflector
    reflector --country India --protocol https --save /etc/pacman.d/mirrorlist

}

timezone () {

    # set timezone.
    ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

    # set the hardware clock from the system clock.
    hwclock --systohc

    # enable network time sync.
    timedatectl set-ntp true

}

locale () {

    # uncomment required locales from '/etc/locale.gen'.
    sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen

    # generate locale.
    locale-gen

    # set system locale ~ creates 'locale.conf'.
    localectl set-locale LANG=en_US.UTF-8

    # install fonts.
    pacman -S ttf-firacode-nerd nerd-fonts noto-fonts noto-fonts-extra noto-fonts-emoji font-manager --noconfirm

}

network () {

    # create the hostname file.
    echo "arch" > /etc/hostname

    # install & enable network.
    pacman -S networkmanager network-manager-applet --noconfirm
    systemctl enable NetworkManager

    # add entries for localhost to '/etc/hosts' file.
    # ( if the system has a permanent IP address, it should be used instead of 127.0.1.1 )
    echo -e 127.0.0.1'\t'localhost'\n'::1'\t\t'localhost'\n'127.0.1.1'\t'arch >> /etc/hosts

    # install & enable firewall.
    pacman -S ufw --noconfirm
    systemctl enable ufw

    # allow outgoing & reject incoming.
    ufw default allow outgoing
    ufw default deny incoming

}

bluetooth () {

    # install bluetooth.
    pacman -S blueman bluez bluez-utils --noconfirm
    lsmod | grep btusb
    rfkill unblock bluetooth
    systemctl enable bluetooth.service

}

audio () {

    # install audio packages.
    pacman -S pipewire lib32-pipewire wireplumber pipewire-audio pipewire-alsa pipewire-pulse sof-firmware pavucontrol --noconfirm

}

chipset () {

    # install microcode for amd.

    vendor="$(lscpu | grep 'Model name')"

    if [[ "$vendor" == *"AMD"* ]]; then
        echo "AMD CPU Found !"
        pacman -S amd-ucode --noconfirm
    fi

}

gpu () {

    # DRI driver for 3D acceleration.
    pacman -S mesa lib32-mesa --noconfirm

    vendor="$( lspci -v | grep -iE 'vga|3d|2d')"

    if [[ "$vendor" == *"AMD"* ]]; then
        echo "AMD GPU Found !"

        # DDX driver which provides 2D acceleration in Xorg
        pacman -S xf86-video-amdgpu --noconfirm

        # vulkan support
        pacman -S vulkan-radeon lib32-vulkan-radeon --noconfirm

        # accelerated video decoding
        pacman -S libva-mesa-driver lib32-libva-mesa-driver --noconfirm

        # "20-amdgpu.conf" will be copied in the config section.

    fi

}

tui () {

    # install packages for a seamless terminal workflow.
    apps=(

        'fish'                  # user-friendly shell
        'fisher'                # fish package manager
        'starship'              # shell prompt
        'tldr'                  # concise command examples

        'exa'                   # alternative to `ls`
        'bat'                   # alternative to `cat`

        'git'                   # version control
        'github-cli'
        'neovim'                # text editor
        'neovide'
        'xclip'                 # clipboard manipulation tool

        'fd'                    # file search
        'ripgrep'               # search tool that combines the usability of ag with the raw speed of grep

        'nodejs'                # Evented I/O for V8 javascript
        'npm'                   # package manager for javascript

        'btop'                  # task manager
        'gdu'                   # disk util info
        'bandwhich'             # bandwidth util info

    )

    for app in "${apps[@]}"; do
        pacman -S "$app" --noconfirm --needed
    done

    # set preset for starship prompt
    starship preset nerd-font-symbols -o ~/.config/starship.toml

    # clone suckless fork. (this command also creates .config dir as root)
    git clone https://github.com/commitsovercoffee/suckless.git /home/hope/.config/suckless

    # install suckless terminal
    cd  /home/hope/.config/suckless/st
    make clean install; cd "$current_dir"

    # set theme for fish shell.
    fish -c "fisher install catppuccin/fish"
    fish -c "fish_config theme save "Catppuccin Mocha""

    # set defaults.
    chsh --shell /bin/fish hope
    echo "export VISUAL=nvim" | tee -a /etc/profile
    echo "export EDITOR=$VISUAL" | tee -a /etc/profile
    echo "export TERMINAL=st" | tee -a /etc/profile

}

gui () {

    apps=(

        # install display server :

        'xorg-server'               # xorg display server.
        'xorg-xinit'                # xinit ~ to start xorg server.
        'xorg-xrandr'               # tui for RandR extension.
        'xorg-xclipboard'           # xclipboard ~ clipboard manager.

        # install graphical utils :

        'picom'                     # X compositor.
        'dunst'                     # notification daemon.

        'feh'                       # desktop wallpaper.
        'gnome-themes-extra'        # window themes.
        'papirus-icon-theme'        # icon themes.

        'dmenu'                     # app menu.
        'lxappearance'              # theme switcher.
        'lxinput-gtk3'              # configure keyboard & mouse.

        'pcmanfm-gtk3'              # file manager.
        'firefox'                   # browser.

    )

    for app in "${apps[@]}"; do
        pacman -S "$app" --noconfirm --needed
    done

    # install dynamic window manager.
    cd /home/hope/.config/suckless/dwm
    make clean install; cd "$current_dir"

    # install dmenu.
    cd /home/hope/.config/suckless/dmenu
    make clean install; cd "$current_dir"

    # install slstatus.
    cd /home/hope/.config/suckless/slstatus
    make clean install; cd "$current_dir"

}

users () {

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

    # create directories for user.
    pacman -S xdg-user-dirs --noconfirm; xdg-user-dirs-update

}

grub () {

    # install required packages.
    pacman -S grub efibootmgr --noconfirm

    # create directory to mount EFI partition.
    mkdir /boot/efi

    # mount the EFI partition.
    mount /dev/nvme0n1p1 /boot/efi

    # install grub.
    grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi

    # enable logs.
    sed -i 's/loglevel=3 quiet/loglevel=3/' /etc/default/grub

    # generate grub config.
    grub-mkconfig -o /boot/grub/grub.cfg

}

config () {

    # 'xinitrc'
    mv .config/.xinitrc /home/hope/.xinitrc

    # 'Xresources'
    mv .config/.Xresources /home/hope/.Xresources

    # '20-amdgpu.conf'
    mv .config/20-amdgpu.conf /etc/X11/xorg.conf.d/20-amdgpu.conf

    # 'picom'
    mkdir -p /home/hope/.config/picom
    mv .config/picom.conf /home/hope/.config/picom/picom.conf

    # 'dunst'
    mkdir -p /home/hope/.config/dunst
    mv .config/dunstrc /home/hope/.config/dunst/dunstrc

    # wallpaper for 'feh'
    mkdir -p /home/hope/Pictures
    mv .config/wallpaper.jpg /home/hope/Pictures/wallpaper.jpg

    # 'fish'
    mkdir -p /home/hope/.config/fish/functions
    mv .config/config.fish /home/hope/.config/fish/config.fish
    mv fish_greeting.fish /home/hope/.config/fish/functions/fish_greeting.fish

    # 'neovim'
    mkdir -p /home/hope/.config/nvim
    git clone --depth 1 https://github.com/commitsovercoffee/minima-nvim ~/.config/nvim

    # 'touchpad'
    mv .config/30-touch.conf /etc/X11/xorg.conf.d/30-touch.conf

    # reset permissions.
    chown -R  hope /home/hope/
    chown -R :hope /home/hope/

}

misc() {

    # recreate the initramfs image
    mkinitcpio -P

    # enable TRIM for SSDs.
    systemctl enable fstrim.timer

    # encryption keys
    pacman -S seahorse --noconfirm

    # bug fix ~ reinstall pambase.
    pacman -S pambase --noconfirm

    # install suite apps if user agrees.
    echo "Do you want to install recommended apps ? [Y/N]. "
    read -r suite;

    if [[ "$suite" == *"Y"* ]] || [[ "$suite" == *"y"* ]]; then
        suite
    fi

}

suite() {

    apps=(

        'gnome-screenshot'      # screenshot tool.
        'gcolor3'               # color picker.

        'pcmanfm-gtk3'          # file manager.
        'unzip'                 # extract/view .zip archives.
        'mtpfs'                 # read/write to MTP devices.
        'libmtp'                # MTP support.
        'gvfs'                  # gnome virtual file system for mounting.
        'gvfs-mtp'              # gnome virtual file system for MTP devices.
        'android-tools'         # android platform tools.
        'android-udev'          # udev rules to connect to android.

        'firefox'                   # primary browser.
        'torbrowser-launcher'       # tertiary browser.
        'firefox-developer-edition' # secondary browser.

        'gedit'                 # text editor.
        'evince'                # doc viewer.
        'ristretto'             # image viewer.

        'gimp'                  # image editor.
        'inkscape'              # vector art.
        'mypaint'               # raster art.
        'obs-studio'            # screen cast/record.

        'qbittorent'            # torrent client.
        'gnome-multi-writer'    # iso file writer.
        'gnome-sound-recorder'  # sound recorder.
        'gnome-disk-utility'    # disk management.

        'vlc'                   # media player.
        'gnome-podcasts'        # podcasts app.

    )

    for app in "${apps[@]}"; do
        pacman -S "$app" --noconfirm
    done

}

# mark pwd
current_dir=$PWD

# setup ...

multilib
timezone
locale
users

network
bluetooth
audio
chipset
gpu

tui
gui

grub
config
misc

# clean dir & exit.
rm -r .config
rm setup.sh
