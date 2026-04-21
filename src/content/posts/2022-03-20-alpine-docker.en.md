---
title: "Alpine for Running Containers"
date: "2022-03-20"
categories: ["linux"]
tags: ["linux","server","alpine","docker"]
draft: false
cover:
  image: "/img/posts/logo-docker-a.svg"
  hidden: true
---

<img src="/img/posts/logo-docker-a.svg" alt="Docker logo" width="150px" style="float:left; padding-right:25px"  />

In this post I describe how to install Alpine Linux in a virtual machine on my QEMU/KVM server and how to install Docker on it. I needed, for proof-of-concept and home services, the ability to run containers on a Docker host that takes up "very little" space. Can you install a Docker Host on top of a Virtual Machine? The answer is a resounding yes — in fact, it's an excellent place to do so, especially in lab environments, home setups, and small deployments.

<br clear="left"/>
<!--more-->

## Introduction

I needed to set up microservices on top of Docker (it had been a while since I [played with Docker]({{< relref "2014-11-01-inicio-docker.md" >}})). I hesitated between adding Docker to my server where I have KVM, dedicating an old PC to Docker, or thinking of something more creative...

In the end I opted for the third option: **setting up virtual machines dedicated to Docker containers running on my KVM server**. My powerful little [System76 Meerkat](https://system76.com/desktops/meerkat) server is where I have all my VMs, and some of them will support microservices on top of Docker.

The second option (adding Docker to my server with KVM) would have been a networking nightmare (openvswitch + docker switches + iptables), so I chose to isolate and contain Docker problems/troubleshooting in dedicated VMs. My VM server setup is as follows:

- Hardware: System76 Meerkat
- Software: [Pop!_OS](https://pop.system76.com), Ubuntu Server LTS.
- Networking: [Open vSwitch]({{< relref "2022-02-20-openvswitch.md" >}})
- QEMU/KVM with Hypervisor
- Several guests with virtual machines running Linux (Ubuntu Server LTS) and services.
- Several guest appliances like [Umbrella](https://umbrella.cisco.com) or [vWLC](https://www.cisco.com/c/en/us/products/wireless/wireless-lan-controller/index.html) from Cisco.
- Several guests with **virtual machines running Alpine Linux with Docker and containers for services (git, nodered, ...)**.

<br/>

### Where to Run Docker?

The first thing I needed to decide was which OS to run Docker on, considering that:

- I'm going to run Docker inside a Virtual Machine on my QEMU/KVM server.
- The guest OS will only run Docker — I don't need a huge distribution.
- I'm looking for something small, easy to maintain, and robust.

Among the different options I found out [there](https://kuberty.io/blog/best-os-for-docker/), I chose [Alpine Linux](https://alpinelinux.org).

<br/>

#### Virtual Machine with Alpine Linux

Let's look at an example creating a VM.

- I download **Alpine Linux** from [Downloads](https://alpinelinux.org/downloads/) > VIRTUAL > *Slimmed down kernel. Optimized for virtual systems*, x86_64 (**only 52MB**) — the most compact version possible.

```shell
luis@sol:~/kvm/base$ wget https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-virt-3.15.3-x86_64.iso
luis@sol:~/kvm/base$ wget https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-virt-3.15.3-x86_64.iso.sha256
luis@sol:~/kvm/base$ sha256sum -c alpine-virt-3.15.3-x86_64.iso.sha256
alpine-virt-3.15.3-x86_64.iso: La suma coincide
```

- I create a `static` port on my virtual switch (more info here: [Open vSwitch and KVM]({{< relref "2022-02-20-openvswitch.md" >}})).

```
luis@sol:~/kvm/base$ sudo ovs-vsctl list-br
solbr
luis@sol:~/kvm/base$ sudo ovs-vsctl list-ports solbr
eth0
:
v100vnet12  (I check which was the last one I had registered)
:
luis@sol:~$ sudo ovs-vsctl add-port solbr v100vnet13 tag=100 -- set Interface v100vnet13 type=internal
```

- I create the directory where I'll place the virtual machine file.

```shell
luis@sol:~/kvm$ mkdir docker
```

- I create a **virtual machine** from `virt-manager` with **1GB of RAM, 1 CPU, 4GB disk, and a virtio NIC**, using the image: `alpine-virt-3.15.3-x86_64.iso`. I name it `docker.yourdomain.com` and for the network configuration I use the interface I just created `v100vnet13`.

```shell
luis@sol:~$ virt-manager
```

<div class="image-box">
  <img src="/img/posts/2022-03-20-alpine-docker-01.png" alt="Creating VM from virt-manager" width="450px" />
  <div class="image-caption">Creating VM from virt-manager</div>
</div>

- I start the VM and enter the Alpine setup (more info in [this guide](https://wiki.alpinelinux.org/wiki/QEMU)).

```shell
luis@sol:~/kvm/gitea-traefik-docker$ virsh console docker.yourdomain.com
localhost login: root
Welcome to Alpine!
:
localhost:~#
:
# export SWAP_SIZE=0
# setup-alpine
Select keyboard layout: [none] es
Select variant (or 'abort'): es
Enter system hostname (fully qualified form, e.g. 'foo.example.org') [localhost] docker
Available interfaces are: eth0.
Which one do you want to initialize? (or '?' or 'done') [eth0]
Ip address for eth0? (or 'dhcp', 'none', '?') [dhcp] 192.168.100.225/24
Gateway? (or 'none') [none] 192.168.100.1
Do you want to do any manual network configuration? (y/n) [n] n
DNS domain name? (e.g 'bar.com') yourdomain.com
DNS nameserver(s)? 192.168.100.224
Changing password for root
Which timezone are you in? ('?' for list) [UTC] Europe/Madrid
HTTP/FTP proxy URL? (e.g. 'http://proxy:8080', or 'none') [none]
Enter mirror number (1-71) or URL to add (or r/f/e/done) [1]
Which SSH server? ('openssh', 'dropbear' or 'none') [openssh]
Which disk(s) would you like to use? (or '?' for help or 'none') [none] vda
How would you like to use it? ('sys', 'data', 'crypt', 'lvm' or '?' for help) [?] sys
WARNING: Erase the above disk(s) and continue? (y/n) [n] y
Installation is complete. Please reboot.
docker:~# reboot
```

- I log in as root and install a few useful tools.

```shell
docker:~# apk add iproute2 nano tzdata
docker:~# cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime
docker:~# echo "Europe/Madrid" >  /etc/timezone
docker:~# apk del tzdata
```

- I create my `luis` user and configure SSH.

```shell
docker:~# addgroup -g 1000 luis
docker:~# adduser -h /home/luis -s /bin/ash -G luis --u 1000 luis
docker:~# adduser luis wheel
docker:~# su - luis
docker:~$
docker:~$ ssh-keygen -t rsa -b 2048 -C "luis@docker.yourdomain.com"
:
docker:~$ exit
```

- I create `authorized_keys` ([post about SSH in Linux]({{< relref "2009-02-01-ssh.md" >}}))
- I modify SSH to work only with public/private key authentication.

```shell
docker:~$ su -
Password:
docker:~# cat /etc/ssh/sshd_config
# Config LuisPa
Port 22
PubkeyAuthentication yes
PasswordAuthentication no
AuthenticationMethods publickey
AllowAgentForwarding yes
AllowTcpForwarding yes
GatewayPorts yes
AddressFamily inet
PrintMotd no
Subsystem sftp /usr/lib64/misc/sftp-server
AcceptEnv LANG LC_*
docker:~# service sshd restart
```

- I create the `/etc/nanorc` file ([source here](https://gist.github.com/LuisPalacios/4e07adf45ec1ba074939317b59d616a4)) for the `nano` editor.
- I speed up boot time to about 5 seconds.

```shell
docker:~# cat /boot/extlinux.conf
# Generated by update-extlinux 6.04_pre1-r9
#DEFAULT menu.c32                        # I comment out this line
DEFAULT virt                             # Added, virt = name below
PROMPT 0
MENU TITLE Alpine/Linux Boot Menu
MENU HIDDEN
MENU AUTOBOOT Alpine will be booted automatically in # seconds.
TIMEOUT 30
LABEL virt
  MENU LABEL Linux virt
  LINUX vmlinuz-virt
  INITRD initramfs-virt
  APPEND root=UUID=bff03f67-29ee-4525-96d9-3096a1799fc7 modules=sd-mod,usb-storage,ext4 quiet rootfstype=ext4
MENU SEPARATOR
```

<br/>

#### Docker and Docker Compose Installation

- I enable the **Community repository**

```shell
git:~# cat /etc/apk/repositories
#/media/cdrom/apks
http://dl-cdn.alpinelinux.org/alpine/v3.15/main
http://dl-cdn.alpinelinux.org/alpine/v3.15/community   <== Uncomment this line
```

- I add the following line to the `/etc/sudoers` file

```shell
# User rules for luis
luis ALL=(ALL) NOPASSWD:ALL
```

- I create a couple of helper scripts

```shell
nodered:~# cat > /usr/bin/e
#!/bin/ash
/usr/bin/nano "${*}"
nodered:~# chmod 755 /usr/bin/e
:
nodered:~# cat > /usr/bin/confcat
#!/bin/ash
# By LuisPa 1998
# confcat: strips comment lines, very useful as a substitute
# for "cat" to view content without comments.
#
grep -vh '^[[:space:]]*#' "$@" | grep -v '^//' | grep -v '^;' | grep -v '^$' | grep -v '^!' | grep -v '^--'
nodered:~# chmod 755 /usr/bin/confcat
:
nodered:~# cat > /usr/bin/s
#!/bin/ash
/usr/bin/sudo -i
nodered:~# chmod 755 /usr/bin/s
```

- I update the system and install very useful tools along with **docker** and **docker-compose**.

```shell
docker:~# apk update
docker:~# apk upgrade --available
docker:~# apk add bash-completion procps util-linux
docker:~# apk add readline findutils sed coreutils sudo
docker:~# apk add docker docker-bash-completion docker-compose docker-compose-bash-completion docker-cli-compose
docker:~# rc-update add docker boot
docker:~# service docker start
```

- I add my user to the docker group and reboot...

```shell
git:~# addgroup luis docker
git:~# reboot -f
```

- I test Docker (with the latest [alpine](https://hub.docker.com/_/alpine) image, which is tiny...)

```shell
docker:~$ docker pull alpine:latest
docker:~$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
alpine       latest    76c8fb57b6fc   3 days ago   5.57MB
docker:~$ docker create -t -i  --name myalpine alpine:latest
5f1fefa539848f9e0fe995bf2e9c426def69ca48bfacc51bdb509197939c041e
docker:~$ docker start myalpine
/ # exit
docker:~$ docker exec -it myalpine /bin/ash
docker:~$ docker stop myalpine
docker:~$ docker rm myalpine
```

- Don't be surprised that `docker stop myalpine` takes a while to stop. [Here](https://stackoverflow.com/questions/60493765/running-and-stopping-an-alpine-docker-container-takes-about-10x-as-long-as-cento) is the explanation.
