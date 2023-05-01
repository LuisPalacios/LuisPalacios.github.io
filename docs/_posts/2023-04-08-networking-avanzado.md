---
title: "Domótica y Networking"
date: "2023-04-08"
categories: administración
tags: domótica networking avanzado linux pve proxmox kvm qemu cloud-init alpine debian ubuntu plantilla virtualización
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-homenet.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Comparto mi **networking doméstico avanzado**, resiliente, funcional y con una buena experiencia de usuario, con opciones como *llamar a la puerta* desde Internet para accesos puntuales. Las redes caseras de hoy en día acaban soportando múltiples servicios y con la irrupción de la domótica se complica la cosa.  

El número de dispositivos crece y mantener la red de un hogar inteligente y automatizado se convierte en una prioridad. Dedico el apunte a esos *Geeks* o *Techys* que, como yo, llevamos tiempo metidos en la *complicación del networking en una red casera domotizada*.


<br clear="left"/>
<!--more-->
 
 
## Punto de partida

El objetivo es que el diseño soporte *muchos cacharros variopintos*, vía LAN/WiFi, que se puedan usar certificados con `https`, poder entrar *llamando a la puerta* desde intenet y ya por pedir, que la domótica siga funcionando si cae internet o la WiFi (que haya unos mínimos). 

¿Cuanto puede crecer tu red? pues sin darte cuenta, sumando switches, AP's, servidores físicos, virtuales, sensores, relés, actuadores, clientes, etc. el otro día veía 122 IP's únicas 😱 en mi router Linux.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-01.png"
    caption="Nos quedamos cortos pronosticando los dispositivos conectados"
    width="400px"
    %}


<br/>

----

<br/>

### Internet

Empiezo la casa por el tejado describiendo:

- Qué uso como **router/firewall** para entrar/salir a Internet. 
- Cómo montar el **dominio dinámico**, para llamar con nombre desde Internet.
- Cómo **llamar a la puerta** para abrir puertos bajo demanda.
- Cómo hacer **ssh, OpenVPN, etc.** para entrar desde Internet.

El **99% de los hogares usa el router del Proveedor de Servicios (Operadora) y cuelga todo debajo**, traen varios puertos y un punto de acceso embebido, suena bien. 

Cuando tienes conocimientos de routing y switching mi **recomendación es poner detrás un router propio + switch(es) + AP(s)** y desactivar el WiFi del Proveedor 😆. El beneficio principal es que pasas a tener un control total, incluso permite añadir extras: sistema para llamar a la puerta abriendo puertos bajo demanda, túneles ipsec, silencio a los pings (si conectas directamente al ONT), identificar intentos de ataques, control del tráfico VoIP e IPTV y otros. 

Partiendo de esta premisa, tengo tres opciones. 

<br/>

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-02.svg"
    caption="Para un control total pongo mi propio router"
    width="800px"
    %} 

<br/>

- **Estándar**: Conecto mi Router al del Proveedor y recibo IP privada (`192.168.1.0/24`).
  - Desventajas: Hay que hacer dos veces Port Forwarding y NAT. Pierdes el control de VoIP/IPTV (si lo tienes contratado). Puede tocarte un router "de baja generación/calidad" y darte problemas de rendimiento y/o cuelgues.
  - Ventajas: No tocas el servicio del Proveedor que suele ser suficientemente estable. El soporte funciona y no hay que dar explicaciones. 
- **Modo Bridge**: Se comporta como un ONT, recibes todas las VLAN's. No lo he configurado nunca pero entiendo que sus ventajas y desventajas son las mismas que el punto siguiente (ONT),  
- **ONT**: Conecto mi Router al *Optical Network Termination*, a su puerto ETH1, me presenta las 3 VLANs: 6 para Datos, 2 para IPTV y 3 para VoIP.
  - Desventajas: Si no tienes experiencia en routing/switching tendrás muchos problemas.
  - Ventajas: Definitivamente control total, incluyendo tráfico IPTV/VoIP además de evitar el doble port-forwaring y doble NAT.

