---
title: "NTP Time Service"
date: "2009-05-01"
categories: ["linux"]
tags: ["linux","ntp","gentoo","time"]
draft: false
cover:
  image: "/img/posts/logo-ntp.svg"
  hidden: true
---

<img src="/img/posts/logo-ntp.svg" alt="ntp" width="150px" height="150px" style="float:left; padding-right:25px"  />

NTP is an Internet protocol for synchronizing computer system clocks by exchanging data packets over networks with variable latency. NTP uses the UDP protocol as its transport layer (port `123`). It is designed to withstand the effects of variable latency.

In this post I explain how to configure NTP on a GNU/Linux machine (Gentoo distribution) to set and maintain the correct time, while also serving as a time server on your home network.

<br clear="left"/>
<!--more-->

## NTP + NTP-CLIENT

[Clock quality](http://www.ntp.org/ntpfaq/NTP-s-sw-clocks-quality.htm): The system will maintain the clock through software techniques while the server is running, but once you shut down the server the hardware clock may drift significantly -- that's why I'll force a clock synchronization during system restart.

I'm going to run the NTP daemon as a service and run it with a user other than root. To be able to run ntp as a non-root user, you need to configure the following in certain Kernel versions and enable the "caps" USE flag.

```conf
Security options  --->
    [*] File POSIX Capabilities
```

NTP

```conf
net-misc/ntp                    ipv6 ssl zeroconf caps
```

Required by NTP

```conf
net-dns/avahi                   mdnsresponder-compat
```

### Installation

I run the installation of ntpd and ntpclient

```shell
# emerge -v ntp ntpclient
```

The ntpd program has to run as a service and the ntp-client program has to run during boot. If this is your first time synchronizing, I recommend the following: add the services, update the time with ntp-client (to adjust the software clock) and reboot the machine, so the hardware clock gets updated and then ntpd starts normally.

### Running with openrc

I configure the support files. The ntpd daemon uses the file /etc/ntp.conf by default

```conf
#
# Servers that provide me with the time
server 0.gentoo.pool.ntp.org
server 1.gentoo.pool.ntp.org
server 2.gentoo.pool.ntp.org
server 3.gentoo.pool.ntp.org
#
# Server that provides the time in case of internet outage, using my hardware clock
server 127.0.0.1
fudge 127.0.0.1 stratum 10
#
# Interfaces on which I will serve the time
interface ignore wildcard
interface listen 127.0.0.1
interface listen 192.168.1.1
#
# Working files
logfile         /var/log/ntpd.log
driftfile   /var/lib/ntp/ntp.drift
#
# Restrictions, working without peers and only serving time on loopback and intranet
restrict default nomodify nopeer
restrict 127.0.0.1
restrict 192.168.1.0 mask 255.255.255.0 nomodify nopeer notrap

NTPD_OPTS="-u ntp:ntp"

NTPCLIENT_CMD="ntpdate"
NTPCLIENT_OPTS="-s -b -u \
    0.gentoo.pool.ntp.org 1.gentoo.pool.ntp.org \
    2.gentoo.pool.ntp.org 3.gentoo.pool.ntp.org"

CLOCK_SYSTOHC="yes"
```

Activation

```shell
# rc-update add ntpd default
# rc-update add ntp-client default
:
# /etc/init.d/ntp-client start
:
# reboot
```

### Running with systemd

I configure the support files. The ntpd daemon uses the file `/etc/ntp.conf` by default, but in my case I preferred to rename it. NOTE: This is a personal decision because I think it makes more sense to add the "d" for daemon, so remember that I have renamed the configuration file to `/etc/ntpd.conf` and I will tell the executable to use it in the ntpd.service file.

```conf
#
# Servers that provide me with the time
server 0.gentoo.pool.ntp.org
server 1.gentoo.pool.ntp.org
server 2.gentoo.pool.ntp.org
server 3.gentoo.pool.ntp.org
#
# Server that provides the time in case of internet outage, using my hardware clock
server 127.0.0.1
fudge 127.0.0.1 stratum 10
#
# Interfaces on which I will serve the time
interface ignore wildcard
interface listen 127.0.0.1
interface listen 192.168.1.1
#
# Working files
logfile         /var/log/ntpd.log
driftfile   /var/lib/ntp/ntp.drift
#
# Restrictions, working without peers and only serving time on loopback and intranet
restrict default nomodify nopeer
restrict 127.0.0.1
restrict 192.168.1.0 mask 255.255.255.0 nomodify nopeer notrap

NTPD_OPTS="-c /etc/ntpd.conf -g -u ntp:ntp"

NTPCLIENT_OPTS="-s -b -u \
    0.gentoo.pool.ntp.org 1.gentoo.pool.ntp.org \
    2.gentoo.pool.ntp.org 3.gentoo.pool.ntp.org"
```

I set the clock and disable the NTP client that comes with systemd.

```shell
cortafuegix ~ # timedatectl set-local-rtc 0
cortafuegix ~ # timedatectl set-timezone Europe/Madrid
cortafuegix ~ # timedatectl set-time "2012-10-30 18:17:16" <= Set the time first.
cortafuegix ~ # timedatectl set-ntp false
```

I configure the .service files for ntp and ntp-client

```conf
[Unit]
Description=Network Time Service
After=ntp-client.service
Conflicts=systemd-timesyncd.service

[Service]
ExecStart=/usr/sbin/ntpd -c /etc/ntpd.conf -g -n -u ntp:ntp
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

```conf
[Unit]
Description=Set time via NTP using ntpdate
After=network-online.target nss-lookup.target
Before=time-sync.target
Wants=time-sync.target
Conflicts=systemd-timesyncd.service

[Service]
Type=oneshot
EnvironmentFile=/etc/conf.d/ntp-client
ExecStart=/usr/sbin/ntpdate $NTPCLIENT_OPTS
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

I enable the service

```shell
# systemctl enable ntp-client
# systemctl enable ntpd
:
# reboot
```

### NTPD Management

It can take up to 4 hours to calibrate the clock before reaching the correct Stratum state (since you're synchronizing with stratum 2 servers, your state should be stratum 3). In fact, the reason I run ntp-client (before ntpd) is to set the machine's time so that this process is faster. When ntpd starts and sees that the machine's time matches its servers, it will synchronize very quickly. If the state hasn't changed after a while, something is failing. The correct result is that it says "stratum=3"

```shell
$ ntpq -c readvar
assID=0 status=06f4 leap_none, sync_ntp, 15 events, event_peer/strat_chg,
version="ntpd 4.2.4p7@1.1607-o lun ago 17 07:38:15 UTC 2009 (1)",
processor="x86_64", system="Linux/2.6.30-gentoo-r4", leap=00, stratum=3,        <=====
precision=-20, rootdelay=81.469, rootdispersion=176.829, peer=59651,
refid=147.83.175.41,
reftime=ce33fdf3.a893739b  Mon, Aug 17 2009 18:04:03.658, poll=6,
clock=ce33fe7e.4d15c9c5  Mon, Aug 17 2009 18:06:22.301, state=4,
offset=-46.921, frequency=11.491, jitter=79.033, noise=3.260,
stability=0.876, tai=0
```

If after a few hours your server is still at stratum 16, then something is failing. Check [this guide](https://support.ntp.org/bin/view/Support/TroubleshootingNTP). You can check which servers you are connected to

```shell
$ ntpq -c peers
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
-clip.dia.fi.upm 193.204.114.232  2 u    5   64  377   45.026  -44.194  71.461
+matillas.uc3m.e 194.117.9.130    3 u   57   64  377   44.340  -46.080   2.409
+alertas.efor.es 193.79.237.14    2 u    1   64  377   64.722  -47.021  64.068
*abridoc.upc.es  158.227.98.15    2 u   50   64  377   58.230  -48.697  79.016
```

## OpenNTP

Below is an example configuration for several Linux machines with systemd. I've configured two as NTP Servers with "OpenNTPD" and the rest will use the client embedded in systemd.

### Servers with Openntpd

OpenNTPD is a lightweight version of the NTP server ported from OpenBSD. I configure two machines as servers: cortafuegix and apodix.

- Installation

```shell
root # emerge --ask net-misc/openntpd
```

### Configuration as Daemon

- I set the clock and disable the NTP client that comes with systemd

```shell
cortafuegix ~ # timedatectl set-local-rtc 0
cortafuegix ~ # timedatectl set-timezone Europe/Madrid
cortafuegix ~ # timedatectl set-time "2012-10-30 18:17:16" <= Set the time first.
cortafuegix ~ # timedatectl set-ntp false
```

- I configure the file to act as a server

```conf
# NTP Server Configuration
listen on *

# Synchronize with NTP pool servers
servers 0.gentoo.pool.ntp.org
servers 1.gentoo.pool.ntp.org
servers 2.gentoo.pool.ntp.org
servers 3.gentoo.pool.ntp.org
```

- I schedule the daemon to start on the next boot and activate it

```shell
cortafuegix ~ # systemctl enable ntpd
cortafuegix ~ # systemctl start ntpd
:
cortafuegix ~ # timedatectl
      Local time: sáb 2015-05-30 08:22:51 CEST
  Universal time: sáb 2015-05-30 06:22:51 UTC
        RTC time: sáb 2015-05-30 06:22:51
       Time zone: Europe/Madrid (CEST, +0200)
     NTP enabled: no                           <== On the Server it shows "NO"
NTP synchronized: yes                          <== On the Server it shows "yes"
 RTC in local TZ: no
      DST active: yes
 Last DST change: DST began at
                  dom 2015-03-29 01:59:59 CET
                  dom 2015-03-29 03:00:00 CEST
 Next DST change: DST ends (the clock jumps one hour backwards) at
                  dom 2015-10-25 02:59:59 CEST
                  dom 2015-10-25 02:00:00 CET
```

## Client with systemd-timesyncd

For the client machines I use the one included with systemd

```conf
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.
#
# You can override the directives in this file by creating files in
# /etc/systemd/timesyncd.conf.d/*.conf.
#
# See timesyncd.conf(5) for details

[Time]
NTP=cortafuegix.tudominio.com apodix.tudominio.com
FallbackNTP=0.gentoo.pool.ntp.org 1.gentoo.pool.ntp.org 2.gentoo.pool.ntp.org 3.gentoo.pool.ntp.org
```

- I set the clock and enable the NTP client that comes with systemd

```shell
gentoo ~ # timedatectl set-local-rtc 0
gentoo ~ # timedatectl set-timezone Europe/Madrid
gentoo ~ # timedatectl set-time "2012-10-30 18:17:16" <= Set the time first.
gentoo ~ # timedatectl set-ntp true
:
gentoo ~ # timedatectl
      Local time: sáb 2015-05-30 08:22:29 CEST
  Universal time: sáb 2015-05-30 06:22:29 UTC
        RTC time: sáb 2015-05-30 06:22:30
       Time zone: Europe/Madrid (CEST, +0200)
     NTP enabled: yes                           <== On Clients it shows "YES"
NTP synchronized: no                            <== On Clients it shows "NO"
 RTC in local TZ: no
      DST active: yes
 Last DST change: DST began at
                  dom 2015-03-29 01:59:59 CET
                  dom 2015-03-29 03:00:00 CEST
 Next DST change: DST ends (the clock jumps one hour backwards) at
                  dom 2015-10-25 02:59:59 CEST
                  dom 2015-10-25 02:00:00 CET
```
