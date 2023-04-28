---
title: "Domótica y Networking"
date: "2023-04-08"
categories: administración
tags: domótica networking avanzado linux pve proxmox kvm qemu cloud-init alpine debian ubuntu plantilla virtualización
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-homenet.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Comparto mi **networking doméstico avanzado**, resiliente, funcional y con una buena experiencia de usuario. No queda más remedio, las redes caseras de hoy en día acaban soportando múltiples servicios y con la irrupción de la domótica se múltiplican. Además, estaría bien poder acceder *llamando a la puerta* desde Internet. 

La domótica hace crecer exponencialmente el número de dispositivos y mantener la red de un hogar inteligente y automatizado se complica. Este apunte está dedicado a esos *Geeks* y *Techys* que, como yo, llevamos ya tiempo metidos en la *complicación de una red casera domotizada*.


<br clear="left"/>
<!--more-->
 
 
## Punto de partida

¿A que me refiero con **networking avanzado**?. Pues que soporte de forma resiliente y segura *muchos cacharros variopintos*, vía LAN/WiFi y puntualmente desde internet. Que pueda usar certificados para trabajar con https, que incluya la domótica y ya por pedir, que siga funcionando si cae internet o la WiFi (por lo menos la mayoría de las cosas).

¿Cuanto puede crecer tu red? pues si sumamos switches, AP's, servidores físicos, virtuales, sensores, relés, actuadores, etc. yo veía el otro día 115 IP's únicas.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-01.png"
    caption="En mi red hay, al menos, 115 equipos que hablan IP"
    width="600px"
    %}

<br/>

### Internet

Empiezo la casa por el tejado, es fundamental decidir cómo queremos conectarnos y controlar lo que entra y lo que sale. En esta sección voy a tratar tres puntos importantes: 

- **Mi router** (y firewall) de salida a Internet. 
- El servicio de **dominio dinámico**
- El servicio **knockd**

Probablemente el **99% de los hogares usa el router del Proveedor de Servicios (Operadora) y cuelga todo debajo**, traen varios puertos y un punto de acceso embebido, suena bien. 

Hasta que te das cuenta que no es suficiente. Mi **recomendación es poner detrás mi propio router + switch(es) + AP(s)** y desactivar el WiFi del router del Proveedor 😆. Partiendo de esta premisa, tenemos tres opciones (ojo!, mi proveedor es movistar, si tienes otro habrá ligeros cambios):

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-03.svg"
    caption="Arquitectura funcional: para un control total mejor poner mi router"
    width="800px"
    %} 

- **Estándar**: Conecto mi Router al del Proveedor y recibo IP privada (`192.168.1.0/24`).
  - Desventajas menores: Hay que hacer dos veces Port Forwarding y NAT.
  - Desventajas mayores: Pierdes el control de VoIP y de IPTV (si lo tienes contratado).
  - Ventajas: No tocas el servicio del Proveedor, suele ser muy estable. El soporte funciona y no hay que dar explicaciones. 
- **Modo Bridge**: Configuro el Router en modo bridge, se comparta como el siguiente punto, un ONT. No lo he configurado nunca, depende de qué Router te pongan se configura distinto. Hay routers (p.ej GPT-2841GX4X5, recuerda que uso movistar) que no soportan esta modalidad. Sus ventajas y desventajas son las mismas que en el modo siguiente.
- **ONT**: Mi Router se conecta al *Optical Network Termination*, a su puerto ETH1 por donde me presenta: VLAN-6 para "datos", VLAN-2 para IPTV y VLAN-3 para VoIP.
  - Desventajas: Te sales del estándar y no es válido para personas sin experiencia en routing/switching. 
  - Ventajas: A todos los beneficios de tener mi Router en medio, le añado el control total del tráfico IPTV y VoIP.

Yo utilizo la opción de la derecha (ONT) porque quiero poder controlar el tráfico IPTV/VoIP usando sus VLAN's. Como ventaja extra tengo que me ahorro el doble port-forwaring y doble NAT. 

