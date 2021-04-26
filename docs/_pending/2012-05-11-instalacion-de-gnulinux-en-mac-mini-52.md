---
title: "Instalación de GNU/Linux en Mac Mini 5,2"
date: "2012-05-11"
categories: 
  - "apuntes"
tags: 
  - "linux"
  - "mac"
  - "mini"
---

Este proyecto trata sobre cómo instalar Linux en un Mac Mini 5,2 con Intel E5 y 4GB de memoria RAM para usarlo como router casero, con algunos servicios adicionales, web, correo, firewall, etc.

Aviso: Siempre hay que poner este tipo de avisos, así que ahí va!... Esto es un ejemplo de la instalación en mi equipo, que va a funcionar con varios servicios, considéralo un ejemplo. No me culpes de nada si usas esta configuración y no te funciona o tienes problemas, considera esto como una referencia que espero te ayude. Eso sí, te recomiendo que además leas la [documentación oficial](http://www.gentoo.org/doc/es/handbook/) y por supuesto [visites los foros](http://forums.gentoo.org/).

[![macmini52_2_o](https://www.luispa.com/wp-content/uploads/2014/12/macmini52_2_o.jpg)](https://www.luispa.com/wp-content/uploads/2014/12/macmini52_2_o.jpg)

**Diseño**

- El diseño que voy a utilizar es el que se describe en el siguiente gráfico. El equipo ejecutará PPP y recibirá la IP pública directamente (el router Comtrend lo configuro en modo bridge). El Mac tendrá funciones de firewall, dns, dhcp server, etc. Para poder conseguir todo esto de forma más o menos segura es necesario usar VLAN's, dado que el equipo sólo cuenta con una única tarjeta Ethernet.

[![macminidesign_0_o](https://www.luispa.com/wp-content/uploads/2014/12/macminidesign_0_o.jpg)](https://www.luispa.com/wp-content/uploads/2014/12/macminidesign_0_o.jpg)

- Esa es la razón por la que empleo un pequeño switch Linksys que soporta varias vlans y resuelve el problema. Mäs adelante, en el punto (3) Configuración describo como se configura en Linux este setup.

 

En [este enlace](http://wiki.luispa.com/index.php/HowTo:gentooMacMini52) encontrarás una wiki donde documenté más en detalle los siguientes contenidos:

**Instalación**

El proceso de instalación es sencillo excepto la creación de un USB bootable para Mac Intel. Esto me costó lo suyo, hasta que encontré una herramienta (mkisohybrid) que lo soluciona

Preparar el Hardware Mac Mini 5,2 USB bootable con Linux para Mac Mini 5,2 Instalación de Linux Gentoo en un Mac Mini 5,2

**Mantenimiento** periódico

Una vez que he terminado con el punto 2 y antes de seguir describiendo más instalaciones y configuraciones es importante tener en cuenta qué trabajo diario o semanal o mensual de mantenimiento debe hacerse con el equipo.

Mantenimiento periódico Recompilar el Kernel

**Configuración**

En la wiki verás documentado la instalación posterior de software y/o configuración de las mismas.

Editor Emacs Video Xorg X11 Monitorización del hardware Configurar la Red, Firewall, DNS, DHCP Podrás encontrar múltiples artículos sobre configuraciones concretas de servicios, aplicaciones, módulos, programas a partir de este enlace, se trata de la documentación original de la instalación de un sistema clónico. La mayoría de los artículos te van a servir.
