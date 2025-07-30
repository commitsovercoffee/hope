#!/bin/sh

# Resource and keymap variables.
userresources="$HOME/.Xresources"
usermodmap="$HOME/.Xmodmap"
sysresources="/etc/X11/xinit/.Xresources"
sysmodmap="/etc/X11/xinit/.Xmodmap"

# Helper functions.
merge_xresources() {
    [ -f "$1" ] && xrdb -merge "$1"
}
merge_xmodmap() {
    [ -f "$1" ] && xmodmap "$1"
}

# Load resources and keymaps (system first, then user).
merge_xresources "$sysresources"
merge_xresources "$userresources"
merge_xmodmap "$sysmodmap"
merge_xmodmap "$usermodmap"

# Background essentials.
xbindkeys &
picom &
nm-applet &
# cbatticon &
# xautolock -time 10 -locker slock &
if [ -f "$HOME/Pictures/wallpaper.jpg" ]; then
    feh --bg-scale "$HOME/Pictures/wallpaper.jpg" &
fi

# Drop my needle...
ghostty -e cmus &
sleep 1
cmus-remote -C "view 2"
cmus-remote -C "set shuffle=true"
cmus-remote -p
cmus-remote --next

# Startup Apps
firefox &
ghostty &
zeditor &
blueman-manager &
pavucontrol &
pcmanfm &

# Run additional startup scripts
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Start your window manager.
exec dwm
