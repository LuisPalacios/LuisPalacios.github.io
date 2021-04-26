---
title: "AFP en Gentoo Linux"
date: "2012-11-15"
categories: 
  - "apuntes"
tags: 
  - "afp"
  - "linux"
---

Para poder compartir los discos de mi [servidor Mac Mini corriendo Gentoo Linux](https://www.luispa.com/?p=477) con equipos clientes Mac OS X en la red casera, el protocolo que voy a utilizar es el Apple´s Filing Protocol (AFP). Para implementar dicho protocolo hay que usar el paquete [Netatalk, una implementación open source del fileserver AFP](http://netatalk.sourceforge.net). El protocolo AFP puede funcionar tanto encima de TCP como de AppleTalk, en mi caso obviamente solo lo hará con TCP.

Empezamos con la instalación en Gentoo

 
# emerge -v netatalk
:
\[ebuild N \] net-fs/netatalk-3.0.5-r1 USE="acl avahi cracklib pam samba shadow ssl tcpd utils -debug -kerberos -ldap -pgp -quota -static-libs" PYTHON\_TARGETS="python2\_7 -python2\_6" 1,674 kB
 

A continuación preparo el fichero de configuración y activo sólo lo que necesito. Notar que desde la versión 3.0 solo hay que modificar el fichero /etc/afp.conf.

En mi caso voy a compartir un [file system HFS+](https://www.luispa.com/?p=498) dentro de un [disco FireWire](https://www.luispa.com/?p=484) mediante sistema de ficheros AFP, todo "muy apple" :-)

; Global server settings
\[Global\]
vol preset = default\_for\_all\_vol
log file = /var/log/netatalk.log
uam list = uams\_dhx.so,uams\_dhx2.so
save password = no

; Aplicable a todos los volumenes
\[default\_for\_all\_vol\]
file perm = 0664
directory perm = 0774
; Base de datos para guardar los ID's de de
; los directorios y ficheros. Recomendado dbd
cnid scheme = dbd
valid users = luis

; Exporto "despensa"
\[Despensa\]
path = /mnt/despensa
valid users = luis
host allow = 192.168.1.4

**Preparar los permisos del File System HFS+**

En mi caso voy a exportar via AFP un filesystem HFS+ (que fue creado en tiempos en un iMac) desde mi linux, por lo tanto antes de hacerlo es necesario entender bien el tema de permisos.

Voy a cambiar al owner:group de todos los ficheros de /mnt/despensa/\* (partición HFS+) para que el propietario sea un usuario del "linux". Recordemos que este disco viene de un antiguo iMac donde el owner:group era 501:20, lo que hago es un find para cambiarlo:

 
# find . -uid 501 -exec chown luis:luis {} \\;
 

Ahora ya puedo arrancar el servicio

 
# /etc/init.d/netatalk start
 

Y desde un mac cliente conectar con el disco. Al hacerlo debo introducir el nombre de usuario y contraseña del equipo linux.

[![afp](https://www.luispa.com/wp-content/uploads/2014/12/afp.png)](https://www.luispa.com/wp-content/uploads/2014/12/afp.png)
