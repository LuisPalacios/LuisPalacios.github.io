---
title: "PlexConnect on Linux"
date: "2014-01-07"
categories: ["linux"]
tags: ["gentoo","plex","plexconnect"]
draft: false
cover:
  image: "/img/posts/logo-plex.svg"
  hidden: true
---

<img src="/img/posts/logo-plex.svg" alt="Plex" width="150px" style="float:left; padding-right:25px"  />

Notes on configuring PlexConnect on Linux to use Plex with an Apple TV3. I only had to modify the DHCP Server, add 3 redirections with iptables, and configure/start the PlexConnect program.

<br clear="left"/>
<!--more-->

## Configuration

These are the IP addresses to understand the instructions:

- Linux server "bolica" - IP address: "192.168.1.1"
- Apple TV 3 "atv3" - IP address: "192.168.1.37"
- Router: 192.168.1.1
- DNS Server: 192.168.1.1

<div class="image-box">
  <img src="/img/posts/2014-01-07-plexconnect-en-linux-02.jpg" alt="PlexConnect project [PlexConnect](https://www.plex.tv/)" width="300px" />
  <div class="image-caption">[PlexConnect](https://www.plex.tv/) project</div>
</div>

Let's look at the Linux configuration

- DHCP, Router, DNS.
- iptables: Port redirection for the ATV3: 80->9080 (http), 443->9443 (https) and 53->9053 (dns)
- PlexConnect: Listens on ports: webserver (9080), webserver https (9443) and dns (9053)

If you have a DNS server on your Linux box, you don't need to touch it since we redirect port 53 (udp) traffic coming from the Apple TV to the DNS server embedded in PlexConnect (9053 udp). If you have a Web Server, same thing — you don't need to touch it because ports 80/443 traffic originating from the Apple TV is redirected to the one embedded in PlexConnect (9080/9443).

<br/>

### Plex Media Server

Obviously, you need to have a Plex Media Server running somewhere. In my case, on the same Linux machine. It's a Gentoo Linux server, so I just had to install it from portage and configure PMS. Installation on Gentoo: `emerge -v plex-media-server`

Then you can [connect via this link](http://192.168.1.1:32400/web/index.html#!/setup)

<br/>

### DHCP

The only important thing here is that the ATV3 must be configured (via DHCP) so that its DNS server points to the Linux box (192.168.1.1). I could have done it manually from the ATV settings, but I prefer to do it via my DHCP server:

```config
  :
  subnet 192.168.1.0 netmask 255.255.255.0 {
    option routers 192.168.1.1;
    option subnet-mask 255.255.255.0;
    option domain-name "tudominio.com";
    option domain-name-servers 192.168.1.1;
    option interface-mtu 1496;
  :
  host atv3 {
    hardware ethernet f4:f9:51:b7:6c:da;
    fixed-address atv3.tudominio.com;
  }
  :
```

### iptables

This is important. To achieve "touching almost nothing" on the Linux machine, I'm going to set up three redirections. Basically, everything coming from the Apple TV destined for ports 80, 443, and 53 (udp) gets redirected. Here's the command I run on my machine:

```shell
iptables -t nat -A PREROUTING -i vlan100 -s 192.168.1.37 -d 192.168.1.1/32 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1:9080
iptables -t nat -A PREROUTING -i vlan100 -s 192.168.1.37 -d 192.168.1.1/32 -p tcp --dport 443 -j DNAT --to-destination 192.168.1.1:9443
iptables -t nat -A PREROUTING -i vlan100 -s 192.168.1.37 -d 192.168.1.1/32 -p udp --dport 53 -j DNAT --to-destination 192.168.1.1:9053
```

<br/>

### PlexConnect Installation

I run the program once, which will terminate with an error. I do this so the configuration file gets created. Note: PlexConnect does NOT work with Python 3.x, so I use version 2.7

```shell
# mkdir /root/Plex
# cd /root/Plex
# wget https://github.com/iBaa/PlexConnect/archive/master.zip
# unzip master.zip
# mv PlexConnect-master PlexConnect
# rm master.zip

# cd /root/Plex/PlexConnect
# EPYTHON="python2.7" ./PlexConnect.py
```

```
# ls -al assets/certificates/
total 24
drwxr-xr-x 2 root root 4096 ene 7 15:50 .
drwxr-xr-x 7 root root 4096 ene 5 19:08 ..
-rw-r--r-- 1 root root 921 ene 5 19:08 certificates.txt
-r-------- 1 root root 872 ene 7 15:50 trailers.cer
-r-------- 1 root root 1679 ene 7 15:50 trailers.key
-r-------- 1 root root 2916 ene 7 15:50 trailers.pem
```

To simplify future startups I created a couple of files:

```shell
# /etc/conf.d/plexconnect
# Copyright 2014 LuisPa
# Distributed under the terms of the GNU General Public License v2

# File where the process number is stored
PLEXCONNECT_PIDFILE="/run/plexconnect.pid"

# Executable: I use Python2 (associated with 2.7, the version supported by PlexConnect)
PLEXCONNECT_EXEC="/usr/bin/python2 /root/Plex/PlexConnect/PlexConnect.py"

# Working directory
PLEXCONNECT_CWD="/root/Plex/PlexConnect"

# Options
PLEXCONNECT_OPTS=""

#!/sbin/runscript
# Copyright 2014 LuisPa
# Distributed under the terms of the GNU General Public License v2
# $Header: $

depend() {
 need net
}

start() {
 ebegin "Starting ${SVCNAME}"

  iptables -t nat -A PREROUTING -i vlan100 -s 192.168.1.37 -d 192.168.1.1/32 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1:9080
 iptables -t nat -A PREROUTING -i vlan100 -s 192.168.1.37 -d 192.168.1.1/32 -p tcp --dport 443 -j DNAT --to-destination 192.168.1.1:9443
 iptables -t nat -A PREROUTING -i vlan100 -s 192.168.1.37 -d 192.168.1.1/32 -p udp --dport 53 -j DNAT --to-destination 192.168.1.1:9053

 start-stop-daemon --start --quiet \
 --make-pidfile \
 --pidfile ${PLEXCONNECT_PIDFILE} \
 --background \
 --chdir ${PLEXCONNECT_CWD} \
 --exec ${PLEXCONNECT_EXEC} \
 -- ${PLEXCONNECT_OPTS}
 eend $?
}

stop() {
 ebegin "Stopping ${SVCNAME}"

 iptables -t nat -D PREROUTING -i vlan100 -s 192.168.1.37 -d 192.168.1.1/32 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1:9080
 iptables -t nat -D PREROUTING -i vlan100 -s 192.168.1.37 -d 192.168.1.1/32 -p tcp --dport 443 -j DNAT --to-destination 192.168.1.1:9443
 iptables -t nat -D PREROUTING -i vlan100 -s 192.168.1.37 -d 192.168.1.1/32 -p udp --dport 53 -j DNAT --to-destination 192.168.1.1:9053

 start-stop-daemon --stop --pidfile ${PLEXCONNECT_PIDFILE}
 eend $?
}
```

As with any other service, I schedule it to run at boot:

```shell
# rc-update add plexconnect default
```

## PlexConnect Configuration

```config
[PlexConnect]
logpath = .
loglevel = High
enable_webserver_ssl = True
enable_dnsserver = True
prevent_atv_update = True
port_dnsserver = 9053
ip_dnsmaster = 192.168.1.1
enable_plexconnect_autodetect = False
ip_plexconnect = 192.168.1.1
port_webserver = 9080
port_ssl = 9443
certfile = ./assets/certificates/trailers.pem
enable_plexgdm = False
ip_pms = 192.168.1.1
port_pms = 32400
hosttointercept = trailers.apple.com
```

```config
[PlexConnect]

# LOG SECTION
# ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======
#
# Log configuration. In this section we define where the
# PlexConnect.log file will be created and its log level
#
# logpath: Directory where PlexConnect.log is created. In my case
# I use --chdir in /etc/init.d/plexconnect so the CWD is
# the same as where the program lives, so I specify '.'
# so the file resides in the same location
logpath = .
#
# loglevel: Log level. I recommend using High initially during
# setup, then 'Normal' and finally 'Off' once everything
# works perfectly. Options: 'Normal', 'High', 'Off'
loglevel = High

# WEB SERVICE SECTION
# ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======
#
# Port to listen for HTTP requests
# An additional "WebServer" process will be started listening
# on this port.
port_webserver = 9080

# Web Service: Define whether to start an HTTPS server
# In my case we need to say yes because we're going to emulate
# Apple's http and https web servers: trailers.apple.com
enable_webserver_ssl = True

# Port to listen for HTTPS requests
# An additional "WebServer" process will be started listening
# on this port to handle "Trailers" requests
port_ssl = 9443
certfile = ./assets/certificates/trailers.pem

# DNS SERVICE SECTION
# ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======
#
# Enable a DNS Server when running PlexConnect.py
# We also enable this — to impersonate trailers.apple.com
# I need to act as a dns server. I listen on an unusual port to
# avoid conflicting with the DNS server already running on Linux
enable_dnsserver = True
#
# Port to listen for DNS requests (udp)
port_dnsserver = 9053
#
# IP address of the next DNS Server, i.e., where to redirect
# all ATV requests we don't want to modify/impersonate
# In my case, my own DNS server running on Linux that I haven't "touched"
ip_dnsmaster = 192.168.1.1
#
# Prevent the ATV from calling home to check for updates
prevent_atv_update = True

# Name of the host to intercept. All 80/443 requests going to it
# will be redirected to Linux on ports 9080/9443
hosttointercept = trailers.apple.com

# PLEXCONNECT SECTION
# ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======
#
# IP address where PlexConnect runs. I disable autodetection, useful if
# you have multiple network cards and only want PlexConnect to listen on
# a single one.
enable_plexconnect_autodetect = False
ip_plexconnect = 192.168.1.1

# PMS Plex Media Server SECTION
# ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======
#
# PlexConnect needs to know where PMS is. In my case, since I only have
# a single PMS, I prefer to set the IP manually
#
# Don't auto-detect PMSs
enable_plexgdm = False

# IP where a PMS is running. In my case it's also on the same Linux system
ip_pms = 192.168.1.1

# Port where PMS listens
port_pms = 32400
```

## Starting the Service

We start it with the command: `/etc/init.d/plexconnect start`

```sh
# ps -ef |grep -i plexco
root 24054 1 1 16:49 ? 00:00:00 /usr/bin/python2 /root/Plex/PlexConnect/PlexConnect.py
root 24064 24054 0 16:49 ? 00:00:00 /usr/bin/python2 /root/Plex/PlexConnect/PlexConnect.py
root 24067 24054 0 16:49 ? 00:00:00 /usr/bin/python2 /root/Plex/PlexConnect/PlexConnect.py
root 24068 24054 0 16:49 ? 00:00:00 /usr/bin/python2 /root/Plex/PlexConnect/PlexConnect.py
```

In total we should see four processes: the main "PlexConnect" which in turn starts a "DNS Server" listening on port 9053, an "HTTP WebServer" listening on port 9080, and a second "HTTPS WebServer" listening on port "9443".

That's it — now you can go to your Apple TV3 and click on the Trailers icon.

<div class="image-box">
  <img src="/img/posts/2014-01-07-plexconnect-en-linux-01.jpg" alt="PlexConnect logo" width="300px" />
  <div class="image-caption">PlexConnect logo</div>
</div>
