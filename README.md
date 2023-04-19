# Hope

**H.O.P.E** stands for `Highly Optimised Productivity Environment`. This project is a collection of scripts and dot files to setup ( and document ) my ever evolving arch work environment.

- Installs base arch.
- Sets up timezone and locale. - Installs fonts ( supports foreign languages, emojis & symbols ).
- Sets up audio, bluetooth, network & firewall.
- Creates normal user with sudo priviledges.
- Sets up GRUB bootloader
- Enables multilib packages (for 32 bit apps) & installs paru (for AUR apps).
- Sets up a friendly default terminal environment. ( st, fish)
- Sets up a minimalist graphical environment. (dwm, dmenu, feh, amd drivers etc)

|      Screenshot 01      |      Screenshot 02      |
| :---------------------: | :---------------------: |
| ![](assets/arch-01.png) | ![](assets/arch-02.png) |

## Usage

> **Note :**
> The scripts are hardcoded for my hardware _(amd cpu and gpu + nvme ssd)_, since this is an automation script, not an arch installer.

> **Warning :**
> Wipes first nvme ssd for installation. READ/EDIT THE SCRIPT BEFORE USING IT !

- You can follow the steps below to install **my** work enviroment.
- Or fork it, and use it as reference for your own remix.

## Pre-installation

- Download the arch iso from [this](https://archlinux.org/download/) page and [verify](https://wiki.archlinux.org/title/Installation_guide#Verify_signature) the signature of your download.
- Prepare the [USB flash installation medium](https://wiki.archlinux.org/title/USB_flash_installation_medium). (Do not use [these](https://wiki.archlinux.org/title/USB_flash_installation_medium#Inadvisable_methods) methods.)
- Boot the live environment in UEFI mode. Disable Secure boot as Arch linux images do not support secure boot.
- Connect to the internet using one of following techniques :
  - Plug in an ethernet cable.
  - Authenticate to a wireless network using [iwctl](https://wiki.archlinux.org/title/Iwd#iwctl).
  - Connect to a mobile network with the [mmcli](https://wiki.archlinux.org/title/Mobile_broadband_modem#ModemManager) utility.

To check if you are connected to the internet. Run the command `ping archlinux.org`.

## Installation

Use the below command from a live arch installation environment to install and setup arch.

```
curl https://raw.githubusercontent.com/commitsovercoffee/hope/main/1-install.sh -o install.sh; bash install.sh
```

- You will be prompted a few times to specify the hostname, username, passwd etc.
- Once the installation is complete. The machine will automatically reboot into arch.
- You will reboot into TTY session where you can input your username and passkey to login.

## What Next ?

<details><summary>Install Apps</summary>
<br>

The script installs a minimal arch setup (no media player, screenshot utility, etc).

- Reply `yes` to the suite option, to install recommended apps. Or ...
- Manually install whatever apps/packages you see fit.

> Want to use [AUR](https://wiki.archlinux.org/title/Arch_User_Repository) packages ? Use [paru](https://github.com/Morganamilo/paru) !!

</details>

<details><summary>Change Appearance</summary>
<br>

- Using `lxappearance` to tweak the theme, icon, font, cursor etc.

</details>

<details><summary>Manage Fonts</summary>
<br>

- Using `font-manager` app to download/install/uninstall fonts ( including ones from [google fonts](https://fonts.google.com/) ).

</details>

<details><summary>Change Shell Style</summary>
<br>

The script installs [fish shell](https://fishshell.com/) with [fisher](https://github.com/jorgebucaran/fisher) plugin manager and
[tokyonight theme](https://github.com/vitallium/tokyonight-fish). If you don't like that theme. You can remove it :

```bash
fish -c "fisher remove vitallium/tokyonight-fish"; sudo pacman -Rns fisher
```

And (maybe) opt for an alternative such as :

- The [oh-my-fish](https://github.com/oh-my-fish/oh-my-fish) framework. To install one of [these](https://github.com/mrshu/oh-my-fish/blob/master/docs/Themes.md) themes.
- Alternatively, you can simply install a shell prompt like [tide](https://github.com/IlanCosman/tide).

</details>

<details><summary>Terminal Support in File Manager</summary>
<br>

The script installs [PcManFM](https://wiki.lxde.org/en/PCManFM) file manager. To enable terminal support (say) `st` in it :

- Open file manager by pressing `Shift + Alt + F`.
- Click on `Edit > Preferences > Advanced`.
- Type **st** in the `Terminal emulator` text field.
- Close the `Preferences` dialog box.

Now, you can press `F4` to open the current directory of the file manager in a terminal.

</details>

<details><summary>Neovim</summary>
<br>

The installation also sets up my neovim config. The first time you open nvim, it will setup everything.

</details>

<details><summary>DNS Settings</summary>
<br>
 
For faster [domain name resolution](https://wiki.archlinux.org/title/Domain_name_resolution) :
- Replace `nameserver 192.168.1.1` with `nameserver 8.8.8.8` in /etc/resolv.conf file.<br>
- Prevent network manager from changing the file back using below command.

```bash
sudo chattr +i /etc/resolv.conf
```

</details>

<details><summary>KVM for virtual machines</summary>
<br>

If you work with VMs, use below commands for a quick KVM setup.

`fish shell does not support $, use bash for below commands`

```bash
sudo pacman -S virt-manager qemu vde2 ebtables dnsmasq bridge-utils openbsd-netcat
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service
sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_ro_perms = "0777"/unix_sock_ro_perms = "0777"/' /etc/libvirt/libvirtd.conf
sudo usermod -a -G libvirt $(whoami)
newgrp libvirt
sudo systemctl restart libvirtd.service
```

</details>

## Support

You can reach out to me on reddit : u/commitsovercoffee

## Status

This project is my daily driver. I contribute to this project if and when I come across something useful or to add bugfixes.

