---
title: "Domótica y Networking"
date: "2023-04-08"
categories: ["administración"]
tags: ["domótica","networking","avanzado","linux","pve","proxmox","kvm","qemu","cloud-init","alpine","lxc","ubuntu","plantilla","virtualización"]
draft: false
cover:
  image: "/img/posts/logo-homenet.svg"
  hidden: true
---


<img src="/img/posts/logo-homenet.svg" alt="logo linux router" width="150px" height="150px" style="float:left; padding-right:25px"  />

Comparto mi **networking doméstico** con la opción de *llamar a la puerta* para accesos puntuales desde Internet. Las redes caseras de hoy en día acaban soportando múltiples servicios y con la irrupción de la domótica se complica la cosa, así que he decidido documentarlo para no perderme en el futuro.

El número de dispositivos crece y mantener la red de un hogar inteligente y automatizado se convierte en una prioridad. Dedico el apunte a esos *Geeks* o *Techys* que, como yo, llevamos tiempo metidos en la *complicación del networking en una red casera domotizada*.

<br clear="left"/>
<!--more-->

## Punto de partida

El objetivo es que el diseño soporte *muchos cacharros variopintos*, vía LAN/WiFi, que se puedan usar certificados con `https`, poder entrar *llamando a la puerta* desde intenet y ya por pedir, que la domótica siga funcionando si cae internet o la WiFi (que haya unos mínimos).

¿Cuanto puede crecer tu red? pues sin darte cuenta, sumando switches, AP's, servidores físicos, virtuales, sensores, relés, actuadores, clientes, etc. el otro día veía 122 IP's únicas 😱 en mi router Linux.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-01.png" alt="Nos quedamos cortos pronosticando los dispositivos conectados" width="400px" />
  <div class="image-caption">Nos quedamos cortos pronosticando los dispositivos conectados</div>
</div>

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

Cuando tienes conocimientos de routing y switching mi **recomendación es poner detrás un router propio + switch(es) + AP(s)** y desactivar el WiFi del Proveedor 😆. El beneficio principal es que pasas a tener un control total, incluso permite añadir extras: por ejemplo lo de llamar a la puerta abriendo puertos bajo demanda, levantar túneles ipsec, silenciar los pings (solo si conectas directamente al ONT), identificar intentos de ataques, control del tráfico VoIP e IPTV y otros.

Partiendo de esta premisa, tengo tres opciones.

<br/>

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-02.svg" alt="Para un control total pongo mi propio router" width="800px" />
  <div class="image-caption">Para un control total pongo mi propio router</div>
</div>

<br/>

- **Estándar**: Conecto mi Router al del Proveedor y recibo IP privada (`192.168.1.0/24`).
  - Desventajas: Hay que hacer dos veces Port Forwarding. Pierdes el control de VoIP/IPTV (si lo tienes contratado). Puede "salirte rana" el router del Proveedor y darte problemas de rendimiento y/o cuelgues. Si haces NAT en "MiRouter" estás haciendo doble NAT y eso no suele gustar. Si no haces NAT en "MiRouter" entonces hay que dar de alta las rutas de la intranet en el router del proveedor, que no me mola.
  - Ventajas: No tocas el servicio del Proveedor que suele ser suficientemente estable. El soporte funciona y no hay que dar explicaciones.
- **Modo Bridge**: Se comporta como un ONT, recibes todas las VLAN's. No lo he configurado nunca pero entiendo que sus ventajas y desventajas son las mismas que el punto siguiente (ONT),
- **ONT**: Conecto mi Router al *Optical Network Termination*, a su puerto ETH1, me presenta las 3 VLANs: 6 para Datos, 2 para IPTV y 3 para VoIP.
  - Desventajas: Si no tienes experiencia en routing/switching tendrás muchos problemas.
  - Ventajas: Definitivamente control total, incluyendo tráfico IPTV/VoIP además de evitar el doble port-forwaring y doble NAT.

¿Cuál recomiendo?

- Si tienes el ONT, es la mejor opción. Llevo usándolo años, cuando Movistar lo instalaba junto con el router. Por desgracia hoy en día no se puede pedir en un alta nueva.

