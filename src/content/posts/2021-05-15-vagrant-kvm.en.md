---
title: "Vagrant with Libvirt KVM"
date: "2021-05-15"
categories: ["virtualization"]
tags: ["linux","kvm","virtualization","python","jupyter","virtualbox","development"]
draft: false
cover:
  image: "/img/posts/logo-vagrantkvm.svg"
  hidden: true
---

<img src="/img/posts/logo-vagrantkvm.svg" alt="vagrant kvm logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

[Vagrant](https://www.vagrantup.com/) creates and runs virtual machines, relying on virtualization providers such as Virtualbox, KVM, Docker, VMWare, and [30+ others](https://github.com/hashicorp/vagrant/wiki/Available-Vagrant-Plugins#providers). It will always default to launching the VM with Virtualbox unless we explicitly specify a different provider. In this guide I explain how I set up **Vagrant with the Libvirt KVM provider on Linux**.

<br clear="left"/>
<!--more-->

## KVM Installation

Since I didn't have KVM installed, I followed these steps on my Linux Desktop (*Debian 11 - Bullseye*) to install KVM.

### Hardware virtualization support

First I check that my hardware supports virtualization. I look for "vmx" (Intel-VT) or "svm" (AMD-V) in the output of the command:

```shell
luis@jupiter:~$ egrep --color -i "svm|vmx" /proc/cpuinfo
```

<div class="image-box">
  <img src="/img/posts/2021-05-15-vagrant-kvm-01.png" alt="Looking for 'vmx' (Intel-VT) or 'svm' (AMD-V)" width="500px" />
  <div class="image-caption">Looking for 'vmx' (Intel-VT) or 'svm' (AMD-V)</div>
</div>

On some CPU models, VT support may be disabled in the BIOS. Check it to enable it...

Another method is to use the command:

```shell
luis@jupiter:~$ lscpu | grep -i Virtualiz
Virtualización: VT-x
```

<br>

### Installing KVM and dependencies

I install KVM and all the necessary dependencies to set up a virtualization environment.

```shell
luis@jupiter:~$ sudo apt install qemu qemu-kvm libvirt-clients libvirt-daemon-system virtinst bridge-utils
```

<br/>

- qemu - A generic machine emulator and virtualizer,
- qemu-kvm - QEMU metapackage for KVM support (i.e., full QEMU virtualization on x86 hardware),
- libvirt-clients - programs for the libvirt library,
- libvirt-daemon-system - Libvirt daemon configuration files,
- virtinst - programs to create and clone virtual machines,
- bridge-utils - utilities for configuring the Linux Ethernet Bridge.

The service should have started (Ubuntu starts services when they're installed), in any case you would do:

```shell
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
```

**I add my user to the `libvirt` group**

```shell
sudo adduser luis libvirt
```

**I verify everything is working**

```shell
systemctl status libvirtd
```

<div class="image-box">
  <img src="/img/posts/2021-05-15-vagrant-kvm-02.png" alt="Checking the services" width="500px" />
  <div class="image-caption">Checking the services</div>
</div>

**I install Virt-Manager** and start it. Although it's the recommended software for managing VMs, in this post I use it as a monitor — it will be useful to see how Vagrant creates, starts, stops, and destroys them.

```shell
luis@jupiter:~$ sudo apt install virt-manager
```

<div class="image-box">
  <img src="/img/posts/2021-05-15-vagrant-kvm-03.png" alt="Starting the VM Manager" width="500px" />
  <div class="image-caption">Starting the VM Manager</div>
</div>

<br/>

| We now have an operational installation where we can start creating and managing virtual machines, **with Vagrant**! |

<br/>

## Vagrant Installation

I install `vagrant` and the `vagrant-libvirt` plugin.

```shell
luis@jupiter:~$ sudo apt update
luis@jupiter:~$ sudo apt upgrade -y
:
luis@jupiter:~$ sudo apt-get install vagrant-libvirt
```

**I create my first VM**

Always in a dedicated directory, I create the `Vagrantfile` and bring up my first VM, in this example a simple `Vanilla Debian box`.

| Note: Here's the list of [boxes](https://app.vagrantup.com/boxes/search) (machines) you can install. I recommend reading this [guide](https://www.vagrantup.com/vagrant-cloud/boxes/catalog) |

```shell
luis@jupiter:~$ mkdir miproyecto
luis@jupiter:~$ cd miproyecto/
luis@jupiter:~/miproyecto$ vagrant init debian/buster64
A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.

luis@jupiter:~/miproyecto$ vagrant up --provider=libvirt
```

<div class="image-box">
  <img src="/img/posts/2021-05-15-vagrant-kvm-04.png" alt="We can see the VM from the manager" width="500px" />
  <div class="image-caption">We can see the VM from the manager</div>
</div>

**I try connecting to the VM**

```shell
luis@jupiter:~/miproyecto$ vagrant ssh
Linux buster 4.19.0-16-amd64 #1 SMP Debian 4.19.181-1 (2021-03-19) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
-bash: warning: setlocale: LC_ALL: cannot change locale (es_ES.UTF-8)
vagrant@buster:~$
```

<br/>

## Networking

By default, virtual machines with Vagrant are created with a private network and use DHCP. I prefer to use static IPs for my lab, but that's a matter of taste and use case. These are the configurations I typically use:

**Private networking + static IP**, `Vagrantfile`:

```config
    # Private Networking, with static IP to make SSH from the Host easier.
    config.vm.network :private_network,
                      :ip => "10.20.30.40",
                      :libvirt__domain_name => "coder.local"
```

**Public networking + static IP**, `Vagrantfile`:

```shell
    # Public Networking, with static IP
    config.vm.network "public_network",
                      :dev => "br0",
                      :mode => "bridge",
                      :type => "bridge",
                      :ip => "192.168.1.100"
```

Watch out!... if you're going to use the public IP version, you need to prepare the Host (your Linux server). It's necessary to configure the Ethernet interface with a bridge, and I recommend doing a manual configuration (don't use NetworkManager or similar). Here's an example of what I did on Linux with Debian 11:

```shell
root@jupiter:~# cat /etc/network/interfaces.d/br0
#
# Static IP configuration on the main Ethernet interface.
# Using Vagrant with public IPs, I need to create a Bridge
#
# After modifying this file: service networking restart
#
auto br0
iface br0 inet static
 address 192.168.1.200
 broadcast 192.168.1.255
 netmask 255.255.255.0
 gateway 192.168.1.1

 # I also installed the "resolvconf" package so I don't have to
 # edit the /etc/resolv.conf file but instead set
 # the DNS server IP from here.
 dns-nameservers 192.168.1.253

 # I add my physical interface to the Bridge. The interfaces
 # configured with Vagrant in public mode with static IP will be
 # added to this bridge.
 #
 bridge_ports enp0s25
 bridge_stp off       # Disable Spanning Tree Protocol
 bridge_waitport 0    # Don't wait before enabling the port
 bridge_fd 0          # No forwarding delay
```

- I install `resolvconf` and restart the networking service

```shell
# apt install resolvconf
# service networking restart  (you might need to reboot)
```

<br/>

## Use case

In this GitHub repository you'll find a [virtual machine for software development prepared with Vagrant](https://github.com/LuisPalacios/devbox). You can also find in the post "[User Systemd Services]({{< relref "2021-05-30-systemd-usuario.md" >}})" how to run user processes during system boot, to start this virtual machine with Vagrant during boot.