¿Cuál recomiendo?

- Si tienes el ONT, es la mejor opción. Llevo usándolo años, cuando Movistar lo instalaba junto con el router. Por desgracia hoy en día no se puede pedir en un alta nueva. 

- Modo bridge - si puedes y tu router lo soporta sería mi segunda opción. Ojo!, hay routers (p.ej GPT-2841GX4X5) que no soportan esta modalidad.

- Modo estándar - sería la última si no me quedase más remedio. Ojo!, vale para todo lo que explico en este apunte pero me incomoda el uso de doble port forwarding, doble NAT, tener que abrir demasiados puertos y la pérdida del control total de VoIP e IPTV.

<br/> 

#### Router

Uso **Linux** sobre máquina virtual, con su **routing nativo** e `iptables`. **Deniego todo el tráfico de entrada** y hago **Masquerade en salida**. Tienes otras opciones más fáciles, como usar [OpenWrt](https://openwrt.org), [IPFire](https://www.ipfire.org) o [pfSense](https://www.pfsense.org) (solo intel). También puede irte a hardware dedicado estilo Mikrotik o router neutro. Por cierto, si te gusta OpenWrt o IPFire hay una opción barata con Raspberry Pi 4B con 1GB.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-03.svg"
    caption="La seguridad es completa, por defecto no entra nada"
    width="800px"
    %} 

Volviendo a mi instalación. El hardware que uso para mi máquina virtual es un Host NUC de Intel. Siempre te hará falta un Switch (mínimo uno de 8xGbe con soporte de VLAN's e IGMP) y AP's con soporte de Roaming para la WiFi. A nivel físico, conecto el Host y el ONT a puertos TRUNK del Switch (puerto del ONT vlan's 2,3,6 y puerto del Host vlan's 2,3,6,100). 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-04.svg"
    caption="Representacion física de conexión"
    width="450px"
    %} 

Me he decantado por **[Ubuntu 22.04 LTS](https://ubuntu.com/blog/tag/LTS)**, robusto y fácil de mantener. Lo instalé usando la [Plantilla de VM en Proxmox]({% post_url 2023-04-07-proxmox-plantilla-vm %}) (luego explico qué es Proxmox). Concedo acceso a las vlan's 2,3,6,100. Una vez que tengo activo mi Linux termino su instalación con algunas herramientas, eliminando `cloud-init` y preparando el fichero `netplan`.

```console
root@muro:~# apt install qemu-guest-agent
root@muro:~# apt install nano net-tools iputils-ping tcpdump ppp
:
root@muro:~# rm -fr /etc/cloud
root@muro:~# apt purge -y cloud-init
root@muro:~# rm /etc/netplan/50-cloud-init.yaml
```

Netplan para la configuración de red. 

```console

root@muro:~# cat /etc/netplan/50-muro.yaml
#
# Ejemplo de fichero netplan para Ubuntu Linux como VM
# en un Host que está conectado a un puerto TRUNK en el Switch. 
#
# Recibo mi interfaz eth0 en modo TRUNK y habilito las
# vlans que necesito para hacer de Router con Movistar
#
# En este ejemplo NO configuro las vlans 2 y 3 (VoIP/IPTV)
#
network:
  ethernets:
      eth0:
        dhcp4: no
  vlans:
      vlan6:                             <== VLAN con el ONT (aquí irá el PPPoE)
        id: 6
        link: eth0
        macaddress: "52:54:12:34:56:78"
        dhcp4: no
      vlan100:                           <== VLAN principal
        id: 100
        link: eth0
        macaddress: "52:54:12:12:12:12"  <== Debe coincidir con la config de VM de Proxmox
        addresses:
        - 192.168.100.1/22               <== Mi IP en la intranet
        nameservers:
          addresses:
          - 192.168.100.224              <== El DNS/DHCP server
          search:
          - tudominio.com
      vlan33:                            <== Un ejemplo de VLAN extra
        id: 33
        link: eth0
        macaddress: "52:54:AB:CD:EF:33"
        addresses:
        - 192.168.33.1/24
  version: 2
```

Importante en el Software de Virtualización del Host (en mi caso Proxmox: `muro -> hardware -> network device`) configuro  la tarjeta de red de la VM con la misma MAC que puse en `netplan` (`52:54:12:12:12:12`).

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-05.png"
    caption="Configuro la tarjeta para que reciba el TRUNK"
    width="600px"
    %} 

