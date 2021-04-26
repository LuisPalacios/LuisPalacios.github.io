---
title: "Activar Conntrack en Linux"
date: "2014-10-19"
categories: 
  - "gentoo"
tags: 
  - "firewall"
  - "iptables"
  - "linux"
  - "seguridad"
---

[![Apps-Firewall-icon](https://www.luispa.com/wp-content/uploads/2014/12/Apps-Firewall-icon-300x300.png)](https://www.luispa.com/wp-content/uploads/2014/12/Apps-Firewall-icon.png)

## ¿Qué es Netfilter/iptables?

[Netfilter/iptables](http://es.wikipedia.org/wiki/Netfilter/iptables) es un framework disponible en el kernel Linux que permite inspeccionar y manipular paquetes de red. Puede hacerlo en diferentes puntos y/o estados durante su viaje por el nucleo. También se encarga de ofrecer herramientas libres para montarte un Firewall basado en Linux.

## ¿Qué es Conntrack?

El "Connection Tracking System" son los módulos del kernel que habilitan el "stateful packet inspection" para iptables

Durante mucho tiempo se usaron en los firewalls políticas de filtrado basándose en la información de la cabecera de los paquetes, pero eso ha quedado obsoleto. Hoy en día los Firewalls necesitan mecanismos avanzados para hacer una inspección profunda basándose en el estado de las conexiones.

Netfilter/iptables incorpora una implementación de un sistema basado en estados y de seguimiento de las conexiones (connection tracking system) que habilita el subsistema para poder hacer un "stateful firewall" basado en el Kernel de Linux. Recomiendo leer este [artículo de Pablo Neira](http://people.netfilter.org/pablo/docs/login.pdf) al respecto.

La activación de "Conntrack" en tu kernel necesita como mínimo lo siguiente (notar que aquí lo cargo como módulos)

 
CONFIG\_NF\_CONNTRACK=m
CONFIG\_NF\_CONNTRACK\_IPV4=m
CONFIG\_NF\_CONNTRACK\_IPV6=m (si usas IPv6)
CONFIG\_NETFILTER\_NETLINK=m (interfaz genérico para Netfilter)
CONFIG\_NF\_CT\_NETLINK=m (interfaz de mensajes para el Connection Tracking System)
CONFIG\_NF\_CONNTRACK\_EVENTS=y  (connection tracking event notification API)
 

### contrack-tools

Además del soporte en el Kernel, también recomiendo instalar las conntrack-tools, un conjunto de herramientas para GNU/Linux que permiten interactuar con este subsistema del kernel "Connection Tracking System". La instalación en Gentoo es sencilla

 
# emerge -v conntrack-tools
 

Un ejemplo de "caso de uso" donde empleo esta tecnología está descrito en el artículo "[Movistar TV: video bajo demanda con router Linux](https://www.luispa.com/?p=378)"
