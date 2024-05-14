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

}

network () {

    # create the hostname file.
    echo "arch" > /etc/hostname

    # install & enable network.
    systemctl enable NetworkManager

    # add entries for localhost to '/etc/hosts' file.
    # ( if the system has a permanent IP address, it should be used instead of 127.0.1.1 )
    echo -e 127.0.0.1'\t'localhost'\n'::1'\t\t'localhost'\n'127.0.1.1'\t'arch >> /etc/hosts

    # install & enable firewall.
    systemctl enable ufw

    # allow outgoing & reject incoming.
    ufw default allow outgoing
    ufw default deny incoming

}

bluetooth () {

    # install bluetooth.
    lsmod | grep btusb
    rfkill unblock bluetooth
    systemctl enable bluetooth.service

}

tui () {

    # set preset for starship prompt
    starship preset nerd-font-symbols -o ~/.config/starship.toml

    # clone suckless fork. (this command also creates .config dir as root)
    retry_command git clone https://github.com/commitsovercoffee/suckless.git /home/hope/.config/suckless

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

    # set git defaults
    git config --global user.name "commitsovercoffee"
    git config --global user.email "commitsovercoffee@gmail.com"

}

gui () {

    # install dynamic window manager.
    cd /home/hope/.config/suckless/dwm
    make clean install; cd "$current_dir"

    # install dmenu.
    cd /home/hope/.config/suckless/dmenu
    make clean install; cd "$current_dir"

    # install slstatus.
    cd /home/hope/.config/suckless/slstatus
    make clean install; cd "$current_dir"

    # install slock.
    cd /home/hope/.config/suckless/slock
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

}

config () {

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

    # 'fish'
    mkdir -p /home/hope/.config/fish/functions
    mv .config/config.fish /home/hope/.config/fish/config.fish
    mv fish_greeting.fish /home/hope/.config/fish/functions/fish_greeting.fish

    # 'starship'
    mv .config/starship.toml /home/hope/.config/starship.toml

    # 'neovim'
    mkdir -p /home/hope/.config/nvim
    retry_command git clone --depth 1 https://github.com/commitsovercoffee/minima-nvim /home/hope/.config/suckless

    # 'touchpad'
    mv .config/30-touch.conf /etc/X11/xorg.conf.d/30-touch.conf

    # reset permissions.
    chown -R  hope /home/hope/
    chown -R :hope /home/hope/

}