Si no queires controlar el tráfico IPTV/VoIP te recomiendo la opción Estándar (izquierda), es perféctamente válidad para todo lo que explico en este apunte. Tendrás que hacer port forwarding "también" en el Router del Proveedor y en el caso de **Knockd tendrás que hacer un apaño** un poco raro para que te funcione, pero funcionará.

<br/> 

#### Mi router

El Router que pongas podría ser cualquiera que te convenga o conozcas mejor o te manejes mejor. Tienes de todo, desde elegir un fabricante hardware que implemente los más conocidos como `OpenWrt` o `pfSense`, irte a Mikrotik o a otros menos conocidos, incluso fabricantes todo-en-uno que te venden un cacharro que además te incluye la WiFi embebida. 

En este apunte yo me centro en hacerlo "a pelo", con un Linux corriendo en una máquina virtual, con `iptables` y conmutando tráfico entre su sesión `pppoe` por la `vlan6` y la vlan que tengo asignada a mi Intranet. Utilizo IP pública dinámica, pero eso aprovecho que tengo un un domiinio propio y lo actualizo dinámicamente en internet (cada vez que cambia mi IP pública).

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-04.svg"
    caption="Representacion física de conexión"
    width="450px"
    %} 

| Nota: Lo mismo podría haberlo hecho en una Raspberry Pi4B (que da buen rendimiento) con un par de tarjetas de red (la suya y otra USB de 1Gbe por ejemplo) |

**Máquina Virtual (VM) con Ubuntu 22.04 LTS**

Como se aprecia en la figura anterior, mi equipo es una máquina Virtual corriendo en un Host NUC de Intel, en realidad en un Cluster Proxmox formado por 2xNUC's + una Pi3B para tener redundancia. Valdría cualquier otra opcion: un ordenador pequeño dedicado, una raspberry Pi4B, una máquina virtual en tu propio servidor KVM/QEMU. 

Utilizo **[Ubuntu 22.04 LTS](https://ubuntu.com/blog/tag/LTS)**, sistema operativo de código abierto basado en Linux, para montar el router software, es muy robusto y fácil de mantener. La versión `LTS` es una versión de soporte a largo plazo que recibe actualizaciones de seguridad y corrección de errores durante cinco años, especialmente adecuado cuando se necesita **estabilidad**.

Instalo una maquina virtual desde [Plantilla de VM en Proxmox]({% post_url 2023-04-07-proxmox-plantilla-vm %}). Llamo al equipo **muro**.

| Nota: `muro` arrancará en la `vlan100` por defecto, recibirá una IP de mi DHCP Server, pronto le pondré una fija y haré que se conecte al TRUNK donde recibirá varias VLAN's. Los dos servidores físicos (Hosts) en el Cluster Proxmox VE están conectados a puertos Trunk del switch. Por cierto, los configuré usando OVS Bridge (en vez de linux brige) |

Antes de tocar la red, levanto esta VM e instalo paquetes, elimino `cloud-init` y preparo el ficheor `netplan` (para el modo trunk).

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

Desde Proxmox: `muro -> hardware -> network device` configuro la tarjeta de red de la máquina virtual, le pongo la misma MAC que he configurado en el fichero `netplan` (`52:54:12:12:12:12`).

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-05.png"
    caption="Configuro la tarjeta para que reciba el TRUNK"
    width="600px"
    %} 

Para que el router `muro` reciba el Trunk (todas las vlan's) basta con dejar vacío el campo `VLAN Tag`. También **recomiendo quitar la opción `Firewall`** (aunque lo tengas desactivado a nivel global en Proxmox), me dió problemas con `IGMP` mullticast.

Arranco el equipo y ya tengo la posibilidad de hacer Routing + Firewall entre múltiples redes.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-06.svg"
    caption="El Router software se encarga de conmutar de forma segura"
    width="600px"
    %} 

Este equipo actúa como router entre las diferentes interfaces y redes disponibles, así que es importante configurar `PPP`, `NAT` e `iptables`.

Estos los ficheros, servicios y Scripts que utilizo. **Revísalos a conciencia** para adaptarlo si es necesario a tu instalación. 
  
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

#### Dominio dinámico

