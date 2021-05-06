---
title: "PlexConnect en Linux"
date: "2014-01-07"
categories: apuntes
tags: linux plex plexconnect
excerpt_separator: <!--more-->
---

Apunte sobre la configuración en Linux de PlexConnect para poder usar Plex con un Apple TV3.

![images](/assets/img/original/images.jpg){: width="730px" padding:10px }

Solo he tenido que modificar el DHCP Server, añadir 3 redirecciones con iptables y configurar/arrancar el programa PlexConnect. Estas son las direcciones IP para entender las instrucciones:

- Servidor Linux "bolica" - dirección IP: "192.168.1.1"
- Apple TV 3 "atv3" - dirección IP: "192.168.1.37"
- Router: 192.168.1.1
- DNS Server: 192.168.1.1

Recomiendo leer la [página de documentación del proyecto PlexConnect](https://github.com/iBaa/PlexConnect/wiki/Install-guides) y sobre todo ![esta otra página donde define cómo generar los certificados](/assets/img/original/){: width="730px" padding:10px }. En el Apple TV3 no hay que hacer nada.

 

## Configuración en Linux

- DHCP, Router, DNS.
- iptables: Cambio puertos para el ATV3: 80->9080 (http), 443->9443 (https) y 53->9053 (dns)
- PlexConnect: Escucha en puertos: webserver (9080), webserver https (9443) y dns (9053)

Si tienes un DNS server en tu linux, no tienes que tocarlo dado que redirigimos el tráfico 53(udp) que provenga del Apple TV hacia el DNS server embebido en PlexConnect (9053 udp). Si tienes un Web Server lo mismo, no lo tocas porque el tráfico 80/443 que origine el Apple TV se redirige al embebido en PlexConnect (9080/9443).  

## Plex Media Server

Obviamente es necesario tener un Plex Media Server funcionando en algún sitio. En mi caso en el mismo equipo Linux. Se trata de un servidor Gentoo Linux así que solo tuve que ejecutar la instalación desde portage y configurar PMS. Instalación en Gentoo: emerge -v plex-media-server

![http://192.168.1.1:32400/web/index.html#!/setup](/assets/img/original/setup){: width="730px" padding:10px }  

## DHCP

Aquí lo único importante es que el ATV3 debe ser configurado (vía DHCP) para que su DNS server apunte al linux (192.168.1.1). Podría haberlo hecho manualmente desde la configuración del ATV pero prefiero hacerlo vía mi DHCP server:

  :
  subnet 192.168.1.0 netmask 255.255.255.0 {
    option routers 192.168.1.1;
    option subnet-mask 255.255.255.0;
    option domain-name "parchis.org";
    option domain-name-servers 192.168.1.1;
    option interface-mtu 1496;
  :
  host atv3 {
    hardware ethernet f4:f9:51:b7:6c:da;
    fixed-address atv3.parchis.org;
  }
  :

 

## iptables

Esto sí es importante. Para conseguir "no tocar casi nada" del equipo linux voy a ejecutar tres redirecciones. Básicamente todo lo que venga del Apple TV con destino puertos 80,443,53(udp) los redirigo. Este es el comando que ejecuto en mi equipo:

 
iptables -t nat -A PREROUTING -i vlan100 -s 192.168.1.37 -d 192.168.1.1/32 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1:9080
iptables -t nat -A PREROUTING -i vlan100 -s 192.168.1.37 -d 192.168.1.1/32 -p tcp --dport 443 -j DNAT --to-destination 192.168.1.1:9443
iptables -t nat -A PREROUTING -i vlan100 -s 192.168.1.37 -d 192.168.1.1/32 -p udp --dport 53 -j DNAT --to-destination 192.168.1.1:9053
 

 

## Instalación de PlexConnect

Descargo el ![software desde el proyecto PlexConnect en GitHub](/assets/img/original/PlexConnect), (uso el enlace que genera un fichero ZIP del repositorio){: width="730px" padding:10px } y lo descomprimo en /root/Plex

 
# mkdir /root/Plex
# cd /root/Plex
# wget https://github.com/iBaa/PlexConnect/archive/master.zip
# unzip master.zip
# mv PlexConnect-master PlexConnect
# rm master.zip
 

Ejecuto una vez el programa, que terminará con un error. Lo hago para que se cree el fichero de configuración. Nota: PlexConnect NO FUNCIONA con Python 3.x, así que uso la versión 2.7

 
# cd /root/Plex/PlexConnect
# EPYTHON="python2.7" ./PlexConnect.py
 

Preparo los ficheros de certificados (recuerdo que ![es importantísimo, no dejes de visitar esta página](/assets/img/original/)){: width="730px" padding:10px }

 
# ls -al assets/certificates/
total 24
drwxr-xr-x 2 root root 4096 ene 7 15:50 .
drwxr-xr-x 7 root root 4096 ene 5 19:08 ..
-rw-r--r-- 1 root root 921 ene 5 19:08 certificates.txt
-r-------- 1 root root 872 ene 7 15:50 trailers.cer
-r-------- 1 root root 1679 ene 7 15:50 trailers.key
-r-------- 1 root root 2916 ene 7 15:50 trailers.pem
 

Para facilitar los arranques futuros he creado un par de ficheros:

# /etc/conf.d/plexconnect
# Copyright 2014 LuisPa
# Distributed under the terms of the GNU General Public License v2

# Fichero donde se guarda el numero del proceso
PLEXCONNECT_PIDFILE="/run/plexconnect.pid"

# Ejecutable: Uso Python2 (asociado a la 2.7, version soportada por PlexConnect)
PLEXCONNECT_EXEC="/usr/bin/python2 /root/Plex/PlexConnect/PlexConnect.py"

# Directorio de trabajo
PLEXCONNECT_CWD="/root/Plex/PlexConnect"

# Opciones
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

Como en cualquier otro servicio, programo su ejecución durante el arranque del equipo:

 
# rc-update add plexconnect default
 

 

## Configuración de PlexConnect

Recomiendo una vez más leer ![la página de documentación del proyecto](https://github.com/iBaa/PlexConnect/wiki/Install-guides) y sobre todo cómo [seguir el proceso de generación de los certificados](/assets/img/original/){: width="730px" padding:10px }.

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

[PlexConnect]

# SECCION Log
# ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======
#
# Configuracion del Log. En esta seccion definimos donde se
# va a crear el fichero PlexConnect.log y el nivel del mismo
#
# logpath: Directorio donde se crea PlexConnect.log. En mi caso
# uso --chdir en /etc/init.d/plexconnect para que el CWD sea
# el mismo donde esta el programa, asi que especifico '.'
# para que el fichero resida en el mismo sitio
logpath = .
#
# loglevel: Nivel de Log. Recomiendo usar High al principio durante
# el setup, despues 'Normal' y finalmente 'Off' cuando todo
# funcione perfectamente. Opciones: 'Normal', 'High', 'Off'
loglevel = High

# SECCION Servicio WEB
# ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======
#
# Puerto por el que escucho peticiones HTTP
# Se arrancara un proceso adicional "WebServer" escuchando
# en este puerto.
port_webserver = 9080

# Servicio WEB: Definimos si vamos a arrancar un servidor HTTPS
# En mi caso hay que decir que si porque vamos a emular a
# los servidores web http y https de apple: trailers.apple.com
enable_webserver_ssl = True

# Puerto por el que escucho peticiones HTTPS
# Se arrancara un proceso adicinal "WebServer" escuchando
# en este puerto para atender las peticiones de "Trailers"
port_ssl = 9443
certfile = ./assets/certificates/trailers.pem

# SECCION Servicio DNS
# ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======
#
# Activar un DNS Server al ejecutar PlexConnect.py
# También lo activamos, para poder suplantar a trailers.apple.com
# tengo que actuar como dns server. Escucho en un puerto "raro", pero 
# es para no entrar en conflicto con el DNS server que ya tiene el linux
enable_dnsserver = True
#
# Puerto en el que escuchara a peticiones DNS (udp)
port_dnsserver = 9053
#
# Direccion IP del siguiente DNS Server, es decir, a quien
# redirigir todas las peticiones del ATV que no queramos modificar/suplantar
# En mi caso a mi propio DNS server que tengo en el linux y no he "tocado"
ip_dnsmaster = 192.168.1.1
# 
# Evitar que el ATV llame a casa y compruebe si hay algun update
prevent_atv_update = True

# Nombre del host a interceptar. Todas las peticiones 80/443 que vayan a él
# se redirigirán al linux en los puertos 9080/9443
hosttointercept = trailers.apple.com

# SECCION PlexConnect
# ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======
#
# Direccion IP donde se ejecuta PlexConnect. Evito autodetectarla, util si 
# tienes varias tarjetas de red y solo quieres que PlexConnect escuche en 
# un unica de sus tarjetas.
enable_plexconnect_autodetect = False
ip_plexconnect = 192.168.1.1

# SECCION PMS Plex Media Servier
# ====== ====== ====== ====== ====== ====== ====== ====== ====== ====== ======
#
# PlexConnect tiene que conocer donde esta el PMS. En mi caso, que solo tengo 
# un unico PMS, prefiero programas la IP manualmente
#
# No detecto los PMSs
enable_plexgdm = False

# IP Donde hay un PMS. En mi caso tambien esta en el mismo sistema Linux
ip_pms = 192.168.1.1

# Puerto donde escucha el PMS
port_pms = 32400

 

## Arranque del Servicio

Arrancamos con el comando: /etc/init.d/plexconnect start

 
# ps -ef |grep -i plexco
root 24054 1 1 16:49 ? 00:00:00 /usr/bin/python2 /root/Plex/PlexConnect/PlexConnect.py
root 24064 24054 0 16:49 ? 00:00:00 /usr/bin/python2 /root/Plex/PlexConnect/PlexConnect.py
root 24067 24054 0 16:49 ? 00:00:00 /usr/bin/python2 /root/Plex/PlexConnect/PlexConnect.py
root 24068 24054 0 16:49 ? 00:00:00 /usr/bin/python2 /root/Plex/PlexConnect/PlexConnect.py
 

En total debemos ver cuatro procesos, el principal "PlexConnect" que a su vez arranca un "DNS Server" escuchando en el puerto 9053, un "WebServer http" que escucha en el puerto 9080 y un segundo "WebServer https" que escucha en el puerto "9443".

Ya está, ahora ya puedes ir a tu Apple TV3 y hacer click en el icono Trailers.

![images_0_o](/assets/img/original/images_0_o.jpg){: width="730px" padding:10px }