grub () {

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

misc() {

    # recreate the initramfs image
    mkinitcpio -P

    # enable TRIM for SSDs.
    systemctl enable fstrim.timer

    # set default apps
    handlr set 'text/*' neovide.desktop
    handlr set 'audio/*' mpv.desktop
    handlr set 'image/*' org.xfce.ristretto.desktop
    handlr set 'application/pdf' org.gnome.Evince.desktop

    # create directories for user.
    xdg-user-dirs; xdg-user-dirs-update

}

# List of packages to download and install
packages=(

    # DRIVERS -----------------------------------------------------------------

    # microcode
    'amd-ucode'

    # DRI driver for 3D acceleration.
    'mesa'
    'lib32-mesa'

    # DDX driver which provides 2D acceleration in Xorg
    'xf86-video-amdgpu'

    # vulkan support
    'vulkan-radeon'
    'lib32-vulkan-radeon'

    # accelerated video decoding
    'libva-mesa-driver'
    'lib32-libva-mesa-driver'

    # audio
    'pipewire'
    'lib32-pipewire'
    'wireplumber'
    'pipewire-audio'
    'pipewire-alsa'
    'pipewire-pulse'
    'sof-firmware'
    'pavucontrol'
    'alsa-utils'

    # network & firewall
    'networkmanager'
    'network-manager-applet'
    'ufw'

    # bluetooth
    'blueman'
    'bluez'
    'bluez-utils'

    # webcam
    'v4l-utils'
    'cameractrls'


    # TUI ---------------------------------------------------------------------

    'fish'                  # user-friendly shell
    'fisher'                # fish package manager
    'starship'              # shell prompt
    'tldr'                  # concise command examples
    'cowsay' 		    # talking cow

    'exa'                   # alternative to `ls`
    'bat'                   # alternative to `cat`

    'git'                   # version control
    'github-cli'
    'neovide'               # text editor
    'xclip'                 # clipboard manipulation tool

    'fd'                    # file search
    'ripgrep'               # search tool

    'nodejs'                # Evented I/O for V8 javascript
    'npm'                   # package manager for javascript

    'btop'                  # task manager
    'ncdu'                  # disk util info

    # GUI ---------------------------------------------------------------------

    'xorg-server'               # xorg display server.
    'xorg-xinit'                # xinit ~ to start xorg server.
    'xorg-xrandr'               # tui for RandR extension.
    'xorg-xclipboard'           # xclipboard ~ clipboard manager.
    'xorg-xclipboard'           # xclipboard ~ clipboard manager.

    'picom'                     # X compositor.
    'dunst'                     # notification daemon.
    'xbindkeys' 	        # bind commands to certain keys.
    'libnotify'                 # lib to send desktop notifications.
    'brightnessctl' 	    	# control brightness.
    'xautolock' 	        # autolocker.
    'cbatticon'                 # battery for systray.

    'feh'                       # desktop wallpaper.
    'gnome-themes-extra'        # window themes.
    'papirus-icon-theme'        # icon themes.

    'dmenu'                     # app menu.
    'xfce4-appfinder' 	    	# alt app menu.
    'lxappearance-gtk3'         # theme switcher.
    'lxinput-gtk3'              # configure keyboard & mouse.

    'ttf-firacode-nerd'  	# fonts ...
    'nerd-fonts'
    'noto-fonts'
    'noto-fonts-extra'
    'noto-fonts-emoji'
    'font-manager'

    'seahorse'
    'pambase'

    # APPS --------------------------------------------------------------------

    'gnome-screenshot'      # screenshot tool.
    'gcolor3'               # color picker.

    'pcmanfm-gtk3'          # file manager.
    'unzip'                 # extract/view .zip archives.
    'file-roller' 		# create/modify archives.
    'mtpfs'                 # read/write to MTP devices.
    'libmtp'                # MTP support.
    'gvfs'                  # gnome virtual file system for mounting.
    'gvfs-mtp'              # gnome virtual file system for MTP devices.
    'android-tools'         # android platform tools.
    'android-udev'          # udev rules to connect to android.

    'firefox'               # primary browser.
    'torbrowser-launcher'   # tertiary browser.
    'vivaldi' 	 	    # secondary browser.

    'gedit'                 # text editor.
    'evince'                # doc viewer.
    'ristretto'             # image viewer.
    'xournalpp' 	    # note taking + pdf annotation.

    'inkscape'              # vector graphics editor.
    'mypaint'               # (raster) painting app.
    'kolourpaint' 		# paint program.
    'obs-studio'            # screen cast/record.
    'peek'     		    # gif recorder.
    'pitivi' 		    # video editor.

    'qbittorent'            # torrent client.
    'gnome-disk-utility'    # disk management.

    'mpv'                   # media player.
    'handlr' 		    # sets default apps.


    # GRUB --------------------------------------------------------------------

    'grub'
    'efibootmgr'

)

# Function to download packages
download_packages() {
    local failed_packages=()
    for package in "${packages[@]}"; do
        echo "Downloading $package..."
        if ! pacman -Sw --noconfirm --needed "$package"; then
            echo "Download failed for $package."
            failed_packages+=("$package")
        fi
    done
    echo "${failed_packages[@]}"
}

# Function to install packages
install_packages() {
    local failed_packages=()
    echo "Installing downloaded packages..."
    if ! pacman -U --noconfirm *.pkg.tar.zst; then
        echo "Installation failed."
        failed_packages=("${packages[@]}")
    fi
    echo "${failed_packages[@]}"
}

# Function to retry a command
retry_command() {
    local max_attempts="${1:-3}"
    shift
    local attempt=1
    until "$@"; do
        if [ $attempt -ge $max_attempts ]; then
            echo "Max attempts reached. Exiting."
            exit 1
        fi
        ((attempt++))
        echo "Retry attempt $attempt..."
        sleep 5
    done
}

# Main function
main() {
    echo "Verifying and downloading packages..."
    local failed_downloads
    while true; do
        failed_downloads=$(download_packages)
        if [ -z "$failed_downloads" ]; then
            break
        fi
        echo "Retrying download for failed packages..."
        packages=("${failed_downloads[@]}")
    done

    local failed_installs
    while true; do
        failed_installs=$(install_packages)
        if [ -z "$failed_installs" ]; then
            break
        fi
        echo "Retrying installation for failed packages..."
        packages=("${failed_installs[@]}")
        failed_downloads=$(download_packages)
        if [ -n "$failed_downloads" ]; then
            echo "Retrying download for failed packages..."
        else
            echo "Failed to download packages. Exiting."
            exit 1
        fi
    done

    echo "Packages Installation completed."
}

# Execute main function
main

# Save current directory
current_dir=$PWD


# setup ...

clear; cowsay "Refreshing package database & adding 32-bit apps."; sleep 5;
multilib

clear; cowsay "Setting up time. Tick-Toc Tick-Toc!"; sleep 5;
timezone

clear; cowsay "Setting up locale. Hola? Namaste?"; sleep 5;
locale

clear; cowsay "Setting up network ..."; sleep 5;
network

clear; cowsay "Setting up bluetooth ..."; sleep 5;
bluetooth

clear; cowsay "Setting Up Terminal."; sleep 5;
tui

clear; cowsay "Setting Up GUI."; sleep 5;
gui

clear; cowsay "Creating user ..."; sleep 5;
users
config

clear; cowsay "Grub it!"; sleep 5;
grub
misc

# clean dir & exit.
rm -r .config
rm setup.sh
