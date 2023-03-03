---
title: "Bridge Ethernet"
date: "2014-10-19"
categories: linux
tags: movistar router cone nat iptables television
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-bridge-eth.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Pruebas de concepto para extender la red de mi casa a un sitio remoto a través de internet y poder consumir los servicios de IPTV de Movistar. Voy a usar dos Raspberry Pi, una en casa sirviendo dos túneles (datos e IPTV) y otra en remoto conectándose a ellos a través de Internet. 

Más info en los apuntes: [Router Linux para Movistar]({% post_url 2014-10-05-router-linux %}) y [videos bajo demanda]({% post_url 2014-10-18-movistar-bajo-demanda %}) con Fullcone NAT en linux. Aunque a nivel de rendimiento debaja mucho que desear, con la [Pi 4]({% post_url 2021-10-19-raspberry-pi-os %}) seguro que funcionaría mejor.

<br clear="left"/>
<!--more-->

## Punto de partida

Este es el Hardware que he utilizado:

- **2 x Raspberry Pi**
  - Para esta prueba de concepto voy a llamar `norte` al equipo que tiene el contrato Movistar y `sur` al equipo remoto.
- **2 x Dongle USB Ethernet** para ser más granular y poder hacer más virguerías a nivel de routing, policy based routing, control de tráfico, etc.
- **1 x Switch** con soporte de VLAN's e IGMP Snooping para la LAN del equipo remoto.

Entre ambas Pi's creo dos túneles que irán por puertos `udp` diferentes:

- 1) **Access Server** para tráfico normal de Internet. Lo montaré con [OpenVPN](https://openvpn.net) y UDP. El que hace de *Servidor* es `norte` y el *Cliente* (llama a casa) es `sur`.

- 2) **Bridge Ethernet** para tráfico IPTV. De nuevo usando [OpenVPN](https://openvpn.net) y UDP. El que hace de *Servidor* es `norte` y el *Cliente* (llama a casa) es `sur`.

El título del apunte es **Bridge Ethernet** porque fue lo que más me costo configurar, hay poca documentación y conmutar multicast por internet no es obvio. De todas formas no solo describo esa función sino que veremos más casos de uso, voy a crear **tres VLANs** que van a permitir:

- VLAN 6
  - Conectar clientes de `sur` que quiero que salgan a Internet a través de la conexión de `norte`, así hago pruebas de **routing** y si es necesario de **policy based routing**
- VLAN 2
  - Conectar Deco en `sur` para que consuma el tráfico IPTV de `norte`, para hacer pruebas de **conmutación de tráfico multicast por túneles encriptados** y el uso de **filtros de nivel 2**
- VLAN 100
  - Conectar clientes de `sur` que quiero que salgan a Internet a través del contrato de `sur`. Esta es quizá la opción más sencilla pero veremos cómo configurar **Source NAT (o masquerade)**.
  
{% include showImagen.html
    src="/assets/img/posts/2014-10-19-bridge-ethernet-01.jpg"
    caption="Arquitectura de la prueba de concepto"
    width="600px"
    %}

<br />

### Software necesario

**Ejecuto lo siguiente en ambas Pi's !!!**

Me convierto en `root`

```console
$ sudo su -i
#
```

Primero actualizo.

```console
# apt update && apt upgrade -y && apt full-upgrade -y
# apt autoremove -y --purge
```

Aprovecho para limitar el log a pocos días :-)

```console
# journalctl --vacuum-time=15d
# journalctl --vacuum-size=500M
```

Verifico que el timezone es correcto y la hora se está sincronizando bien. 

```console
# dpkg -l | grep -i tzdata
ii  tzdata      2021a-1+deb11u8       all        time zone and daylight-saving time data
# date
vie 03 mar 2023 11:05:46 CET
# timedatectl
               Local time: vie 2023-03-03 11:05:49 CET
           Universal time: vie 2023-03-03 10:05:49 UTC
                 RTC time: n/a
                Time zone: Europe/Madrid (CET, +0100)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```

Lo tengo bien, **Europe/Madrid**, si no fuese el caso tendría que corregirlo con `apt -y install --reinstall tzdata` y `dpkg-reconfigure tzdata`

Instalo OpenVPN, Bridge Utils y algunas herramientas importantes.

```console
# apt -y install openvpn unzip bridge-utils igmpproxy dnsutils tcpdump ebtables
```

Preparo el directorio de trabajo de **easy-rsa**

```console
# cp -a /usr/share/easy-rsa /etc/openvpn/easy-rsa
```

<br />

### Configuración de "norte"

Sección dedicada al servidor `norte`, que si recordamos es el que está en mi casa y que conectaremos físicamente al router de Movistar en 2 puertos. 


