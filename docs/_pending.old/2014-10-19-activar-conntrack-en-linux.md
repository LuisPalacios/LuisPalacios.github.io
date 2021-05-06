---
title: "Activar Conntrack en Linux"
date: "2014-10-19"
categories: gentoo
tags: firewall iptables linux seguridad
excerpt_separator: <!--more-->
---

![Apps-Firewall-icon](/assets/img/original/Apps-Firewall-icon-300x300.png){: width="730px" padding:10px }

## ¿Qué es Netfilter/iptables?

![Netfilter/iptables](/assets/img/original/iptables){: width="730px" padding:10px } es un framework disponible en el kernel Linux que permite inspeccionar y manipular paquetes de red. Puede hacerlo en diferentes puntos y/o estados durante su viaje por el nucleo. También se encarga de ofrecer herramientas libres para montarte un Firewall basado en Linux.

## ¿Qué es Conntrack?

El "Connection Tracking System" son los módulos del kernel que habilitan el "stateful packet inspection" para iptables

Durante mucho tiempo se usaron en los firewalls políticas de filtrado basándose en la información de la cabecera de los paquetes, pero eso ha quedado obsoleto. Hoy en día los Firewalls necesitan mecanismos avanzados para hacer una inspección profunda basándose en el estado de las conexiones.

Netfilter/iptables incorpora una implementación de un sistema basado en estados y de seguimiento de las conexiones (connection tracking system) que habilita el subsistema para poder hacer un "stateful firewall" basado en el Kernel de Linux. Recomiendo leer este ![artículo de Pablo Neira](/assets/img/original/login.pdf){: width="730px" padding:10px } al respecto.

La activación de "Conntrack" en tu kernel necesita como mínimo lo siguiente (notar que aquí lo cargo como módulos)

 
CONFIG_NF_CONNTRACK=m
CONFIG_NF_CONNTRACK_IPV4=m
CONFIG_NF_CONNTRACK_IPV6=m (si usas IPv6)
CONFIG_NETFILTER_NETLINK=m (interfaz genérico para Netfilter)
CONFIG_NF_CT_NETLINK=m (interfaz de mensajes para el Connection Tracking System)
CONFIG_NF_CONNTRACK_EVENTS=y  (connection tracking event notification API)
 

### contrack-tools

Además del soporte en el Kernel, también recomiendo instalar las conntrack-tools, un conjunto de herramientas para GNU/Linux que permiten interactuar con este subsistema del kernel "Connection Tracking System". La instalación en Gentoo es sencilla

 
# emerge -v conntrack-tools
 

![Movistar TV: video bajo demanda con router Linux](/assets/img/original/?p=378){: width="730px" padding:10px }"