Verifico que el router Linux reciba el Trunk. En el caso de Proxmox basta con dejar vacío el campo `VLAN Tag`. Ah! también **recomiendo quitar la opción `Firewall` en las opciones**. No se porqué, pero me dió problemas con `IGMP` mullticast a pesar de tenerlo desactivado a nivel global.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-06.svg"
    caption="El Router software se encarga de conmutar de forma segura"
    width="600px"
    %}  

Ficheros que configuro alrededor de `PPP`, `NAT` e `iptables`. Recuerda que son solo una referencia y que debes **revisarlos para adaptarlos a tu instalación**. 
  
- [/etc/systemd/system/internet_wait.service](https://gist.github.com/LuisPalacios/68fccb64e9e1b8ef598ee7bf6de181ee)
- [/etc/systemd/system/firewall_1_pre_network.service](https://gist.github.com/LuisPalacios/d90ff449e2e9886341ffa019008757b4)
- [/etc/systemd/system/firewall_2_post_network.service](https://gist.github.com/LuisPalacios/3345a1ad94231a74fe5442c738e97cb0)
- [/etc/default/netSetupVars](https://gist.github.com/LuisPalacios/bcc7df9cd60937f6cec40a6c9ede6469)
- [/root/firewall/firewall_clean.sh](https://gist.github.com/LuisPalacios/dfc8a5e82b3dab4e2ef78ccf77263a9a)
- [/root/firewall/firewall_1_pre_network.sh](https://gist.github.com/LuisPalacios/b648ef38206caa8c28cbc148a89ff364)
- [/root/firewall/firewall_2_post_network.sh](https://gist.github.com/LuisPalacios/c7ed6d89343e9238770db550b5dc6718)
- [/root/firewall/firewall_verifica.sh](https://gist.github.com/LuisPalacios/252db87b4e9866e2132e8bf8d71571cb)
- [/etc/ppp/pap-secrets](https://gist.github.com/LuisPalacios/3b4b33fd4378663cc38c09065b5e3b3f)
- [/etc/ppp/options](https://gist.github.com/LuisPalacios/96e392282fd9011986614c2a32fa3273)
- [/etc/ppp/peers/movistar](https://gist.github.com/LuisPalacios/07e99b6067fba47886c0a79c5bab26b7)
- [/etc/systemd/system/ppp_wait@.service](https://gist.github.com/LuisPalacios/647dc4190a3c9f80efe7188ac955cf87)
- [/etc/systemd/system/ppp_nowait@.service](https://gist.github.com/LuisPalacios/e216877fe5595d7b2bdcbc70257e7166)


Recuerda habilitarlos. También dejé unidades para el arranque de `PPPoE`, una que espera a que se establezca la sesión y otra que no. En mi caso uso la que espera (`ppp_wait@movistar.service`).

```console
# chmod 755 /root/firewall/*.sh
# systemctl enable internet_wait.service
# systemctl enable firewall_1_pre_network.service
# systemctl enable firewall_2_post_network.service
# systemctl enable ppp_wait@movistar.service
```

<br/> 

#### Dominio dinámico

Tu proveedor de servicios puede cambiar la IP que te asigna vía PPPoE en cada arranque o reconexión. Si quiero tener un nombre fijo (p.ej. `miservidor.tudominio.com`) para saber a dónde llamar desde Internet necesito tener un dominio propio y que mi proveedor DNS soporte alguna forma de hacer "Dominio Dinámico". 

Es un servicio que permite actualizar mi nueva IP en mi dominio en Internet. Hay proveedores de DNS **dinámico** como DynDNS, No-IP, DuckDNS. Probablemente tu proveedor DNS también lo soporte, como es mi caso. 

Yo tengo mi dominio alojado en `cdmon.es` y soportan esta función ([documentación para actualizar la IP](https://ticket.cdmon.com/es/support/solutions/articles/7000005922-api-de-actualización-de-ip-del-dns-gratis-dinámico/)). A modo de ejemplo estos son los servicio en `systemd` y un pequeño `script` que uso en mi router Linux. 

- [/etc/systemd/system/cdmon_update.service](https://gist.github.com/LuisPalacios/0455cff3e67d500772c23b58b2a8ff10)
- [/etc/systemd/system/cdmon_update.timer](https://gist.github.com/LuisPalacios/415e188233fa71e3651413580281839a)
- [/usr/bin/cdmon_update.sh](https://gist.github.com/LuisPalacios/a3ce16ea1ad60064849cd08c11b284e0)

```console
# chmod 755 /usr/bin/cdmon_update.sh
# systemctl enable cdmon_update.timer
```

Cada 5 minutos mira a ver si ha cambiado la IP y si es así la actualiza. Tengo dados de alta varios registros de tipo `'A'` resolviendo a la misma IP Pública de mi casa: 

- Home Assistant -> `ha.tudominio.com`, 
- SSH -> `ssh.tudominio.com`, 
- :

Resolución de nombres desde internet:

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-07.svg"
    caption="Cómo hago la resolución de nombres"
    width="800px"
    %} 

Luego veremos cómo lo hago en mi Intranet. Te anticipo que cuento con un servidor DNS interno que sirve el mismo dominio (`tudominio.com`) en local, entregando IP's privadas de casa. Este donde esté (internet o intranet) las App's siempre saben cómo llegar a los servicios caseros. 

<br/>

#### Llamar a la puerta

Durante años he usado varias técnicas para protegerme de ataques y desde hace tiempo he optado por no abrir ningún puerto. Mi router descarta/tira todos los paquetes que llegan desde internet, siempre. Bueno, casi siempre. Hay un par de servicios a los que sí que me gustaría poder acceder desde Internet: levantar un túnel `ssh` o `ipsec` para hacer una administración puntual y acceso a mi servidor *Home Assistant* para la domótica. 

Descubrí la técnica del **Port Knocking** (llamar a la puerta) y me gustó mucho. Se trata de un App que envia 3 o 4 paquetes especiales al Router/Firewall para que reconozca que estás "llamando a la puerta" y si llamas como a él le gusta te abre temporalmente (solo a la IP desde la que llamo) el puerto del servicio que quieras consumir.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-08.jpg"
    caption="Aplicaciones involucradas"
    width="300px"
    %} 
    
Uso **PortKnock** (App para smartphone): lanza la petición (1) Ábreme el puerto para llegar a Home Assistant (envía una serie de paquetes con una cadencia determinada), el router/firewall se da por enterado y abre durante un rato el puerto `p.ej. 28123`. (2) **Home asistant** pueda entrar. 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-09.svg"
    caption="Así funciona *Llamar a la puerta*"
    width="800px"
    %} 

Podemos configurar cuántos toques se dan a la puerta y a qué puertos. Deben coincidir en el servidor y cliente. Por ejemplo, dar tres toques cada segundo sería: Envía un `SYN` al puerto #1, espera un segundo, un `SYN` al puerto #2, espera otro segundo y envía un último `SYN` al puerto #3. En ese instante nuestro daemon `knockd` ejecuta lo que queramos, que será típicamente `iptables` para abrir el puerto (`28123` en este ejemplo).

Veremos que HomeAssistant siempre conecta con `ha.tudominio.com:28123`, en casa o en internet. Si estoy en casa mi DNS Server resuelve con la IP privada correcta. Así no tengo que cambiar su configuración. 

**Instalación y activación**
  
```console
root@muro:~# apt install knockd
:
root@muro:~# systemctl enable knockd
```

Aquí tienes un ejemplo del fichero de configuración, **revísalo para adaptarlo a tu instalación**. 

- [/etc/knockd.conf](https://gist.github.com/LuisPalacios/6132bb17999934f5eb51cf186d94910f)

<br/>

#### OpenVPN

Para montar un Servidor de Acceso IPSec uso [OpenVPN](https://openvpn.net/) que sigue siendo la mejor solución, es fiable, rápido y seguro. Como cliente utilizo [Passepartout](https://passepartoutvpn.app/). 

* Si optas por **dejar siempre un puerto abierto**, esto es lo que iría en el fichero [firewall_1_pre_network.sh](https://gist.github.com/LuisPalacios/b648ef38206caa8c28cbc148a89ff364).

```bash
## ACCESO EXTERNO a mis Servicios
## IPSec como Servidor:  XXXXXX (Cambiar por el puerto donde escuchas en ipsec)
#  Dejé de usar esta opción para pasar a usar knockd.
#iptables -N CH_OPENPORTS
#iptables -A INPUT -p udp -m udp  -m multiport  --dports XXXXXX -m conntrack --ctstate NEW  -j CH_OPENPORTS  # OpenVPN en UDP
#if [ "${LOGSERVICIOS}" = "yes" ] || [ "${LOGALL}" = "yes" ]; then
#   iptables -A CH_OPENPORTS -j $LOGGING "CH_OPENPORTS -- OK "
#fi
#iptables -A CH_OPENPORTS -j ACCEPT
```

* Yo prefiero **abrir un puerto con el método de Llamar a la puerta**. Llamo a la puerta ([/etc/knockd.conf](https://gist.github.com/LuisPalacios/6132bb17999934f5eb51cf186d94910f)), se abre el puerto de OpenVPN y arranco mi cliente Passepartout.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-10.svg"
    caption="Uso knockd para abrir el puerto OpenVPN"
    width="500px"
    %} 

Este sería un ejemplo de configuración a modo de referencia, recomiendo **revisarlo**.

- [/etc/openvpn/server/muro_access_server.conf](https://gist.github.com/LuisPalacios/c60fc46dfc2867aa716820b63cd30b2e)

Te dejo un par de apuntes (algo antiguos pero válidos) como referencia para la instalación de OpenVPN.

- [Bridge Ethernet]({% post_url 2014-10-19-bridge-ethernet %}) sobre cómo extender la red de mi casa a un sitio remoto a través de internet, donde instalo y configuro OpenVPN
- [OpenVPN Server]({% post_url 2014-09-14-vpn-server-en-linux %}) donde describo describir cómo montar un servidor VPN casero sobre linux Gentoo. 

<br/>

----

<br/>

### Intranet

Vamos bajando por la casa y llegamos a la Intranet, cosas que he montado y algunos consejos humildes después de muchas experiencias negativas: 

- La red física: Dos switches principales, de 24 y 10 puertos de 1Gbe y luego switches pequeños en los cuartos. Tardé años aprovechando obras para ir tirando cables 🤗. Recomiendo encarecidamente cablear todo lo posible. No os fiéis del alcance y potencia de los AP's WiFi, un muro de carga o ciertos materiales pueden destrozarte la cobertura en un santiamén. 

- También desaconsejo (mucho) WiFi MESH, ese día que "pixela" el video, que falla la domótica (WiFi), que tus móviles se desasocian, que Homekit, Alexa o Google se va, en fin, te acordarás del cable!. Ya se que hay muchos casos donde no podemos pasar cable (o no nos dejan), pero lo recuerdo porque lo he sufrido.

- Si tienes la fortuna de casa nueva o obra enorme, no lo dudes ni un segundo. Cable a "todos" los espacios de la casa con CAQT6 minimo. Decidir dónde (techos o paredes) van a ir los AP's y dejar tirado CAT6 a esos puntos (alimentar los AP's vía POE). 

- Cuidado también con equipos WiFi super inteligentes que montan redes privadas en la WiFi, con NAT. Son equipos para consumo que desaconsejo encarecidamente. Si estás leyendo este apunte es que sabes de qué va esto. Huye de cualquier cosa que no te permite configurar transparentemente como tu quieras.

- Servicios de Red: Tengo un **Servidor DNS/DHCP sobre PiHole**, un controlador para los AP's, un **Proxy Inverso** y he probado algunas herramientas (opcionales) de monitorización como Gatus, Uptime Kuma, LibreNMS, Netdisco. Todo como VM/LXC's en mi(s) Host(s).

- Servicios de domótica: El networking de la casa da conectividad a Home Assistant, Node-RED, Zigbee2MQTT, Mosquito, Grafana e InfluxDB, como VM/LXC's en mi(s) Host(s). Permiten controlar y automatizar diferentes dispositivos en el hogar, como la iluminación, los sistemas de climatización, sensores, luces, enchufes, relés, las cerraduras y los electrodomésticos. La gran mayoría utilizan WiFi y algunos Zigbee (esta red no la cubro en este apunte).

<br/>


#### Hardware para VM/LXC

Ya lo he anticipado antes, utilizo una mezcla de máquinas virtuales y/o contenedores (Docker o LXC). Durante años usé un Host Linux con KVM/QEMU y hace poco cambié a [Proxmox VE](https://www.proxmox.com/en/proxmox-ve).

Poner todo los huevos en el mismo cesto no es aconsejable y los Tecky's lo sabemos bien. De hecho, cuando se me caía el "host" con mis VM's me quedaba sin casa 😂 y me caía la bronca. Hace poco he evolucionado a un Cluster Proxmox VE con 2xNUC's + 1xPi3B para hospedar las máquinas virtuales, contenedores LXC o Docker con servicios. La Pi es lo más barato que tenía para que el Cluster "negocie bien" la tolerancia a fallos, no tiene servicios.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-11.jpg"
    caption="Como decía, llevo tiempo complicando mi instalación"
    width="600px"
    %} 

<br/>

#### DNS y DHCP

Un Servicio fundamental. Mi servidor DNS y DHCP es [Pi-hole](https://pi-hole.net). Tengo un rango dinámico de IP's privadas y muchísimas IP's fijas (por MAC a todos los equipos y servidores fijos). Uso una CMDB casera muy simple en un fichero excel. Cuando hago cambios solo tengo que tocar un par de ficheros de PiHole. En internet mi dominio `tudominio.com` está siendo servido por mi proveedor de DNS, en la Intranet el mismo `tudominio.com` está siendo servidor por PiHole.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-12.svg"
    caption="Cómo hago la resolución de nombres"
    width="800px"
    %}

Cuando alguien de la Intranet pide un nombre lo hace a PiHole. Te recomiendo consultar este apunte sobre [Pi-hole casero]({% post_url 2021-06-20-pihole-casero %}) para entender mejor cómo funciona. 

* Un pequeño vistazo al fichero donde se hace la asignación estática para DHCP

```console
pihole $ sudo cat /etc/dnsmasq.d/04-pihole-static-dhcp.conf
dhcp-host=52:54:12:12:12:12,192.168.100.1,muro.tudominio.com
dhcp-host=00:08:22:37:0E:A1,192.168.100.2,equipo.tudominio.com

dhcp-host=38:34:D3:3E:DA:31,192.168.100.50,nodo1.tudominio.com
dhcp-host=38:F9:34:B7:36:96,192.168.100.51,nodo2.tudominio.com
```

* El fichero donde se asignan nombres DNS a direcciones IP.
  
```console
pihole $ sudo cat /etc/pihole/custom.list
192.168.100.1 muro.tudominio.com
192.168.100.2 equipo.tudominio.com
:
192.168.100.50 nodo1.tudominio.com
192.168.100.51 nodo2.tudominio.com
:
192.168.100.224 pihole.tudominio.com
```

<br/>

#### Proxy Inverso

Un proxy inverso es un servidor que actúa como intermediario entre los usuarios y los servidores web que hay detrás de él. Cuando hago una solicitud a un sitio web (de mi intranet), en lugar de enviar la solicitud a él, se envía al proxy inverso y este a su vez al servidor web correspondiente. Permite que el navegador use `https` con el proxy inverso, aunque este a su vez use `http` con el Web original. 

He montado varios servicios que administro vía Navegador y quiero usar `https` con certificados válidos generados con [Let's Encrypt](https://letsencrypt.org/es/). Para configurarlo necesito solicitar un certificado para cada nombre del servidor Web. 

Por lo tanto, necesito dar de alta los nombres tanto en mi proveedor DNS de internet (porque Let's Encrypt necesita verificar que soy el propietario) como en mi intranet.

**Configuración DNS**

Doy de alta los nombres de aquellos equipos Web a los que quiero llegar en ambos sitios: 

- En Internet (proveedor de DNS dinámico): Varios registros de tipo 'A' contra el mismo usuario, de modo que al cambiar la IP dinámica de dicho usuario se aplique la misma IP a todos; es decir, todos resolverán a mi misma IP pública.

```consola
    git.tudominio.com            Usuario: MiUsuarioEnMiProveedor 
    grafana.tudominio.com        Usuario: MiUsuarioEnMiProveedor
    ha.tudominio.com             Usuario: MiUsuarioEnMiProveedor
    kuma.tudominio.com           Usuario: MiUsuarioEnMiProveedor
    librenms.tudominio.com       Usuario: MiUsuarioEnMiProveedor
    sol.tudominio.com            Usuario: MiUsuarioEnMiProveedor
    tierra.tudominio.com         Usuario: MiUsuarioEnMiProveedor
```

- En Intranet, en Pihole, los doy de alta apuntando todos a la misma IP, la de mi (futuro) Nginx Proxy Manager.

```consola
    git.tudominio.com            192.168.100.243
    grafana.tudominio.com        192.168.100.243
    ha.tudominio.com             192.168.100.243
    kuma.tudominio.com           192.168.100.243
    librenms.tudominio.com       192.168.100.243
    sol.tudominio.com            192.168.100.243
    tierra.tudominio.com         192.168.100.243
```

<br/> 

**Instalación de Contenedor LXC [Nginx Proxy Manager](https://nginxproxymanager.com)** 

Empiezo con la instalación de mi Proxy Inverso. Utilizo NPM (Nginx Proxy Manager) porque es muy rápido, ligero y además soporta las tres cosas que necesito: Proxy Inverso con soporte de `https`, gestión de Certificados SSL con Let's Encrypt y Port Forwarding (lo llama Streams).

* Creo un contenedor LXC en Proxmox VE [mediante un Helper Script](https://tteck.github.io/Proxmox/): 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-13.png"
    caption="Instalación de Contenedor LCX usando un Helper Script"
    width="700px"
    %} 

Desde la consola de uno de mis Host lanzo el proceso de instalación: 

```console
root@pve-sol:~# LANG=C bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/nginxproxymanager.sh)"
```

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-14.png"
    caption="Contesto todas las preguntas y se crea el Contenedor LCX"
    width="800px"
    %} 

Hago la configuración a través de su interfaz Web

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-15.png"
    caption="Varios Proxy Hosts, Certificados y un Stream"
    width="600px"
    %} 

* Definición de los Proxy Hosts

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-16.png"
    caption="Lista de Proxy Hosts"
    width="600px"
    %} 

Hago un paréntesis: Para el Proxy Host de Home Assistant he hecho una configuración personalizada para que funcione correctamente Visual Studio Code Server. También te pongo qué hay que configurar en el `configuration.yaml`de Home Assistant.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-20.png"
    caption="Configuración de un port forwarding"
    width="400px"
    %} 


```yaml
## Sección en el configuration.yaml de Home Assistant
## para que funcione bien a través de un Proxy Inverso
http:
  use_x_forwarded_for: true
  trusted_proxies:
  - 192.168.100.243 ### IP del Nginx Proxy Manager LXC ###
```  

* Configuración de Certificados con Let's Encrypt. Para poder crear y renovar los certificados necesitas que Let's Encrypt valide que eres quien dices ser. Utiliza dos métodos y dependiendo de qué soporte tu proveedor de dominios deberás usar uno u otro. 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-17.png"
    caption="Lista de Certificados vía Let's Encrypt"
    width="600px"
    %} 


- Método DNS Challenge: Este método es el mejor, no necesitas abrir ningún puerto en tu router, pero *tu proveedor DNS tiene que estar en la lista de los soportados por Let's Encrypt*. Si no está o no puedes crear registros TXT dinámicamente en tu proveedor entonces tienes que usar el método manual. 

- Método Manual: Este método necesita que abras, al menos temporalmente, el puerto 80 en tu router y firewall, además necesitas que tu proveedor DNS resuelva correctamente el subdominio sobre el cual quieres solicitar el certificado.

Yo uso el método manual con un par de scripts. Antes de solicitar o renovar el certificado abro ejecutando `open-npm-letsencryp.sh` desde mi router Linux. Cuando acaba todo vuelvo a cerrar con `close-npm-letsencrypt.sh`.

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-22.png"
    caption="Tipo de comunicación con Let's Encrypt"
    width="600px"
    %} 

- [open-npm-letsencrypt.sh](https://gist.github.com/LuisPalacios/3cff94bf807965b448d59523537eb9a6)
- [close-npm-letsencrypt.sh](https://gist.github.com/LuisPalacios/c10af93c6d3be7b1c5796899ad57d3f4)


* Todos los Proxy Hosts tienen activo el Websockets Support y Force SSL en el Certificado

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-19.png"
    caption="Configuración de un port forwarding"
    width="600px"
    %} 

* Configuración de un Stream (Port Forwarding)

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-18.png"
    caption="Configuración de un port forwarding"
    width="600px"
    %} 

¿Qué es esto de Port Forwarding para mi servidor Git?. Pues que si quiero usar el mismo nombre DNS para hacer `https` para la administración y `ssh` para sincronizar los repositorios, tengo que hacer un pequeño invento. Consiste en dar de alta un Proxy Host para la parte `https` y un Port Forwarding (Stream) para la parte de `ssh`. Así paso a tener disponible `https://git.tudominio.com` y `git@git.tudominio.com:privado/repositorio.git` para hacer commits, etc. Además me permite (previo knock, knock) acceder desde internet. 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-networking-avanzado-21.png"
    caption="Detalle del port forwarding"
    width="300px"
    %} 


Cuando conecto desde Internet, con cualquiera de los tres primeros, vía `https`, conectaré con mi IP pública, me dejará entrar porque he llamado previamente a la puerta con `knockd` (como vimos en la sección de Internet), y mi router/firewall hace port-forwarding hacia NPM (Nginx Proxy Manager), que gracias al nombre que viene en la petición https reenvía a su vez hacia la IP del servicio concreto en la Intranet.

Cuando estoy en casa y conecto desde la Intranet, con cualquiera de esos nombres o de los adicionales vía `https`, mi DNS Server interno resuelve a la IP interna de mi NPM (Nginx Proxy Manager), que por el nombre me deriva a su vez al servicio concreto.


<br/>
