---
title: "Firewall+Router en máquina virtual linux"
date: "2015-03-19"
categories: apuntes
tags: esxi firewall iptables linux movistar netfilter router virtualizacion
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/?p=3462)"
    caption="VM Linux en KVM, esta vez con iSCSI"
    width="600px"
    %}

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

{% include showImagen.html
    src="/assets/img/original/?p=266). En dicho apunte usé un Linux sobre Mac Mini, mientras que ahora el servidor lo virtualizo y el tráfico de las VLAN's llega sin etiquetar (vlan-id"
    caption="Movistar Fusión Fibra + TV + VoIP con router Linux"
    width="600px"
    %}

[/dropshadowbox]

{% include showImagen.html
    src="/assets/img/original/ESXi-Docker-Router-710x1024.png"
    caption="ESXi-Docker-Router"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/?p=1803) y crear una máquina virtual nueva. La voy a llamar "**Cortafuegix**", en alusión a la Aldea Gala de ASterix :-"
    caption="Gentoo VM"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/Cortafuegix.jpg"
    caption="Cortafuegix"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/?p=172"
    caption="Docker"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/Aplicacionix.jpg"
    caption="Aplicacionix"
    width="600px"
    %}

## La Red

Empiezo por el principio, la configuración de la red y vlan's.

En casos como este es muy importante tener claro cual es el diseño físico de la red, qué NIC's tenemos y qué NIC's virtuales van a presentarse (desde ESXi) a la VM. Voy a configurar las vNICs con nombres predecibles, con IPs estáticas (sin dhcp) y que no cambie nada al hacer reboot.

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**NOTA**: Mi plantilla usaba cliente DHCP así que lo paro y lo deshabilito: systemctl stop dhcpcd.service y systemctl disable dhcpcd.service.

[/dropshadowbox]   **Conexión física en ESXi**

Si empezamos por el diseño físico, es simple, mi Servidor casero, donde se ejecuta ESXi, tiene una única tarjeta de red, asi que conecto ese puerto al Switch externo por el cual entrega 4 x VLAN's: 2 (iptv), 3 (voip), 6 (internet), 100 (intranet).

{% include showImagen.html
    src="/assets/img/original/ESXiFisico-1024x851.png"
    caption="ESXiFisico"
    width="600px"
    %}

