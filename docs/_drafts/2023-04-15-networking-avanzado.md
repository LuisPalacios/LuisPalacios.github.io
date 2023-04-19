---
title: "Domótica y Networking"
date: "2023-04-13"
categories: administración
tags: domótica networking avanzado linux pve proxmox kvm qemu cloud-init alpine debian ubuntu plantilla virtualización
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-homenet.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Con la Domótica se complica el **networking**. Si te metes en ese pozo sin fin verás cómo tu red crece en número de dispositivos y la dificultad para mantener un hogar inteligente y automatizado sin líos. Este apunte está dedicado a esos *Geeks* y *Techys* que, como yo, llevamos ya tiempo metidos en esta *complicación*.

Me he replanteado el networking doméstico para hacerlo resiliente, no me quedó más remedio para tener el control, sin dolores de cabeza, poder soportar varios servicios en la red local y accesible de forma segura desde Internet (sin exponerse demasiado). Ahí va este apunte por si te sirve de inspiración.

<br clear="left"/>
<!--more-->
 
 
## Punto de partida

¿A que me refiero con **avanzado**? a un networking que soporte de forma resiliente y segura *muchos cacharros variopintos*, vía LAN / WiFi en local y puntualmente desde internet. Ah! y que incluya toda la domótica. Que siga funcionando si cae internet o la WiFi (al menos la mayoría de las cosas).

También pretendo que funcione con nombres DNS (en vez de IPs) y sobre todo que tenga la mayor disponibilidad (y backup's) posible, saber recuperarte ante un desastre, etc.

¿A qué me refiero con que he añadido mucho equipos a lo largo de los años?. Pues a esto:

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-01.png"
    caption="En mi red hay, al menos, 115 equipos que hablan IP"
    width="600px"
    %}  

Incluso tuve que cambiar a una `/22` (porque mi `192.168.1/24` se quedó pequeña), mantengo un fichero CMDB para las IP's estáticas (MAC's), un servidor DNS y DHCP interno, varias VLAN's, varios servicios vía HTTPS (con su correspondientes certificados *válidos*), un proxy inverso, etc.

Ya con la domótica se complicó, son muchos equipos hablando IP: además de los Host y sus VM's/Contenedores, tengo el QNAP para backups, el inversor (fotovoltaica), la aerotermia, luces, enchufes, relés,sensores, monitores de consumo, control de puertas, ventanas, cámaras de vigilancia, etc. Eso sin hablar de los cacharros Zigbee (que no cubro en este apunte).

Lo primero que me planteé fue el tema de resiliencia. Cuando se me caía el "host" con mis VM's me quedaba sin casa 😂 y me caía la bronca. He optado por poner un par de Host (2xNUC's + 1xPi) formando un Cluster Proxmox VE para hospedar las máquinas virtuales, contenedores LXC o Docker con servicios.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-02.jpg"
    caption="Como decía, llevo tiempo complicando mi instalación"
    width="600px"
    %} 

<br/>

### Servicios

Todos los servidores que menciono a continuación corren en máquinas virtuales linux o en contenedores (LXC o Docker) en el Cluster:

- Servicios de Networking: Un Router/Firewall/OpenVPN/Knock, varios Switches, Access Points y servicios: Servidor DHCP, DNS, controlador de AP's, Nginx Proxy Manager y herramientas como Gatus, Uptime Kuma, LibreNMS, Netdisco para la monitorización del rendimiento de la red y los diferentes servicios que se estén utilizando.

- Servicios de domótica: Home Assistant, Node-RED, Zigbee2MQTT, Mosquito, Grafana e InfluxDB. Permiten controlar y automatizar diferentes dispositivos en el hogar, como la iluminación, los sistemas de climatización, las cerraduras y los electrodomésticos.

- Servicios adicionales: Un QNAP para hacer backups y un servidor GIT que permite alojar y compartir proyectos de software y configuraciones. Por no mencionar laboratorios para aprender.

<br/>

## Networking

Veamos cómo he montado el **networking** para todo esto. Voy a empezar por el acceso a internet, así que voy desde fuera hacia dentro.

Empiezo por el router con internet. Probablemente el **99% de los hogares usa el router del operador y cuelga todo debajo**, incluye varios puertos y un punto de acceso, suena bien. Anticiparás mi recomendación para un networking avanzado 😆, **poner nuestro propio router, switch(es) y AP(s)**. 

Así conseguimos más control, seguridad, alcance (WiFi), resiliencia, escalabilidad, etc. Tiene su lado negativo: necesitas tener un *Techy* en casa (o un amigo); son más cacharros, más administración, mantenimiento, más puntos de fallo, disaster recovery, etc.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-03.svg"
    caption="Para tener un control total mejor poner mi router"
    width="600px"
    %} 

En la figura vemos dos opciones, la primera es ponerlo detrás del router del operador (izda). La desventaja es que tienes que configurar los port forwarding estáticos un par de veces y hacer doble NAT en salida y entrada (cuando abramos puertos). La ventaja es que no tocas nada del Operador y cuando falla y pides soporte viene bien.

