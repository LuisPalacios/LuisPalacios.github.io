---
title: "Static IP with Systemd on Gentoo"
date: "2013-12-23"
categories: ["linux"]
tags: ["linux","systemd","gentoo","networking","ip","static"]
draft: false
cover:
  image: "/img/posts/logo-ip.svg"
  hidden: true
---


<img src="/img/posts/logo-ip.svg" alt="Static IP" width="150px" style="float:left; padding-right:25px"  />

In this post I describe how to configure a static IP address on a Linux machine based on Gentoo. Normally this operating system comes pre-configured to load a dynamic IP address via the DHCP protocol.

<br clear="left"/>
<!--more-->

First we check the name of the device that gives us network access.

```shell
# emerge -v iproute2
:
# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eno16777736: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
link/ether 00:0c:29:85:24:22 brd ff:ff:ff:ff:ff:ff
:
``` 

Next we're going to **stop the DHCP client**. Note that in my case the interface is called "eno16777736". Let's get to it... the first step is to stop the "DHCP Client" service if you had it running.

```shell 
# systemctl stop dhcpcd.service
# systemctl disable dhcpcd.service
``` 

Now we can assign the **static IP address**. We prepare the `/etc/resolv.conf` file

```shell
domain yourdomain.com
nameserver 192.168.1.1
```

Then I create the following two files:

```shell
address=192.168.1.40
netmask=24
broadcast=192.168.1.255
gateway=192.168.1.1
```

```
[Unit]
Description=Network connectivity (%i)
Wants=network.target
Before=network.target
BindsTo=sys-subsystem-net-devices-%i.device
After=sys-subsystem-net-devices-%i.device

[Service]
Type=oneshot
RemainAfterExit=yes
EnvironmentFile=/etc/conf.d/network@%i

ExecStart=/bin/ip link set dev %i up
ExecStart=/bin/ip addr add ${address}/${netmask} broadcast ${broadcast} dev %i
ExecStart=/bin/ip route add default via ${gateway}

ExecStop=/bin/ip addr flush dev %i
ExecStop=/bin/ip link set dev %i down

[Install]
WantedBy=multi-user.target
```

Finally, **enable and start the new service** -- the execution of the service that will activate the static IP.

```shell
# systemctl enable network\@eno16777736.service
# systemctl start network\@eno16777736.service
```
