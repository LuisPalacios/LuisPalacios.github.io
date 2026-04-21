#!/bin/bash

##
## Fichero /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_DOWN.sh
## En Servidor ‘sur’
##
## Este fichero está relacionado con este apunte:
## https://www.luispa.com/linux/2014/10/19/bridge-ethernet.html
##

# Script que se ejecuta al hacer un `stop` del servicio Bridge Ethernet

# Interfaces, rutas + IP y MACs asociaré a las interfaces tap y bridge
. /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_CONFIG.sh

# Quitar las reglas iptables
for i in `echo ${EB_TAP} ${EB_VLAN} ${EB_BRIDGE}`; do
    iptables -D INPUT -i ${i} -j ACCEPT 2>/dev/null
    iptables -D FORWARD -i ${i} -j ACCEPT 2>/dev/null
    iptables -D OUTPUT -o ${i} -j ACCEPT 2>/dev/null
done

# Eliminar la IP del bridge
ip addr del ${bridge_ip_local} brd + dev ${EB_BRIDGE} 2>/dev/null

# Remove interfaces from the bridge
brctl delif ${EB_BRIDGE} ${EB_VLAN} 2>/dev/null
brctl delif ${EB_BRIDGE} ${EB_TAP} 2>/dev/null

# Destroy interface tunel IPSec
ip link set ${EB_TAP} down 2>/dev/null

# Destroy interface vlan
ip link set ${EB_VLAN} down 2>/dev/null

# Destroy the BRIDGE
ip link set ${EB_BRIDGE} down 2>/dev/null
brctl delbr ${EB_BRIDGE} 2>/dev/null

# Destruir la tabla de routing para los clientes Decos
/etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_RT_DOWN.sh
