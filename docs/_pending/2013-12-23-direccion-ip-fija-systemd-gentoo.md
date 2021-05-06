---
title: "Dirección IP fija: Systemd + Gentoo"
date: "2013-12-23"
categories: gentoo linux systemd
tags: linux systemd
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/IP.jpg"
    caption="IP"
    width="600px"
    %}

 
# emerge -v iproute2
:
# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eno16777736: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
link/ether 00:0c:29:85:24:22 brd ff:ff:ff:ff:ff:ff
:
 

**Parar el cliente dhcp** Nota que en mi caso el interfaz se llama "eno16777736". Vamos a ello... el primer paso es parar el servicio "DHCP Cliente" si lo tenías funcionando.

 
# systemctl stop dhcpcd.service
# systemctl disable dhcpcd.service
 

**Dirección IP fija** Primero preparo el fichero resolv.conf

domain parchis.org
nameserver 192.168.1.1

Después creo los dos archivos siguientes:

address=192.168.1.40
netmask=24
broadcast=192.168.1.255
gateway=192.168.1.1

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

**Habilito y arranco el nuevo servicio** Por último habilito y ordeno la ejecución del servicio que activará la IP fija.

 
# systemctl enable network\@eno16777736.service
# systemctl start network\@eno16777736.service
