#!/bin/bash
# Script que se ejecuta al hacer un `stop` del servicio Bridge Ethernet

# Interfaces, rutas + IP y MACs asociaré a las interfaces tap y bridge
. /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_CONFIG.sh

##
## Equipos (Decos) que llegan a Movistar IPTV
##
ip rule del from ${bridge_ip_rango} table Decos 2>/dev/null
ip route del default via ${bridge_ip_remota} table Decos 2>/dev/null
ip route del ${bridge_ip_rango} dev ${EB_BRIDGE} table Decos 2>/dev/null
