---
title: "Instalación de \"ntopng\" en Gentoo"
date: "2013-11-22"
categories: apuntes
tags: linux ntopng
excerpt_separator: <!--more-->
---

Hace no demasiado se ha liberado "ntopng" 1.1 y ya es hora de echarle un ojo. Todavía no está en Portage, así que gracias al overlay (via layman) de Eigenlay he encontrado lo necesario para realizar la instalación.

![ntop](/assets/img/original/ntop.jpg){: width="730px" padding:10px }

Ya tenía instalado layman, así que estos son los pasos realizados:

 
# layman -a eigenlay
 

Configuro Portage para que acepte esta versión "beta"

 
# echo "=net-analyzer/ntopng-9999 **" >> /etc/portage/package.accept_keywords
# echo "=net-analyzer/ntopng-9999" >> /etc/portage/package.unmask
 

Ejecuto el proceso de instalación, notar que elimino todas las opciones en las variables MAKEOPTS y EMERGE_DEFAULT_OPTS, es importante hacerlo para evitar que trabaje en modo silencioso.

 
#  MAKEOPTS="" EMERGE_DEFAULT_OPTS="" emerge -v ntopng
These are the packages that would be merged, in order:
Calculating dependencies ... done!
[ebuild N ] dev-libs/geoip-1.5.0 USE="ipv6 -city -perl-geoipupdate -static-libs" 3,921 kB
[ebuild N ] dev-libs/jemalloc-3.3.1 USE="-debug -static-libs -stats" 248 kB
[ebuild N ] dev-db/redis-2.6.13 USE="jemalloc -tcmalloc {-test}" 972 kB
[ebuild N #] net-analyzer/ntopng-9999::eigenlay 0 kB
Total: 4 packages (4 new), Size of downloads: 5,139 kB
 

/usr/bin/ntopng
/usr/share/ntopng
/usr/share/ntopng/httpdocs
/usr/share/ntopng/scripts
Nota: /usr/local/share/ntopng se hace un link simbólico a /usr/share/ntopng

## Gentoo init

El paquete anterior no trae el script que necesitamos en /etc/init.d ni tampoco el de configuración que va en /etc/conf.d, así que he creado los míos propios:

#!/sbin/runscript
#

NTOPNG_USER=${NTOPNG_USER:-nobody}
NTOPNG_GROUP=${NTOPNG_GROUP:-nobody}
NTOPNG_OPTS=${NTOPNG_OPTS:-"--pid ${NTOPNG_PID}
--daemon
"}

command=/usr/bin/ntopng
start_stop_daemon_args="--quiet"
command_args="${NTOPNG_OPTS}"

pidfile=${NTOPNG_PID:-/var/run/ntopng/ntopng.pid}

depend() {
use net localmount logger redis
after keepalived
}

start_pre() {
checkpath -d -m 0775 -o ${NTOPNG_USER}:${NTOPNG_GROUP} $(dirname ${NTOPNG_PID})
}

# usuario ntopng
NTOPNG_USER="nobody"

# grupo para ntopng
NTOPNG_GROUP="nobody"

# interfaces separadas por comas
NTOPNG_LOCALNETS="88.212.145.112/32,11.64.119.91/32,192.168.15.2/32,192.168.1.0/24,0.0.0.0/32,224.0.0.0/8,239.0.0.0/8"

# interfaces
NTOPNG_INTERFACES="-i ppp0 -i vlan500 -i vlan400 -i vlan100"

# fichero pid
NTOPNG_PID="/var/run/ntopng/ntopng.pid"

# donde escucha Redis
NTOPNG_REDIS="localhost:6379"

# Opciones finales
#
NTOPNG_OPTS="
-m ${NTOPNG_LOCALNETS}
${NTOPNG_INTERFACES}
--pid ${NTOPNG_PID}
--daemon
--redis ${NTOPNG_REDIS}
"

## Arranque y configuración inicial

Primero arrancamos REDIS y lo añadimos para que arranque siempre.

 
bolica ~ # /etc/init.d/redis start
bolica ~ # netstat -nap | grep -i redis
tcp 0 0 127.0.0.1:6379 0.0.0.0:* LISTEN 12642/redis-server
bolica ~ # rc-update add redis default
* service redis added to runlevel default
 

A continuación ya podemos arrancar ntopng y añadirlo para que arranque siempre

 
bolica ~ # /etc/init.d/ntopng start
* Caching service dependencies ... [ ok ]
* /var/run/ntopng: creating directory
* /var/run/ntopng: correcting owner
* Starting ntopng ...

bolica ~ # rc-update add ntopng default
* service ntopng added to runlevel default
 

 

## Configuración de GeoIP

El ebuild de ntopng todavía no integra bien el tema de GeoIP. A continuación tienes un script que puedes usar para bajarte los ficheros .dat de geoip, que se instalen en el directorio correcto y además puedes invocar a este script desde crontab para actualizarlos por ejemplo una vez a la semana.

#!/bin/bash
#
# update-geoip.sh actualiza los ficheros .dat de geoip para ntopng
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#

# Functions
# ==========================================================================
#
# Mostra como se usa este programa
#
uso() {
echo -n "\`basename $0\`, v"
echo -n $version | awk '{printf $3}'
echo ". By Luis Palacios"
echo "Uso: update-geoip.sh [-h]"
echo " -h help"
echo " "
echo " "
exit -1 # Salimos
}

# Analisis de las opciones
while getopts "h" Option
do
case $Option in

# EOM, no comments
h ) uso;;

# Resto de argumentos, error.
* ) uso;;

esac
done

#
# ================================================================
#
echo

#
cd /usr/local/share/ntopng/httpdocs/geoip
wget -nc http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
gunzip -f GeoLiteCity.dat.gz

#
cd /usr/local/share/ntopng/httpdocs/geoip
wget -nc http://geolite.maxmind.com/download/geoip/database/GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz
gunzip -f GeoLiteCityv6.dat.gz

#
cd /usr/local/share/ntopng/httpdocs/geoip
wget -nc http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz
gunzip -f GeoIPASNum.dat.gz

#
cd /usr/local/share/ntopng/httpdocs/geoip
wget -nc http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNumv6.dat.gz
gunzip -f GeoIPASNumv6.dat.gz

**Crea el fichero, dale permisos y ejecútalo para bajarte los .dat**

 
bolica bin # chmod 755 update-geoip.sh
bolica bin # ./update-geoip.sh
:
bolica bin # ls -al /usr/local/share/ntopng/httpdocs/geoip/
total 39296
drwxr-xr-x 2 root root 4096 nov 23 21:30 .
drwxr-xr-x 9 root root 4096 nov 22 09:16 ..
-rw-r--r-- 1 root root 3507428 nov 19 02:48 GeoIPASNum.dat
-rw-r--r-- 1 root root 3754285 mar 18 2013 GeoIPASNumv6.dat
-rw-r--r-- 1 root root 16231805 nov 6 16:55 GeoLiteCity.dat
-rw-r--r-- 1 root root 16731716 nov 6 02:54 GeoLiteCityv6.dat
 

Conexión con ntopng: http://192.168.1.1:3000/login.html