En el ESXi creo un único Virtual Switch con 4 x "Port Group's", uno por VLAN, que podré asociar a diferentes vNICs (virtual NIC's) en las máquinas virtuales. Veamos un ejemplo en la figura siguiente: Virtual Switch, los "Port Groups" y su asociación a las vNIC's de la máquina virtual "Cortafuegix"

{% include showImagen.html
    src="/assets/img/original/ESXiNet-1-1024x806.png"
    caption="ESXiNet-1"
    width="600px"
    %}

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

{% include showImagen.html
    src="/assets/img/original/1000 que tenga soporte de VLAN’s (802.1q) y Multicast (IGMP Snooping"
    caption="Movistar Fusión Fibra + TV + VoIP con router Linux"
    width="600px"
    %}

[/dropshadowbox]   **Conexiones ethernet en la VM**

En esta configuración he decidido que sea el ESXi el que trate el VLAN-ID, de modo que el tráfico llegará "limpio" a las ma´quinas virtuales (sin vlanid). En la configuración de la VM "cortafuegix" creo varias tarjetas de red, todas con el driver E1000 y las asocio a los port groups. Veamos cómo recibimos dichas vNICs en la VM, cómo se ven en linux y si hace falta hacer algo más...

{% include showImagen.html
    src="/assets/img/original/"
    caption="upstream"
    width="600px"
    %}

Conseguirlo es muy fácil, lo primero es que asignes direcciones MAC estáticas a cada una de las tarjetas, desde vSphere Client, en la configuración de la máquina virtual.

{% include showImagen.html
    src="/assets/img/original/FixMac.png"
    caption="FixMac"
    width="600px"
    %}

A continuación creas un fichero con reglas para que **udev** cambie el nombre de las tarjetas usando dichas direcciones Mac y rearrancas la VM.

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**Truco**: Ya que pones las MAC's, aprovecha y que te digan algo, en mi caso he elegido que los dos últimos bytes coincidan con el número de la VLAN.

[/dropshadowbox]

# South CASA vlan100
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:50:56:aa:01:00", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="vlan100"

# North INTERNET vlan6
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:50:56:aa:00:06", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="vlan6"

# North INTERNET vlan2
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:50:56:aa:00:02", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="vlan2"

# North INTERNET vlan3
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:50:56:aa:00:03", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="vlan3"

Tras el próximo arranque podemos observar cómo han cambiado los nombres de las interfaces.

{% include showImagen.html
    src="/assets/img/original/GentooVM-Rules-1.png"
    caption="GentooVM-Rules-1"
    width="600px"
    %}

  [dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

{% include showImagen.html
    src="/assets/img/original/?p=266"
    caption="Movistar Fusión Fibra + TV + VoIP con router Linux"
    width="600px"
    %}

[/dropshadowbox]   **systemd-networkd**

{% include showImagen.html
    src="/assets/img/original/systemd-networkd"
    caption="systemd-networkd"
    width="600px"
    %}

#
# Interfaz para IPTV (IP Estática asignada a tu contrato)
#
[Match]
Name=vlan2

[Network]
Address=10.214.XX.YY/9

#
# Interfaz para VoIP (recibirá su IP por DHCP usando "dhclient"
#
[Match]
Name=vlan3

#
# Interfaz para DATOS Internet (recibirá su IP por PPPoE)
#
[Match]
Name=vlan6

#
# Interfaz para la Intranet (IP estática)
#
[Match]
Name=vlan100

[Network]
Address=192.168.1.1/24

Notarás que no he especificado ningún gateway por defecto, ni tampoco el DNS server. Lo he hecho a proposito, el router por defecto se establecerá al activar PPPoE y la información del DNS Server la pondré de manera estática en el /etc/resolv.conf.

Puedes ejecutar systemctl start systemd-networkd y ver el estado de las interfaces con el comando networkctl. Dejo a continuación algunos comandos de referencia, aunque te recomiendo que esperes a leer todo el apunte porque he creado múltiples ficheros de apoyo para configurar "systemd" y el arranque de los servicios:

- Arrancar durante el boot: systemctl enable systemd-networkd
- Arrancar manualmente: systemctl start systemd-networkd
- Re-arrancar (si cambias algo): systemctl restart systemd-networkd
- Verificar: networkctl

  **PPP**

{% include showImagen.html
    src="/assets/img/original/2015-03-19-config-3.18.7-Gentoo_VM_ESXi.txt)"
    caption="plantilla](https://www.luispa.com/?p=1803) ya está preparada ([.config"
    width="600px"
    %}

Preparo parámetros USE e instaloo net-dialup/ppp:

net-dialup/ppp -ipv6

# emerge -v net-dialup/ppp

Creo el fichero /etc/systemd/system/ppp_wait@.service

#
# Unit para gestión de PPP
#
[Unit]
Description=PPP link to %I wait
After=network-online.target
Wants=network-online.target
After=sys-subsystem-net-devices-vlan6.device

[Service]
Type=forking
PIDFile=/run/ppp-%i.pid
ExecStart=/usr/sbin/pppd call %I linkname %i updetach
Restart=on-abort

[Install]
WantedBy=multi-user.target

Configuramos el fichero /etc/ppp/pap-secrets

# Secrets for authentication using PAP
# client                  server    secret         IP addresses
adslppp@telefonicanetpa   pppd      adslppp        *

Creo un "peer" llamado movistar:

# Plugins
plugin rp-pppoe.so
plugin passwordfd.so

# Usuario
name "adslppp@telefonicanetpa"

# Opciones
updetach
noauth
defaultroute
ipcp-accept-remote
ipcp-accept-local
lcp-echo-interval 15
lcp-echo-failure 3
persist
holdoff 3
mru 1492
mtu 1492
lock
noaccomp noccp nobsdcomp nodeflate nopcomp novj novjccomp

# network interface
vlan6

Programo que el servicio arranqeu durante el boot (usar \@movistar en el nombre del servicio):

# systemctl enable ppp_wait\@movistar.service

  **DHCLIENT**

Necesito activar un cliente DHCP para recibir la IP de VoIP en el interfaz VLAN3. En vez de usar el cliente embebido de systemd-networkd voy a usar el programa "dhclient". El cliente embebido en systemd-networkd es muy intrusivo, manipula la tabla de routing e impide que RIPD (más adelante) instale sus rutas.

La instalación y configuración de DHCLIENT la dejo para más adelante, viene incluido con el DHCP Server.

 

## El Firewall

El "**cortafuegos**" lo haré con el framework **netfilter** del kernel y un montón de comandos **iptables**, el logging será con **ulogd**, un daemon que se ejecuta en el "userspace" especialmente diseñado para netfilter/iptables.

Preparo las variables USE y ejecuto la instalación de ulogd.

app-admin/ulogd                         mysql nfct nflog dbi nfacct pcap sqlite

# emerge -v ulogd

{% include showImagen.html
    src="/assets/img/original/"
    caption="documentación oficial"
    width="600px"
    %}

# Example configuration for ulogd
# Adapted to Debian by Achilleas Kotsis [global]
######################################################################
# GLOBAL OPTIONS
######################################################################

# logfile for status messages
logfile="/var/log/ulogd/ulogd.log"

# loglevel: debug(1), info(3), notice(5), error(7) or fatal(8) (default 5)
loglevel=5

######################################################################
# PLUGIN OPTIONS
######################################################################

# We have to configure and load all the plugins we want to use

# general rules:
# 1. load the plugins _first_ from the global section
# 2. options for each plugin in seperate section below

plugin="/usr/lib64/ulogd/ulogd_inppkt_NFLOG.so"
#plugin="/usr/lib64/ulogd/ulogd_inppkt_ULOG.so"
#plugin="/usr/lib64/ulogd/ulogd_inppkt_UNIXSOCK.so"
plugin="/usr/lib64/ulogd/ulogd_inpflow_NFCT.so"
plugin="/usr/lib64/ulogd/ulogd_filter_IFINDEX.so"
plugin="/usr/lib64/ulogd/ulogd_filter_IP2STR.so"
plugin="/usr/lib64/ulogd/ulogd_filter_IP2BIN.so"
#plugin="/usr/lib64/ulogd/ulogd_filter_IP2HBIN.so"
plugin="/usr/lib64/ulogd/ulogd_filter_PRINTPKT.so"
plugin="/usr/lib64/ulogd/ulogd_filter_HWHDR.so"
plugin="/usr/lib64/ulogd/ulogd_filter_PRINTFLOW.so"
#plugin="/usr/lib64/ulogd/ulogd_filter_MARK.so"
plugin="/usr/lib64/ulogd/ulogd_output_LOGEMU.so"
plugin="/usr/lib64/ulogd/ulogd_output_SYSLOG.so"
plugin="/usr/lib64/ulogd/ulogd_output_XML.so"
#plugin="/usr/lib64/ulogd/ulogd_output_SQLITE3.so"
plugin="/usr/lib64/ulogd/ulogd_output_GPRINT.so"
#plugin="/usr/lib64/ulogd/ulogd_output_NACCT.so"
#plugin="/usr/lib64/ulogd/ulogd_output_PCAP.so"
#plugin="/usr/lib64/ulogd/ulogd_output_PGSQL.so"
#plugin="/usr/lib64/ulogd/ulogd_output_MYSQL.so"
#plugin="/usr/lib64/ulogd/ulogd_output_DBI.so"
plugin="/usr/lib64/ulogd/ulogd_raw2packet_BASE.so"
plugin="/usr/lib64/ulogd/ulogd_inpflow_NFACCT.so"
plugin="/usr/lib64/ulogd/ulogd_output_GRAPHITE.so"
#plugin="/usr/lib64/ulogd/ulogd_output_JSON.so"

# this is a stack for logging packet send by system via LOGEMU
stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU

# this is a stack for packet-based logging via LOGEMU
stack=log2:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu2:LOGEMU

# this is a stack for packet-based logging via LOGEMU
stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu3:LOGEMU

# this is a stack for packet-based logging via LOGEMU
stack=log4:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu4:LOGEMU

# this is a stack for packet-based logging via LOGEMU
stack=log5:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu5:LOGEMU

# this is a stack for packet-based logging via LOGEMU
stack=log6:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu6:LOGEMU

# this is a stack for packet-based logging via LOGEMU
stack=log7:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu7:LOGEMU

# this is a stack for packet-based logging via LOGEMU
stack=log8:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu8:LOGEMU

# this is a stack for ULOG packet-based logging via LOGEMU
#stack=ulog1:ULOG,base1:BASE,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU

# this is a stack for packet-based logging via LOGEMU with filtering on MARK
#stack=log2:NFLOG,mark1:MARK,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU

# this is a stack for packet-based logging via GPRINT
#stack=log1:NFLOG,gp1:GPRINT

# this is a stack for flow-based logging via LOGEMU
#stack=ct1:NFCT,ip2str1:IP2STR,print1:PRINTFLOW,emu1:LOGEMU

# this is a stack for flow-based logging via GPRINT
#stack=ct1:NFCT,gp1:GPRINT

# this is a stack for flow-based logging via XML
#stack=ct1:NFCT,xml1:XML

# this is a stack for logging in XML
#stack=log1:NFLOG,xml1:XML

# this is a stack for accounting-based logging via XML
#stack=acct1:NFACCT,xml1:XML

# this is a stack for accounting-based logging to a Graphite server
#stack=acct1:NFACCT,graphite1:GRAPHITE

# this is a stack for NFLOG packet-based logging to PCAP
#stack=log2:NFLOG,base1:BASE,pcap1:PCAP

# this is a stack for logging packet to MySQL
#stack=log2:NFLOG,base1:BASE,ifi1:IFINDEX,ip2bin1:IP2BIN,mac2str1:HWHDR,mysql1:MYSQL

# this is a stack for logging packet to PGsql after a collect via NFLOG
#stack=log2:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,mac2str1:HWHDR,pgsql1:PGSQL

# this is a stack for logging packet to JSON formatted file after a collect via NFLOG
#stack=log2:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,mac2str1:HWHDR,json1:JSON

# this is a stack for logging packets to syslog after a collect via NFLOG
#stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG

# this is a stack for logging packets to syslog after a collect via NuFW
#stack=nuauth1:UNIXSOCK,base1:BASE,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG

# this is a stack for flow-based logging to MySQL
#stack=ct1:NFCT,ip2bin1:IP2BIN,mysql2:MYSQL

# this is a stack for flow-based logging to PGSQL
#stack=ct1:NFCT,ip2str1:IP2STR,pgsql2:PGSQL

# this is a stack for flow-based logging to PGSQL without local hash
#stack=ct1:NFCT,ip2str1:IP2STR,pgsql3:PGSQL

# this is a stack for flow-based logging to SQLITE3
#stack=ct1:NFCT,sqlite3_ct:SQLITE3

# this is a stack for logging packet to SQLITE3
#stack=log1:NFLOG,sqlite3_pkt:SQLITE3

# this is a stack for flow-based logging in NACCT compatible format
#stack=ct1:NFCT,ip2str1:IP2STR,nacct1:NACCT

# this is a stack for accounting-based logging via GPRINT
#stack=acct1:NFACCT,gp1:GPRINT

[ct1]
#netlink_socket_buffer_size=217088
#netlink_socket_buffer_maxsize=1085440
#netlink_resync_timeout=60 # seconds to wait to perform resynchronization
#pollinterval=10 # use poll-based logging instead of event-driven
# If pollinterval is not set, NFCT plugin will work in event mode
# In this case, you can use the following filters on events:
#accept_src_filter=192.168.1.0/24,1:2::/64 # source ip of connection must belong to these networks
#accept_dst_filter=192.168.1.0/24 # destination ip of connection must belong to these networks
#accept_proto_filter=tcp,sctp # layer 4 proto of connections

[ct2]
#netlink_socket_buffer_size=217088
#netlink_socket_buffer_maxsize=1085440
#reliable=1 # enable reliable flow-based logging (may drop packets)
hash_enable=0

# Logging of system packet through NFLOG
[log1]
# netlink multicast group (the same as the iptables --nflog-group param)
# Group O is used by the kernel to log connection tracking invalid message
group=0
#netlink_socket_buffer_size=217088
#netlink_socket_buffer_maxsize=1085440
# set number of packet to queue inside kernel
#netlink_qthreshold=1
# set the delay before flushing packet in the queue inside kernel (in 10ms)
#netlink_qtimeout=100

# packet logging through NFLOG for group 1
[log2]
# netlink multicast group (the same as the iptables --nflog-group param)
group=1 # Group has to be different from the one use in log1
#netlink_socket_buffer_size=217088
#netlink_socket_buffer_maxsize=1085440
# If your kernel is older than 2.6.29 and if a NFLOG input plugin with
# group 0 is not used by any stack, you need to have at least one NFLOG
# input plugin with bind set to 1. If you don't do that you may not
# receive any message from the kernel.
#bind=1

# packet logging through NFLOG for group 2, numeric_label is
# set to 1
[log3]
# netlink multicast group (the same as the iptables --nflog-group param)
group=2 # Group has to be different from the one use in log1/log2
numeric_label=1 # you can label the log info based on the packet verdict
#netlink_socket_buffer_size=217088
#netlink_socket_buffer_maxsize=1085440
#bind=1

# packet logging through NFLOG for group 3, numeric_label is
# set to 1
[log4]
# netlink multicast group (the same as the iptables --nflog-group param)
group=3 # Group has to be different from the one use in log1/log2
#numeric_label=1 # you can label the log info based on the packet verdict
#netlink_socket_buffer_size=217088
#netlink_socket_buffer_maxsize=1085440
#bind=1

# packet logging through NFLOG for group 4
[log5]
# netlink multicast group (the same as the iptables --nflog-group param)
group=4 # Group has to be different from the one use in log1/log2
#numeric_label=1 # you can label the log info based on the packet verdict
#netlink_socket_buffer_size=217088
#netlink_socket_buffer_maxsize=1085440
#bind=1

# packet logging through NFLOG for group 5
[log6]
# netlink multicast group (the same as the iptables --nflog-group param)
group=5 # Group has to be different from the one use in log1/log2
#numeric_label=1 # you can label the log info based on the packet verdict
#netlink_socket_buffer_size=217088
#netlink_socket_buffer_maxsize=1085440
#bind=1

# packet logging through NFLOG for group 6
[log7]
# netlink multicast group (the same as the iptables --nflog-group param)
group=6 # Group has to be different from the one use in log1/log2
#numeric_label=1 # you can label the log info based on the packet verdict
#netlink_socket_buffer_size=217088
#netlink_socket_buffer_maxsize=1085440
#bind=1

# packet logging through NFLOG for group 6
[log8]
# netlink multicast group (the same as the iptables --nflog-group param)
group=7 # Group has to be different from the one use in log1/log2
#numeric_label=1 # you can label the log info based on the packet verdict
#netlink_socket_buffer_size=217088
#netlink_socket_buffer_maxsize=1085440
#bind=1

[ulog1]
# netlink multicast group (the same as the iptables --ulog-nlgroup param)
nlgroup=1
#numeric_label=0 # optional argument

[nuauth1]
socket_path="/run/nuauth_ulogd2.sock"

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
sync=1

[emu5]
file="/var/log/ulogd/iptables_servicios.log"
sync=1

[emu6]
file="/var/log/ulogd/iptables_chrome.log"
sync=1

[emu7]
file="/var/log/ulogd/iptables_mcast.log"
sync=1

[emu8]
file="/var/log/ulogd/iptables_docker.log"
sync=1

[op1]
file="/var/log/ulogd/ulogd_oprint.log"
sync=1

[gp1]
file="/var/log/ulogd/ulogd_gprint.log"
sync=1
timestamp=1

[xml1]
directory="/var/log/ulogd/"
sync=1

[json1]
sync=1
#file="/var/log/ulogd/ulogd.json"
#timestamp=0
# device name to be used in JSON message
#device="My awesome Netfilter firewall"
# If boolean_label is set to 1 then the numeric_label put on packet
# by the input plugin is coding the action on packet: if 0, then
# packet has been blocked and if non null it has been accepted.
#boolean_label=1

[pcap1]
#default file is /var/log/ulogd/ulogd.pcap
#file="/var/log/ulogd/ulogd.pcap"
sync=1

[mysql1]
db="nulog"
host="localhost"
user="nupik"
table="ulog"
pass="changeme"
procedure="INSERT_PACKET_FULL"
# backlog configuration:
# set backlog_memcap to the size of memory that will be
# allocated to store events in memory if data is temporary down
# and insert them when the database came back.
#backlog_memcap=1000000
# number of events to insert at once when backlog is not empty
#backlog_oneshot_requests=10

[mysql2]
db="nulog"
host="localhost"
user="nupik"
table="conntrack"
pass="changeme"
procedure="INSERT_CT"

[pgsql1]
db="nulog"
host="localhost"
user="nupik"
table="ulog"
#schema="public"
pass="changeme"
procedure="INSERT_PACKET_FULL"
# connstring can be used to define PostgreSQL connection string which
# contains all parameters of the connection. If set, this value has
# precedence on other variables used to build the connection string.
# See http://www.postgresql.org/docs/9.2/static/libpq-connect.html#LIBPQ-CONNSTRING
# for a complete description of options.
#connstring="host=localhost port=4321 dbname=nulog user=nupik password=changeme"
#backlog_memcap=1000000
#backlog_oneshot_requests=10
# If superior to 1 a thread dedicated to SQL request execution
# is created. The value stores the number of SQL request to keep
# in the ring buffer
#ring_buffer_size=1000

[pgsql2]
db="nulog"
host="localhost"
user="nupik"
table="ulog2_ct"
#schema="public"
pass="changeme"
procedure="INSERT_CT"

[pgsql3]
db="nulog"
host="localhost"
user="nupik"
table="ulog2_ct"
#schema="public"
pass="changeme"
procedure="INSERT_OR_REPLACE_CT"

[pgsql4]
db="nulog"
host="localhost"
user="nupik"
table="nfacct"
#schema="public"
pass="changeme"
procedure="INSERT_NFACCT"

[dbi1]
db="ulog2"
dbtype="pgsql"
host="localhost"
user="ulog2"
table="ulog"
pass="ulog2"
procedure="INSERT_PACKET_FULL"

[sqlite3_ct]
table="ulog_ct"
db="/var/log/ulogd/ulogd.sqlite3db"
buffer=200

[sqlite3_pkt]
table="ulog_pkt"
db="/var/log/ulogd/ulogd.sqlite3db"
buffer=200

[sys2]
facility=LOG_LOCAL2

[nacct1]
sync = 1
#file = /var/log/ulogd/ulogd_nacct.log

[mark1]
mark = 1

[acct1]
pollinterval = 2
# If set to 0, we don't reset the counters for each polling (default is 1).
#zerocounter = 0
# Set timestamp (default is 0, which means not set). This timestamp can be
# interpreted by the output plugin.
#timestamp = 1

[graphite1]
host="127.0.0.1"
port="2003"
# Prefix of data name sent to graphite server
prefix="netfilter.nfacct" 

{% include showImagen.html
    src="/assets/img/original/2015-03-19-config-3.18.7-Gentoo_VM_ESXi.txt)"
    caption="plantilla](https://www.luispa.com/?p=1803) ya está preparada ([.config"
    width="600px"
    %}

No voy a explicar iptables por completo pero dejo aquí un vistazo sobre cómo he hecho para cargar las reglas durante el boot. El comando "iptables" no es un daemon en sí, se trata de un programa que permite instalar Rules (reglas) en el Kernel. El truco consiste en ejecutar muchas veces iptables introduciendo una a una las reglas y cuando todo funciona salvas dichas "reglas o estado" en una fichero externo (con el comando iptables-save) y en el siguiente boot las recuperas desde dicho fichero (con iptables-restore).

Eso sería lo normal, pero en mi caso prefiero ejecutar dos scripts que tienen todos esos comandos "iptables" durante el boot del equipo, uno antes de que se active la red y otro "después" de que se activa la red.

Creo el directorio donde dejaré los script mkdir /root/firewall y los ficheros de servicios systemd

[Unit]
Description=Activar reglas iptables antes que la red
Wants=network-pre.target
Before=network-pre.target

[Service]
Type=oneshot
ExecStart=/bin/bash /root/firewall/router.ipv4.iptables_pre_network.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

[Unit]
Description=Activar reglas iptables despues de la red
Wants=network-online.target dhcpd.service
After=network-online.target dhcpd.service

[Service]
Type=oneshot
ExecStart=/bin/bash /root/firewall/router.ipv4.iptables_post_network.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

Este es el primer script. Como decía se ejecutará antes de que haya red e interfaces disponibles, pero no pasa nada, se instalarán las reglas correctamente. El objetivo es que haya reglas activa según se "enciende" el networking :-).

#!/bin/bash
#
# Script que "instala" RULES para iptables antes de que se active la red
#

echo "============================================================================="
echo "IPTABLES PRE network"
echo "$0"
echo "============================================================================="

# =====================================================================================
#                                  INTERFACE NAMES
#
export vlan100="vlan100"
export vlan2="vlan2"
export vlan3="vlan3"
export vlan6="vlan6"

# =====================================================================================
#                                     VARIABLES
#
# LOG
export LOGALL="no"
export LOGDROP="yes"
export LOGSERVICIOS="yes"
export LOGMCAST="no"

# Diferentes sistemas de LOGGING. Ahora uso ULOG (con NFLOG)
# SYSLOG: "LOG --log-level info --log-prefix"
# ULOG:   "ULOG --ulog-prefix"
# NFLOG:  "NFLOG --nflog-group --nflog-prefix"
export LOG_ALL="NFLOG --nflog-group 0 --nflog-prefix"
export LOG_DROP="NFLOG --nflog-group 1 --nflog-prefix"
export LOG_SERVICIOS="NFLOG --nflog-group 4 --nflog-prefix"
export LOG_MCAST="NFLOG --nflog-group 6 --nflog-prefix"

# Variables para identificar direcciones IPs y rangos de forma más sencilla
#
#
export YO_IPV4_PUBLIC="80.28.PPP.PPP"
export YO_IPV4_VLAN_100="192.168.1.1"
export YO_IPV4_VLAN_002="10.214.XX.YY"

echo "ACTIVANDO IPTABLES"
echo "============================================================================="
echo "IP Pública : ${YO_IPV4_PUBLIC}"
echo "   VLAN100 : ${YO_IPV4_VLAN_100}"
echo "     VLAN2 : ${YO_IPV4_VLAN_002}"
echo "============================================================================="

export YO_IPV4="${YO_IPV4_PUBLIC}   \
                ${YO_IPV4_VLAN_100} \
                ${YO_IPV4_VLAN_002}"
export ANTISPOOF_IP="${YO_IPV4_VLAN_100} \
                     ${YO_IPV4_VLAN_002}"
export ANTISPOOF_NET="192.168.1.0/24 192.168.0.0/24 10.128.0.0/9"

echo "       YO_IPV4: \`echo ${YO_IPV4}|sed 's/  */ /g'\`"
echo "  ANTISPOOF_IP: \`echo ${ANTISPOOF_IP}|sed 's/  */ /g'\`"
echo " ANTISPOOF_NET: \`echo ${ANTISPOOF_NET}|sed 's/  */ /g'\`"
echo "============================================================================="

# Redes de INTRANET a las que permito salir hacia cualquier sitio
#
export INTRANET="${ANTISPOOF_NET}"

echo "    INTRANET: \`echo ${INTRANET}|sed 's/  */ /g'\`"
echo "============================================================================="

# Destination NAT
#
export DO_DNAT="yes"
export LOGDNAT="no"
export LOG_DNAT="NFLOG --nflog-group 3 --nflog-prefix"
export DNAT_WEB_PORTS="80"
export DNAT_WEB_IP="192.168.1.ZZZ"  # IP del equipo donde está el Web Server interno

# =====================================================================================
#                                  CLEAN IPTABLES
#
set_table_policy() {
    local chains table=$1 policy=$2
    case ${table} in
        nat)    chains="PREROUTING POSTROUTING OUTPUT";;
        mangle) chains="PREROUTING INPUT FORWARD OUTPUT POSTROUTING";;
        filter) chains="INPUT FORWARD OUTPUT";;
        *)      chains="";;
    esac
    local chain
    for chain in ${chains} ; do
        iptables -t ${table} -P ${chain} ${policy}
    done
}

