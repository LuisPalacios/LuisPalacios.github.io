---
title: "Router Linux para Movistar"
date: "2014-10-05"
categories: linux
tags: movistar mac iptables router
excerpt_separator: <!--more-->
---

![logo linux router](/assets/img/posts/logo-linux-router.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

Este apunte describe qué hay detrás (a nivel técnico) del servicio IP que nos ofrece Movistar Fusión FTTH (Fibra) y como sustituir el router que nos instalan por un equipo basado en GNU/Linux, que hará de Router (junto con un Switch Ethernet) para ofrecer los mismos servicios de Datos, Televisión (IPTV) y Voz (VoIP).

Después de leer este apunte te recomiendo que sigas con el apunte sobre cómo hacer que funcionen los [videos bajo demanda para Movistar]({% post_url 2014-10-18-movistar-bajo-demanda %}) y el apunte sobre un laboratorio para extender con un [Bridge Ethernet]({% post_url 2014-10-19-bridge-ethernet %}) tu red local a un sitio remoto.

<br clear="left"/>
<!--more-->

| Actualización 2023: Este apunte tiene muchos años y tras la incorporación de DRM ya no es posible ver los canales con `VLC`, `OpenELEC` o `TVheadend`, pero la posibilidad de cambiar el Router de Movistar por un router Neutro o un Linux siguen estando vigentes, siempre que tengas la ONT o el Router de Movistar modo Bridge Puro / ONT. |

## Punto de partida

Veamos cual es la instalación que nos queda cuando instalan "la fibra". El cable "negro" que nos llega a casa es una fibra (monomodo 657-A2) que el técnico "empalma" dentro de una roseta de tipo ICT-2, que a su vez ofrece un conector SC/APC de salida. De dicho conector sale un latiguillo de fibra estándar al ONT y desde ahí salen dos cables, uno de teléfono que normalmente conectan a la entrada de teléfono de tu casa y otro Ethernet que se conecta al router.

{% include showImagen.html
    src="/assets/img/posts/mv-partida.png"
    caption="Configuración inicial Movistar Fibra"
    width="600px"
    %}

El **ONT** es el equipo que termina la parte "óptica", sus siglas singnifican Optical Network Termination y se encarga de convertir la señal óptica a eléctrica, en concreto ofrece un interfaz Ethernet tradicional (utilizo el puerto ETH1). Salvando mucho, pero que mucho las distancias, vendría a ser algo parecido al PTR de una línea de teléfono analógica cuando teníamos ADSL.

El siguiente equipo es el **Router**, que va a recibir, desde el ONT a través del cable Ethernet, tres VLAN's; una para cada servicio: VLAN-6 para "datos", VLAN-2 para IPTV y VLAN-3 para VoIP. Su función consiste en conmutar entre la VLAN apropiada y la "intranet" dependiendo de qué servicio consuma y/o qué configuración tenga el cliente (decodificador, ordenador, teléfono).

<br/>

## Objetivo Final

Consiste en sustituir el Router de Movistar por un equipo con Linux (yo uso **Gentoo**) junto con un Switch Ethernet y poder ofrecer los tres servicios: Datos, IPTV y VoIP. 

Necesitamos un switch porque necesitamos sus puertos ethernet y sobre todo porque es mucho más sencillo (y barato) que instalar tarjetas de puertos ethernet en tu Linux... Importantísimo que tu **Switch Ethernet 10/100/1000 tenga soporte de VLAN's (802.1q) y Multicast (IGMP Snooping), y sobre todo que tu equipo Linux tenga una NIC que soporte VLAN's** (es lo más habitual).

Ah!, si tienes que adquirir dicho switch y ya puestos te recomiendo que aproveches y soporte «port mirroring» que te vendrá muy bien para hacer «troubleshooting» capturando y analizando el tráfico con [WireShark](https://www.wireshark.org/).


{% include showImagen.html
    src="/assets/img/posts/mv-final.png"
    caption="Objetivo final"
    width="600px"
    %}

En el gráfico anterior tienes la configuración final, en mi caso uso un Mac Mini «reconvertido» con Gentoo GNU/Linux (y que en breve voy a evolucionar a un equipo NUC de Intel), un [Switch Ethernet SG 200-08 de Cisco](http://www.cisco.com/c/dam/en/us/products/collateral/switches/small-business-100-series-unmanaged-switches/data_sheet_c78-634369_Spanish.pdf). 

Conecto la salida Ethernet (ETH1) del ONT al puerto del Switch (donde configuraré las vlan’s 2, 3 y 6 tagged; en mi ejemplo he usado el puerto 1), conecto el Linux al puerto-2 (donde configuro las vlan’s 2, 3, 6 y 100 Tagged) y el resto de puertos quedan configurados como de acceso de la vlan 100 (untagged)  donde conectaré los equipos de la Intranet: ordenador, punto de acceso wifi y Deco.

<br/>

## Configuración completa de la red

A continuación voy a entrar de lleno a mostrar los detalles necesarios sobre la configuración del Linux para que puedas comprender cómo hacerlo funcionar. Empiezo por un resumen general de toda la configuración de red del equipo para luego entrar al detalle de los tres servicios.

Configuración de la interfaz de red y las VLAN's en Linux (recuerdo que es la distro de Gentoo, en tu caso podrá ser otra por lo que los ficheros aquí documentados te tienen que servir de ejemplo y referencia):

```config
config_enp2s0f0="null"
mtu_enp2s0f0="1504"
vlans_enp2s0f0="2 3 6 100"
vlan2_name="vlan2"
vlan3_name="vlan3"
vlan6_name="vlan6"
vlan100_name="vlan100"
config_vlan2="10.214.XX.YY/9"
config_vlan6="null"
config_vlan100="192.168.1.1/24"
config_ppp0="ppp"
modules="dhclient"
config_vlan3="dhcp"
dhcp_vlan3="nogateway nodns nontp nosendhost nonis"
link_ppp0="vlan6"
plugins_ppp0="pppoe"
username_ppp0='adslppp@telefonicanetpa'
password_ppp0='adslppp'
pppd_ppp0="
 updetach
 noauth
 defaultroute
 ipcp-accept-remote
 ipcp-accept-local
 lcp-echo-interval 15
 lcp-echo-failure 3
 persist
 holdoff 3
 mru 1492
 mtu 1492
 lock
 noaccomp noccp nobsdcomp nodeflate nopcomp novj novjccomp
"
rc_net_ppp0_provide="!net"
```

La configuración del fichero anterior supone lo siguiente:

```
- WAN (Exterior)
    
    - vlan6 (datos) - PPPoE para recibir la IP. Ruta por defecto
    - vlan2 (iptv) - IP estática y RIP para recibir rutas IPTV
    - vlan3 (voip) - IP vía DHCP. Ruta vía RIP. No DNS/NIS/NTP

- LAN (Interior)
    
    - vlan100 (intranet) - Rango privado 192.168.1/24 y la ".1" al linux.
```

<br/>

#### Salida del comando ifconfig

He cambiado las IP's para hacerlas coincidir con el gráfico anterior.

```console
# ifconfig
enp2s0f0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1504
        ether 11:22:33:44:55:66  txqueuelen 1000  (Ethernet)
        RX packets 1366700756  bytes 1796575658464 (1.6 TiB)
        RX errors 3  dropped 300332  overruns 0  frame 3
        TX packets 1371022373  bytes 1805554316729 (1.6 TiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 16

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        loop  txqueuelen 0  (Local Loopback)
        RX packets 1025365  bytes 692058711 (659.9 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1025365  bytes 692058711 (659.9 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

ppp0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1492
        inet 80.28.PPP.PPP  netmask 255.255.255.255  destination 80.58.67.163
        ppp  txqueuelen 3  (Point-to-Point Protocol)
        RX packets 62838909  bytes 80275340154 (74.7 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 33578297  bytes 8751086608 (8.1 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vlan2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1504
        inet 10.214.XX.YY  netmask 255.128.0.0  broadcast 10.255.255.255
        ether 11:22:33:44:55:66  txqueuelen 0  (Ethernet)
        RX packets 1255455700  bytes 1667405535815 (1.5 TiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 128629  bytes 12264838 (11.6 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vlan3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1504
        inet 10.25.AA.BB  netmask 255.255.192.0  broadcast 10.25.255.255
        ether 11:22:33:44:55:66  txqueuelen 0  (Ethernet)
        RX packets 17697  bytes 943607 (921.4 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 23323  bytes 5580893 (5.3 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vlan6: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1504
        ether 11:22:33:44:55:66  txqueuelen 0  (Ethernet)
        RX packets 62878158  bytes 80779704539 (75.2 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 33613070  bytes 9490852380 (8.8 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vlan100: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1504
        inet 192.168.1.1  netmask 255.255.255.0  broadcast 192.168.1.255
        ether 11:22:33:44:55:66  txqueuelen 0  (Ethernet)
        RX packets 41268354  bytes 16754406776 (15.6 GiB)
        RX errors 0  dropped 7  overruns 0  frame 0
        TX packets 1325467487  bytes 1783103909820 (1.6 TiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

<br/>

### Routing (RIP pasivo)

Me anticipo a algo que vas a necesitar y lo dejo ya documentado. Telefónica utiliza RIP Pasivo para mandarnos varias rutas para su servicio IPTV y una única ruta para su servicio VoIP. Es recomendable activar RIP (pasivo) en la interfaz VLAN2 (iptv) y la VLAN3 (voip). Otra opción es configurarlas a “pelo” (rutas estáticas). En mi caso he preferido usar RIP, así que instalo [Quagga](http://quagga.net/) (Es un fork de Zebra, una suite de software de enrutamiento que proporciona implementaciones de OSPF, RIP, y BGP-4 multiplataforma)

* Instalo quagga:

```console
# emerge -v quagga
```

* Configuración: `/etc/quagga/zebra.conf`

```config
!
! Zebra configuration saved from vty
! 2014/09/27 19:32:29
!
hostname bolica
password XXXXXXX
enable password XXXXXXX
log file /var/log/zebra.log
!
interface enp2s0f0
!
interface lo
!
interface ppp0
!
interface tunl0
!
interface vlan2
!
interface vlan3
!
interface vlan6
!
interface vlan100
!
ip forwarding
ipv6 forwarding
!
!
line vty
!
```

* Configuración: `/etc/quagga/ripd.conf`

```console
hostname ripd
!
! Zebra configuration saved from vty
! 2014/10/11 19:29:17
!
hostname ripd
password XXXXXXXXXX
log file /var/log/ripd.log
!
router rip
 version 2
 network vlan2
 network vlan3
 passive-interface vlan2
 passive-interface vlan3
!
line vty
!
```


Muestro a continuación las rutas que verás, cuando esté todo funcionando (Ojo que no hemos llegado, pero aquí te pongo el resultado final)

```console
# ip route
 
_____(WAN)__________________
default via 80.58.67.163 dev ppp0 metric 4010
80.58.67.163 dev ppp0 proto kernel scope link src <80.28.XX.YY>

_____(VLAN3 VoIP)___________
10.25.192.0/19 dev vlan3 proto kernel scope link src <10.25.X.X> metric 5
10.31.255.128/27 via 10.25.192.1 dev vlan3 proto zebra metric 3  

_____(Internal localhost)___
127.0.0.0/8 dev lo scope host
127.0.0.0/8 via 127.0.0.1 dev lo

_____(VLAN2 IPTV)___________
10.128.0.0/9 dev vlan2 proto kernel scope link src <10.214.XX.YY> 
172.26.22.0/26 via 10.128.0.1 dev vlan2 proto zebra metric 3    
172.26.22.56/29 via 10.128.0.1 dev vlan2 proto zebra metric 3    
172.26.23.0/27 via 10.128.0.1 dev vlan2 proto zebra metric 3     
172.26.23.4 via 10.128.0.1 dev vlan2 proto zebra metric 3        
172.26.23.5 via 10.128.0.1 dev vlan2 proto zebra metric 3        
172.26.23.23 via 10.128.0.1 dev vlan2 proto zebra metric 3       
172.26.23.24 via 10.128.0.1 dev vlan2 proto zebra metric 3       
172.26.23.30 via 10.128.0.1 dev vlan2 proto zebra metric 3       
172.26.80.0/21 via 10.128.0.1 dev vlan2 proto zebra metric 3

_____(VLAN100 Intranet)_____
192.168.1.0/24 dev vlan100 proto kernel scope link src 192.168.1.1
```

El siguiente paso es que arranques ambos daemos, estas son las órdenes en Gentoo: 


```console 
# /etc/init.d/zebra start
# /etc/init.d/ripd start
```

Puedes conectar con ambos daemons y ver qué está pasando. Primero con el daemon general de zebra:

```console
# telnet localhost 2601
:
Password:
bolica> enable
Password:
bolica# show ip route
:
bolica# quit
``` 

Después con el daemon ripd

```console
# telnet localhost 2602
:
Password:
ripd> enable
ripd# show ip rip
:
bolica# quit
```

<br/>

### Source NAT

Para que los equipos de la Intranet (PCs, ordenador, teléfono WiFi) puedan llegar a Internet hay que hacer Source NAT. Para que los Decos puedan llegar a Imagenio también hay que hacer Source NAT y para que los teléfonos VoIP o aplicaciones VoIP puedan llegar a su servicio también hay que hacerles Source Nat.

El equipo sabrá qué tráfico va a Internet, IPTV o VoIP gracias al routing (a la dirección destino), así que con tres líneas de iptables el equipo se encargará de conmutar usando el interfaz de salida adecuado y cambiar y poner la dirección IP fuente correspondiente.

El tráfico del Deco querrá ir siempre a direcciones que empiezan por 172.26*, por lo tanto el equipo linux los querrá sacar por la VLAN2 (iptv). Lo mismo pasa con el tráfico que quiera ir a la dirección del proxy VoIP (10.31.255.128/27), que saldrá por la VLAN3 (voip). El resto de tráfico se conmutará por el enlace ppp0.

A continuación muestro las líneas para configurar el Source NAT para los tres interfaces.

Para la vlan 6 (datos internet)

```console 
# export ipVLAN6=\`ip addr show dev vlan6 | grep inet | awk '{print $2}' | sed 's;\/.*;;'\`
# iptables -t nat -A POSTROUTING -o ppp0 -s 192.168.1.0/24 -j SNAT --to-source ${ipVLAN6}
```

Para la vlan 2 (IPTV)

```console 
#iptables -t nat -A POSTROUTING -o vlan2 -s 192.168.1.0/24 -j SNAT --to-source 10.214.XX.YY
```

Para la vlan 3 (VoIP)


```console 
# export ipVLAN3=\`ip addr show dev vlan3 | grep inet | awk '{print $2}' | sed 's;\/.*;;'\`
# iptables -t nat -A POSTROUTING -o vlan3 -s 192.168.1.0/24 -j SNAT --to-source ${ipVLAN3}
```

<br/>

### I. Servicio de acceso a Internet (vlan6)

Como acabo de mencionar, recibimos Internet por la VLAN-6 y se utiliza PPPoE (PPP over Ethernet) para recibir la dirección IP, así que lo único que hay que hacer es activar PPPoE sobre el interfaz VLAN6 (ver el ejemplo anterior `/etc/conf.d/net`)

Si tienes problemas te recomiendo que añadas una linea con la cadena `debug` en la opción `pppd_ppp0="..."`. Así podrás observar en el syslog lo que ocurre. Una vez lo tengas estable quita dicha línea. 

Tanto si has contratado una IP fija como una dinámica la configuración es la misma, al arrancar el daemon PPP el equipo recibirá su IP, instalará una ruta por defecto por dicho interfaz y listo.

OJO!: Una de las desventajsa de PPPoE es que reduce la MTU a 1492 y el MSS (Maximum Segment Size) negociado de TCP a 1452, así que tenemos que hacer lo mismo en nuestro Linux. ¿Dónde?, pues la MTU en un sitio y el MSS en otro:

- MTU: El PPPD se encarga de definir la MTU en `/etc/conf.d/net`
- MSS: El MSS se tiene que configurar con `iptables`

Dentro de iptables tenemos dos opciones para especificar el MSS:

- `--clamp-mss-to-pmtu` Restringe el MSS al valor del Path MTU menos 40 bytes = 1452
- `--set-mss` Pone el valor a "pelo", (equivale al comando IOS: `ip tcp adjust-mss 1452`)

En mi caso uso la primera opción, he añadido las líneas siguientes al "principio" de mi script donde tengo todos los comandos iptables, de modo que afecte a todos los paquetes:

```console
:
iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
:
```

Preparamos el arranque futuro

```console  
# ln -s /etc/init.d/net.lo net.ppp0
# rc-update add net.ppp0 default
```

* Arranco el servicio: 

```console
# /etc/init.d/net.ppp0 start
```

Recibirás una IP fija o dinámica dependiendo de tu contrato. Dicha IP será del tipo 80.28.PP.PP. Nota que en mi caso empieza así y termina con la IP que tengo asignada (contraté una IP fija), pero en el tuyo puede ser cualquier otra cosa, depende de lo que Movistar haya provisionado en tu caso.

<br/>

# II. Servicio de Voz VoIP (vlan 3)

El Servicio VoIP nos llega por la VLAN-3. La configuración es sencilla, el equipo linux debe recibir una dirección IP mediante DHCP, hacer Source NAT por esta interfaz e instalar una única ruta (Ojo!, instalar un único prefijo específico para dicha ruta, no ponerla como ruta por defecto, o default route).

<br/>

### Cliente dhcp

En la configuración cliente DHCP de linux hay que especificar que "no" sobreescriba NIS, NTP ni DNS, y además que "no" se instale una ruta por defecto por dicha VLAN3. Lo vimos en la configuración de la red al principio, pero como recordatorio estas son las líneas específicas en /etc/conf.d/net

```config
vlan3_name="vlan3"
modules="dhclient"
config_vlan3="dhcp"
dhcp_vlan3="nogateway nodns nontp nosendhost nonis"
```

<br/>

### Source NAT

Debes hacer source NAT, de modo que el tráfico originado por tu cliente SIP (que reside en la VLAN100 con dirección 192.168.1.xxx)  que salga por la vlan3 lo haga con la dirección IP fuente del linux (recibida por dhcp y del estilo 10.25.ZZZ.ZZZ), como recordatorio estos son los comandos que ejecuto:

```console
# export ipVLAN3=\`ip addr show dev vlan3 | grep inet | awk '{print $2}' | sed 's;\/.*;;'\`
# iptables -t nat -A POSTROUTING -o vlan3 -s 192.168.1.0/24 -j SNAT --to-source ${ipVLAN3}
```

<br/>

### La "ruta" para Voip

Por este interfaz solo vamos a necesitar una única ruta y podemos aprenderla por RIP pasivo o bien instalarla manualmente. En mi caso he preferido usar RIP.  Lo vimos al principio, estas son las líneas específicas en `/etc/quagga/ripd.conf`

```config
 router rip
 network vlan3
 passive-interface vlan3
```

Para que puedas comprobar si lo estás configurando bien, estas son las rutas que deberías recibir:

```console
# ip route
:
10.25.192.0/19 dev vlan3 proto kernel scope link src 10.25.ZZZ.ZZZ metric 5
10.31.255.128/27 via 10.25.192.1 dev vlan3 proto zebra metric 3
:
```

<br/>

### Clientes SIP

Deberías estar ya preparado para probar con un cliente SIP desde un ordenador de la intranet (vlan100) o desde un teléfono SIP. Aquí tienes un [artículo](https://en.wikipedia.org/wiki/Comparison_of_VoIP_software) donde compara muchos clientes VoIP.

Los datos que necesitas son los siguientes:

```config
Proxy/registrar: 10.31.255.134:5070
Domain/realm: telefonica.net
STUN: [vacío]
Nombre de usuario: [tu teléfono]
Contraseña: [tu teléfono]
```

He probado con un par de clientes, la versión gratuita de «[Zoiper](http://www.zoiper.com/en)» para MacOSX, funciona pero no me ha dejado muy convencido. En cualquier caso, esta es mi configuración:

{% include showImagen.html
    src="/assets/img/posts/zoiper_0_o.png"
    caption="Cliente Zoiper"
    width="600px"
    %}

Otro cliente para MacOSX mucho más simple es [Telephone](http://www.tlphn.com/), está disponible en la App Store, es gratuito y la verdad es que me ha gustado más, por simple, que el anterior.

{% include showImagen.html
    src="/assets/img/posts/voip-1.png"
    caption="Cliente Telephone"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/posts/voip-2.png"
    caption="Cliente Telephone"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/posts/voip-3.png"
    caption="Cliente Telephone"
    width="600px"
    %}

Otro cliente que he probado es «[PhonerLite](http://phonerlite.de/index_en.htm)» para Windows (en mi caso ejecutado en Parallels para MacOSX), y tengo que decir que ha funcionado mucho mejor, (muy limpio y sin errores al ver el tráfico de registro, llamadas, recepción de llamadas). Una pena que solo exista para Windows.



{% include showImagen.html
    src="/assets/img/posts/phonerlite_0_o.jpg"
    caption="Cliente PhonerLite"
    width="600px"
    %}

Durante las pruebas de VoIP me he quedado con una sensación de inestabilidad, aparentemente no se registra a veces, alguna llamada no llega a sonar en el Softphone, por lo que tengo seguir investigando. También he detectado mucha diferencia entre un software y otro (en cuanto a estabilidad). El tráfico entre el softphone y el servidor de registro ocurre en UDP y es importante que tengas activo SourceNAT en el linux tal como describí en la sección de red.

<br/>

# III. Servicio de Televisión (vlan2)

El tráfico IPTV es entregado desde el ONT a través de la VLAN-2, por donde encontraremos los servicios OPCH, DVBSTP y Streams Multicast.

* OPCH: Servidores Imagenio que indican al deco la configuracion del portal, pelis, etc..
* DVBSTP: Protocolo de transferencia para el servicio SD&S (Service Discovery & Selection), mediante el cual se manda a los decos información de programación y de canales. Aquí tienes un [enlace al estándar](http://www.etsi.org/deliver/etsi_ts/102000_102099/102034/01.04.01_60/ts_102034v010401p.pdf).
* Streams Multicast: Son los flujos de tráfico con dirección destino «multicast», es decir entre otros, los streams MPEG con los datos del canal de televisión al que se haya suscrito el Deco.

En la VLAN2 es importante que utilices la misma dirección IP estática asignada por Movistar al Router original, es decir, debes averiguar qué dirección del tipo 10.214.X.Y/9 tiene. Para encontrar dicha IP tienes un par de opciones: 1) acceder a la configuración del router original o 2) "espiar" con tcpdump o wireshark el tráfico de la van 2 (si tu switch soporta port-mirroring).

**Nota**: Si quieres intentar la opción (1), configuración del router original, tendrás que cambiarle la contraseña del Router de Movistar. Ojo! que dejará de ser gestionable desde el portal de Movistar así que haz esto bajo tu responsabilidad y sigue este sencillo proceso: Haz un reset del router a factory defaults, arráncalo de nuevo y conéctalo al ONT, se auto-provisionará y se le asigna una contraseña aleatoria, espera a que todo funcione de nuevo. Entra a la configuración del router vía Alejandra (movistar.es->Mi Movistar->Configura tu router). Entre los menús verás una opción “Contraseña”, sigue todos los pasos (pedirá múltiples confirmaciones) para cambiar la contraseña. A partir de ahí ya puedes conectar al router desde tu intranet, usando http://192.168.1.1, usuario 1234 y la contraseña que hayas puesto.

<br/> 

### Tipo de tráfico en la vlan 2

A continuación el tipo de tráfico que he visto en la vlan2 con WireShark:

- Desde el Deco hacia Imagenio:
    - Consultas via udp al DNS Server (172.26.23.3)
    - Conexión vía HTTP/TCP a Servicios Imagenio (172.26.22.23), por ejemplo Grabaciones, Configuración, Personalización, 
- Desde Imagenio hacia el Deco [UDP - Flujos Multicast]:    
    - 239.0.[0,3,4,5,6,7,8,9].* CANALES.
    - 239.0.2.30:22222 OPCH
    - 239.0.2.129:3937 DVBSTP
    - 239.0.2.131:3937 DVBSTP
    - 239.0.2.132:3937 DVBSTP
    - 239.0.2.155:3937 DVBSTP

<br/>

## DHCP para los Decos

En la VLAN-100 tengo los equipos normales que acceden a internet, ordenador, portátil. Además tenemos el Decodificador (o decodificadores). Para facilitar el trabajo de provisión (asignación de IP's, etc...) empleo un DHCP server en Linux y entrego a cada equipo de la red su dirección IP, la IP del DNS server, etc. Creo un pool para los equipos normales y asigno IPs estáticas y específicas para cada dirección MAC del Deco (su dirección MAC la tienes en una pegatina en la parte de atrás del mismo). Verás que además le entrego la dirección del OPCH.

Ejemplo de configuración usando el [DHCP Server de ISC](http://www.isc.org/products/DHCP), fichero `/etc/dhcp/dhcpd.conf`:

```conf
:
ddns-update-style none;
authoritative;
:
option opch code 240 = text;
:
shared-network lan {
:
    subnet 192.168.1.0 netmask 255.255.255.0 {
        option routers 192.168.1.1;
        option subnet-mask 255.255.255.0;
        option domain-name "parchis.org";
        option domain-name-servers 192.168.1.1;
        option interface-mtu 1496;
        allow bootp;
        allow booting;
        pool {
           range 192.168.1.210 192.168.1.249;
           # allow unknown-clients;
        }
    }
}
:
:
host deco-cocina {
        hardware ethernet 4c:9e:ff:0c:50:2c;
        fixed-address 192.168.1.200;
        option domain-name-servers 172.26.23.3;
        option opch ":::::239.0.2.10:22222:v6.0:239.0.2.30:22222";
}
```

<br/>

## IGMP Proxy

Los JOIN’s de los Decos entrarán por la VLAN100 al Linux y será responsabilidad de este útimo re-enviarlos hacia la VLAN2. Esto se puede hacer de dos formas 1) Activando en el Kernel la opción de convertirlo en un Bridge Ethernet o 2) mucho más fácil y recomendado: usar un programa llamado [igmpproxy](http://sourceforge.net/projects/igmpproxy/).


Este pequeño programa hace dos cosas:

- 1) Escucha los Joins/Leaves IGMP de los Deco’s en el interface downstream (VLAN100, donde están los decos) y los replica en el interfaz upstream (VLAN2 donde están las fuentes). En el mismo instante en que replica (envía a movistar) el JOIN se empezará a recibir por el interfaz upstream (VLAN2) el tráfico multicast (el video).
- 2) Instala y "Activa" rutas en el kernel del Linux para que este (kernel) conmute los paquetes multicast. En el mismo momento en que recibió el JOIN (1) intentará instalar y "Activar" una ruta en el Kernel. Si lo consigue entonces el Kernel empezará a conmutar (forwarding) los paquetes que está recibiendo por el VLAN2 hacia los el(los) Deco(s) en el interfaz VLAN100 (downstream).

| **IMPORTANTE**: igmpproxy no conmuta los paquetes Multicast, solo replica los Joing/Leave e instala/activa las rutas en el Kernel. Será este, el kernel, el que se encargue de conmutar los paquetes que vienen desde Movistar (upstream) hacia los decos (downstream). |

<br/> 

### Preparar el Kernel para la Conmutación Multicast

Nos concentramos en la capa de conmutación, asumimos que lo anterior está ya funcionando y empiezan a llegarnos paquetes multicast UDP por el interfaz upstream (VLAN2). Tenemos que instalar/activar rutas en el Kernel y "convencerle" de que conmute el tráfico, tiene que hacer routing multicast, por lo tanto es muy importante que tengas configurado lo siguiente en el Kernel:

```conf
:
CONFIG_IP_MULTICAST=y
CONFIG_IP_MROUTE=y
:
```

Después viene la parte que más dolores de cabeza genera, ya tenemos todo, pero "no funciona", el tráfico llega por la VLAN2, el multicast está activo en el kernel, igmproxy arrancado, pero "NO SE ACTIVAN" las rutas. Sí parece que las instala en el kernel pero "no se activan".

¿Cual es la solución?, pues consiste en desactivar la comprobación RPF (Reverse Path Forwarding) en "ALL" y en el interfaz upstream (VLAN2), que es por donde viene el tráfico desde las fuentes, debes ejecutar los dos comandos siguientes durante el boot de tu equipo:

| **IMPORTANTE**: No te olvides de desactivar RPF en la opción "All" además de la "vlan2" o no funcionará. |
 
```conf
___ Pon a "0" la opción "All" ____
# echo "0" > /proc/sys/net/ipv4/conf/all/rp_filter

___ Pon a "0" el Interfaz Upstream ____
# echo "0" > /proc/sys/net/ipv4/conf/vlan2/rp_filter
```

¿Por qué debo desactivar [RPF](http://en.wikipedia.org/wiki/Reverse_path_forwarding)?. Porque lo normal es que las fuentes envían su tráfico desde direcciones IP que no tengo en mi tabla de routing y en linux por defecto tenemos activo («1») el RPF, así que se “bloquean” dichos paquetes. La forma más sencilla de solucionarlo es 1) insertar rutas a dichas fuentes a través de la vlan2 o 2) desactivar RPF (opción que he elegido en mi caso), de modo que el Kernel permite «activarlas» y a partir de ese momento veremos como empieza a conmutar el tráfico.

Tienes que desactivar (0) en `All` y en `vlan2`, dejando el resto activas (1), donde el RPF seguirá actuando. Notarás que la `loopback` (lo) también está desactivado, es correcto.

``conf 
/proc/sys/net/ipv4/conf/all/rp_filter        0
/proc/sys/net/ipv4/conf/default/rp_filter    1
/proc/sys/net/ipv4/conf/vlan100/rp_filter    1
/proc/sys/net/ipv4/conf/vlan2/rp_filter      0
:
/proc/sys/net/ipv4/conf/lo/rp_filter         0
/proc/sys/net/ipv4/conf/ppp0/rp_filter       1
```

```console
___ COMPRUEBA TU INSTALACIÓN ___
# for i in /proc/sys/net/ipv4/conf/*/rp_filter ; do echo $i; cat $i; done
```

<br/> 

### Source NAT y Firewall (iptables)

Aunque ya lo expliqué antes, recordatorio: para que los paquetes de los Decos salgan hacia la VLAN2 con tú dirección IP (en la vlan2) es necesario hacer Source NAT.

```console
iptables -t nat -A POSTROUTING -o vlan2 -s 192.168.1.0/24 -j SNAT --to-source 10.214.XX.YY
```

Opcional, si tu Linux es un router de internet y usas iptables para hacer de firewall, recuerda aceptar los paquetes multicast. Te dejo un recordatorio:

```console 
iptables -I INPUT -d 224.0.0.0/4 -j ACCEPT
iptables -I OUTPUT -d 224.0.0.0/4 -j ACCEPT
iptables -I FORWARD -d 224.0.0.0/4 -j ACCEPT
```

<br/>

### Instalación y configuración de igmpproxy

Primero tenemos que instalar el programa, aquí tienes un ejemplo en Gentoo: emerge -v igmpproxy

A continuación debes modificar el fichero de configuración. En la configuración es importante que se añada el prefijo de las fuentes en el upstream (línea donde pongo `altnet 172.0.0.0/8`). Notar que hago un agregado muy exagerado pero no importa en mi caso porque no tengo más fuentes multicast en mi red.

* Fichero `/etc/igmpproxy.conf`

```conf
quickleave

phyint vlan2 upstream  ratelimit 0  threshold 1
        altnet 172.0.0.0/8

phyint vlan100 downstream  ratelimit 0  threshold 1

phyint enp2s0f0 disabled
phyint lo disabled
phyint ppp0 disabled
phyint vlan6 disabled
```

Arranque en Gentoo:

```console 
# rc-update add igmpproxy default
# /etc/init.d/igmpproxy start
```

<br/>

### Resolución de problemas

Comprueba varias cosas si estás teniendo problemas con el servicio de IPTV. Para empezar deberías poder hacer ping al DNS Server interno que tiene Movistar en su propia red para este servicio de Televisión.

```console
# ping 172.26.23.3 
64 bytes from 172.26.23.3: icmp_seq=1 ttl=126 time=7.54 ms
64 bytes from 172.26.23.3: icmp_seq=2 ttl=126 time=4.24 ms
:
```

OJo!. Algunos me han comentado que a ellos no les funciona este "ping" pero sí les va el resto de funciones. De hecho a mi me ha estado funcionando muchos meses y de repente ha dejado de funcionar, así que mejor usa lo siguiente, esto Sí que debería funcionar y es consultas DNS. Prueba por ejemplo a consultar el registro SOA del dicho DNS Server:

```console 
# dig @172.26.23.3 imagenio.telefonica.net | grep SOA
imagenio.telefonica.net. 10800  IN  SOA mmsdmco1-01.imagenio.telefonica.net. postmaster.imagenio.telefonica.net. 2015080901 86400 7200 2592000 345600
:
```

En vez de arrancar el daemon en el background, durante las pruebas o para resolver problemas y ver "qué está pasando" ejecuta igmpproxy manualmente de la siguiente forma:

```console
# /usr/sbin/igmpproxy -d -vv /etc/igmpproxy.conf
```

Además puedes ir comprobando en otros terminales cómo se van insertando las rutas multicast en el kernel, el tráfico que pasa por cada fuente, etc...

```console
bolica ~ # cat /proc/net/ip_mr_cache
Group    Origin   Iif     Pkts    Bytes    Wrong Oifs
810900EF 3A4D1AAC 0      26264 35595536        0  2:1
560500EF 01481AAC 0      58765 78415404        0  2:1
4C0000EF 11481AAC 0      14704 19172500        0  2:1
9B0200EF 27141AAC 0        780   829104        0  2:1
810200EF 27141AAC 0        168   172648        0  2:1
1E0200EF 27141AAC 0       1430   848580        0  2:1
FAFFFFEF F301A8C0 -1         0        0        0
FAFFFFEF 0101A8C0 -1         0        0        0

bolica ~ # cat /proc/net/ip_mr_vif
Interface      BytesIn  PktsIn  BytesOut PktsOut Flags Local    Remote
 0 vlan2      774846616  584180         0       0 00000 2673D60A 00000000
 1 vlan3             0       0         0       0 00000 6BC2190A 00000000
 2 vlan100           0       0  774846616  584180 00000 0101A8C0 00000000
 5 ppp0              0       0         0       0 00000 B9FB1C50 00000000
 
# ip mroute
(172.26.20.41, 239.0.2.2) Iif: vlan2 Oifs: vlan100
(172.26.20.41, 239.0.2.30) Iif: vlan2 Oifs: vlan100
(172.26.20.39, 239.0.2.130) Iif: vlan2 Oifs: vlan100
(172.26.20.39, 239.0.2.129) Iif: vlan2 Oifs: vlan100
(172.26.20.39, 239.0.2.155) Iif: vlan2 Oifs: vlan100
```

Verificar que tienes activo el routing (y desactivo el RPF) en el kernel:

```console 
___ GENERAL ____  
# cat /proc/sys/net/ipv4/ip_forward
1

___ INTERFAZ UPSTREAM (VLAN2) ____  
bolica ~ # cat /proc/sys/net/ipv4/conf/vlan2/forwarding
1
bolica ~ # cat /proc/sys/net/ipv4/conf/vlan2/rp_filter
0

___ INTERFAZ DOWNSTREAM (VLAN100) ____  
bolica ~ # cat /proc/sys/net/ipv4/conf/vlan100/forwarding
1
bolica ~ # cat /proc/sys/net/ipv4/conf/vlan100/rp_filter   (NO hace falta desactivar aquí el RPF)
1

___ AL ARRANCAR IGMPPROXY VERAS QUE SE PONEN A 1 ____  
bolica ~ # cat /proc/sys/net/ipv4/conf/vlan2/mc_forwarding
1
bolica ~ # cat /proc/sys/net/ipv4/conf/vlan100/mc_forwarding
1
```

Verificar cómo tienes el RPF

```console 
# for i in /proc/sys/net/ipv4/conf/*/rp_filter ; do echo $i; cat $i; done
```

<br/>

### IGMP Snooping

Es importante evitar que la intranet donde están los DECO’s (u otros receptores) se llene de tráfico Multicast en todos sus puertos. Si no hacemos nada, al enviar tráfico multicast hacia la VLAN100 el switch replicará en todos los puertos que pertenezcan a dicha vlan, es decir, una tormenta de tráfico innecesario que no necesitamos, de hecho donde menos lo queremos es en los puntos de acceso Wifi, imagínate recibiendo 10, 20, 30Mbps extra, supondrá un desastre para la calidad de los clientes Wifi.

Para solucionarlo no hay que hacer nada en el linux, solo en el switch ethernet. Es tan simple como activar IGMP Snooping, que normalmente podrás hacer por puerto, grupos de puertos, por vlan, etc. depende del switch.

Al activarlo estamos pidiendo al switch que espíe el tráfico IGMP, mantenga un mapa de qué puertos piden suscribirse a los flujos (multicast) y así saber a quién mandar y a quién no.

<br/>

## Ver la TV

Si has llegado hasta aquí entonces estarás deseando “ver” la TV y para hacerlo tenemos varias opciones. La primera y más evidente es utilizar el "Deco" que nos entrega Movistar con el servicio, pero también podrías intentar usar algún cliente IPTV.

<br/>

### Cliente "Deco" de Movistar

Es el método más claro y sencillo de todos, para configurarlo pulsa repetidamente la tecla menú después de arrancarlo; cuando está parpadeando el último cuadro durante el boot. Entrarás en el menú de configuración del firmware y desde ahí podrás activar (viene así por defecto) que use DHCP. Lo de entrar con la tecla menú realmente no hace falta, solo es para ver que recibe la IP correcta desde el DHCP Server.

Una vez que lo tengas encendido y conectado a tu TV debería funcionar todo, bueno, casi todo (más adelante verás el tema de Acceso a videos bajo demanda).

<br/>

### Cliente IPTV "VLC"

Otro método evidente y sencillo, usar el mejor cliente de video que existe: VLC. De hecho, antes de intentar otras opciones es la que te recomiendo, una vez arrancado en tu ordenador, selecciona “Abrir Red” y utiliza el URL siguiente: `rtp://@239.0.0.76:8208`, para ver TVE-1. Ya está, no hay mucho más que hacer, has utilizado VLC como cliente IPTV con protocolo multicast.

{% include showImagen.html
    src="/assets/img/posts/iptvvlc1.png"
    caption="Conexión vía Red"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/posts/iptvvlc2-1024x659.png"
    caption="Vemos TV1"
    width="600px"
    %}

<br/>

**Fichero de ejemplo con la Lista de canales**

| En este enlace dejo la [Lista de canales de Movistar TV](https://gist.github.com/LuisPalacios/b906b58128a2d4cb62799220df628bd0) (válidos en Octubre de 2014). Sálva el contenido en un fichero con el nombre `Movistar.m3u` y úsalo desde VLC. |

 
<br/>

### TVHeadend (como cliente IPTV)


Otra opción mucho mejor, pásate al mundo de los Media Center’s, donde necesitaras clientes del estilo XBMC/KODI en ordenadores o en Raspberry’s. Para poder «servirlos» el mejor que he probado hasta ahora es Tvheadend, así que te recomiendo instalar [Tvheadend](https://tvheadend.org/projects/tvheadend) ([GitHub tvheadend](https://github.com/tvheadend/tvheadend)), se trata de un DVR (Digital Video Recorder) y un servidor de streaming de TV que soporta todo tipo de fuentes: DVB-C, DVB-T(2), DVB-S(2), ATSC y además «IPTV (UDP o HTTP)«, siendo esta última precisamente la que me interesa.

La pregunta sería ¿para qué quiero un Servidor de Streams de TV si «eso es precisamente» lo que ya tengo funcionando?. La respuesta es que no voy a usarlo para recibir fuentes de satelite ni TDT y convertirlas en streams multicast. Lo voy a usar como intermediario que lee los streams multicast de Movitar TV y los entrega en protocolo [HTSP](https://tvheadend.org/projects/tvheadend/wiki/Htsp) a clientes IPTV de mi red.

Una de sus ventajas es que puedes emplear Media Centers «baratos» como por ejemplo una Raspberry Pi con OpenELEC (XBMC) que trae de serie el cliente HTSP de Tvheadend (échale un ojo a este otro apunte sobre Media Center integrado con Movistar TV), y otra ventaja importante es que con TVHeadend podremos integrar el EPG de movistar TV.

Estoy instalando la última versión disponible en GitHub porque me interesa que la versión sea 3.9+ para poder aprovechar toda su potencia. Proceso de instalación:

```console
totobo ~ # echo "=media-video/libav-11.3 ~amd64" >> /etc/portage/package.accept_keywords
totobo ~ # echo "=media-tv/tvheadend-9999 **" >> /etc/portage/package.accept_keywords
totobo ~ # echo "media-tv/tvheadend avahi dvb dvbscan ffmpeg zlib xmltv"  >> /etc/portage/package.use
totobo ~ # emerge -v media-tv/tvheadend
:
totobo ~ # /etc/init.d/tvheadend start
```

Una vez que lo he arrancado ya puedo conectar con su interfaz web usando el puerto 9981 (http://dirección_ip_de_tu_linux:9981), podré dar de alta las fuentes IPTV, los canales y "ver" quién está accediendo a ellos. En el ejemplo siguiente he configurado dos canales:

{% include showImagen.html
    src="/assets/img/posts/tvheadend1.png"
    caption="Configuración de IPTV en Tvheadend"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/posts/tvheadend2.png"
    caption="Configuración Channel/EPG"
    width="600px"
    %}

A continuación configuro mi cliente Raspberry Pi con OpenElec para que conecte con TVheadend usando el plugin «TVHeadend HTSP Client»

{% include showImagen.html
    src="/assets/img/posts/tvheadend5-1024x578.png"
    caption="«TVHeadend HTSP Client»"
    width="600px"
    %}

Una de las ventajas que tenemos es la posibildiad de monitorizar quién está usando el servicio y cuando ancho de banda está consumiendo (un canal HD de movistar suelen ser ~10Mbps).

{% include showImagen.html
    src="/assets/img/posts/tvheadend3-1024x186.png"
    caption="Monitor de ancho de banda"
    width="600px"
    %}

<br/>

### udpxy

Para conseguirlo tenemos este pequeño paquete que es simplemente genial. Se trata de un Daemon que permite hacer relay del tráfico multicast UDP hacia clientes TCP (HTTP). Es decir, él va a tratar por un lado el tráfico multicast y por otro nos dejará ver los canales en HTTP. Traducido: sirve para que desde cualquier clientes PC’s, Mac’s, Linux, etc. con un cliente IPTV que solo soporta HTTP podamos ver los canales.

Primero lo instalo (Gentoo): `emerge -v udpxy` y lo configuro:

`UDPXYOPTS="-a vlan100 -p 4022 -m vlan2 -c 16"`

En este caso estamos diciendo que escuche por el puerto tcp:4022 en la vlan100, que se suscriba a los grupos multicast a través de la interfaz vlan2 y **con el argumento -c 16 le decimos que soporte hasta 16 clientes (ojo que por defecto sirve un máximo de 3 clientes)**. Cuando un cliente le pida ver un canal concreto por la vlan100 (en http), él se suscribirá a dicho canal por la vlan2 y en cuanto empiece a recibir el video (vía multicast por vlan2) lo reenviará al cliente pero en HTTP por la vlan100

Arranque en Gentoo: `/etc/init.d/udpxy start`

A partir de aquí ya podremos conectar con las fuentes usando el protocolo HTTP. A modo de ejemplo con VLC usando la siguiente dirección de Red deberías ver TVE2:

- `http://192.168.1.1:4022/udp/239.0.0.2:8208`

<br/>
**Fichero de ejemplo con la Lista de canales en formato HTTP**

| En este enlace dejo la [Lista de canales de Movistar TV en formato HTTP](https://gist.github.com/LuisPalacios/1a2bc5a354537857a524d9e7375af0c0) (válidos en Octubre de 2014), por si prefieres la opción UDPXY vs IGMP Proxy + RTP. |

<br/>

## udpxrec

Otra joya... que viene con updxy y nos permite programar grabaciones. No está nada mal!!

Ejemplo:

```console 
udpxrec -b 15:45.00 -e +2:00.00 -M 1.5Gb -n 2 -B 64K -c 239.0.0.2:8208 /mnt/Multimedia/0.MASTER/videos/Pelicula.mpg
```

Programa una grabación del canal multicast `239.0.0.2:8208` a las 15:45 hoy, con un tiempo de grabación de dos horas o que también pare si el tamaño del fichero es mayor de 1.5Gb. Se establece el tamaño del buffer de socket a 64Kb; incrementa el nice value en 2 (prioridad del proceso en linux) y se especifica cual es el fichero de salida.

<br/>

### xupnpd

Y la última joya, este otro programa [xupnpd](http://xupnpd.org/) que permite anunciar canales y contenido multimedia a través de DLNA. Vía DLNA (UPnP) se entregará una lista personalizada con los canales de Imagenio a los dispositivos de la LAN. Existen múltiples cliente que pueden consumir este servicio, por ejemplo VLC y así no tener que crear un fichero .m3u en cada ordenador.

La instalación de xupnpd en Gentoo es un poco más complicada de lo normal, necesitas `layman`, así que ahí va una guía rápida por si no lo tienes instalado:

* Fichero: `/etc/portage/package.accept_keywords`

```conf
=app-portage/layman-2.3.0 ~amd64
=net-misc/xupnpd-9999 **
```

* Fichero: `/etc/portage/package.unmask`

```conf
=net-misc/xupnpd-9999
```

* Fichero: `/etc/portage/package.usr/layman`

```conf
app-portage/layman  git mercurial
```

* Instalo `layman`

```console
# emerge -v layman
# mkdir /etc/portage/repos.conf
# layman-updater -R
# layman -L
# layman -a arcon 
```

* Instalo `xupnpd`

```console
# emerge -v xupnpd
```

Configuración: notar que solo muestro qué opciones he cambiado respecto al fichero original

* Fichero `/etc/xupnpd/xupnpd.lua

```conf 
:
cfg.ssdp_interface='vlan100'
cfg.embedded=true <== Desactivo el Logging
cfg.udpxy_url='http://192.168.1.1:4022'
cfg.mcast_interface='vlan100'
cfg.name='TV Casa’
:
```

El siguiente es preparar un fichero "m3u", te recomiendo que copies/pegues todos los canales del fichero que mostré en la sección IGMP Proxy > Cliente VLC > "[Movistar.m3u vía RTP](https://gist.github.com/LuisPalacios/b906b58128a2d4cb62799220df628bd0)", no uses el de HTTP. Copia/pega los canales que te interesen y crea un archivo M3U en el directorio de playlists con cualquier nombre: `/etc/xupnpd/playlists/Movistar TV.m3u`

* Arranque del daemon (gentoo):

```console
# /etc/init.d/xupnpd start
```

Ya lo tienes, ahora solo hay que consumir este servicio, con cualquier cliente UPnP, por ejemplo Televisiones SmartTV (para las que no tengas un Descodificador) o con VLC o con mediacenters basados en XBMC.

- Desde un SmartTV busca la opción de *Plug’n’Play*
- VLC, selecciona `Red local` > `Plug’n’Play Universal`
- Media Center, por ejemplo basado en Raspberry Pi + XBMC y configurarlo con un Add-On «PVR IPTV Simple Client» para acceder a este servicio.

En el caso de dicho PVR IPTV Simple Client se configura así:

```conf 
:
General
 Location: Remote Path (internet address)
 MRU Play List URL: http://192.168.1.1:4044/ui/Movistar%20TV.m3u
 Cache m3u at local storage (x)
 Numbering channels starts at: 1
:
```

<br/>

### Acceso a videos bajo demanda

Falta un último detalle que he dejado para el final, el servicio de Video de Movistar Fusión permite seleccionar y ver videos bajo demanda en dos situaciones: 1) reproducir una grabación que hayamos programado o 2) reproducir un video desde la parrilla de Movistar TV.

Es un pelín complicado, así que he creado un apunte técnico especial que encontrarás en [videos bajo demanda para Movistar]({% post_url 2014-10-18-movistar-bajo-demanda %})

<br/>

## Resumen

El orden de arranque de todos los scripts vistos en este artículo es el que tienes más abajo. Nota que los he programado para que arranquen durante el boot (en gentoo se haría por ejemplo así: rc-update add zebra default).

```console
# /etc/init.d/zebra start
# /etc/init.d/ripd start
# echo "0" > /proc/sys/net/ipv4/conf/vlan2/rp_filter
# /etc/init.d/igmpproxy start
# /etc/init.d/udpxy start
# /etc/init.d/xupnpd start
```

<br/> 
