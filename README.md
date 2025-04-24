# Hope

Highly Optimised Productivity Environment ~ Scripts and dot files of my ever evolving arch setup.

![](hope.png)

## Pre-requisites

- [ ] Confirm your cpu & gpu both are from [team red](https://www.amd.com/en.html).
- [ ] Read the _fucking_ script before using it.
- [ ] Realize that the script will [wipe](https://github.com/commitsovercoffee/hope/blob/301e5b76593e0f921a531058d802f506ce01bd4d/install.sh#L21) your first NVMe SSD.
- [ ] (Optional) Cry later when you figure out the script wiped your first NVMe SSD.

## Usage

- Grab the arch ISO from [here](https://archlinux.org/download/).
- Create a bootable USB using [recommended methods](https://wiki.archlinux.org/title/USB_flash_installation_medium).
- Boot in UEFI mode with [Secure Boot Disabled](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Disabling_Secure_Boot).
- Connect to the internet via Ethernet or Wifi (with [iwctl](https://wiki.archlinux.org/title/Iwd#Connect_to_a_network)).
- Run the following command from the arch live environment to [install](https://github.com/commitsovercoffee/hope/blob/main/install.sh) and [setup](https://github.com/commitsovercoffee/hope/blob/main/setup.sh) arch :

```bash
pacman -Sy git;
git clone https://github.com/commitsovercoffee/hope.git;
bash ./hope/install.sh;
```

> install.sh automatically calls setup.sh during the process.

You'll be prompted for input or a password at a few steps. After installation, the
system will reboot automatically. Log in with username "hope" and the password you set during setup.

## Keymaps

This setup includes custom keybindings tailored to my workflow. You can explore all the defined shortcuts and their corresponding actions in the [key definitions](https://github.com/commitsovercoffee/dwm-remix/blob/18ea6642abae18e1c79c3359b02ee5e538a2a53a/config.def.h#L113) section of the configuration. It covers everything from launching apps to managing windows and layouts efficiently.

## Status

This setup is my daily driver. I update it whenever I find something useful or need to fix a bug.
