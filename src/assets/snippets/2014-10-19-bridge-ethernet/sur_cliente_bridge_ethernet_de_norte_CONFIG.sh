#!/bin/bash

##
## Fichero /etc/openvpn/client/sur_cliente_bridge_ethernet_de_norte_CONFIG.sh
## En Servidor ‘sur’
##
## Este fichero está relacionado con este apunte:
## https://www.luispa.com/linux/2014/10/19/bridge-ethernet.html
##

# Este fichero contiene los nombres de las interfaces y parámetros de cada uno de
# ellas. Los utilizan los scripts de arranque y parada del servicio Bridge Ethernet

# Configuración General
export mtu="1492"

# Para el Bridge
export EB_TAP="tap206"     # Nombre del interfaz tap (ver .conf), representa al tunel openvpn y que añadiré al bridge.
export EB_BRIDGE="br206"   # Interfaz virtual Bridge que voy a crear.
export EB_VLAN="eth1.206"  # Interfaz VLAN local que añadiré al bridge

# Configuración para el tunel openvpn (interfaz tapXXX)
# Las direcciones MAC's pueden ser cualquiera, obviamente que no se usen en otro sitio.
export mac_tap="be:64:00:02:06:02"       # MAC privada para el interfaz tap local que asociaré al bridge
export mac_bridge="02:64:00:02:06:02"    # MAC privada para el bridge local
# Configuración para el bridge local (interfaz brXXX)
# El rango puede ser cualquiera, una vez más que no e use en otro sitio
export bridge_ip_rango="192.168.206.0/24" # Rango que voy a usar en el bridge
export bridge_ip_local="192.168.206.2/24" # IP de este servidor en su interfaz brXXX (bridge local)
export bridge_ip_remota="192.168.206.1"   # IP de del servidor remoto en su interfaz brXXX (su propio bridge)

# Acceso a internet vía el proveedor remoto en NORTE
export ifWan="eth0"
export ipWan=`ip addr show dev ${ifWan} | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2`
export ifSur="eth1.10"
export ipSurRango="192.168.10.0/24"
export ipSur="192.168.10.1"

# Acceso a internet vía el proveedor local en SUR
export ifNorteTunel="tun1"
export ipNorteTunelRango="192.168.224.0/24"
export ipNorteTunel="192.168.224.2"
export ipNorteTunelRouter="192.168.224.1"
export ifNorteLan="eth1.107"
export ipNorteLanRango="192.168.107.0/24"
export ipNorteLan="192.168.107.1"
