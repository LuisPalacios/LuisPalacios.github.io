---
title: "Cross compilar para ARMv7"
date: "2015-05-23"
categories: apuntes
tags: cisco hiperconvergencia ucs
excerpt_separator: <!--more-->
---

## Introducción

El objetivo de este apunte es describir cómo montar un entorno de cross-compilación, de tal forma que desde un equipo con procesador Intel i5 pueda generar ejecutables para ARMv7. Tengo 2 casos de uso muy concretos: 1) **reducir los tiempos de compilación de ![una Raspberry Pi2](https://www.luispa.com/?p=3128)** (**ARMv5 Processor rev 5 (v7l)**) **que ya tiene Gentoo instalado** y 2) poder compilar un programa muy concreto (tvheadend) para mi [servidor de Streaming IPTV casero](/assets/img/original/?p=2647) (MOI Pro con ARMv7 Processor rev 10 (v7l) que venía con un linux a medida){: width="730px" padding:10px }

Si recapitulamos, voy a tener lo siguiente:

- ![PI2 con Gentoo Linux](/assets/img/original/?p=3128) (ARMv7){: width="730px" padding:10px }.
- ![Servidor de Streaming IPTV casero](/assets/img/original/?p=2647) (MOIPro ARMv7){: width="730px" padding:10px }
- Equipo Intel i5 con Linux Gentoo al que llamaré "**BUILD SERVER**".

 

Parto de una situación donde ya tengo los tres equipos instalados y voy a realizar cambios en la configuración para que funcione la cross compilación.

### DISTCC en Pi2 y en Build Server

Asumo que ya tengo los equipos funcionando. Diste es una herramienta que permite distribuir tareas de compilación entre varias máquinas de la red. EN mi caso voy a tener 2 equipos participando la Pi2i y el build server (intel). Nota: es importante que todas las máquinas en la red tengan la misma versión de GCC. Instalo distcc en ambos equipos:

# cat /etc/portage/package.use/crosscompilar
sys-devel/distcc gtk crossdev

# emerge -v distcc

Arranque del daemon vía systemd

# cat /etc/systemd/system/distccd.service.d/00gentoo.conf
[Service]
Environment="ALLOWED_SERVERS=192.168.1.0/24"

# systemctl daemon-reload
# systemctl enable distccd
# systemctl start distccd

Configuración de equipos participantes

### En el Build Server

Configurar Hosts que participan en la compilación distribuida (/etc/distcc/hosts)

- Build server: distcc-config --set-hosts "127.0.0.1 192.168.100.3"

### En la Pi2

Configurar Hosts que participan en la compilación distribuida (/etc/distcc/hosts)

- Pi2:  distcc-config --set-hosts "192.168.100.3"

Decirle a Portage que use distcc: `/etc/portage/make.conf`

FEATURES="distcc"

 

 

Convierto el fichero cortafuegix.qcow2 a RAW (tarda ~ 1min 15seg) - **Paso 1** en el gráfico.

### Tips

Interesante lectura tras hace r el emerge de distcc

* * Tips on using distcc with Gentoo can be found at
 * https://wiki.gentoo.org/wiki/Distcc
 *
 * How to use pump mode with Gentoo:
 * # distcc-config --set-hosts "foo,cpp,lzo bar,cpp,lzo baz,cpp,lzo"
 * # echo 'FEATURES="${FEATURES} distcc distcc-pump"' >> /etc/portage/make.conf
 * # emerge -u world
 *
 * To use the distccmon programs with Gentoo you should use this command:
 * # DISTCC_DIR="/var/tmp/portage/.distcc" distccmon-text 5
 * Or:
 * # DISTCC_DIR="/var/tmp/portage/.distcc" distccmon-gnome

 

Habilitar el auto arranque de distcc y a continuación arrancar el servicio:
