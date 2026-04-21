---
title: "ProxmoxVE Helper Scripts"
date: "2025-08-14"
categories: ["sysadmin"]
tags: ["linux","pve","proxmox","kvm","qemu","cloud-init","alpine","debian","ubuntu","template", "virtualization", "container", "ct"]
draft: false
cover:
  image: "/img/posts/logo-proxmox-ve.svg"
  hidden: true
---


<img src="/img/posts/logo-proxmox-ve.svg" alt="linux router logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

[Proxmox VE](https://www.proxmox.com/en/proxmox-ve) is a powerful and easy-to-use open-source virtualization platform that enables the deployment and management of **virtual machines** (VMs with [KVM](https://www.linux-kvm.org/page/Main_Page)/[QEMU](https://www.qemu.org)) and **containers** (CTs based on [LXC](https://linuxcontainers.org/lxc/introduction/)).

If you have little experience it might be a bit daunting, which is why I recommend this wonderful project: [Proxmox VE Helper-Scripts](https://community-scripts.github.io/ProxmoxVE/scripts), where you'll find hundreds of scripts to **make your life easier installing CTs or VMs** on top of your Proxmox.

<br clear="left"/>
<!--more-->

### Introduction

This project is truly spectacular. This is where you should go when you want to install something:

- [Proxmox VE Helper-Scripts](https://community-scripts.github.io/ProxmoxVE/scripts). Search for what you want and follow the instructions.

<div class="image-box">
  <img src="/img/posts/2025-08-14-proxmox-ve-01.png" alt="350+ scripts to install your CTs or VMs" width="800px" />
  <div class="image-caption">350+ scripts to install your CTs or VMs</div>
</div>

The FOSS project is at [ProxmoxVE](https://github.com/community-scripts/ProxmoxVE). It includes scripts organized by categories for containers and virtual machines. Each script automates the deployment of a specific service or application within an LXC or a VM.

**Example: Minimalist LXC container based on Alpine Linux**:

```bash
# From the Proxmox Shell
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/alpine.sh)"
```

During execution, the script will ask for parameters such as the container ID, hostname, user and password, as well as resource allocation (CPU, RAM, storage)

When finished, you'll have the container (CT) ready and configured.

**Example: Docker VM (based on Debian 12)**:

```bash
# From the Proxmox Shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/vm/docker-vm.sh)"
```

Sets up a Docker server VM in a couple of minutes, an example: Container ID: `100`, machine `Q35`, disk `32GB`, disk Cache `None (default)`, hostname: `docker`, CPU Model `Host`, Cores `4`, memory: `8192`, bridge: `vmbr1`.

Once it boots, I log in as `root` in the Proxmox GUI (password `docker` if it asks). From there I set up SSH, create a user and done...

```bash
apt install openssh-server locales
adduser luis
usermod -aG sudo luis
usermod -aG docker luis
passwd luis
echo "luis ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/10luis
dpkg-reconfigure locales
timedatectl set-timezone Europe/Madrid
timedatectl set-ntp on
```

### Best practices

- **Base templates**: Use official Proxmox templates (Alpine, Debian, Ubuntu) as a base before customizing.
- **Prior backups**: Before running a script in production, take a snapshot or backup of the node.
- **Code review**: Always review the script contents to understand what it installs and configures.

### Resources

- [Full repository on GitHub](https://github.com/community-scripts/ProxmoxVE)
- [Script list with descriptions](https://community-scripts.github.io/ProxmoxVE/scripts)
- [Proxmox support forum](https://forum.proxmox.com/)
