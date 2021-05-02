---
title: "Servicio horario NTP"
date: "2009-05-01"
categories: gentoo
tags: linux ntp
excerpt_separator: <!--more-->
---

![ntp-dali](/assets/img/posts/ntp-dali.jpg){: style="float:left; padding-right:10px" }

NTP es un protocolo de Internet para sincronizar los relojes de los sistemas informáticos conmutando paquetes de datos en redes con latencia variable. NTP utiliza el protocolo UDP como su capa de transporte (puerto `123`). Está diseñado para resistir a los efectos de la latencia variable.

En este apunte explico cómo configurar NTP en un equipo GNU/Linux (distribución Gentoo) para ajustar la hora y que se mantenga, a la vez que pueda hacer de servidor horario en tu red casera.

<br clear="left"/>
<!--more-->

# NTP + NTP-CLIENT

[La calidad de los relojes](http://www.ntp.org/ntpfaq/NTP-s-sw-clocks-quality.htm): El sistema mantendrá el reloj a través de técnicas software mientras que el servidor está arrancado, pero una vez que apagas el servidor, el reloj HW puede que se quede bastante desincronizado, esa es la razón por la que forzaré una sincronización del reloj durante el re-arranque del sistema.

Voy a ejecutar el daemon NTP como un servicio y lo ejecutaré con un usuario diferente a root. Para poder ejecutar ntp como un usuario diferente a root es necesario configurar lo siguiente en ciertas versiones del Kernel y activar el USE "caps".

```
Security options  --->
    [*] File POSIX Capabilities
```

NTP

```
net-misc/ntp                    ipv6 ssl zeroconf caps
```

Requerido por NTP

```
net-dns/avahi                   mdnsresponder-compat
```

### Instalación

Ejecuto la instalación de ntpd y ntpclient

```
# emerge -v ntp ntpclient
```

El programa ntpd tiene que ejecutarse como un servicio y el programa ntp-client tiene que ejecutarse durante el arranque. Si es la primera vez que vas a sincronizar, te recomiendo hacer lo siguiente: añade los servicios, cambia la hora con ntp-client (para ajustar el reloj software) y rearranca el equipo, para que se cambie el reloj hardware y luego se arranquen ntpd de forma normal.

### Ejecución con openrc

Configuro los ficheros de apoyo. El daemon ntpd utiliza por defecto el fichero /etc/ntp.conf

```
#
# Equipos que me dan la hora
server 0.gentoo.pool.ntp.org
server 1.gentoo.pool.ntp.org
server 2.gentoo.pool.ntp.org
server 3.gentoo.pool.ntp.org
#
# Equipo que me da la hora en caso de caida de internet, uso mi reloj hardware
server 127.0.0.1
fudge 127.0.0.1 stratum 10
#
# Interfaces en las que voy a servir la hora
interface ignore wildcard
interface listen 127.0.0.1
interface listen 192.168.1.1
#
# Ficheros de trabajo
logfile         /var/log/ntpd.log
driftfile   /var/lib/ntp/ntp.drift
#
# Restricciones, trabajo sin peers y solo doy la hora en loopback e intranet
restrict default nomodify nopeer
restrict 127.0.0.1
restrict 192.168.1.0 mask 255.255.255.0 nomodify nopeer notrap

NTPD_OPTS="-u ntp:ntp"

NTPCLIENT_CMD="ntpdate"
NTPCLIENT_OPTS="-s -b -u \
    0.gentoo.pool.ntp.org 1.gentoo.pool.ntp.org \
    2.gentoo.pool.ntp.org 3.gentoo.pool.ntp.org"

CLOCK_SYSTOHC="yes"
```

Activación

```
# rc-update add ntpd default
# rc-update add ntp-client default
:
# /etc/init.d/ntp-client start
:
# reboot
```

### Ejecución con systemd

Configuro los ficheros de apoyo. El daemon ntpd utiliza por defecto el fichero `/etc/ntp.conf` pero en mi caso he preferido cambiarle el nombre. NOTA: Esto es una decisión personal porque creo que tiene más sentido añadir la "d" de daemon, así que recordar que he cambiado el nombre del fichero de configuración a `/etc/ntpd.conf` e indicaré al ejecutable que lo utilice en el fichero ntpd.service.

```
#
# Equipos que me dan la hora
server 0.gentoo.pool.ntp.org
server 1.gentoo.pool.ntp.org
server 2.gentoo.pool.ntp.org
server 3.gentoo.pool.ntp.org
#
# Equipo que me da la hora en caso de caida de internet, uso mi reloj hardware
server 127.0.0.1
fudge 127.0.0.1 stratum 10
#
# Interfaces en las que voy a servir la hora
interface ignore wildcard
interface listen 127.0.0.1
interface listen 192.168.1.1
#
# Ficheros de trabajo
logfile         /var/log/ntpd.log
driftfile   /var/lib/ntp/ntp.drift
#
# Restricciones, trabajo sin peers y solo doy la hora en loopback e intranet
restrict default nomodify nopeer
restrict 127.0.0.1
restrict 192.168.1.0 mask 255.255.255.0 nomodify nopeer notrap

NTPD_OPTS="-c /etc/ntpd.conf -g -u ntp:ntp"

NTPCLIENT_OPTS="-s -b -u \
    0.gentoo.pool.ntp.org 1.gentoo.pool.ntp.org \
    2.gentoo.pool.ntp.org 3.gentoo.pool.ntp.org"
```

Programo el reloj y deshabilito el cliente NTP que trae systemd.

```
cortafuegix ~ # timedatectl set-local-rtc 0
cortafuegix ~ # timedatectl set-timezone Europe/Madrid
cortafuegix ~ # timedatectl set-time "2012-10-30 18:17:16" <= Ponerlo primero en hora.
cortafuegix ~ # timedatectl set-ntp false
```

Configuro los .service de ntp y ntp-client

```
[Unit]
Description=Network Time Service
After=ntp-client.service
Conflicts=systemd-timesyncd.service

[Service]
ExecStart=/usr/sbin/ntpd -c /etc/ntpd.conf -g -n -u ntp:ntp
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

```
[Unit]
Description=Set time via NTP using ntpdate
After=network-online.target nss-lookup.target
Before=time-sync.target
Wants=time-sync.target
Conflicts=systemd-timesyncd.service

[Service]
Type=oneshot
EnvironmentFile=/etc/conf.d/ntp-client
ExecStart=/usr/sbin/ntpdate $NTPCLIENT_OPTS
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Habilito el servicio

```
# systemctl enable ntp-client
# systemctl enable ntpd
:
# reboot
```

### Gestión de NTPD

Puede llegar a tardar hasta 4 horas calibrar el reloj antes de llegar al estado correcto de Stratum (dado que estás sincronzando con servidores stratum 2, tu estado debería ser de stratum 3). De hecho la razón por la que ejecuto ntp-client (antes que ntpd) es para poner el equipo en hora y que este proceso sea más rápido. Cuando ntpd arranque y vea que la hora del equipo coincide con la de sus servidores, tardará muy poco en sincronizar. Si el estado no ha cambiado tras un rato es que algo está fallando. Lo correcto es que diga que es "stratum=3"

```
$ ntpq -c readvar
assID=0 status=06f4 leap_none, sync_ntp, 15 events, event_peer/strat_chg,
version="ntpd 4.2.4p7@1.1607-o lun ago 17 07:38:15 UTC 2009 (1)",
processor="x86_64", system="Linux/2.6.30-gentoo-r4", leap=00, stratum=3,        <=====
precision=-20, rootdelay=81.469, rootdispersion=176.829, peer=59651,
refid=147.83.175.41,
reftime=ce33fdf3.a893739b  Mon, Aug 17 2009 18:04:03.658, poll=6,
clock=ce33fe7e.4d15c9c5  Mon, Aug 17 2009 18:06:22.301, state=4,
offset=-46.921, frequency=11.491, jitter=79.033, noise=3.260,
stability=0.876, tai=0
```

Si después de una horas tu servidor sigue en stratum 16 entonces es que algo está fallando. Mira [esta guía](https://support.ntp.org/bin/view/Support/TroubleshootingNTP). Puedes comprobar contra qué servidores estás conectados

```zsh
$ ntpq -c peers
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
-clip.dia.fi.upm 193.204.114.232  2 u    5   64  377   45.026  -44.194  71.461
+matillas.uc3m.e 194.117.9.130    3 u   57   64  377   44.340  -46.080   2.409
+alertas.efor.es 193.79.237.14    2 u    1   64  377   64.722  -47.021  64.068
*abridoc.upc.es  158.227.98.15    2 u   50   64  377   58.230  -48.697  79.016
```

## OpenNTP

A continuación muestro un ejemplo de configuración para varios equipos Linux con systemd. He configurado dos como Servidores NTP con "OpenNTPD" y el resto usarán el cliente embebido en systemd.

### Servidores con Openntpd

OpenNTPD es una versión ligera del servidor NTP que se ha portado desde OpenBSD. Configuro dos equipos como servidores: cortafuegix y apodix.

- Instalación

```
root #emerge --ask net-misc/openntpd
```

### Configuración como Daemon

- Programo el reloj y deshabilito el cliente NTP que trae systemd

```
cortafuegix ~ # timedatectl set-local-rtc 0
cortafuegix ~ # timedatectl set-timezone Europe/Madrid
cortafuegix ~ # timedatectl set-time "2012-10-30 18:17:16" <= Ponerlo primero en hora.
cortafuegix ~ # timedatectl set-ntp false
```

- Configuro el fichero para que actúe como servidor

```
# Configuración como Servidor NTP
listen on *

# Sincronizo con los servidores del pool ntp
servers 0.gentoo.pool.ntp.org
servers 1.gentoo.pool.ntp.org
servers 2.gentoo.pool.ntp.org
servers 3.gentoo.pool.ntp.org
```

- Programo el daemon para que arranque en el siguiente boot y lo activo

```
cortafuegix ~ # systemctl enable ntpd
cortafuegix ~ # systemctl start ntpd
:
cortafuegix ~ # timedatectl
      Local time: sáb 2015-05-30 08:22:51 CEST
  Universal time: sáb 2015-05-30 06:22:51 UTC
        RTC time: sáb 2015-05-30 06:22:51
       Time zone: Europe/Madrid (CEST, +0200)
     NTP enabled: no                           <== En el Servidor aparece como "NO"
NTP synchronized: yes                          <== En el Servidor aparece como "yes"
 RTC in local TZ: no
      DST active: yes
 Last DST change: DST began at
                  dom 2015-03-29 01:59:59 CET
                  dom 2015-03-29 03:00:00 CEST
 Next DST change: DST ends (the clock jumps one hour backwards) at
                  dom 2015-10-25 02:59:59 CEST
                  dom 2015-10-25 02:00:00 CET
```

## Cliente con systemd-timesyncd

Para los equipos cliente utilizo el que incluye systemd

```
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.
#
# You can override the directives in this file by creating files in
# /etc/systemd/timesyncd.conf.d/*.conf.
#
# See timesyncd.conf(5) for details

[Time]
NTP=cortafuegix.parchis.org apodix.parchis.org
FallbackNTP=0.gentoo.pool.ntp.org 1.gentoo.pool.ntp.org 2.gentoo.pool.ntp.org 3.gentoo.pool.ntp.org
```

- Programo el reloj y deshabilito el cliente NTP que trae systemd

```
gentoo ~ # timedatectl set-local-rtc 0
gentoo ~ # timedatectl set-timezone Europe/Madrid
gentoo ~ # timedatectl set-time "2012-10-30 18:17:16" <= Ponerlo primero en hora.
gentoo ~ # timedatectl set-ntp true
:
gentoo ~ # timedatectl
      Local time: sáb 2015-05-30 08:22:29 CEST
  Universal time: sáb 2015-05-30 06:22:29 UTC
        RTC time: sáb 2015-05-30 06:22:30
       Time zone: Europe/Madrid (CEST, +0200)
     NTP enabled: yes                           <== En los Clientes aparece como "YES"
NTP synchronized: no                            <== En los Clientes aparece como "NO"
 RTC in local TZ: no
      DST active: yes
 Last DST change: DST began at
                  dom 2015-03-29 01:59:59 CET
                  dom 2015-03-29 03:00:00 CEST
 Next DST change: DST ends (the clock jumps one hour backwards) at
                  dom 2015-10-25 02:59:59 CEST
                  dom 2015-10-25 02:00:00 CET
```

