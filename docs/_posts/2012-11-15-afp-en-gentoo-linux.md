---
title: "AFP en Gentoo Linux"
date: "2012-11-15"
categories: apuntes
tags: afp linux
excerpt_separator: <!--more-->
---

![Apple AFP](/assets/img/post/AppleAFP.svg){: width="150px" style="float:left; padding-right:10px" } 

Para poder compartir los discos de mi servidor Gentoo Linux con equipos Mac OS X en la red casera, el protocolo que voy a utilicé durante el 2012 fue el Apple Filling Protocol (AFP). Más adelante Apple empezó a recomendar SMB. 

<br clear="left"/>
<!--more-->

Para implementar dicho protocolo hay que usar el paquete [Netatalk](https://netatalk.sourceforge.net), una implementación open source del fileserver AFP. El protocolo AFP puede funcionar tanto encima de TCP como de AppleTalk, en mi caso obviamente solo lo hará con TCP.

### Instalación en Gentoo

``` 
# emerge -v netatalk
:
[ebuild N ] net-fs/netatalk-3.0.5-r1 USE="acl avahi cracklib pam samba shadow ssl tcpd utils -debug -kerberos -ldap -pgp -quota -static-libs" PYTHON_TARGETS="python2_7 -python2_6" 1,674 kB
```

A continuación preparo el fichero de configuración y activo sólo lo que necesito. Notar que desde la versión 3.0 solo hay que modificar el fichero /etc/afp.conf.

En mi caso voy a compartir un file system HFS+ dentro de un disco FireWire  mediante sistema de ficheros AFP, todo "muy apple" :-).

```
; Global server settings
[Global]
vol preset = default_for_all_vol
log file = /var/log/netatalk.log
uam list = uams_dhx.so,uams_dhx2.so
save password = no

; Aplicable a todos los volumenes
[default_for_all_vol]
file perm = 0664
directory perm = 0774
; Base de datos para guardar los ID's de de
; los directorios y ficheros. Recomendado dbd
cnid scheme = dbd
valid users = luis

; Exporto "despensa"
[Despensa]
path = /mnt/despensa
valid users = luis
host allow = 192.168.1.4
````

### Permisos del File System HFS+

En mi caso voy a exportar via AFP un filesystem HFS+ (que fue creado en tiempos en un iMac) desde mi linux, por lo tanto antes de hacerlo es necesario entender bien el tema de permisos.

Voy a cambiar al owner:group de todos los ficheros de `/mnt/despensa/*`(partición HFS+) para que el propietario sea un usuario del "linux". Recordemos que este disco viene de un antiguo iMac donde el owner:group era 501:20, lo que hago es un find para cambiarlo:

```
# find . -uid 501 -exec chown luis:luis {} \;
``` 

Ahora ya puedo arrancar el servicio

``` 
# /etc/init.d/netatalk start
```

Y desde un mac cliente conectar con el disco. Al hacerlo debo introducir el nombre de usuario y contraseña del equipo linux.

<!-- 
{:refdef: style="text-align: center;"}
![afp](/assets/img/original/afp.png){: width="300px" } 
{: refdef}
 -->

| *Acceso desde Finder* |
|:--:| 
| ![Acceso desde Finder](/assets/img/original/afp.png){: width="400px" } | 
