---
title: "Remote Virt-Manager"
date: "2022-02-19"
categories: ["administration"]
tags: ["linux","kvm","vm","qemu","virtualization","virt-manager","libvirt"]
draft: false
cover:
  image: "/img/posts/logo-virtmanager.svg"
  hidden: true
---

<img src="/img/posts/logo-virtmanager.svg" alt="Virt Manager Logo" width="150px" style="float:left; padding-right:25px"  />

The goal is to run **[virt-manager](https://virt-manager.org)** from my Mac to manage VMs on a couple of remote KVM/QEMU host servers without needing to install an X11 environment on them. I've documented two options: the first uses a local **virtual machine** (VirtualBox/Parallels/...) with Ubuntu and a minimal GUI environment (just `Xorg/X11` and `virt-manager`), the second uses **HomeBrew**.

<br clear="left"/>
<!--more-->

## Virtual Machine Option

I have [Parallels](https://www.parallels.com/es/) as virtualization software, but this should work exactly the same with [VirtualBox](https://www.virtualbox.org) or any other virtualizer on your Mac.

<div class="image-box">
  <img src="/img/posts/2022-02-19-virt-manager-01.png" alt="VM Installation with Ubuntu" width="500px" />
  <div class="image-caption">VM Installation with Ubuntu</div>
</div>

- I create a VM with [Ubuntu Server 20.04 LTS](https://ubuntu.com/server/docs/installation): ubuntu-20.04.3-live-server-amd64.iso
- I install the [Parallel Tools](https://kb.parallels.com/en/121370) (optional)
- Shared networking — it will automatically assign an IP from the private range.

<div class="image-box">
  <img src="/img/posts/2022-02-19-virt-manager-02.png" alt="Network configuration from Parallels" width="500px" />
  <div class="image-caption">Network configuration from Parallels</div>
</div>

- Parallels creates an entry in `/etc/hosts` with the virtual machine's name and its IP. I verify it works and also disable the Ubuntu motd (Message of the Day).

```
luis@macos:~$ ssh -p 22 ubuntu-linux
: 
luis@ubuntu:~$ touch $HOME/.hushlogin
```

- I set up the minimal Xorg/X11 environment ([more info](https://help.ubuntu.com/community/ServerGUI)):
  
```
luis@ubuntu:~$ sudo apt install xauth
:
luis@ubuntu:~$ sudo apt install virt-manager ssh-askpass-gnome --no-install-recommends

luis@ubuntu:~$ sudo apt install -y spice-client-gtk

```

- I set up SSH to connect from my `ubuntu` VM to a server called `tierra` running KVM/QEMU. Here's a [guide on SSH in Linux](https://www.luispa.com/linux/2006/11/13/ssh.html) and another on [SSH and X11 as root](https://www.luispa.com/linux/2017/02/11/x11-desde-root.html).
  
```
 virt-manager                   libvirtd
 host:ubuntu                    host:tierra
+-------------+               +--------------+
| luis@ubuntu | ---- ssh ---> | luis@tierra  |
+-------------+               +--------------+
```

- I configure the SSH client on `ubuntu`. In my case, the `tierra` server requires public key authentication.

```
luis@ubuntu $ ssh-keygen -t rsa -b 2048
```

- On the `@tierra` server, I add the user to the `libvirt` group.

```
root@tierra # cat /etc/group
:
libvirt:x:116:luis
```

- I verify...
  
```
luis@macos:$ ssh -Y -a luis@ubuntu-linux
:
luis@ubuntu:~$ ssh tierra
Enter passphrase for key '/home/luis/.ssh/id_rsa':

luis@tierra:~$
luis@tierra:~$ id
uid=1000(luis) gid=1000(luis) grupos=1000(luis),4(adm),24(cdrom),27(sudo),116(libvirtd)
```

#### Connecting from virt-manager in the virtual machine

```
luis@macos:$ ssh -Y -a -p 22 luis@ubuntu-linux
:
luis@ubuntu:~$ virt-manager
```

- File > Add Connection
  - Hypervisor: QEMU/KVM
  - (x) Connect to remote host via SSH
  - Username: luis
  - Hostname: tierra.yourdomain.com
  - Autoconnect: (X)
  - Generated URI: qemu+ssh://luis@tierra...

<div class="image-box">
  <img src="/img/posts/2022-02-19-virt-manager-03.png" alt="Remote SSH connection configuration" width="500px" />
  <div class="image-caption">Remote SSH connection configuration</div>
</div>

<div class="image-box">
  <img src="/img/posts/2022-02-19-virt-manager-04.png" alt="Virt-manager GUI" width="600px" />
  <div class="image-caption">Virt-manager GUI</div>
</div>

- Command-line connection

You also have the option to connect directly from the command line, or if your remote server listens on a different SSH port, replace XXXXX with the port number.

```
luis@ubuntu$ virt-manager -c 'qemu+ssh://luis@tierra.yourdomain.com/system?keyfile=id_rsa'

luis@ubuntu$ virt-manager -c 'qemu+ssh://luis@tierra.yourdomain.com:XXXXX/system?keyfile=id_rsa'

```

<br/>

## HomeBrew Option

- Virt-manager is not available in HomeBrew. There's a custom [formula](https://github.com/jeffreywildman/homebrew-virt-manager) that allows installing it, but it's outdated and broken. Thanks to this [Issues/184](https://github.com/jeffreywildman/homebrew-virt-manager/issues/184) and multiple forks, I found *Damenly*'s, which looks promising. Note that it's super simple — it only installs virt-manager, not libvirt, and doesn't support certain dependencies (such as the SSH password; read the [README](https://github.com/Damenly/homebrew-virt-manager)).
- I had some issues installing it and ended up uninstalling it. I'm leaving this here for tracking purposes.

```
brew tap Damenly/homebrew-virt-manager
brew install virt-manager --HEAD
brew install virt-viewer
```

- Once installed, we run:

```
export XDG_DATA_DIRS="/opt/homebrew/share/".
virt-manager -c test:///default
```

<br/>