export iptables_proc="/proc/net/ip_tables_names"
for a in $(cat ${iptables_proc}) ; do
    set_table_policy $a ACCEPT
    iptables -F -t $a
    iptables -X -t $a
done

# =====================================================================================
#                                     GENERAL
#

# ========== Definir parametros TCP generales
#
echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout
echo 1800 > /proc/sys/net/ipv4/tcp_keepalive_intvl

# =====================================================================================
#                                 PREPARAR LO MINIMO

# ========== Definir el default policy, por defecto se tira todo el tráfico
#
iptables -P OUTPUT  DROP
iptables -P INPUT   DROP
iptables -P FORWARD DROP

# ========== Flush de los chains existentes, vacio lo que haya activo ahora mismo.
#
cat /proc/net/ip_tables_names | while read table; do
                                    iptables -t $table -L -n | while read c chain rest; do
                                                                   if test "X$c" = "XChain" ; then
                                                                       iptables -t $table -F $chain
                                                                   fi
                                                               done
                                    iptables -t $table -X
                                done

# ========== TCP MSS
# Una de las desventajsa de PPPoE es que reduce la MTU a 1492 y el MSS (Maximum Segment Size)
# negociado de TCP a 1452, así que tenemos que hacer lo mismo en nuestro Linux
#
iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# ========== Aceptar las sesiones actuales que ya estaban establecidas
#
# Creo un CHAIN nuevo llamado established y lo uso en Input, Output y Forward
iptables -N established
iptables -A INPUT   -m conntrack --ctstate ESTABLISHED,RELATED -j established
iptables -A OUTPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j established
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j established
#
# ...aceptar todo lo ESTABLISHED,RELATED
if [ "${LOGALL}" = "yes" ]; then
    iptables -A established -j $LOG_ALL "established -- OK "
