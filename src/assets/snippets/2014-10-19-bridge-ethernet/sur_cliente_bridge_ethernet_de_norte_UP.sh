#!/bin/bash

##
## Fichero /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_UP.sh
## En Servidor ‘sur’
##
## Este fichero está relacionado con este apunte:
## https://www.luispa.com/linux/2014/10/19/bridge-ethernet.html
##

# Script que se ejecuta al hacer un `start` del servicio Bridge Ethernet

# Interfaces, rutas + IP y MACs asociaré a las interfaces tap y bridge
. /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_CONFIG.sh

# Activo el tunel IPSec
ip link set ${EB_TAP} address ${mac_tap}
ip link set ${EB_TAP} up
ip link set ${EB_TAP} mtu ${mtu}

# SETUP BRIDGE
brctl addbr ${EB_BRIDGE}
brctl stp ${EB_BRIDGE} off                         # HUB: no uso STP
brctl setageing ${EB_BRIDGE} 0                     # HUB: olvidar MAC addresses, be a HUB
brctl setfd ${EB_BRIDGE} 0                         # HUB: elimino el forward delay
#ip link set ${EB_BRIDGE} promisc on              # entregar el paquete en local
ip link set ${EB_BRIDGE} address ${mac_bridge}     # Cada nodo debe tener una distinta
ip link set ${EB_BRIDGE} arp on
ip link set ${EB_BRIDGE} mtu ${mtu}
ip link set ${EB_BRIDGE} up

# Activatar VLAN y cambiar MTU
ip link set ${EB_VLAN} up
ip link set ${EB_VLAN} mtu ${mtu}

# Añadir interfaces al bridge
brctl addif ${EB_BRIDGE} ${EB_TAP}  # Añado tunel ipsec al bridge
brctl addif ${EB_BRIDGE} ${EB_VLAN} # Añado vlan al bridge

# Asignar una IP al Bridge si queremos que vaya todo por el bridge
# IMPORTANTÍSIMO poner /24 o asignará una /32 (no funcionará)
ip addr add ${bridge_ip_local} brd + dev ${EB_BRIDGE}

# === QoS/Offloads/Snooping para IPTV (Sur) ===
ETHTOOL="$(command -v ethtool || echo /sbin/ethtool)"
TC="$(command -v tc || echo /sbin/tc)"
disable_offloads() { "$ETHTOOL" -K "$1" gro off gso off tso off 2>/dev/null || true; }

# IGMP Snooping en el bridge
if [ -e "/sys/class/net/${EB_BRIDGE}/bridge/multicast_snooping" ]; then
  echo 1 > "/sys/class/net/${EB_BRIDGE}/bridge/multicast_snooping"
fi

# Desactivar GRO/GSO/TSO en el path IPTV: bridge, tap, vlan del bridge y WAN
for i in "${EB_BRIDGE}" "${EB_TAP}" "${EB_VLAN}" "${ifWan}"; do
  [ -d "/sys/class/net/$i" ] && disable_offloads "$i"
done

# fq_codel en en interfaz WAN efectiva que me saca a internet
"$TC" qdisc replace dev "${ifWan}" root fq_codel 2>/dev/null || true

# Me aseguro de configurar bien el rp_filter
echo -n 0 > /proc/sys/net/ipv4/conf/${EB_BRIDGE}/rp_filter
echo -n 1 > /proc/sys/net/ipv4/conf/${EB_VLAN}/rp_filter
echo -n 1 > /proc/sys/net/ipv4/conf/${EB_TAP}/rp_filter

# Me aseguro de que el forwarding está funcionando
echo -n 1 > /proc/sys/net/ipv4/ip_forward

# Permito el tráfico
for i in `echo ${EB_TAP} ${EB_VLAN} ${EB_BRIDGE}`; do
    iptables -I INPUT -i ${i} -j ACCEPT
    iptables -I FORWARD -i ${i} -j ACCEPT
    iptables -I OUTPUT -o ${i} -j ACCEPT
done

# Tabla de routing para los Decos
/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_RT_UP.sh
