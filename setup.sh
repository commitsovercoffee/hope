#!/bin/bash
# This script configures the installed arch linux for daily use.

multilib() {

    # enable multi-lib for 32-bit apps.
    echo "" >>/etc/pacman.conf
    echo "[multilib]" >>/etc/pacman.conf
    echo "Include = /etc/pacman.d/mirrorlist" >>/etc/pacman.conf

    # refresh database.
    pacman -Syy reflector --noconfirm
    reflector --country India --protocol https --save /etc/pacman.d/mirrorlist

}

timezone() {

    # set timezone.
    ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

    # set the hardware clock from the system clock.
    hwclock --systohc

    enable network time sync
    timedatectl set-ntp true

}

locale() {

    # uncomment required locales from '/etc/locale.gen'.
    sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen

    # generate locale.
    locale-gen

    # set system locale ~ creates 'locale.conf'.
    localectl set-locale LANG=en_US.UTF-8

    # install fonts.
    pacman -S aspell-en ttf-firacode-nerd nerd-fonts noto-fonts noto-fonts-extra noto-fonts-emoji font-manager --noconfirm

}

network() {

    # create the hostname file.
    echo "arch" >/etc/hostname

    # install & enable network.
    pacman -S linux-firmware-marvell networkmanager network-manager-applet traceroute --noconfirm
    systemctl enable NetworkManager

    # add entries for localhost to '/etc/hosts' file.
    # ( if the system has a permanent IP address, it should be used instead of 127.0.1.1 )
    # echo -e 127.0.0.1'\t'localhost'\n'::1'\t\t'localhost'\n'127.0.1.1'\t'arch >> /etc/hosts

    # install & enable firewall.
    pacman -S ufw --noconfirm
    systemctl start ufw.service
    systemctl enable ufw.service

    # allow outgoing & reject incoming.
    ufw default allow outgoing
    ufw default deny incoming

    # install & enable syncthing.
    pacman -S syncthing --noconfirm
    mv .config/syncthing.service /etc/systemd/system
    systemctl start syncthing@hope.service
    systemctl enable syncthing@hope.service

}

bluetooth() {

    # install bluetooth.
    pacman -S bluez bluez-utils blueman --noconfirm
    lsmod | grep btusb
    rfkill unblock bluetooth
    systemctl enable bluetooth.service

}

audio() {

    # install audio packages.
    pacman -S sof-firmware pipewire lib32-pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber pavucontrol alsa-utils --noconfirm

}

webcam() {

    # install webcam packages.
    pacman -S cameractrls --noconfirm

}

chipset() {

    # install microcode for amd.
    vendor="$(lscpu | grep 'Model name')"
    if [[ "$vendor" == *"AMD"* ]]; then
        echo "AMD CPU Found !"
        pacman -S amd-ucode --noconfirm
    fi

}

gpu() {

    # DRI driver for 3D acceleration.
    pacman -S mesa lib32-mesa --noconfirm

    vendor="$(lspci -v | grep -iE 'vga|3d|2d')"

    if [[ "$vendor" == *"AMD"* ]]; then
        echo "AMD GPU Found !"

        # DDX driver which provides 2D acceleration in Xorg.
        pacman -S xf86-video-amdgpu --noconfirm

        # vulkan support.
        pacman -S vulkan-radeon lib32-vulkan-radeon --noconfirm

        # accelerated video decoding.
        pacman -S libva-mesa-driver lib32-libva-mesa-driver --noconfirm

    fi

}

tui() {

    apps=(

        # install packages for a seamless terminal experience :

        'ghostty'  # terminal emulator.
        'fish'     # user-friendly shell.
        'fisher'   # fish package manager.
        'starship' # shell prompt.
        'man-db'   # man pages.
        'tldr'     # command tldr.
        'cowsay'   # ascii cow.

        'exa' # alternative to `ls`.
        'bat' # alternative to `cat`.

        'btop' # task manager.
        'ncdu' # disk util info.

        # install tui apps :

        'git'   # version control.
        'rsync' # copying tool.

        'cmus' # music player.
        'mpv'  # video player.

    )

    for app in "${apps[@]}"; do
        pacman -S "$app" --noconfirm --needed
    done

    # set preset for starship prompt.
    starship preset nerd-font-symbols -o ~/.config/starship.toml

    # set theme for fish shell.
    fish -c "fisher install catppuccin/fish"
    fish -c "fish_config theme save "Catppuccin Mocha""

    # set fish as default shell.
    chsh --shell /bin/fish hope

}