- Modo bridge - si puedes y tu router lo soporta sería mi segunda opción. Ojo!, hay routers (p.ej GPT-2841GX4X5) que no soportan esta modalidad.

- Modo estándar - sería la última si no me quedase más remedio. Ojo!, vale para todo lo que explico en este apunte pero me incomoda el uso de doble port forwarding, el posible doble NAT o tener que poner las estáticas a mi intranet, tener que abrir demasiados puertos y la pérdida del control total de VoIP e IPTV.

<br/>

#### Router

En mi caso tengo ONT y uso **Linux** sobre máquina virtual, con su **routing nativo** e `iptables`. **Deniego todo el tráfico de entrada** y hago **Masquerade en salida**. Tienes otras opciones más fáciles, como usar [OpenWrt](https://openwrt.org), [IPFire](https://www.ipfire.org) o [pfSense](https://www.pfsense.org) (solo intel). También puede irte a hardware dedicado estilo Mikrotik o router neutro. Por cierto, si te gusta OpenWrt o IPFire hay una opción barata con Raspberry Pi 4B con 1GB.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-03.svg" alt="La seguridad es completa, por defecto no entra nada" width="500px" />
  <div class="image-caption">La seguridad es completa, por defecto no entra nada</div>
</div>

Volviendo a mi instalación (la de la derecha en la figura). El hardware que uso para mi máquina virtual es un Host NUC de Intel. Siempre te hará falta un Switch (mínimo uno de 8xGbe con soporte de VLAN's e IGMP) y AP's con soporte de Roaming para la WiFi.

En el gráfico dejo cómo sería la conexión física en la modalidad "Estándar" (no es mi caso). Si lo conectas así yo pondría el Router del Operador a un puerto de **Acceso** de mi switch y el Host con mi Router a un puerto TRUNK. Cearía una VLAN exclusiva para que puedan verse el router del Operador con el mío (por ejemplo `VLAN 192`) y subnet `192.168.1/24` y dejaría la `VLAN 100` para mi casa y mi propia subnet `192.168.100/24`. No es obligatorio hacer Masquerade en la modalidad Estándar, pero yo lo prefiero (aunque haya doble NAT en salida) porque no quiero dar de alta todas las rutas estáticas en el router del operador.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-04.svg" alt="Representacion física de conexión" width="800px" />
  <div class="image-caption">Representacion física de conexión</div>
</div>

En mi caso (que conecto directo al ONT), a nivel físico tanto mi Host como el ONT a puertos TRUNK del Switch (puerto del ONT vlan's 2,3,6 y puerto del Host vlan's 2,3,6,100). Hablaré `PPPoE` por la `vlan6` y la `VLAN 100` para mi casa y mi propia subnet `192.168.100/24`.

Como distribución Linux me he decantado por **[Ubuntu 22.04 LTS](https://ubuntu.com/blog/tag/LTS)**, robusto y fácil de mantener. Lo instalé usando la [Plantilla de VM en Proxmox]({{< relref "2023-04-07-proxmox-plantilla.md" >}}) (luego explico qué es Proxmox). Concedo acceso a las vlan's 2,3,6,100. Una vez que tengo activo mi Linux termino su instalación con algunas herramientas, eliminando `cloud-init` y preparando el fichero `netplan`.

```shell
root@muro:~# apt install qemu-guest-agent
root@muro:~# apt install nano net-tools iputils-ping tcpdump ppp
:
root@muro:~# rm -fr /etc/cloud
root@muro:~# apt purge -y cloud-init
root@muro:~# rm /etc/netplan/50-cloud-init.yaml
```

Netplan para la configuración de red.

```shell

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

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-05.png" alt="Configuro la tarjeta para que reciba el TRUNK" width="600px" />
  <div class="image-caption">Configuro la tarjeta para que reciba el TRUNK</div>
</div>

Verifico que el router Linux reciba el Trunk. En el caso de Proxmox basta con dejar vacío el campo `VLAN Tag`. Ah! también **recomiendo quitar la opción `Firewall` en las opciones**. No se porqué, pero me dió problemas con `IGMP` mullticast a pesar de tenerlo desactivado a nivel global.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-06.svg" alt="El Router software se encarga de conmutar de forma segura" width="600px" />
  <div class="image-caption">El Router software se encarga de conmutar de forma segura</div>
</div>

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

```shell
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

```shell
# chmod 755 /usr/bin/cdmon_update.sh
# systemctl enable cdmon_update.timer
```

Cada 5 minutos mira a ver si ha cambiado la IP y si es así la actualiza. Tengo dados de alta varios registros de tipo `'A'` resolviendo a la misma IP Pública de mi casa:

- Home Assistant -> `ha.tudominio.com`,
- SSH -> `ssh.tudominio.com`,
- :

Resolución de nombres desde internet:

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-07.svg" alt="Cómo hago la resolución de nombres" width="800px" />
  <div class="image-caption">Cómo hago la resolución de nombres</div>
</div>

Luego veremos cómo lo hago en mi Intranet. Te anticipo que cuento con un servidor DNS interno que sirve el mismo dominio (`tudominio.com`) en local, entregando IP's privadas de casa. Este donde esté (internet o intranet) las App's siempre saben cómo llegar a los servicios caseros.

<br/>

#### Llamar a la puerta

Durante años he usado varias técnicas para protegerme de ataques y desde hace tiempo he optado por no abrir ningún puerto. Mi router descarta/tira todos los paquetes que llegan desde internet, siempre. Bueno, casi siempre. Hay un par de servicios a los que sí que me gustaría poder acceder desde Internet: levantar un túnel `ssh` o `ipsec` para hacer una administración puntual y acceso a mi servidor *Home Assistant* para la domótica.

Descubrí la técnica del **Port Knocking** (llamar a la puerta) y me gustó mucho. Se trata de un App que envia 3 o 4 paquetes especiales al Router/Firewall para que reconozca que estás "llamando a la puerta" y si llamas como a él le gusta te abre temporalmente (solo a la IP desde la que llamo) el puerto del servicio que quieras consumir.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-08.jpg" alt="Aplicaciones involucradas" width="300px" />
  <div class="image-caption">Aplicaciones involucradas</div>
</div>

Uso **PortKnock** (App para smartphone): lanza la petición (1) Ábreme el puerto para llegar a Home Assistant (envía una serie de paquetes con una cadencia determinada), el router/firewall se da por enterado y abre durante un rato el puerto `p.ej. 28123`. (2) **Home asistant** pueda entrar.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-09.svg" alt="Así funciona *Llamar a la puerta*" width="800px" />
  <div class="image-caption">Así funciona *Llamar a la puerta*</div>
</div>

Podemos configurar cuántos toques se dan a la puerta y a qué puertos. Deben coincidir en el servidor y cliente. Por ejemplo, dar tres toques cada segundo sería: Envía un `SYN` al puerto #1, espera un segundo, un `SYN` al puerto #2, espera otro segundo y envía un último `SYN` al puerto #3. En ese instante nuestro daemon `knockd` ejecuta lo que queramos, que será típicamente `iptables` para abrir el puerto (`28123` en este ejemplo).

Veremos que HomeAssistant siempre conecta con `ha.tudominio.com:28123`, en casa o en internet. Si estoy en casa mi DNS Server resuelve con la IP privada correcta. Así no tengo que cambiar su configuración.

**Instalación y activación**

```shell
root@muro:~# apt install knockd
:
root@muro:~# systemctl enable knockd
```

Aquí tienes un ejemplo del fichero de configuración, **revísalo para adaptarlo a tu instalación**.

- [/etc/knockd.conf](https://gist.github.com/LuisPalacios/6132bb17999934f5eb51cf186d94910f)

<br/>

#### OpenVPN

Para montar un Servidor de Acceso IPSec uso [OpenVPN](https://openvpn.net/) que sigue siendo la mejor solución, es fiable, rápido y seguro. Como cliente utilizo [Passepartout](https://passepartoutvpn.app/).

- Si optas por **dejar siempre un puerto abierto**, esto es lo que iría en el fichero [firewall_1_pre_network.sh](https://gist.github.com/LuisPalacios/b648ef38206caa8c28cbc148a89ff364).

```shell
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

- Yo prefiero **abrir un puerto con el método de Llamar a la puerta**. Llamo a la puerta ([/etc/knockd.conf](https://gist.github.com/LuisPalacios/6132bb17999934f5eb51cf186d94910f)), se abre el puerto de OpenVPN y arranco mi cliente Passepartout.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-10.svg" alt="Uso knockd para abrir el puerto OpenVPN" width="500px" />
  <div class="image-caption">Uso knockd para abrir el puerto OpenVPN</div>
</div>

Este sería un ejemplo de configuración a modo de referencia, recomiendo **revisarlo**.

- [/etc/openvpn/server/muro_access_server.conf](https://gist.github.com/LuisPalacios/c60fc46dfc2867aa716820b63cd30b2e)

Te dejo un par de apuntes (algo antiguos pero válidos) como referencia para la instalación de OpenVPN.

- [Bridge Ethernet]({{< relref "2014-10-19-bridge-ethernet.md" >}}) sobre cómo extender la red de mi casa a un sitio remoto a través de internet, donde instalo y configuro OpenVPN
- [OpenVPN Server]({{< relref "2014-09-14-vpn-server-en-linux.md" >}}) donde describo describir cómo montar un servidor VPN casero sobre linux Gentoo.

<br/>

----

<br/>

### Intranet

Vamos bajando por la casa y llegamos a la Intranet, cosas que he montado y algunos consejos humildes después de muchas experiencias negativas:

- La red física: Dos switches principales, de 24 y 10 puertos de 1Gbe y luego switches pequeños en los cuartos. Tardé años aprovechando obras para ir tirando cables 🤗. Recomiendo encarecidamente cablear todo lo posible. No os fiéis del alcance y potencia de los AP's WiFi, un muro de carga o ciertos materiales pueden destrozarte la cobertura en un santiamén.

- También desaconsejo (mucho) WiFi MESH, ese día que "pixela" el video, que falla la domótica (WiFi), que tus móviles se desasocian, que Homekit, Alexa o Google se va, en fin, te acordarás del cable!. Ya se que hay muchos casos donde no podemos pasar cable (o no nos dejan), pero lo recuerdo porque lo he sufrido.

- Si tienes la fortuna de casa nueva o una obra, no lo dudes, cable a "todos" los espacios de la casa con CAT6 minimo. También a techos o paredes donde irán los AP's (mejor alimentarlos con PoE).

- Cuidado también con equipos WiFi demasiado inteligentes que montan redes privadas en la WiFi y te obligan a hacer NAT. Son equipos para consumo que desaconsejo; suelo huir de tecnologías que no te permite configurar transparentemente como tu quieras.

- Servicios de Red: Tengo un **Servidor DNS/DHCP sobre PiHole**, un controlador para los AP's, un **Proxy Inverso** y he probado algunas herramientas (opcionales) de monitorización como Gatus, Uptime Kuma, LibreNMS, Netdisco. Todo como VM/LXC's en mi(s) Host(s).

- Servicios de domótica: El networking de la casa da conectividad a Home Assistant, Node-RED, Zigbee2MQTT, Mosquito, Grafana e InfluxDB, como VM/LXC's en mi(s) Host(s). Permiten controlar y automatizar diferentes dispositivos en el hogar, como la iluminación, los sistemas de climatización, sensores, luces, enchufes, relés, las cerraduras y los electrodomésticos. La gran mayoría utilizan WiFi y algunos Zigbee (esta red no la cubro en este apunte).

<br/>

#### Hardware para VM/LXC

Ya lo he anticipado antes, utilizo una mezcla de máquinas virtuales y/o contenedores (Docker o LXC). Durante años usé un Host Linux con KVM/QEMU y hace poco cambié a [Proxmox VE](https://www.proxmox.com/en/proxmox-ve).

Poner todo los huevos en el mismo cesto no es aconsejable y los Tecky's lo sabemos bien. De hecho, cuando se me caía el "host" con mis VM's me quedaba sin casa 😂 y me caía la bronca. Hace poco he evolucionado a un Cluster Proxmox VE con 2xNUC's + 1xPi3B para hospedar las máquinas virtuales, contenedores LXC o Docker con servicios. La Pi es lo más barato que tenía para que el Cluster "negocie bien" la tolerancia a fallos, no tiene servicios.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-11.jpg" alt="Como decía, llevo tiempo complicando mi instalación" width="600px" />
  <div class="image-caption">Como decía, llevo tiempo complicando mi instalación</div>
</div>

<br/>

#### DNS y DHCP

Utilizo [Pi-hole](https://pi-hole.net) como servidor DNS y DHCP. Para DHCP uso un rango dinámico y muchas IP's fijas (por MAC). Mi dominio interno es exactamente el mismo que el externo: `tudominio.com`.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-12.svg" alt="DNS y DHCP en mi intranet" width="500px" />
  <div class="image-caption">DNS y DHCP en mi intranet</div>
</div>

Cuando se pide desde **Internet** un nombre bajo `tudominio.com` se entrega mi IP pública (que actualizo dinámicamente). Cuando se lanza una consulta DNS desde la **Intranet** siempre se hace a PiHole, si es un nombre bajo `tudominio.com` entregará una IP privada directamente, si es cualquier otro nombre irá a averiguarlo a su siguiente nivel (DNS Servers de Movistar por ejemplo).

Te recomiendo consultar este apunte sobre [Pi-hole casero]({{< relref "2021-06-20-pihole-casero.md" >}}) para entender mejor cómo funciona. En casa uso una CMDB muy simple en un fichero excel para llevar el control de MAC->IP privada y actualizo un par de ficheros de PiHole cuando hay cambios.

<br/>

#### Proxy Inverso

Un proxy inverso es un servidor que actúa como intermediario entre los usuarios y los servidores web que hay tras él. Cuando se solicita un sitio web, en lugar de enviarle la solicitud, se envía al proxy inverso y este a su vez al servidor web. Permite que el navegador use `https` con el proxy inverso y este use `http` con el Web original.

Podré usar `https` con certificados válidos generados con [Let's Encrypt](https://letsencrypt.org/es/), con un certificado para cada nombre del servidor Web al que quiero llegar. Todas mis sesiones `https` quedan centralizadas a través de él.

**Configuración DNS**

Veamos con ejemplos la configuración. Tengo los servicios *git, grafana y home assistant*. Quiero poder llegar vía `https` a los tres y además `ssh` al servidor *git*.

- En **Internet** mantengo un registro `A` para cada uno y todos resuelven a mi misma IP pública (w.x.y.z), que actualizo dinámicamente.

```consola
    git.tudominio.com            w.x.y.z
    grafana.tudominio.com        w.x.y.z
    ha.tudominio.com             w.x.y.z
```

- En la **Intranet** esos mismos nombres resuelven A la IP del Proxy Inverso. También tengo nombres para los host reales de mis máquinas virtuales donde están los servicios.

```consola
git.tudominio.com          192.168.100.243  <- VM de mi Proxy Inverso (NPM)
grafana.tudominio.com      192.168.100.243  <- VM de mi Proxy Inverso (NPM)
ha.tudominio.com           192.168.100.243  <- VM de mi Proxy Inverso (NPM)
    :
vm-git.tudominio.com       192.168.100.XXX  <- VM del servidor Gitea
vm-grafana.tudominio.com   192.168.100.YYY  <- VM del servidor con grafana e influxdb
vm-ha.tudominio.com        192.168.100.ZZZ  <- VM de HASS (Home Assistant)
```

La foto final quedaría así:

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-13.svg" alt="Cómo hago la resolución de nombres completa" width="800px" />
  <div class="image-caption">Cómo hago la resolución de nombres completa</div>
</div>

<br/>

**Configuración Proxy Inverso:**

Utilizo [Nginx Proxy Manager](https://nginxproxymanager.com) (NPM) como Proxy Inverso, porque es rápido, ligero y soporta lo que necesito, `https` con gestión de Certificados SSL vía Let's Encrypt y Port Forwarding (lo llama Streams).

Lo instalo como **Contenedor LXC** en Proxmox VE. Conecto con [Proxmox VE Helper-Scripts](https://community-scripts.github.io/ProxmoxVE/scripts) > **`Webservers & Proxies`**. Ocupa poca memoria y su arranque es ultra rápido.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-14.png" alt="Instalación de Contenedor LXC usando un Helper Script" width="700px" />
  <div class="image-caption">
    <a href="https://github.com/community-scripts/ProxmoxVE" target="_blank" rel="noopener noreferrer">
      Los helper scripts son un proyecto open source
    </a>
  </div>
</div>

La instalación se hace desde la consola de uno de mis Host:

```shell
root@pve-sol:~# LANG=C bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/nginxproxymanager.sh)"
```

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-15.png" alt="Contesto todas las preguntas para crear el Contenedor LXC" width="800px" />
  <div class="image-caption">Contesto todas las preguntas para crear el Contenedor LXC</div>
</div>

<br/>

**Configuración de Proxy Hosts**

Proxy Hosts creados a través de su interfaz Web.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-16.png" alt="Varios Proxy Hosts, Certificados y un Stream" width="600px" />
  <div class="image-caption">Varios Proxy Hosts, Certificados y un Stream</div>
</div>

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-17.png" alt="Lista de Proxy Hosts" width="600px" />
  <div class="image-caption">Lista de Proxy Hosts</div>
</div>

Ejemplo de **Proxy Host** de *Home Assistant*.

| *Domain Name* | *Nombre con el que se accede al servicio vía `https`*, por ejemplo `ha.tudominio.com`. Por omisión el puerto por el que escucha es el estándar: `443` (excepto Grafana, ver *Parámetros avanzados*). Estamos hablando de la conexión entre el Navegador y NPM |
| *Scheme* | La forma en la que se llega al servidor web que hay detrás, típicamente será `http`. Esta es la conexión entre NPM y el Web Server |
| *Forward Hostname/IP* | Nombre del servidor web que hay detrás o su IP, por ejemplo `vm-ha.tudominio.com` o su IP `192.168.100.ZZZ` (yo uso la IP) |
| *Forward Port* | Número de puerto por el que escucha el servidor web que ha detrás, por ejemplo `8123` |
| *Websockets Support* | Siempre lo activo. No suelo activar *Cache Assets* ni *Block Common Exploits*  |
| Custom Locations | No añado nada|
| SSL | Aquí añadiré el Certificado de `ha.tudominio.com` más adelante, cuando lo pida a Let's Encrypt en el siguiente paso. Siempre activaré la opción *Force SSL* |
| Advanced | No añado nada, excepto para Home Asssistant y Grafana, ver *Parámetros avanzados* más adelante |

Esta es la configuración de Certificados con Let's Encrypt. Para poder crear y renovar los certificados necesitas que Let's Encrypt valide que eres quien dices ser. Primero tu proveedor DNS debe resolver correctamente el subdominio sobre el cual estás solicitando el certificado (en este ejemplo de Home Assistant sería `ha.tudominio.com`). Segundo y más importante, confirmarlo con uno de los dos métodos siguientes.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-18.png" alt="Lista de Certificados vía Let's Encrypt" width="600px" />
  <div class="image-caption">Lista de Certificados vía Let's Encrypt</div>
</div>

- Método *DNS Challenge*: Es el mejor, no necesitas abrir ningún puerto en tu router.  *Tu proveedor DNS tiene que estar en la lista de los soportados por Let's Encrypt*. Si no está ni tampoco puedes crear registros TXT dinámicamente, tendrás que usar el método manual.

- Método *Manual*: Me fuerza a abrir temporalmente el puerto 80. Desde Let's Encrypt necesita hablar por ese puerto (y no otro) con un web server temporal que levanta NPM.

Yo uso el método manual y un par de scripts, [open-npm-letsencrypt.sh](https://gist.github.com/LuisPalacios/3cff94bf807965b448d59523537eb9a6) para abrir el puerto `80` antes de solicitar o renovar el certificado y cuando acaba vuelvo a cerrarlo con [close-npm-letsencrypt.sh](https://gist.github.com/LuisPalacios/c10af93c6d3be7b1c5796899ad57d3f4).

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-19.png" alt="Tipo de comunicación con Let's Encrypt" width="600px" />
  <div class="image-caption">Tipo de comunicación con Let's Encrypt</div>
</div>

<br/>

**Parámetros avanzados**

- **Home Assistant**

**En la VM de NPM:** *Proxy Hosts >* **Home Assistant** *> Advanced >* **Custom Nginx Configuration**.

```conf
# Para que Visual Studio Server funcione correctamente.
location / {
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection $http_connection;
  proxy_http_version 1.1;
  proxy_set_header X-Forwarded-Host $http_host;
  include /etc/nginx/conf.d/include/proxy.conf;
}
```

**En Home Assistan:** Settings > System > Network: `http://192.168.100.ZZZ:8123`

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-20.png" alt="URL por la que escucha HASS" width="400px" />
  <div class="image-caption">URL por la que escucha HASS</div>
</div>

Y en su fichero `configuration.yaml` para que acepte peticiones de un proxy inverso:

```yaml
## Sección en el configuration.yaml de Home Assistant
## para que funcione bien a través de un Proxy Inverso
http:
  use_x_forwarded_for: true
  trusted_proxies:
  - 192.168.100.243 ### IP del Nginx Proxy Manager LXC ###
```

- **Grafana**

**En la VM de NPM:** *Proxy Hosts >* **Grafana** *> Advanced >* **Custom Nginx Configuration**.

```conf
# Para que NPM también escuche por el puerto `48123` además del `443` para grafana
listen 48123 ssl http2;
```

**En la VM de Grafana:** Fichero `/etc/grafana/grafana.ini`

```conf
[server]
protocol = http
http_port = 3000
```

<br/>

**Configuración de Stream (Port Forwarding)**

Para aclarar la nomenclatura, he visto que NPM llama **Stream** al hecho de hacer **Port Forwarding**. Permite reenviar todo lo que recibe por un puerto hacia otro equipo por el mismo u otro puerto. **Hago Port Forwarding del puerto `22` hacia mi servidor GIT en la Intranet.**

| ¡¡¡ MUY IMPORTANTE !!! Antes de hacer Port Forwarding del puerto `ssh (22)` en el **Nginx Proxy Manager** es importantísimo cambiar el puerto por el que escucha su propio daemon `sshd` por uno alternativo o perdería el aceso vía `ssh` al NPM. He documentado en el apunte [Socketed SSH]({{< relref "2023-04-14-ssh-socket.md" >}}) cómo se hace (en un Contenedor LXC con Ubuntu, donde he montado mi NPM). |

¿Porqué quiero hacer Port Forwarding hacia mi servidor Git?. Pues porque quiero usar `ssh` como método de comunicación para conectar con `git@git.tudominio.com:...` (commits, push, pull, etc...) y además usar el mismo nombre DNS que uso para administrar mi servidor Git vía `https`: `https://git.tudominio.com`.

Como Git usa el puerto (fijo) `22` cuando uso la nomenclatura `git@git.tudominio.com` no me queda más remedio que hacer algún truco para redirigir dicho puerto en mi NPM.

Como ya había dado de alta un Proxy Host para la parte `https` solo me falta añadir el Stream para reenviar el tráfico del puerto `22` hacia mi servidor Git en la intranet.

<div class="image-box">
  <img src="/img/posts/2023-04-08-networking-avanzado-21.png" alt="Configuración de un port forwarding" width="600px" />
  <div class="image-caption">Configuración de un port forwarding</div>
</div>

Ahora tengo disponible `https://git.tudominio.com (puerto 443)` para administrar y `git@git.tudominio.com:repositorio.git (puerto 22)` para trabajar con mi Git server privado. Lo mejor es que también es compatible con el acceso, previo *knock, knock*, desde internet.

<br/>