fi
iptables -A established -j ACCEPT

# =====================================================================================
#                                   MULTICAST

# Permito el trafico multicast, necesario para Movistar TV
#
iptables -N MCAST_Traffic
iptables -I INPUT -d 224.0.0.0/4 -j MCAST_Traffic
iptables -I OUTPUT -d 224.0.0.0/4 -j MCAST_Traffic
iptables -I FORWARD -d 224.0.0.0/4 -j MCAST_Traffic
if [ "${LOGMCAST}" = "yes" ]; then
    iptables -A MCAST_Traffic -j $LOG_MCAST "MCAST_Traffic -- OK "
fi
iptables -A MCAST_Traffic -j ACCEPT

# =====================================================================================
#                                    SNAT

# === Todo el trafico hacia Movistar IPTV sale con mi IP fija entregada por Movistar
iptables -t nat -A POSTROUTING -o ${vlan2} -s 192.168.1.0/24 -j SNAT --to-source 10.214.XX.YY

# === Todo el trafico hacia VoIP sale con mi IP fija entregada por Movistar via DHCP
# Notar que esta orden la ejecuto en el "post", para intentar averiguar la IP dinámica

# === Todo el trafico DATOS INTERNET sale con mi ip fija publica
iptables -t nat -A POSTROUTING -o ppp0  -s 192.168.1.0/24 -j SNAT --to-source 80.28.AA.BB