gui() {

    apps=(

        # install display server :

        'xorg-server'     # xorg display server.
        'xorg-xinit'      # xinit ~ to start xorg server.
        'xorg-xrandr'     # tui for RandR extension.
        'xorg-xclipboard' # xclipboard ~ clipboard manager.
        'xclip'           # clipboard manipulation tool.

        # install graphical utils :

        'picom'         # X compositor.
        'dunst'         # notification daemon.
        'libnotify'     # lib to send desktop notifications.
        'xbindkeys'     # bind commands to certain keys.
        'brightnessctl' # control brightness.
        'lxrandr-gtk3'  # monitor configuration.
        'cbatticon'     # battery for systray.
        'xautolock'     # autolocker.
        'seahorse'      # encryption keys.
        'pambase'       # PAM config.
        'slock'         # screen locker for X.

        'feh'                # desktop wallpaper.
        'gnome-themes-extra' # window themes.
        'papirus-icon-theme' # icon themes.

        'gnome-disk-utility' # disk management.
        'dosfstools'         # for F32 systems.

        'xfce4-appfinder'   # app finder.
        'lxappearance-gtk3' # theme switcher.
        'lxinput-gtk3'      # configure keyboard & mouse.

        # install gui apps :

        # tag 0 ~ current workspace.

        'galculator'       # basic calculator.
        'gnome-screenshot' # screenshot tool.
        'peek'             # gif recorder.
        'gcolor3'          # color picker.

        # tag 1 ~ web browsing.

        'firefox'                   # primary browser.
        'firefox-developer-edition' # secondary browser.
        'torbrowser-launcher'       # tertiary browser.
        'chromium'                  # testing browser.

        # tag 2 ~ terminals.

        'ghostty'        # primary terminal emulator.
        'xfce4-terminal' # secondary terminal emulator.

        # tag 3 ~ text editors.

        'zed'      # primary text editor.
        'mousepad' # alternate text editor.

        # tag 4 ~ file viewers.

        'evince'    # doc viewer.
        'ristretto' # image viewer.
        'celluloid' # video player.
        'amberol'   # music player.

        # tag 5 ~ utils.

        'pavucontrol' # audio control.
        'blueman'     # bluetooth control.

        'catfish'            # file searching tool.
        'gnome-disk-utility' # disk manager.
        'bitwarden'          # password manager.

        'qbittorent' # torrent client.
        'nicotine+'  # soul-seek client.

        # tag 6 ~ file manager.

        'pcmanfm-gtk3'  # file-manager.
        'unzip'         # extract/view .zip archives.
        'file-roller'   # create/modify archives.
        'mtpfs'         # read/write to MTP devices.
        'libmtp'        # MTP support.
        'gvfs'          # gnome virtual file system for mounting.
        'gvfs-mtp'      # gnome virtual file system for MTP devices.
        'android-tools' # android platform tools.
        'android-udev'  # udev rules to connect to android.

        # tag 7 ~ creative suite.

        'obsidian'    # note taking.
        'kolourpaint' # paint program.
        'kdenlive'    # video editing.

        # tag 8 ~ obs.

        'obs-studio'           # screen cast/record.
        'steam'                # video games :D
        'steam-native-runtime' # steam runtime using system libs

    )

    for app in "${apps[@]}"; do
        pacman -S "$app" --noconfirm --needed
    done

    # clone my pre-patched dwm repo. (this command also creates .config dir as root)
    git clone https://github.com/commitsovercoffee/dwm-remix.git /home/hope/.config/suckless/dwm-remix

    # install dynamic window manager.
    cd /home/hope/.config/suckless/dwm-remix
    make clean install
    cd "$current_dir"

}

