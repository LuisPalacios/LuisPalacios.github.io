---
title: "MacOSX: Monitorizar la red con PeakHour"
date: "2014-01-24"
categories: apuntes
tags: macosx peakhour snmp
excerpt_separator: <!--more-->
---

![Plex](/assets/img/original/2014-01-2408-54-36_0_o.png){: width="150px" style="float:left; padding-right:25px" } 

Hace no mucho me encontré con PeakHour, una herramienta que vive en la barra de menú, con un look & feel muy agradable capaz de visualizar el tráfico de la red de tu casa en tiempo real. Para conseguirlo utiliza el protocolo SNMP, vas dando de alta todos los dispositivos que soportan dicho protocolo y los irá interrogando en serie y mostrando el tráfico que pasa por ellos.

<br clear="left"/>
<!--more-->

## Monitorizar la Red

Mi caso de uso es proporcionarme un vistazo instantáneo de la actividad de la red de mi casa. Como decía, aunque no todos soportan SNMP basta con tenerlo configurado en los Access Points y el Router para que se convierta en ideal para el control de la conexión a Internet o Wi-Fi, puede ayudar a determinar cuánto ancho de banda de los equipos y dispositivos están utilizando en un momento dado.

 

Estos son los sitios habituales donde activar SNMP

* Switches y Puntos de Acceso

Cada uno tendrá su método de configuración, lo único que tienes que hacer es "activar SNMP y modo lectura" con la community (contraseña) que desees (la típica es "public") para poder consultarlos.

* Equipos Apple con MacOSX

Para activar SNMP en un MacOSX solo tienes que hacer lo siguiente: Abre una shell con Terminal.app y como root crea el fichero `snmpd.conf`

```console
$ su - 
# cp /etc/snmp/snmpd.conf.default /etc/snmp/snmpd.conf
```

Modifica el fichero  `snmpd.conf`, estas dos entradas (pon la dirección de red que corresponda en tu caso)

```config
com2sec my network 192.168.1/24 public
rocommunity public
```

A continuación le decimos al MacOSX que arranque el servicio SNMPD de forma permanente

```console
# launchctl load -w /System/Library/LaunchDaemons/org.net-snmp.snmpd.plist
```

* Equipos Linux

En mi caso uso la distribución Gentoo, asi que estos son los pasos que he realizado para instalar snmp y configurarlo

```console
$ su - 
# emerge -v mysql
# emerge -v net-snmp
``` 

Modifico el fichero de configuración, a continuación muestro un ejemplo muy básico, lo mínimo necesario para que funcione

```config
agentAddress  udp:127.0.0.1:161
agentAddress  udp:192.168.1.245:161
view   systemonly  included   .1.3.6.1.2.1.1
view   systemonly  included   .1.3.6.1.2.1.25.1
 rocommunity public  default  #  -V systemonly
 rouser   authOnlyUser
sysLocation    En el baul de los recuerdos
sysContact     Me sysServices    72
proc  mountd
proc  ntalkd    4
proc  sendmail 10 1
disk       /     10000
disk       /var  5%
includeAllDisks  10%
load   12 10 5
 trapsink     localhost public
iquerySecName   internalUser
rouser          internalUser
defaultMonitors          yes
linkUpDownNotifications  yes
 extend    test1   /bin/echo  Hello, world!
 extend-sh test2   echo Hello, world! ; echo Hi there ; exit 35
 master          agentx 
```

Activo el servicio y configuro que arranque siempre al hacer boot

```console
# rc-update add snmpd default
# /etc/init.d/net-snmp start
``` 

* Troubleshooting

Si tienes problemas con el servicio, bien porque no arranca o bien porque deseas saber qué está haciendo, puedes ejecutar el daemon en un terminal y "ver" todo lo que hace con el comando siguiente:

```console
# snmpd -Le -V -f
```
