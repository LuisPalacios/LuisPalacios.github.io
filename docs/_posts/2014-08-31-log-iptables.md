---
title: "IPtables con nflog"
date: "2014-08-31"
categories: seguridad
tags: linux vpn openvpn firewall túneles seguridad iptables
excerpt_separator: <!--more-->
---


![logo log](/assets/img/posts/imagenes_web111.jpg){: width="150px" style="float:left; padding-right:25px" } 

Cita Geek: "Registrar lo que pasa es de sabios...". En el pasado usaba `ULOG` para analizar qué paquetes eran descartados por `iptables`, pero como ha sido marcado como obsoleto he cambiado a `NFLOG`.

<br clear="left"/>
<!--more-->


#### Configuración del kernel

Configurar lo siguiente en el Kernel:

```config
- CONFIG_NETFILTER_NETLINK_LOG=y # Log packets via NFNETLINK interface
- CONFIG_NETFILTER_XT_TARGET_NFLOG=y # Enables NFLOG target (allows log through nfnetlink_log)
- CONFIG_NETFILTER_XT_TARGET_LOG=y # Enables LOG target (allows log through syslog) OLD METHOD
- CONFIG_IP_NF_TARGET_ULOG=n # "unset" OLD ULOG Target
```

#### CONFIG_NETFILTER_NETLINK_LOG

Activamos la opción de hacer Logging a través de NFNETLINK, es la opción nueva que permitirá trabajar con el target NFLOG

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

Target NFLOG, para que podamos usarlo con iptables.

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

Se trata del método antiguo usado para hacer logging al SYSLOG. Ya no lo necesito, así que lo he desactivado:

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

#### CONFIG_NETFILTER_XT_TARGET_LOG (OBSOLETO)

Este es el antiguo ULOG, que al quedar obsoleto también he desactivado

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

### Programa ULOG

No olvides que tienes que instalar ULOG y configurarlo

```console
emerge -v ulogd
```

Fichero de configuración:

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

### Ejemplo de uso con IPTABLES

Sección de un script donde añado una regla para hacer drop de ciertas IP's de una supuesta blacklist:

```console
 :
 # Prefijos que bloqueo de forma especifica
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
# === Creo el CHAIN "BlackList" para bloquear ciertas IP's...
 iptables -N BlackList
:
# === Redirigir al CHANIN paquetes con IP's del BlackList
 for blacklist in $BLACKLIST
 do
 iptables -A INPUT -s $blacklist -j BlackList
 iptables -A FORWARD -s $blacklist -j BlackList
 done
:
 # === Hacer LOGGING de dichos paquetes
 if [ "${LOGBLACKLIST}" = "yes" ]; then
 iptables -A BlackList -j NFLOG --nflog-group 2 --nflog-prefix "BlackList -- DROP "
 fi
 
 # === Finalmente hacer DROP de los paquetes
 iptables -A BlackList -j DROP
 
 :
 =====
```
 
<br/>
### Mostrar logging

Ejecutar el comando siguiente: 

```console
tail -f /var/log/ulog/iptables_drop.log
```