dev() {

    # install packages for a seamless dev experience :

    apps=(

        'zed'         # primary text editor
        'neovim'      # secondary text editor
        'tree-sitter' # parsing library

        'git'        # version control
        'github-cli' # github cli, duh!

        'fd'      # file search
        'ripgrep' # search tool
        'jq'      # JSON processor

        'nodejs' # evented io for V8 js
        'npm'    # package manager for js

        'go'      # golang
        'gopls'   # golang lsp
        'gofumpt' # golang formatter

        # Formatters :

        'prettier' # html, css, js, md, bash etc formatter

        # LSP : Zed extensions have lsp, so below packages aren't needed.

        # 'lua-language-server'        # lua
        # 'stylua'                     # lua formatter
        # 'bash-language-server'       # bash
        # 'vscode-html-languageserver' # html
        # 'vscode-css-languageserver'  # css
        # 'tailwind-language-server'   # tailwind
        # 'svelte-language-server'     # svelte

    )

    for app in "${apps[@]}"; do
        pacman -S "$app" --noconfirm --needed
    done

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

    # create directories for user.
    pacman -S xdg-user-dirs --noconfirm
    xdg-user-dirs-update
    mkdir -p /home/hope/{Batcave,Sync,Zion} && touch /home/hope/memo.md

}

grub() {

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

config() {

    # '20-amdgpu.conf'
    mv .config/20-amdgpu.conf /etc/X11/xorg.conf.d/20-amdgpu.conf

    # 'xinitrc'
    mv .config/.xinitrc /home/hope/.xinitrc

    # '.xbindkeysrc'
    mv .config/.xbindkeysrc /home/hope/.xbindkeysrc
    mv .config/.get-vol.sh /home/hope/.get-vol.sh
    chmod u+x /home/hope/.get-vol.sh

    # 'Xresources'
    mv .config/.Xresources /home/hope/.Xresources

    # 'picom'
    mkdir -p /home/hope/.config/picom
    mv .config/picom.conf /home/hope/.config/picom/picom.conf

    # 'dunst'
    mkdir -p /home/hope/.config/dunst
    mv .config/dunstrc /home/hope/.config/dunst/dunstrc

    # 'lxappearance'
    mkdir -p /home/hope/.config/gtk-3.0
    mv .config/settings.ini /home/hope/.config/gtk-3.0

    # wallpaper for 'feh'
    mkdir -p /home/hope/Pictures
    mv .config/wallpaper.jpg /home/hope/Pictures/wallpaper.jpg

    # 'touchpad'
    mv .config/30-touch.conf /etc/X11/xorg.conf.d/30-touch.conf

    # 'ghostty'
    mkdir -p /home/hope/.config/ghostty
    mv .config/config /home/hope/.config/ghostty/config

    # 'fish'
    mkdir -p /home/hope/.config/fish/functions
    mv .config/config.fish /home/hope/.config/fish/config.fish
    mv fish_greeting.fish /home/hope/.config/fish/functions/fish_greeting.fish

    # 'starship'
    mv .config/starship.toml /home/hope/.config/starship.toml

    # 'neovim'
    mkdir -p /home/hope/.config/nvim
    mv .config/init.lua /home/hope/.config/nvim/init.lua

    # 'zed'
    mkdir -p /home/hope/.config/zed
    mv .config/keymap.json /home/hope/.config/zed/keymap.json
    mv .config/settings.json /home/hope/.config/zed/settings.json

    # 'obs'
    mkdir -p /home/hope/.config/obs-studio
    mv .config/basic /home/hope/.config/obs-studio

    # 'cmus  theme'
    mkdir -p /home/hope/.config/cmus
    mv .config/catppuccin.theme /home/hope/.config/cmus/catppuccin.theme

    # reset permissions.
    chown -R hope /home/hope/
    chown -R :hope /home/hope/

}

misc() {

    # recreate the initramfs image
    mkinitcpio -P

    # enable TRIM for SSDs.
    systemctl enable fstrim.timer

}

current_dir=$PWD

# setup ...

multilib
timezone
locale
users
network
bluetooth
audio
webcam
chipset
gpu
tui
gui
dev
grub
config
misc

# clean dir & exit :

rm -r .config
rm setup.sh