<br/>

#### Router principal

Las segunda opción (figura anterior, a la derecha) es la mía, si puedes y te dejan no lo dudes. Necesitarás tener el ONT original o el Router del operador configurado en modo Bridge (te traslada la VLAN del ONT interno). Así trabajo yo, me conecto directamente a la VLAN de datos del ONT (vlan6) y levanto sesión `ppp` con mi router Linux (`pppd+iptables`) que recibe la IP Pública de Internet. Por supuesto valdría cualquier Router hardware/software estilo Mikrotik, OpenWrt, pfSense, Tomato, etc...

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-04.svg"
    caption="Mi router es un Linux con iptables (bastante sencillo)"
    width="600px"
    %} 

**Máquina Virtual (VM) con Ubuntu 22.04 LTS**

Utilizo **[Ubuntu 22.04 LTS](https://ubuntu.com/blog/tag/LTS)**, sistema operativo de código abierto basado en Linux, para montar mi router software, es muy robusto y fácil de mantener. La versión `LTS` es una versión de soporte a largo plazo que recibe actualizaciones de seguridad y corrección de errores durante cinco años, especialmente adecuado cuando se necesita **estabilidad**.

Respecto a su instalación, creo una VM desde Plantilla. Tienes un apunte llamado [Plantilla de VM en Proxmox]({% post_url 2023-04-07-proxmox-plantilla-vm %}) como referencia. Lo sigo y llamo al equipo **muro**.

| Nota: `muro` arrancará en la `vlan100` por defecto, recibirá una IP de mi DHCP Server, pronto le pondré una fija y haré que se conecte al TRUNK donde recibirá varias VLAN's. Los dos servidores físicos (Hosts) en el Cluster Proxmox VE están conectados a puertos Trunk del switch. Por cierto, los configuré usando OVS Bridge (en vez de linux brige) |

Antes de activar el modo trunk en la VM voy a levantar la VM, instalar un montón de software, eliminar `cloud-init`, preparar el ficheor `netplan` (para el modo trunk) y apagarla.

```console
root@muro:~# apt install qemu-guest-agent
root@muro:~# apt install nano net-tools iputils-ping tcpdump
```

Elimino cloud-init

```console
root@muro:~# rm -fr /etc/cloud
root@muro:~# apt purge -y cloud-init
root@muro:~# rm /etc/netplan/50-cloud-init.yaml
```

Preparo Netplan para el próximo arranque, parametrizo el interfaz trunk y las vlan's. 

```console

root@muro:~# cat /etc/netplan/50-muro.yaml
# Fichero netplan para muro
network:
  ethernets:
      eth0:
        dhcp4: no
  vlans:
      vlan6:                             <== VLAN con el ONT (aquí irá el ppp)
        id: 6
        link: eth0
        macaddress: "52:54:12:34:56:78"
        dhcp4: no
      vlan100:                           <== VLAN principal
        id: 100
        link: eth0
        macaddress: "52:54:12:12:12:12"  <== Debe coincidir con el siguiente paso
        addresses:
        - 192.168.1.1/22               <== Mi IP en la intranet
        nameservers:
          addresses:
          - 192.168.1.224              <== El DNS/DHCP server
          search:
          - parchis.org
      vlan33:                            <== Un ejemplo de VLAN extra
        id: 33
        link: eth0
        macaddress: "52:54:AB:CD:EF:33"
        addresses:
        - 192.168.33.1/24
  version: 2
```

Ya puedo apagar el equipo. 

```console
root@muro:~# poweroff
```

Desde `muro -> hardware -> network device` configuro la tarjeta de red de la máquina virtual, le pongo la misma MAC que he configurado en el fichero `netplan` (`52:54:12:12:12:12`).

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-05.png"
    caption="Configuro la tarjeta para que reciba el TRUNK"
    width="600px"
    %} 

Para que el router `muro` reciba el Trunk (todas las vlan's) basta con dejar vacío el campo `VLAN Tag`. También **recomiendo quitar la opción `Firewall`** (aunque lo tengas desactivado a nivel global en Proxmox). Dejarlo puesto me dió problemas con `IGMP` en multicast.

Arranco el equipo, configuro más ficheros y paso a tener la posibilidad de hacer Routing + Firewall entre múltiples redes.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-06.svg"
    caption="El Router software se encarga de conmutar de forma segura"
    width="600px"
    %} 

Este equipo actúa como router entre las diferentes interfaces y redes disponibles, así que es importante configurar `PPP`, `NAT` e `iptables`.

Servicios y Scripts que utilizo:
  
