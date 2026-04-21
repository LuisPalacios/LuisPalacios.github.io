---
title: "OpenVPN Server"
date: "2014-09-14"
categories: ["security"]
tags: ["linux","vpn","openvpn","firewall","tunnels","security"]
draft: false
cover:
  image: "/img/posts/logo-openvpn.svg"
  hidden: true
---

<img src="/img/posts/logo-openvpn.svg" alt="OpenVPN logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

In this technical post I'll describe how to set up a home VPN Server based on [OpenVPN](https://openvpn.net/), which remains the best solution today despite being more complex to implement. The goal is to have access to the internal services of my home network from the internet.

<br clear="left"/>
<!--more-->

- OpenVPN is the best VPN solution available today. It's reliable, fast, and most importantly, very secure — even against agencies that claim to have compromised other protocols. On the downside, its configuration is more complex and it requires additional software on clients.
- IKEv2 is also a fast and secure protocol when using the open source implementation. For mobile users, it has the advantage (over OpenVPN) of reconnecting automatically. It's the only solution for BlackBerry users.
- SSTP offers the same advantages as OpenVPN but only for Windows environments, so forget about it — created by Microsoft and proprietary.
- PPTP is very **insecure** — even Microsoft, which participated in its development, has abandoned it. It has the advantage of being very easy to implement and is compatible with several platforms, but you should avoid it. A quick alternative is L2TP/IPsec with the same advantages but more secure.
- L2TP/IPsec is a good VPN solution for non-critical use and quick setup without additional software, but beware! rumors suggest it has also been compromised.

<br/>

## Software Installation

We prepare the file `/etc/portage/package.use/vpn`

```config
net-misc/openvpn      lzo -pam plugins ssl systemd iproute2 examples
```

We launch the installation.

```shell
# emerge -v app-crypt/easy-rsa
# emerge -v openvpn
```

<br/>

## PKI Infrastructure

This is my first time installing OpenVPN, so I need to create my own PKI infrastructure from scratch. PKI stands for Public Key Infrastructure and is the set of resources needed to create digital certificates. I'll leave [here](http://sobrebits.com/montar-un-servidor-casero-con-raspberry-pi-parte-7-instalacion-y-configuracion-de-openvpn/) and [here](https://wiki.gentoo.org/wiki/Create_a_Public_Key_Infrastructure_Using_the_easy-rsa_Scripts) a couple of interesting links where everything is well explained. Below is a record of my installation:

```shell
# cp -a /usr/share/easy-rsa /root/easy-rsa-servidor
# cd /root/easy-rsa-servidor
```

Configuration file `/root/easy-rsa-servidor`

```config
export KEY_COUNTRY="ES"
export KEY_PROVINCE="Madrid"
export KEY_CITY="Madrid"
export KEY_ORG="Parchis"
export KEY_EMAIL="mi@correo.com"
export KEY_CN="servidor.dominio.com"
export KEY_NAME="LuisPa"
export KEY_OU="Parchis"
```

```shell
# cd /root/easy-rsa-servidor
# source ./vars
# ./clean-all
# ./build-ca
# ./build-key-server servidor.dominio.com
# ./build-dh
```

I create the key for each user that will connect to this VPN Server, starting with mine:

```shell
# ./build-key luis
```

I generate the Hash-based Message Authentication Code (HMAC):

```shell
# openvpn --genkey --secret /root/easy-rsa-servidor/keys/ta.key
```

The files end up in the **keys** directory:

- `ca.crt`: Public certificate of the Certificate Authority (CA) that I'll need to use on both the server and all clients.
- `servidor.dominio.com.crt` and `servidor.dominio.com.key`: Server's public and private certificate, only needed on the Linux box, not on clients.
- `luis.crt` and `luis.key`: Client's public and private certificates created with `./build-key luis`, to be used on that user's device.

<br/>

## OpenVPN

I move the directory created with easy-rsa to /etc/openvpn

```shell
# mv /root/easy-rsa-servidor /etc/openvpn
```

I edit and prepare the configuration file called luispaVPN: `/etc/openvpn/luispaVPN.conf`

```config
# server binding port
port 12112

# openvpn protocol, could be tcp / udp / tcp6 / udp6
proto udp

# tun/tap device
dev tun0

# keys configuration, use generated keys
ca easy-rsa-servidor/keys/ca.crt
cert easy-rsa-servidor/keys/servidor.dominio.com.crt
key easy-rsa-servidor/keys/servidor.dominio.com.key
dh easy-rsa-servidor/keys/dh1024.pem

# optional tls-auth key to secure identifying
# tls-auth example/ta.key 0

# OpenVPN 'virtual' network infomation, network and mask
server 192.168.254.0 255.255.255.0

# persistent device and key settings
persist-key
persist-tun
ifconfig-pool-persist ipp.txt

# pushing route tables
push "route 192.168.1.0 255.255.255.0"
push "dhcp-option DNS 192.168.1.1"

# connection
keepalive 10 120
comp-lzo

user nobody
group nobody

# logging
status openvpn-status.log
log /etc/openvpn/openvpn.log
verb 4
```

- I start the service with systemd, verify it works, and enable it for boot. Since the file name is `luispaVPN.conf`, I use `luispaVPN` as the service name.

```shell
# mkdir /var/run/openvpn

# systemctl start openvpn@luispaVPN
:
# ps -ef
:
nobody   13080     1  0 17:13 ?        00:00:00 /usr/sbin/openvpn --daemon --writepid /var/run/openvpn/luispaVPN.pid --cd /etc/openvpn/ --config luispaVPN.conf
:
#
# systemctl enable openvpn@luispaVPN
```

<br/>

## macOS Client

To connect from macOS you need to install a client. A very popular one is [Passepartout](https://passepartoutvpn.app/):

- Download and install the OpenVPN client for macOS: Passepartout
- Run Passepartout

Remember that you need to transfer the files `ca.crt, luis.crt and luis.key` to the client.