Un dominio dinámico es un servicio que permite asignar un nombre fácil de recordar a mi dirección IP pública, la cual puede cambiar periódicamente. Esto es especialmente útil para acceder a dispositivos en la red doméstica desde fuera de ella, como es mi caso cuando necesito conectar por ejemplo con servicios del tipo **Home Assistant, SSHD, acceso OpenVPN**, etc.

Obviamente estoy asumiendo que tenemos un dominio de internet, por ejemplo `tudominio.com`, lo que tienes que hacer es registrarte con un proveedor de servicios de dominio dinámico, como DynDNS, No-IP, DuckDNS, etc. Hoy en día todos los proveedores de dominios suelen soportar los dinámicos.

Configuro mi router para que ejecute un script y notifique el cambio de IP. De esta manera, puedo acceder a mis servicios usando el mismo nombre cuando estoy en Internet, independientemente de cuál sea la dirección IP pública actual. 

Yo trabajo con CDMON y entre sus páginas se encuentra la [documentación para actualizar la IP](https://ticket.cdmon.com/es/support/solutions/articles/7000005922-api-de-actualización-de-ip-del-dns-gratis-dinámico/). Para que veas un ejemplo, en un Linux creo un servicio en `systemd` y un pequeño `script`. 

- [/etc/systemd/system/cdmon_update.service](https://gist.github.com/LuisPalacios/0455cff3e67d500772c23b58b2a8ff10)
- [/etc/systemd/system/cdmon_update.timer](https://gist.github.com/LuisPalacios/415e188233fa71e3651413580281839a)
- [/usr/bin/cdmon_update.sh](https://gist.github.com/LuisPalacios/a3ce16ea1ad60064849cd08c11b284e0)

```console
# chmod 755 /usr/bin/cdmon_update.sh
# systemctl enable cdmon_update.timer
```

<br/>

#### Llamar a la puerta

El **Port Knocking** es una técnica que consiste en enviar varios paquetes a tu servidor (firewall) para que reconozca que estás "llamando a la puerta" y te abra temporalmente solo a ti (la IP desde la que conectas) un puerto concreto.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-08.svg"
    caption="Modo de funcionamiento de knockd."
    width="500px"
    %} 

Me he instalado el cliente **PortKnock** en mi smartphone, lanzo la petición "Ábreme el puerto para llegar a Home Assistant" y una vez prospera, arranco el App **Home Assistant**. Lo que ocurre "por detrás" es que PortKonck envía una serie de paquetes con una cadencia determinada; el router/firewall se da por enterado (están llamando a la puerta) y me abre solo a mi IP, durante un rato, el puerto `28123`. 

El App **Home asistant** está configurado siempre con el mismo nombre de servidor: `mihass.midominio.com` que se resuelve tanto en Internet (dominio dinámico) como en la Intranet (ya veremos cómo más tarde).

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-09.jpg"
    caption="Modo de funcionamiento de knockd."
    width="400px"
    %} 

Podemos configurar el número de knock's y puertos que queramos, siempre que coincida en ambos, servidor y cliente. Por ejemplo, con tres paquetes `SYN` (nkock's) cada segundo sería: Envía un `SYN` al puerto #1, espera un segundo, un `SYN` al puerto #2, espera otro segundo y envía un último `SYN` al puerto #3. En ese instante nuestro daemon `knockd` ejecuta lo que queramos, que será típicamente `iptables` para abrir el puerto (`28123` en este ejemplo).

**Instalación**
  
```console
root@muro:~# apt install knockd
```

Aquí tienes un ejemplo que funciona, del fichero de configuración, donde he cambiado por números aleatorios a modo de ejemplo.

- [/etc/knockd.conf](https://gist.github.com/LuisPalacios/6132bb17999934f5eb51cf186d94910f)

**Activación del servicio**

```console
root@muro:~# systemctl enable knockd
```

<br/>

#### OpenVPN

Describir aquí OpenVPN


<br/>

**Acceso a múltiples hosts vía `https`**

Un caso donde puedes es necesario dar de alta múltiples registros de tipo 'A' en el dominio externo es, por ejemplo, cuando necesito conectar con `https` a verios servicios de casa. En mi caso he montado un Proxy inverso con Nginx Proxy manager, tengo varios servicios que se administran vía Web,  y he solicitado certificados con Let's Encrypt. 

Un ejemplo, con cuatro servicios: `https://mihass.midominio.com`, `https://migitea.midominio.com`, `https://milibrenms.midominio.com`, `https://miproxmox.midominio.com`. Quiero entrar desde Internet y la Intranet. ¿Cómo lo configuro?

- En Internet (proveedor de DNS dinámico): Doy de alta 4 x registros de tipo 'A' contra el mismo usuario, de modo que al cambiar la IP dinámica de dicho usuario, me aplica a los cuatro. A todos los efectos, los cuatro subdominios resuelven a mi misma IP pública. 
- En Intranet, mi software DNS/DHCP server interno (PiHole, que veremos luego) tiene dados de alta los cuatro apuntando a la misma IP, la interna de mi Nginx Proxy Manager.

Cuando conecto desde Internet, con cualquiera de esos nombres, vía `https`, todos conectan con mi IP pública, me dejará entrar porque he llamado previamente a la puerta con `nockd` (ver siguiente punto), y mi router/firewall hace port-forwarding hacia mi proxy inverso, que por el nombre me deriva a su vez al servicio concreto.

Cuando conecto desde la Intranet, con cualquiera de esos nombres, vía `https`, mi DNS Server interno resuelve a la IP interna de mi proxy inverso, que por el nombre me deriva a su vez al servicio concreto.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-07.svg"
    caption="Servidores DNS y conexiones `https`"
    width="500px"
    %} 


<br/>



<br/>

### Infraestructura

- Servicios de Networking: Un Router/Firewall/OpenVPN/Knock, varios Switches, Access Points y servicios: Servidor DHCP, DNS, controlador de AP's, Nginx Proxy Manager y herramientas como Gatus, Uptime Kuma, LibreNMS, Netdisco para la monitorización del rendimiento de la red y los diferentes servicios que se estén utilizando.

- Servicios de domótica: Home Assistant, Node-RED, Zigbee2MQTT, Mosquito, Grafana e InfluxDB. Permiten controlar y automatizar diferentes dispositivos en el hogar, como la iluminación, los sistemas de climatización, las cerraduras y los electrodomésticos.

- Servicios adicionales: Un QNAP para hacer backups y un servidor GIT que permite alojar y compartir proyectos de software y configuraciones. Por no mencionar laboratorios para aprender.

Para el IT: Tengo un Cluster con Proxmox (2xNUc's + 1Pi) haciendo de Host para múltiples máquinas virtuales y/o contenedores. Además un QNAP para backups e imágenes. 

Para la Domótica, la mayoría conectados por WiFi: Un inversor (fotovoltaica), aerotermia, luces, enchufes, relés, sensores, monitores de consumo, control de puertas, ventanas, cámaras de vigilancia. Además interruptores y sensores Zigbee (que no cubro en este apunte).

Lo primero que me planteé fue el tema de resiliencia. Cuando se me caía el "host" con mis VM's me quedaba sin casa 😂 y me caía la bronca. He optado por poner un par de Host (2xNUC's + 1xPi) formando un Cluster Proxmox VE para hospedar las máquinas virtuales, contenedores LXC o Docker con servicios.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-02.jpg"
    caption="Como decía, llevo tiempo complicando mi instalación"
    width="600px"
    %} 


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
dhcp-host=52:54:12:12:12:12,192.168.10.1,muro.midominio.com
dhcp-host=00:08:22:37:0E:A1,192.168.1.2,estatico.midominio.com

dhcp-host=38:34:D3:3E:DA:31,192.168.1.50,nodo1.midominio.com
dhcp-host=38:F9:34:B7:36:96,192.168.1.51,nodo2.midominio.com
```

* Asigno nombres DNS a direcciones IP.
  
```console
$ sudo cat /etc/pihole/custom.list
192.168.1.1 muro.midominio.com
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

<br/>

#### Monitorizacion: Gatus

https://github.com/TwiN/gatus