- [/etc/systemd/system/internet_wait.service](https://gist.github.com/LuisPalacios/68fccb64e9e1b8ef598ee7bf6de181ee)
- [/etc/systemd/system/firewall_1_pre_network.service](https://gist.github.com/LuisPalacios/d90ff449e2e9886341ffa019008757b4)
- [/etc/systemd/system/firewall_2_post_network.service](https://gist.github.com/LuisPalacios/3345a1ad94231a74fe5442c738e97cb0)
- [/etc/default/netSetupVars](https://gist.github.com/LuisPalacios/bcc7df9cd60937f6cec40a6c9ede6469)
- [/root/firewall/firewall_clean.sh](https://gist.github.com/LuisPalacios/dfc8a5e82b3dab4e2ef78ccf77263a9a)
- [/root/firewall/firewall_1_pre_network.sh](https://gist.github.com/LuisPalacios/b648ef38206caa8c28cbc148a89ff364)
- [/root/firewall/firewall_2_post_network.sh](https://gist.github.com/LuisPalacios/c7ed6d89343e9238770db550b5dc6718)
- [/root/firewall/firewall_verifica.sh](https://gist.github.com/LuisPalacios/252db87b4e9866e2132e8bf8d71571cb)


Habilito los servicios (se activará en el próximo reboot)

```console
# chmod 755 /root/firewall/*.sh
# systemctl enable internet_wait.service
# systemctl enable firewall_1_pre_network.service
# systemctl enable firewall_2_post_network.service
```

<br/>

#### Knockd

El Port Knocking (llamar a la puerta) consiste en enviar varios paquetes a tu servidor (firewall) para que reconozca que estás "llamando a la puerta" y te abra un puerto concreto (solo a la IP desde la que llamas).

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-08.svg"
    caption="Modo de funcionamiento de knockd."
    width="500px"
    %} 

Un ejemplo sería querer entrar desde el App de Home Assistant desde internet. Utilizo por ejemplo el cliente PortKnock en mi iPad, mandará sius tres paquetes con una cadencia determinada; el router/firewall se da por enterado (están llamando a la puerta) y abre durante un rato el puerto 8123 (a la IP desde donde estás mandándolos). Arranco el App de Home Assistant y ya estamos dentro.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-07.jpg"
    caption="Modo de funcionamiento de knockd."
    width="400px"
    %} 

Pueden configurar el número de paquetes que quieras y los puertos que desees, siempre que coincida en ambos, servidor y cliente. 

En un ejemplo con 3 paquetes enviaría un SYN al puerto #1, espera un segundo, manda un SYN al puerto #2, espera otro segundo y envía un último paquete SYN al puerto #3. En ese instante nuestro daemon `knockd` ejecuta lo que queramos, que será típicamente `iptables` para abrir el puerto (8123 en este ejemplo).

**Instalación**
  
```console
root@cortafuegix:~# apt install knockd
```

Aquí tienes un ejemplo que funciona, del fichero de configuración, donde he cambiado por números aleatorios a modo de ejemplo.

- [/etc/knockd.conf](https://gist.github.com/LuisPalacios/6132bb17999934f5eb51cf186d94910f)

**Activación del servicio**

```console
root@cortafuegix:~# systemctl enable knockd
```

<br/>

#### DNS y DHCP

Como servidor DNS y DHCP utilizo desde hace tiempo Pi-hole porque además de esos dos servicios también protege de contenido no deseado, hace de sumidero de la publicidad no deseada.

![logo pihole](/assets/img/posts/logo-pihole.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

Tengo un sistema rudimentario para mantener la lista de equipos, MACs y la IP que les asigno. Lo mantengo en una hoja de cálculo maestra y cada vez que hago un cambio actualizo los ficheros del servidor PiHole. 

En el apunte donde explico cómo instalar un [Pi-hole casero]({% post_url 2021-06-20-pihole-casero %}) verás que puedes acceder directamente a los dos ficheros principales donde se guardan las asignaciones para el DHCP y los nombres DNS.

Describo a continuación un ejemplo. Así es como tengo todos mis equipos, en dos ficheros, con esta sintaxis: 

* Asigno IP's vía DHCP de forma estática (por la MAC)

```console
$ sudo cat /etc/dnsmasq.d/04-pihole-static-dhcp.conf
dhcp-host=52:54:12:12:12:12,192.168.10.1,cortafuegix.midominio.com
dhcp-host=00:08:22:37:0E:A1,192.168.1.2,estatico.midominio.com

dhcp-host=38:34:D3:3E:DA:31,192.168.1.50,nodo1.midominio.com
dhcp-host=38:F9:34:B7:36:96,192.168.1.51,nodo2.midominio.com
```

* Asigno nombres DNS a direcciones IP.
  
```console
$ sudo cat /etc/pihole/custom.list
192.168.1.1 cortafuegix.midominio.com
192.168.1.2 estatico.midominio.com
:
192.168.1.50 nodo1.midominio.com
192.168.1.51 nodo2.midominio.com
:
192.168.1.224 pihole.midominio.com
```

* Si modificas ficheros manualmente no olvides rearrancar pihole

```console
$ sudo pihole restartdns
```

<br/>

#### Servidor NPM

Describir aquí NPM

<br/>

#### Servidor Proxy Inverso (CTX)

Utilizo **[Nginx Proxy Manager](https://nginxproxymanager.com)**.

Describir aquí NPM

#### OpenVPN

Describir aquí OpenVPN


<br/>

#### Monitorizacion: Gatus

https://github.com/TwiN/gatus

