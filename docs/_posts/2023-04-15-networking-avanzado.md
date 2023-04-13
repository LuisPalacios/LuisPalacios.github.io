---
title: "Networking casero avanzado"
date: "2023-04-13"
categories: administración
tags: linux pve proxmox kvm qemu cloud-init alpine debian ubuntu plantilla virtualización
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-homenet.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Describo el **nerworking (L2/IP)** que utilizo para mantener un hogar inteligente y automatizado. En el futuro verás cómo tu red crece en el número de dispositivos y el horror que supone que falle. Este apunte está dedicado a los *Geeks* y *Techys* que, como yo, llevamos ya tiempo metidos en esta *complicación*, añadiendo equipos y servicios a nuestra red casera y sabemos de la enorme dependencia que supone.

En mi caso a llevado a replantearme el networking doméstico para hacerlo resiliente, es *obligatorio* para tener el control, sin dolores de cabeza, para soportar varios servicios en la red local y accesible de forma segura desde Internet (sin exponerse).

<br clear="left"/>
<!--more-->
 
 
## Punto de partida

¿A que me refiero con **avanzado**? a un networking que soporte de forma resiliente y segura *muchos cacharros variopintos*, vía LAN / WiFi en local, puntualmente desde internet, y que incluya toda la domótica. Que siga funcionando si cae internet o la WiFi (al menos la mayoría de las cosas).

También que funcione con nombres DNS (com mi dominio local propio, no con IPs) y sobre todo que tengas la mayor disponibilidad y backup's de las configuraciones posible. Saber recuperarte ante un desastre. ¿Cómo recuperas tu domótica cuando te quedas sin WiFi/LAN/Internet?.

¿A qué me refiero con que he añadido mucho equipos a lo largo de los años?. Pues a esto: 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-01.png"
    caption="En mi red hay, al menos, 115 equipos que hablan IP"
    width="600px"
    %}  

En mi caso tengo que usar una `/22` (la estándar `192.168.1/24` se quedó pequeña), mantengo un fichero CMDB para las IP's estáticas (MAC's), un servidor DNS interno, VLAN's, varios servicios vía HTTPS (con su correspondientes certificados *válidos*). 

Son muchos equipos hablando IP: los host y sus VM's, Contenedores, el QNAP para backups, el inversor (fotovoltaica), la aerotermia, luces, enchufes, relés, monitores de consumo, control de puertas, ventanas, cámaras de vigilancia, etc). Eso sin hablar de los cacharros Zigbee (que no cubro en este apunte).

Como host(s) uso un par de NUC's (+ una Pi) formando un Cluster Proxmox VE para hospedar varias máquinas virtuales, contenedores LXC o Docker con servicios: Home Assistant, Zigbee2MQTT, Mosquito, Node-RED, Grafana e InfluxDB. Firewall (iptables), servidor DNS y DHCP basado en PiHole, servidor de túneles IPSEC, un servidor GIT. Además, monitorización y gestión como Uptime Kuma, LibreNMS y Netdisco.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-02.jpg"
    caption="Como decía, llevo tiempo complicando mi instalación"
    width="600px"
    %} 

<br/>

### Servicios

Todos los servidores que menciono a continuación corren en máquinas virtuales linux o en contenedores (LXC o Docker) linux en mi Host (como decía 2xNUC's en Cluster con Proxmox VE):

- Servicios de Networking: Un Router (en mi caso basado en Software en una VM), varios Switches y Access Points y servicios: Servidor DHCP, DNS, controlador de AP's, Nginx Proxy Manager y herramientas como Uptime Kuma, LibreNMS, Netdisco para la monitorización del rendimiento de la red y los diferentes servicios que se estén utilizando.

- Servicios de domótica: Uso Home Assistant, Node-RED, Zigbee2MQTT, Mosquito, Grafana e InfluxDB. Permiten controlar y automatizar diferentes dispositivos en el hogar, como la iluminación, los sistemas de climatización, las cerraduras y los electrodomésticos.

- Servicios adicionales: Uso un antiguo QNAP para hacer backups y un servidor GIT que permite alojar y compartir proyectos de software y configuraciones. Por no mencionar laboratorios que monto y desmonto en plan hobby o para aprender.

<br/>

## Networking

Como decía, apunte se centra en el **networking avanzado**. Es sencillo y está funcionando bastante estable:


FOTO DE LA RED COMPLETA !!


Para la administración de las direcciones IP, se puede utilizar un servidor DNS y DHCP basado en PiHole. Esta herramienta permite bloquear publicidad y rastreadores de Internet y también proporciona protección contra malware.

Firewall:

Un firewall es esencial para garantizar la seguridad de la red casera. En este caso, se puede utilizar el firewall iptables para proteger la red de posibles amenazas.

mientras que el controlador wireless permite administrar y controlar el acceso a la red inalámbricas.

Todo cacharro persistente (la mayoría) reciben una IP fija desde el DHCP Server por su MAC
