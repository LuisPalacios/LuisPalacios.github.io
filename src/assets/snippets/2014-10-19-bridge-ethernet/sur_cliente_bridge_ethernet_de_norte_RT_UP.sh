#!/bin/bash
# Script que se ejecuta al hacer un `start` del servicio Bridge Ethernet

# Interfaces, rutas + IP y MACs asociaré a las interfaces tap y bridge
. /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_CONFIG.sh

##
## Equipos (Decos) que llegan a Movistar IPTV
##
# Creo una tabla de routing dedicada
grep -i "^206 Decos" /etc/iproute2/rt_tables > /dev/null 2>&1
if [ "$?" = 1 ]; then
    sudo echo "206 Decos" >> /etc/iproute2/rt_tables
fi
ip route add ${bridge_ip_rango} dev ${EB_BRIDGE} table Decos 2>/dev/null
ip route add default via ${bridge_ip_remota} table Decos 2>/dev/null
# Creo una regla que indica qué equipos deben usar dicha tabla de routing
ip rule add from ${bridge_ip_rango} table Decos 2>/dev/null