# =====================================================================================
#                                ANTISPOOF

# ========== Evito el anti-spoofing en la interfaz publica
#
iptables -N In_AntiSpoof
for antispoof_ip in $ANTISPOOF_IP
do
    iptables -A INPUT    -i ppp0  -s $antispoof_ip  -m conntrack --ctstate NEW  -j In_AntiSpoof
    iptables -A FORWARD  -i ppp0  -s $antispoof_ip  -m conntrack --ctstate NEW  -j In_AntiSpoof
done
for antispoof_net in $ANTISPOOF_NET
do
    iptables -A INPUT    -i ppp0  -s $antispoof_net  -m conntrack --ctstate NEW  -j In_AntiSpoof
    iptables -A FORWARD  -i ppp0  -s $antispoof_net  -m conntrack --ctstate NEW  -j In_AntiSpoof
done

# Chain In_AntiSpoof
if [ "${LOGDROP}" = "yes" ] || [ "${LOGALL}" = "yes" ]; then
    iptables -A In_AntiSpoof  -j $LOG_DROP "In_AntiSpoof -- DROP "
fi
iptables -A In_AntiSpoof  -j DROP

# =====================================================================================
#                                     LOOPBACK

# Permitir todo "mi" trafico originado o recibido en la loopback
#
# === Creo un CHAIN nuevo llamado lo-in y lo instalo en INPUT
iptables -N lo-in
iptables -A INPUT    -i lo -m conntrack --ctstate NEW  -j lo-in

# Chain "lo-in", aceptar todo lo recibido en la loopback
if [ "${LOGALL}" = "yes" ]; then
    iptables -A lo-in    -j $LOG_ALL "lo-in -- OK "
fi
iptables -A lo-in    -j ACCEPT

# === Creo un CHAIN nuevo llamado lo-in y lo instalo en INPUT
iptables -N lo-out
iptables -A OUTPUT   -o lo -m conntrack --ctstate NEW  -j lo-out

# Chain "lo-out", aceptar todo lo enviado desde la loopback
if [ "${LOGALL}" = "yes" ]; then
    iptables -A lo-out    -j $LOG_ALL "lo-out -- OK "
fi
iptables -A lo-out    -j ACCEPT

# =====================================================================================
#                                     SALIDA desde mi mismo

# ========== Permito que yo pueda salir hacia cualquier sitio
# === Nuevo CHAIN
iptables -N YoOk
for yo_ipv4 in $YO_IPV4
do
    iptables -A INPUT    -s $yo_ipv4 -m conntrack --ctstate NEW  -j YoOk
done
iptables -A OUTPUT -m conntrack --ctstate NEW  -j YoOk

# Chain YoOK
if [ "${LOGALL}" = "yes" ]; then
    iptables -A YoOk  -j $LOG_ALL "YoOk -- OK "
fi
iptables -A YoOk -j ACCEPT

# =====================================================================================
#                  ACCESO EXTERNO a mis Servicios en HOST interno DNATed
#
# === Activo el DNAT y permito la conmutación de los paquetes DNATed (a los que se les ha cambiado la ip destino)
if [ "${DO_DNAT}" = "yes" ]; then

    # ABRO DNAT_Servicios
    iptables -N DNAT_Servicios

    # DNAT WEB (80)
    for dnatport in ${DNAT_WEB_PORTS}
    do
        # primero cambio la ip destino
        iptables -t nat -A PREROUTING -i ppp0 -p tcp --dport $dnatport -d ${YO_IPV4_PUBLIC} -j DNAT --to-destination ${DNAT_WEB_IP}
        # despues acepto este tipo de paquetes
        iptables -A FORWARD -i ppp0 -p tcp --dport $dnatport -d ${DNAT_WEB_IP} -j DNAT_Servicios
    done

    # CIERRO DNAT_Servicios
    # Si se requiere logging, pues toma logging...
    if [ "${LOGDNAT}" = "yes" ]; then
        iptables -A DNAT_Servicios -j $LOG_DNAT "DNAT_Servicios -- OK "
    fi
    iptables -A DNAT_Servicios -j ACCEPT
fi

# =====================================================================================
#                              ACCESO EXTERNO a mis Servicios

# ========== Permito acceso a ciertos puertos desde Internet
# === OUTPUT
iptables -N Out_Servicios1
iptables -A OUTPUT -p tcp -m tcp  -m multiport  --dports 80 -m conntrack --ctstate NEW  -j Out_Servicios1

# Chain Out_Servicios 1 - aceptar solo si la IP destino es una de las mias
iptables -N Out_Servicios
for yo_ipv4 in $YO_IPV4
do
    iptables -A Out_Servicios1 -d $yo_ipv4 -j Out_Servicios
done

# Chain Out_Serviciso, aceptar directamente y registrar en el LOG
if [ "${LOGSERVICIOS}" = "yes" ] || [ "${LOGALL}" = "yes" ]; then
   iptables -A Out_Servicios  -j $LOG_SERVICIOS "Out_Servicios -- OK "
fi
iptables -A Out_Servicios -j ACCEPT

# INPUT
iptables -N In_Servicios
iptables -A INPUT -p tcp -m tcp  -m multiport  --dports 80 -m conntrack --ctstate NEW  -j In_Servicios

# Chain Out_Servicios, aceptar directamente y registrar en el LOG
if [ "${LOGSERVICIOS}" = "yes" ] || [ "${LOGALL}" = "yes" ]; then
   iptables -A In_Servicios  -j $LOG_SERVICIOS "In_Servicios -- OK "
fi
iptables -A In_Servicios -j ACCEPT

# =====================================================================================
#                             PERMITIR CUALQUIER TRAFICO INTRANET

# === Nuevo CHAIN
iptables -N Intranet
for intranet in $INTRANET
do
    iptables -A INPUT -s $intranet -m conntrack --ctstate NEW -j Intranet
    iptables -A OUTPUT -s $intranet -m conntrack --ctstate NEW -j Intranet
    iptables -A FORWARD -s $intranet -m conntrack --ctstate NEW -j Intranet
done

# Chain Intranet
if [ "${LOGALL}" = "yes" ]; then
    iptables -A Intranet -j $LOG_ALL "Intranet -- OK "
fi
iptables -A Intranet -j ACCEPT

# Permito bootp,s en la vlan100
iptables -A INPUT -i ${vlan100} -p udp -m udp -m multiport --dports 68,67 -j ACCEPT
iptables -A FORWARD -o ${vlan100} -p udp -m udp -m multiport --dports 68,67 -j ACCEPT

# =====================================================================================
#                           DENEGAR TRÁFICO EN ESTADOS INVÁLIDOS
#
# ========== Cargarse cualquier paquete que no este en ningun estado valido

# === Creo un CHAIN nuevo llamado "invalid" y lo uso en Input, Output, Forward
iptables -N invalid
iptables -A INPUT   -m conntrack --ctstate INVALID -j invalid
iptables -A OUTPUT  -m conntrack --ctstate INVALID -j invalid
iptables -A FORWARD -m conntrack --ctstate INVALID -j invalid

# Chain "invalid", tirar todo lo que sea INVALID
if [ "${LOGDROP}" = "yes" ] || [ "${LOGALL}" = "yes" ]; then
    iptables -A invalid -j $LOG_DROP "invalid -- DROP "
