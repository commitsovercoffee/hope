# Hope

Highly Optimised Productivity Environment ~ Scripts and dot files of my ever evolving arch setup. 

|      Screenshot 01      |      Screenshot 02      |
| :---------------------: | :---------------------: |
| ![](assets/layout-1.png) | ![](assets/layout-2.png) |

## Features :

- uses [linux-zen](https://github.com/zen-kernel/zen-kernel) kernel.
- [multilib](https://wiki.archlinux.org/title/official_repositories#multilib) support.
- driver suport for [network](https://wiki.archlinux.org/title/NetworkManager), [bluetooth](https://wiki.archlinux.org/title/bluetooth), [audio](https://wiki.archlinux.org/title/PipeWire), [microcode](https://wiki.archlinux.org/title/Ryzen) & [gpu](https://wiki.archlinux.org/title/AMDGPU#Installation).
- multilingual font support with glyphs & emoticons.
- runs on [suckless](https://suckless.org/) apps ~ dwm, dmenu, slstatus & st.
- [fish](https://fishshell.com/) & [starship](https://starship.rs/) powered terminal.
- sane [dot files](https://github.com/commitsovercoffee/hope/tree/main/.config) for xinitrc, picom, touchpad etc.

## Usage

> **Note :**
>
> - It installs drivers for AMD builds only.
> - It wipes the first NVMe SSD for installation.

Since, This is an automation script, not an installer.

> READ/EDIT THE SCRIPT BEFORE USING IT !

- Follow the steps below to install **my** setup.
- Or fork it, and use it as reference for your own remix.

## Pre-installation

- Download the arch iso from [this](https://archlinux.org/download/) page and [verify](https://wiki.archlinux.org/title/Installation_guide#Verify_signature) the signature of your download.
- Prepare the [USB flash installation medium](https://wiki.archlinux.org/title/USB_flash_installation_medium). (Do not use [these](https://wiki.archlinux.org/title/USB_flash_installation_medium#Inadvisable_methods) methods.)
- Disable `secure boot`. Boot the live environment in UEFI mode.
- Connect to the internet by plugging in an ethernet cable or using [iwctl](https://wiki.archlinux.org/title/Iwd#Connect_to_a_network).

To check if you are connected to the internet. Run the command `ping archlinux.org`.

## Installation

Use the below command from a live arch installation environment to install and setup arch.

```bash
pacman -S git;
git clone https://github.com/commitsovercoffee/hope.git;
bash ./hope/install.sh;
```

- You will be prompted to set the password for the root & regular user.
- Once the installation is complete. The machine will automatically reboot into arch.
- You will reboot into TTY session where you can input your username and password to login.

## What Next ?

<details><summary>Change Appearance</summary>
<br>

- Use `lxappearance` to tweak the theme, icon, font, cursor etc.
- Use `font-manager` to download/install/uninstall fonts (including ones from [google fonts](https://fonts.google.com/)).

</details>

<details><summary>Change Shell Style</summary>
<br>

The script installs [fish shell](https://fishshell.com/) with [fisher](https://github.com/jorgebucaran/fisher) plugin manager and
[catppuccin theme](https://github.com/catppuccin/fish). If you don't like that theme. You can remove it :

```bash
fish -c "fisher remove catppuccin/fish"; # remove catpuccin theme
sudo pacman -Rns fisher; # remove plugin manager (in case you want to use omf)
```

And (maybe) opt for an alternative such as the [oh-my-fish](https://github.com/oh-my-fish/oh-my-fish) framework. To install one of [these](https://github.com/mrshu/oh-my-fish/blob/master/docs/Themes.md) themes.

</details>

<details><summary>Setup Neovim</summary>
<br>

Use below command to try my [neovim setup](https://github.com/commitsovercoffee/minima-nvim) :

```bash
git clone --depth 1 https://github.com/commitsovercoffee/minima-nvim ~/.config/nvim
```

After executing above command, open neovim (you will see a blank screen), wait till all plugins are installed.

</details>

<details><summary>Terminal Support in File Manager</summary>
<br>

The script installs [PcManFM](https://wiki.lxde.org/en/PCManFM) file manager. To enable terminal support (say) `st` in it :

- Open file manager by pressing `Alt + Shift + K`.
- Click on `Edit > Preferences > Advanced`.
- Type **st** in the `Terminal emulator` text field.
- Close the `Preferences` dialog box.

Now, you can press `F4` to open the current directory of the file manager in a terminal.

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

## Status

This project is my daily driver. I contribute to this project if and when I come across something useful or to add bugfixes.
