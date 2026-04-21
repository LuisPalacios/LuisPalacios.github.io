---
title: "IPtables with nflog"
date: "2014-08-31"
categories: ["security"]
tags: ["linux","vpn","openvpn","firewall","tunnels","security","iptables"]
draft: false
cover:
  image: "/img/posts/2014-08-31-log-iptables-01.jpg"
  hidden: true
---


<img src="/img/posts/2014-08-31-log-iptables-01.jpg" alt="log logo" width="150px" style="float:left; padding-right:25px"  />

Geek quote: "Logging what happens is wise..." In the past I used `ULOG` to analyze which packets were being dropped by `iptables`, but since it's been marked as deprecated I've switched to `NFLOG`.

<br clear="left"/>
<!--more-->

#### Kernel Configuration

Configure the following in the Kernel:

```config
- CONFIG_NETFILTER_NETLINK_LOG=y # Log packets via NFNETLINK interface
- CONFIG_NETFILTER_XT_TARGET_NFLOG=y # Enables NFLOG target (allows log through nfnetlink_log)
- CONFIG_NETFILTER_XT_TARGET_LOG=y # Enables LOG target (allows log through syslog) OLD METHOD
- CONFIG_IP_NF_TARGET_ULOG=n # "unset" OLD ULOG Target
```

#### CONFIG_NETFILTER_NETLINK_LOG

We enable the logging option through NFNETLINK — this is the new option that will allow working with the NFLOG target

```kernel
Symbol: NETFILTER_NETLINK_LOG [=y]
Prompt: Netfilter LOG over NFNETLINK interface
 -> Networking support (NET [=y])
 -> Networking options
 -> Network packet filtering framework (Netfilter) (NETFILTER [=y])
 -> Core Netfilter Configuration
 {*} Netfilter LOG over NFNETLINK interface
```

#### CONFIG_NETFILTER_XT_TARGET_NFLOG

NFLOG target, so we can use it with iptables.

```kernel
Symbol: NETFILTER_XT_TARGET_NFLOG [=m]
Prompt: "NFLOG" target support
 -> Networking support (NET [=y])
 -> Networking options
 -> Network packet filtering framework (Netfilter) (NETFILTER [=y])
 -> Core Netfilter Configuration
 -> Netfilter Xtables support (required for ip_tables) (NETFILTER_XTABLES [=y])
 <*> "NFLOG" target support
```

#### CONFIG_NETFILTER_XT_TARGET_LOG

This is the old method used for logging to SYSLOG. I no longer need it, so I've disabled it:

```kernel
Symbol: NETFILTER_XT_TARGET_LOG [=y]
Prompt: LOG target support
 -> Networking support (NET [=y])
 -> Networking options
 -> Network packet filtering framework (Netfilter) (NETFILTER [=y])
 -> Core Netfilter Configuration
 -> Netfilter Xtables support (required for ip_tables) (NETFILTER_XTABLES [=y])
 < > LOG target support
```

#### CONFIG_NETFILTER_XT_TARGET_LOG (OBSOLETE)

This is the old ULOG, which being obsolete I've also disabled

```kernel
Symbol: IP_NF_TARGET_ULOG [=n]
Prompt: ULOG target support (obsolete)
 -> Networking support (NET [=y])
 -> Networking options
 -> Network packet filtering framework (Netfilter) (NETFILTER [=y])
 -> IP: Netfilter Configuration
 -> IP tables support (required for filtering/masq/NAT) (IP_NF_IPTABLES [=y])
 < > ULOG target support (obsolete)
```

### ULOG Program

Don't forget that you need to install ULOG and configure it

```shell
emerge -v ulogd
```

Configuration file:

```config
[global]
logfile="/var/log/ulogd/ulogd.log"
loglevel=5
plugin="/usr/lib64/ulogd/ulogd_inppkt_NFLOG.so"
plugin="/usr/lib64/ulogd/ulogd_inpflow_NFCT.so"
plugin="/usr/lib64/ulogd/ulogd_filter_IFINDEX.so"
plugin="/usr/lib64/ulogd/ulogd_filter_IP2STR.so"
plugin="/usr/lib64/ulogd/ulogd_filter_IP2BIN.so"
plugin="/usr/lib64/ulogd/ulogd_filter_PRINTPKT.so"
plugin="/usr/lib64/ulogd/ulogd_filter_HWHDR.so"
plugin="/usr/lib64/ulogd/ulogd_filter_PRINTFLOW.so"
plugin="/usr/lib64/ulogd/ulogd_output_LOGEMU.so"
plugin="/usr/lib64/ulogd/ulogd_output_SYSLOG.so"
plugin="/usr/lib64/ulogd/ulogd_output_XML.so"
plugin="/usr/lib64/ulogd/ulogd_output_GPRINT.so"
plugin="/usr/lib64/ulogd/ulogd_raw2packet_BASE.so"
plugin="/usr/lib64/ulogd/ulogd_inpflow_NFACCT.so"
plugin="/usr/lib64/ulogd/ulogd_output_GRAPHITE.so"
stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU
stack=log2:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu2:LOGEMU
stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu3:LOGEMU
stack=log4:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu4:LOGEMU
:
[log1]
group=0
[log2]
group=1 # Group has to be different from the one use in log1
[log3]
group=2 # Group has to be different from the one use in log1/log2
numeric_label=1 # you can label the log info based on the packet verdict
[log4]
group=3 # Group has to be different from the one use in log1/log2
:
[emu1]
file="/var/log/ulogd/iptables_all.log"
sync=1
[emu2]
file="/var/log/ulogd/iptables_drop.log"
sync=1
[emu3]
file="/var/log/ulogd/iptables_dropblacklist.log"
sync=1
[emu4]
file="/var/log/ulogd/iptables_dnat.log"
```

<br/>

### Usage Example with IPTABLES

Section of a script where I add a rule to drop certain IPs from a supposed blacklist:

```shell
 :
 # Prefixes I specifically block
 export LOGDROPBLACKLIST="yes"
 export BLACKLIST="
 190.55.85.0/24 \
 190.55.95.0/24 \
 190.55.98.0/24 \
 95.211.100.0/24 \
 63.217.28.226 \
 194.179.126.151 \
 216.151.130.170 \
 62.109.4.89 \
 192.168.1.17 \
 "
:
# === Create the "BlackList" CHAIN to block certain IPs...
 iptables -N BlackList
:
# === Redirect packets with BlackList IPs to the CHAIN
 for blacklist in $BLACKLIST
 do
 iptables -A INPUT -s $blacklist -j BlackList
 iptables -A FORWARD -s $blacklist -j BlackList
 done
:
 # === LOG those packets
 if [ "${LOGBLACKLIST}" = "yes" ]; then
 iptables -A BlackList -j NFLOG --nflog-group 2 --nflog-prefix "BlackList -- DROP "
 fi

 # === Finally DROP the packets
 iptables -A BlackList -j DROP

 :
 =====
```

<br/>

### Show logging

Run the following command:

```shell
tail -f /var/log/ulog/iptables_drop.log
```
