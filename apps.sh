apps=(

  # tag 0 ~ current workspace.

  'xfce4-appfinder'  # app finder
  'galculator'       # calculator.
  'gnome-screenshot' # screenshot.
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

  # terminal apps...

  'btop'    # resource monitor.
  'cmus'    # music player.
  'neovim'  # text editor.
  'rsync'   # file transfer util.
  'plocate' # file finder.

  # tag 3 ~ workbench.

  'zed' # code editor.

  # tag 4 ~ file viewers.

  'mousepad'  # text editor.
  'evince'    # doc viewer.
  'foliate'   # epub viewer.
  'ristretto' # image viewer.
  'celluloid' # video player.

  # tag 5 ~ utils.

  'pavucontrol'        # audio control.
  'blueman'            # bluetooth control.
  'gnome-disk-utility' # disk manager.
  'qbittorent'         # torrent client.
  'nicotine+'          # soul-seek client.
  'bitwarden'          # password manager.
  'syncthing'          # file sync util.

  # tag 6 ~ file manager.

  'pcmanfm'       # file-manager.
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

  'obs-studio' # screen cast/record.
  'steam'      # game distribution platform.
)

for app in "${apps[@]}"; do
  sudo pacman -S "$app" --noconfirm --needed
done

# enable syncthing.
sudo mv ./.settings/syncthing.service /etc/systemd/system
systemctl start syncthing@hope.service
systemctl enable syncthing@hope.service

cowsay "installation complete."
