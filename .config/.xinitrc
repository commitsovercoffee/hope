#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

merge_xresources() {
    if [ -f "$1" ]; then
        xrdb -merge "$1"
    fi
}

merge_xmodmap() {
    if [ -f "$1" ]; then
        xmodmap "$1"
    fi
}

merge_xresources "$sysresources"
merge_xmodmap "$sysmodmap"
merge_xresources "$userresources"
merge_xmodmap "$usermodmap"

# startup

{
    st &
    pavucontrol &
    bluetooth &
    pcmanfm &
    firefox &
    xbindkeys &
    picom &
    nm-applet &
    slstatus &
    feh --bg-scale "$HOME/Pictures/wallpaper.jpg" &
    xautolock -time 1 -locker slock &
} &

# Check and execute additional startup scripts
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Execute window manager
exec dwm