fi
iptables -A invalid -j DROP

# =====================================================================================
#                                   DESCARTAR EL RESTO

# ========== LOG del resto de paquetes antes de descartarlos

# === Creo un CHAIN nuevo llamado log y lo instalo en Input, Forward y Output
iptables -N log
iptables -A INPUT    -j log
iptables -A FORWARD  -j log
iptables -A OUTPUT   -j log

# Todos los paquetes se registran en "log"
if [ "${LOGDROP}" = "yes" ] || [ "${LOGALL}" = "yes" ]; then
    iptables -A log      -j $LOG_DROP "Resto -- DROP "
fi
iptables -A log      -j DROP 

El segundo script es el siguiente, se ejecutará tras tener toda la red y sus interfaces activas.

#!/bin/bash
#
# Script que "instala" RULES para iptables despues de tener ya la red activa
#

echo "============================================================================="
echo "IPTABLES POST network"
echo "$0"
echo "============================================================================="

# =====================================================================================
#                                  INTERFACE NAMES
#
export vlan100="vlan100"
export vlan2="vlan2"
export vlan3="vlan3"
export vlan6="vlan6"

# =====================================================================================
#                                   SNAT VLAN3
#
# Source NAT del trafico hacia VoIP para que salga con mi IP fija entregada por
# movistar via DHCP en la vlan3. Si todavía no tengo la dirección IP entonces hago
# lo mismo pero usando MASQUERADE (el efecto es el mismo pero en teoría es un poco
# más rápido usar SNAT)
#
export YO_IPV4_VLAN_003=\`ip addr show dev vlan3 | grep inet | awk '{print $2}' | sed 's;\/.*;;'\`
echo "============================================================================="
echo "     DIRECCION IP EN VLAN3: ${YO_IPV4_VLAN_003}"
echo "============================================================================="
#
if [ ! -z ${YO_IPV4_VLAN_003} ]
then
    iptables -t nat -A POSTROUTING -o ${vlan3} -s 192.168.1.0/24 -j SNAT --to-source ${YO_IPV4_VLAN_003}
else
    iptables -t nat -A POSTROUTING -o ${vlan3} -s 192.168.1.0/24 -j MASQUERADE
fi

# =====================================================================================
#                                ACTIVAR EL FORWARDING
#
echo 1 > /proc/sys/net/ipv4/ip_forward

# =====================================================================================
#                                  RPF
#
echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter
echo 1 > /proc/sys/net/ipv4/conf/${vlan100}/rp_filter
echo 1 > /proc/sys/net/ipv4/conf/${vlan6}/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/${vlan2}/rp_filter
echo 1 > /proc/sys/net/ipv4/conf/${vlan3}/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/lo/rp_filter
if [ -f /proc/sys/net/ipv4/conf/ppp0/rp_filter ]
then
    echo 1 >     /proc/sys/net/ipv4/conf/ppp0/rp_filter
fi
echo 1 > /proc/sys/net/ipv4/conf/tunl0/rp_filter

# MUESTRO EL RESULTADO FINAL
valor=\`cat /proc/sys/net/ipv4/ip_forward\`
echo ${valor} /proc/sys/net/ipv4/ip_forward
for i in /proc/sys/net/ipv4/conf/*/rp_filter
do
    valor=\`cat $i\`
    echo ${valor} $i
done

Activa los servicios para que arranquen durante el boot (de momento no hagas reboot)

- Servicio Pre-Red: systemctl enable router_iptables_pre_net.service
- Servicio Post-Red: systemctl enable router_iptables_post_net.service

  **Alternativa a iptables**

{% include showImagen.html
    src="/assets/img/original/"
    caption="pfSense"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/networking.png"
    caption="networking"
    width="600px"
    %}

 

### Servidores DNS y DHCP

El siguiente paso es instalar BIND y DHCP para tener un Servidor de nombres y uno de direcciones IP. Dejo unos ejemplos "cuasi" reales para que te sirvan de "munición" en tu propia configuración.

net-dns/bind   dlz ipv6 -mysql ssl xml

# emerge -v net-misc/dhcp net-dns/bind

**DNS Server**

Si tienes un equipo Linux encendido 24 horas en tu intranet te recomiendo activar tu propio DNS Server, podrás asignar nombres a las direcciones IP y junto con un DHCP Server asignar direcciones IP estáticas sobre la base de la dirección MAC (usando el nombre DNS). Prepara el fichero **named.conf** y un par de ficheros más para tu dominio privado. Dejo un ejemplo para un dominio interno que he llamado "parchis.org". La ventaja que tiene es que hace de acelerador/proxy, cuando consultes un dominio desoncocido pues se irá a internet a buscar la respuesta.

/*
 * Refer to the named.conf(5) and named(8) man pages, and the documentation
 * in /usr/share/doc/bind-* for more details.
 * Online versions of the documentation can be found here:
 * https://kb.isc.org/article/AA-01031
 *
 * If you are going to set up an authoritative server, make sure you
 * understand the hairy details of how DNS works. Even with simple mistakes,
 * you can break connectivity for affected parties, or cause huge amounts of
 * useless Internet traffic.
 */

acl "xfer" {
    /* Deny transfers by default except for the listed hosts.
     * If we have other name servers, place them here.
     */
    none;
};

/*
 * You might put in here some ips which are allowed to use the cache or
 * recursive queries
 */
acl "trusted" {
    127.0.0.0/8;
    ::1/128;
        192.168.1/24; 10.55.138.142; 192.168.0.1;
};

options {
    directory "/var/bind";
    pid-file "/run/named/named.pid";

    /* https://www.isc.org/solutions/dlv >=bind-9.7.x only */
    //bindkeys-file "/etc/bind/bind.keys";

    //listen-on-v6 { ::1; };
    listen-on { 127.0.0.1; };
        listen-on { 192.168.1.1; 10.55.138.142; 192.168.0.1; };

    allow-query {
        /*
         * Accept queries from our "trusted" ACL.  We will
         * allow anyone to query our master zones below.
         * This prevents us from becoming a free DNS server
         * to the masses.
         */
        trusted;
    };

    allow-query-cache {
        /* Use the cache for the "trusted" ACL. */
        trusted;
    };

        allow-recursion {
        /* Only trusted addresses are allowed to use recursion. */
        trusted;
    };

    allow-transfer {
        /* Zone tranfers are denied by default. */
        none;
    };

    allow-update {
        /* Don't allow updates, e.g. via nsupdate. */
        none;
    };

    dnssec-enable yes;
    //dnssec-validation yes;

    /*
     * As of bind 9.8.0:
     * "If the root key provided has expired,
     * named will log the expiration and validation will not work."
     */
    dnssec-validation auto;

    /* if you have problems and are behind a firewall: */
    //query-source address * port 53;
};

include "/etc/bind/rndc.key";
controls {
    inet 127.0.0.1 port 953 allow { 127.0.0.1/32; ::1/128; } keys { "rndc-key"; };
};

/**
 *   ====================================================================================
 *   LOG - Activo Log muy detallado junto con ulog
 *   ====================================================================================
 */
logging {
    channel default_file {
        file "/var/log/named/default.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel general_file {
        file "/var/log/named/general.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel database_file {
        file "/var/log/named/database.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel security_file {
        file "/var/log/named/security.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel config_file {
        file "/var/log/named/config.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel resolver_file {
        file "/var/log/named/resolver.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel xfer-in_file {
        file "/var/log/named/xfer-in.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel xfer-out_file {
        file "/var/log/named/xfer-out.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel notify_file {
        file "/var/log/named/notify.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel client_file {
        file "/var/log/named/client.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel unmatched_file {
        file "/var/log/named/unmatched.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel queries_file {
        file "/var/log/named/queries.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel network_file {
        file "/var/log/named/network.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel update_file {
        file "/var/log/named/update.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel dispatch_file {
        file "/var/log/named/dispatch.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel dnssec_file {
        file "/var/log/named/dnssec.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };
    channel lame-servers_file {
        file "/var/log/named/lame-servers.log" versions 3 size 5m;
        severity dynamic;
        print-time yes;
    };

    category default { default_file; };
    category general { general_file; };
    category database { database_file; };
    category security { security_file; };
    category config { config_file; };
    category resolver { resolver_file; };
    category xfer-in { xfer-in_file; };
    category xfer-out { xfer-out_file; };
    category notify { notify_file; };
    category client { client_file; };
    category unmatched { unmatched_file; };
    category queries { queries_file; };
    category network { network_file; };
    category update { update_file; };
    category dispatch { dispatch_file; };
    category dnssec { dnssec_file; };
    category lame-servers { lame-servers_file; };
};

/**
 *   ====================================================================================
 *   ZONAS - Creo un view privado para la intranet
 *   ====================================================================================
 */

view "privado" {

   match-clients { 192.168.1.0/24; 127.0.0.1; }; // LAN "Casera"

   allow-recursion {
      /* Only trusted addresses are allowed to use recursion. */
      trusted;
   };

   recursion yes;

   // LOCALHOST
   zone "." IN {
    type hint;
    file "named.cache";
        };

   zone "localhost" IN {
    type master;
    file "pri/localhost.zone";
    allow-update { none; };
    notify no;
   };

   zone "127.in-addr.arpa" IN {
    type master;
    file "pri/127.zone";
    allow-update { none; };
    notify no;
   };

   // Para peticiones desde la intranet hacia DNS de Movistar
   //
   // Traslado al dns server 172.26.23.3 todas las consulatas que me 
   // hagan que terminen en cualquiera de estos dos dominios
   //
   zone "svc.imagenio.telefonica.net" in {
        type forward;
        forwarders { 172.26.23.3; };
        forward only;
   };
   zone "tv.movistar.es" in {
        type forward;
        forwarders { 172.26.23.3; };
        forward first;
   };

  /**
   *   Zonas privadas
   */

  zone "parchis.org" {
    notify no;
    type master;
    file "pri/privado/parchis.org";
    allow-transfer { localhost; };
    allow-query { any; };
  };

  zone "1.168.192.in-addr.arpa" {
    notify no;
    type master;
    file "pri/privado/192.168.1";
    allow-transfer { localhost; };
    allow-query { any; };
  };
};

Zona interna (parchis.org)

;
; Fichero de la zona parchis.org
;
$TTL 3D
@       IN      SOA     ns1.parchis.org. luis.parchis.org.  (
                                      2015031901 ; Serial
                                      28800      ; Refresh
                                      14400      ; Retry
                                      3600000    ; Expire
                                      86400 )    ; Minimum
                TXT            "NS de Parchis"
                NS          ns1.parchis.org.
;
localhost       A               127.0.0.1
servidor        A               192.168.1.1
ns1             A               192.168.1.1
www             A               192.168.1.1

; Servidor de aplicaciones dockerizadas
apps            A               192.168.1.1

; Equipos adicionales en la red
panoramix       A               192.168.1.150
                HINFO           "QNAPTS569Pro" "QNAP TS-569 Pro en el garaje"
luispa-mac      A               192.168.1.151
                HINFO           "MacbookPro" "MBP6.2 de Luis"
rasp-dormitorio A               192.168.1.152
                HINFO           "RaspberryPi" "Raspberry Pi 2 Model B v1.1"
deco-movistar   A               192.168.1.200
                HINFO           "Movistar TV" "Zyxel STB-2112T Nano V2"
switch          A               192.168.1.254
                HINFO           "Switch" "Switch con soporte de VLANs"

Resolución inversa

;
; Fichero de la zona inversa parchis.org
;
$TTL 3D
@       IN      SOA     ns1.parchis.org. luis.parchis.org.  (
                                      2015031901 ; Serial
                                      28800      ; Refresh
                                      14400      ; Retry
                                      3600000    ; Expire
                                      86400 )    ; Minimum
                NS      ns1.parchis.org.

1       PTR     servidor.parchis.org.
1       PTR     ns1.parchis.org.
150     PTR     panoramix.parchis.org.
151     PTR     luispa-mac.parchis.org.
152     PTR     rasp-dormitorio.parchis.org.
200     PTR     deco-movistar.parchis.org.
254     PTR     switch.parchis.org.

Tanto este servidor (él mismo) como cualquier otro equipo de la Intranet debe apuntar a él para las consultas DNS, y como decía antes si es necesario él irá a internet a buscar las respuestas.

domain parchis.org
nameserver 192.168.1.1

Activo el servicio DNS Server, no necesitas crear ningún fichero .service, en esta ocasión voy a usar el que trae el sistema (se encuentran en /usr/lib64/systemd/system).

- Servicio DNS: systemctl enable named.service

  **DHCP Server**

El DHCP Server también es muy sencillo de configurar, se basa en el fichero /etc/dhcp/dhcpd.conf y /etc/conf.d/dhcp.

# dhcpd.conf
#
ddns-update-style none;
authoritative;
option opch code 240 = text;

#
# Definicion de las subnets (scopes)
#
shared-network lan {
    #------------------------------------------------------#
    #                                                      #
    #  Interface activa. Ver /etc/conf.d/dhcpd             #
    #   DHCPD_IFACE="vlan100"                              #
    #                                                      #
    #------------------------------------------------------#
    subnet 192.168.1.0 netmask 255.255.255.0 {
        option routers 192.168.1.1;
        option subnet-mask 255.255.255.0;
        option domain-name "parchis.org";
        option domain-name-servers 192.168.1.1;
        option interface-mtu 1496;

        allow bootp;
        allow booting;

        # Pool

        pool {
             range 192.168.1.150 192.168.1.190;
        }
    }
}

#####################
###
### Ejemplo de un host al que se le asigna una direccion especifica
###
#####################

        host equipo1 {
                hardware ethernet 12:34:56:78:aa:bb;
                fixed-address equipo1.parchis.org;
        }

#####################
###
### Ejemplo de DECO del servicio Movistar TV
###
#####################

        host deco-cocina {
                hardware ethernet 4c:9e:ff:11:22:33;
                fixed-address 192.168.1.200;
                option domain-name-servers 172.26.23.3;
                option opch ":::::239.0.2.10:22222:v6.0:239.0.2.30:22222";
        }

DHCPD_IFACE="vlan100"

Creo el Unit porque el que trae el sistema no me vale:

[Unit]
Description=DHCPv4 Server Daemon
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
EnvironmentFile=/etc/conf.d/dhcpd
ExecStart=/usr/sbin/dhcpd -cf /etc/dhcp/dhcpd.conf -user dhcp -group dhcp --no-pid $DHCPD_IFACE
Restart=on-abort

[Install]
WantedBy=multi-user.target

Activo el servicio DHCP Server.

- Servicio DHCP Server: systemctl enable dhcpd.service

  **DHClient para vlan3**

Lo comenté antes, hay que activar un cliente DHCP para la IP de VoIP en el interfaz VLAN3, no uso el embebido de systemd-networkd sino el "dhclient" que viene con el DHCP Server que acabamos de instalar.

Creo un unit specífico:

[Unit]
Description=DHCP Client
Wants=network-online.target router_iptables_post_net.service
After=network-online.target
Before=router_iptables_post_net.service

[Service]
Type=simple
ExecStart=/sbin/dhclient -4 -d -v -cf /etc/dhcp/dhclient.conf vlan3
Restart=on-abort

[Install]
WantedBy=multi-user.target

IMPORTANTE: Creo el fichero de configuración de dhclient y sobre todo el fichero de "hook", no te olvides o te instalará una ruta por defecto adicional que te "destrozará" el routing :-)

backoff-cutoff 10;
initial-interval 2;
timeout 15;
retry 10;
reboot 5;
interface "vlan3" {
 request subnet-mask;
 require subnet-mask;
 }

# Impido que se instalen rutas por defecto
unset new_routers

Activo el servicio DHCP Cliente.

- Servicio DHCP Cliente vlan3: systemctl enable dhclient.service

 

### Servicios adicionales

{% include showImagen.html
    src="/assets/img/original/?p=266"
    caption="apunte"
    width="600px"
    %}

**igmpproxy.service**

[Unit]
Description=IGMP Proxy
After=network-online.target zebra.service
ConditionPathExists=/etc/igmpproxy.conf

[Service]
Type=simple
ExecStart=/usr/sbin/igmpproxy /etc/igmpproxy.conf
#Restart=on-abort

[Install]
WantedBy=multi-user.target

**udpxy.service**

[Unit]
Description=UDP-to-HTTP multicast traffic relay daemon
After=network-online.target igmpproxy.service

[Service]
Type=forking
EnvironmentFile=/etc/conf.d/udpxy
ExecStart=/usr/bin/udpxy $UDPXYOPTS
Restart=on-abort

[Install]
WantedBy=multi-user.target

**zebra.service**

[Unit]
Description=GNU Zebra routing manager
After=syslog.target network.target
ConditionPathExists=/etc/quagga/zebra.conf

[Service]
Type=forking
EnvironmentFile=-/etc/conf.d/quagga
ExecStartPre=/bin/ip route flush proto zebra
ExecStart=/usr/sbin/zebra -d $ZEBRA_OPTS -f /etc/quagga/zebra.conf
Restart=on-abort

[Install]
WantedBy=network.target

**ripd.service**

[Unit]
Description=RIP routing daemon
BindTo=zebra.service
After=syslog.target network.target zebra.service
ConditionPathExists=/etc/quagga/ripd.conf

[Service]
Type=forking
EnvironmentFile=/etc/conf.d/quagga
ExecStart=/usr/sbin/ripd -d $RIPD_OPTS -f /etc/quagga/ripd.conf
Restart=on-abort

[Install]
WantedBy=network.target

- Servicio igmpproxy: systemctl enable igmpproxy.service
- Servicio udpxy: systemctl enable udpxy.service
- Servicio zebra: systemctl enable zebra.service
- Servicio ripd: systemctl enable ripd.service

 

## Directorio "run"

Los directorios en /run y /var/run que necesitan los programas anteriores no se crean con systemd, así que he montado un "service" y un pequeño script para solucionarlo.

[Unit]
Description=Crear directorios en /var/run
Wants=network-pre.target
Before=network-pre.target

[Service]
Type=oneshot
ExecStart=/bin/bash /root/firewall/router.ipv4.run_directory.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

#!/bin/bash

mkdir /var/run/named
chown named:named /var/run/named

mkdir /var/run/dhcp

> /var/log/zebra.log
chown quagga:quagga /var/log/zebra.log

mkdir /run/quagga
chmod 750 /run/quagga
chown quagga:quagga /run/quagga/

> /var/log/ripd.log
chown quagga:quagga /var/log/ripd.log

Activo el servicio:

- Servicio creación de directorios: systemctl enable router_pre.service

 

## Herramienta de verificación

Para terminar te dejo una herramienta que me he preparado para ver si todo va bien...

#!/bin/bash
#
# nene-gre, script que verifica que la configuracion de la red es correcta,
# que hay conectividad con internet, tc... 
#
# Copyright (C) 2006 Luis Palacios
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#

# Variables de trabajo
temporal=/tmp/temp-parchis-verifica.sh

# Usar las variables con "echo -e" para que interprete las secuencias \escaped...
NORMAL="\033[0;39m"
ROJO="\033[1;31m"
VERDE="\033[1;32m"
AMARILLO="\033[1;33m"

# Columna donde se muestra el mensaje de resultado (linea 1000, asi siempre
# se ensena en la ultima linea de la shell... y columna 80)
RESOK="\033[1000;80H[${VERDE}OK${NORMAL}]"
RESWARN="\033[1000;75H[${AMARILLO}warning${NORMAL}]"
RESERROR="\033[1000;77H[${ROJO}ERROR${NORMAL}]"

# Salir del programa
salir() {
    rm -f $temporal
    exit
}

# Funcion para comprobar el estado de las subinterfaces
# En $1 nos pasan el nombre de la interfaz
# En $2 el nivel de importancia que tiene (1-aviso, 2 o cualquier
# otro numero entonces es critico) si la interfaz no esta disponible
test_intf() {
    # Get the IP Address from first argument
    intf=$1
    nivel=$2

    echo -n "Probando interface: $intf"
    ip link show $intf 2>/dev/null | grep UP > /dev/null 2>/dev/null
    ret=$?

    if [ "$ret" = "0" ] ; then
        echo -e "${RESOK}"
    else
        if [ "$nivel" = "1" ]; then
            echo -e "${RESWARN}"
    else
            echo -e "${RESERROR}"
        fi
    fi
}

# Funcion para probar conectividad con la direccion
# IP que nos pasan en '$1' y mostrando detras el mensajje en '$2'
# En $2 el nivel de importancia que tiene (1-aviso, 2 o cualquier
# otro numero entonces es critico) si la interfaz no esta disponible
test_ip() {
    # Get the IP Address from first argument
    ip=$1
    txt=$2
    nivel=$3

    echo -n "Probando IP $ip: $txt ..."
    ping -c 1 $ip > $temporal 2>/dev/null
    ret=$?

    if [ "$ret" = "0" ] ; then
        ms=\`cat $temporal | grep rtt | awk 'BEGIN{FS="/"};{printf $5}'\`
        echo -e "${RESOK} $ms ms"
    else
        if [ "$nivel" = "1" ]; then
            echo -e "${RESWARN}"
    else
            echo -e "${RESERROR}"
        fi
    fi
}

# Comprobar estado de un unit en '$1' de systemd, mostrando mensaje '$2'.
# En $2 el nivel de importancia que tiene (1-aviso, 2 o cualquier
# otro numero entonces es critico)
test_unit() {
    unit=$1
    txt=$2
    nivel=$3

    echo -n "Unit (servicio) ${unit}: $txt ..."
    systemctl is-active ${unit} > ${temporal} 2>/dev/null
    ret=$?

    if [ "$ret" = "0" ] ; then
        echo -e "${RESOK}"
    else
        if [ "$nivel" = "1" ]; then
            echo -e "${RESWARN}"
    else
            echo -e "${RESERROR}"
        fi
    fi
}

#
# Verificar units de systemd
# ===============================
test_unit router_iptables_pre_net.service "IPTABLES (pre-net)"
test_unit router_iptables_post_net.service "IPTABLES (post-net)"
test_unit sshd.service "SSHD"
test_unit named.service "DNS Server"
test_unit dhcpd.service "DHCP Server"
test_unit ppp_wait@movistar.service "PPP Movistar"
test_unit zebra.service "Quagga Zebra"
test_unit ripd.service "Quagga ripd"
test_unit igmpproxy.service "IGMPProxy Movistar TV"
test_unit udpxy.service "udpxy Movistar TV"
test_unit dhclient.service "DHCP Client vlan3"
test_unit router_pr_post_iptables.service "Policy Routing"

#
# Verificar interfaces
# ===============================
test_intf lo 2
test_intf ppp0 2
test_intf vlan100 2
test_intf vlan2 2
test_intf vlan3 2
test_intf vlan6 2

#
# Verificar la conectividad IP
# ===============================
test_ip localhost "localhost (lo)"
test_ip 192.168.1.253 "Switch en la intranet (vlan100)" 1
test_ip 130.206.1.2 "Equipo de Internet (ppp0)"
test_ip 172.26.23.3 "DNS Server de MOVISTAR TV"

{% include showImagen.html
    src="/assets/img/original/router-verifica.png"
    caption="router-verifica"
    width="600px"
    %}
