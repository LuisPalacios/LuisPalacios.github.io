---
title: "Movistar Fusión Fibra + TV + VoIP con router Linux"
date: "2014-10-05"
categories: apuntes
tags: linux movistar router television
excerpt_separator: <!--more-->
---

Este apunte describe qué hay detrás (a nivel técnico) del servicio IP que nos ofrece Movistar Fusión FTTH (Fibra) y como sustituir el router que nos instalan por un equipo basado en **Gentoo** GNU/Linux, que hará de Router (junto con un Switch Ethernet) para ofrecer los mismos servicios de Datos, Televisión (IPTV) y Voz (VoIP).

## Punto de partida

Veamos cual es la instalación que nos queda cuando instalan "la fibra". El cable "negro" que nos llega a casa es una fibra (monomodo 657-A2) que el técnico "empalma" dentro de una roseta de tipo ICT-2, que a su vez ofrece un conector SC/APC de salida. De dicho conector sale un latiguillo de fibra estándar al ONT y desde ahí salen dos cables, uno de teléfono que normalmente conectan a la entrada de teléfono de tu casa y otro ethernet que se conecta al router. Ver el gráfico siguiente:

{% include showImagen.html
    src="/assets/img/original/redold_0_o-1024x893.png"
    caption="redold_0_o"
    width="600px"
    %}

El **ONT** es el equipo que termina la parte "óptica", sus siglas singnifican Optical Network Termination y se encarga de convertir la señal óptica a señal eléctrica, en concreto ofrece un interfaz Ethernet tradicional (utilizo el puerto ETH1). Salvando mucho, pero que mucho, las distancias, vendría a ser algo parecido al PTR de una línea de teléfono analógica cuando teníamos ADSL.

El siguiente equipo es el **Router**, que va a recibir, desde el ONT, tres VLAN's, una para cada servicio: VLAN-6 para "datos", VLAN-2 para IPTV y VLAN-3 para VoIP. Su función consiste en conmutar entre la VLAN apropiada y la "intranet" dependiendo de qué servicio consuma y/o qué configuración tenga el cliente (decodificador, ordenador, teléfono).

## Objetivo Final

Consiste en sustituir el Router de Movistar por un equipo con Linux y un Switch Ethernet y poder ofrecer los tres servicios: Datos, IPTV y VoIP. ¿porqué un Switch Ethernet?, pues porque necesitas que alguien tenga los puertos ethernet y sobre todo porque es mucho más sencillo (y barato) que instalar tarjetas de puertos ethernet en tu Linux... Importantísimo que tu **Switch Ethernet 10/100/1000 tenga soporte de VLAN's (802.1q) y Multicast (IGMP Snooping), y sobre todo que tu equipo Linux tenga una NIC que soporte VLAN's** (es lo más habitual).

{% include showImagen.html
    src="/assets/img/original/"
    caption="WireShark"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/red_0_o-1024x758.png"
    caption="red_0_o"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/data_sheet_c78-634369_Spanish.pdf), conecto la salida Ethernet (ETH1) del ONT al puerto del Switch (donde configuraré las vlan's 2, 3 y 6 tagged; en mi ejemplo he usado el puerto 1), conecto el Linux al puerto-2 (donde configuro las vlan's 2, 3, 6 y 100 Tagged) y el resto de puertos quedan configurados como de acceso de la vlan 100 (untagged"
    caption="Switch Ethernet SG 200-08 de Cisco"
    width="600px"
    %}

## Configuración completa de la red

A continuación voy a entrar de lleno en mostrar los detalles necesarios sobre la configuración del Linux para que puedas comprender cómo hacerlo funcionar. Empiezo por un resumen general de toda la configuración de red del equipo para luego entrar al detalle de los tres servicios.

Configuración de la interfaz de red y las VLAN's en Linux (recuerdo que es la distro de Gentoo, en tu caso podrá ser otra por lo que los ficheros aquí documentados te tienen que servir de ejemplo y referencia):

 
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

La configuración del fichero anterior supone lo siguiente:

- WAN (Exterior)
    
    - vlan6 (datos) - PPPoE para recibir la IP. Ruta por defecto
    - vlan2 (iptv) - IP estática y RIP para recibir rutas IPTV
    - vlan3 (voip) - IP vía DHCP. Ruta vía RIP. No DNS/NIS/NTP
- LAN (Interior)
    
    - vlan100 (intranet) - Rango privado 192.168.1/24 y la ".1" al linux.

#### Salida del comando ifconfig

Notar que he cambiado las IP's para hacerlas coincidir con el gráfico anterior.

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

### Routing (RIP pasivo)

{% include showImagen.html
    src="/assets/img/original/) (fork de Zebra"
    caption="Quagga"
    width="600px"
    %}

Gentoo: emerge -v quagga

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

Muestro a continuación las rutas que tendrás una vez  que tengas TODO funcionando (Ojo que no hemos llegado, pero aquí te pongo el resultado final)

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
 

Arranque en Gentoo:

 
# /etc/init.d/zebra start
# /etc/init.d/ripd start
 

Puedes conectar con ambos daemons y ver qué está pasando. Primero con el daemon general de zebra:

 
# telnet localhost 2601
:
Password:
bolica> enable
Password:
bolica# show ip route
:
bolica# quit
 

Después con el daemon ripd

 
# telnet localhost 2602
:
Password:
ripd> enable
ripd# show ip rip
:
bolica# quit
 

### Source NAT

Para que los equipos de la Intranet (PCs, ordenador, teléfono WiFi) puedan llegar a Internet hay que hacer Source NAT. Para que los Decos puedan llegar a Imagenio también hay que hacer Source NAT y para que los teléfonos VoIP o aplicaciones VoIP puedan llegar a su servicio también hay que hacerles Source Nat.

El equipo sabrá qué tráfico va a Internet, a IPTV y a VoIP gracias al routing (a la dirección destino), así que con tres líneas de iptables y esta información de dirección destino, el equipo se encargará de conmutar usando el interfaz de salida adecuado y cambiar y poner la dirección IP fuente adecuada

El tráfico del Deco querrá ir siempre a direcciones que empiezan por 172.26*, por lo tanto el equipo linux los querrá sacar por la VLAN2. Lo mismo pasa con el tráfico que quiera ir a la dirección del proxy VoIP (10.31.255.128/27), que saldrá por la VLAN3. Para el resto de tráfico se conmutará por el enlace ppp0.

A continuación muestro las líneas para configurar el Source NAT para los tres interfaces.

Para la vlan 6 (datos internet)

 
# export ipVLAN6=\`ip addr show dev vlan6 | grep inet | awk '{print $2}' | sed 's;\/.*;;'\`
# iptables -t nat -A POSTROUTING -o ppp0 -s 192.168.1.0/24 -j SNAT --to-source ${ipVLAN6}
 

Para la vlan 2 (IPTV)

 
#iptables -t nat -A POSTROUTING -o vlan2 -s 192.168.1.0/24 -j SNAT --to-source 10.214.XX.YY
 

Para la vlan 3 (VoIP)

 
# export ipVLAN3=\`ip addr show dev vlan3 | grep inet | awk '{print $2}' | sed 's;\/.*;;'\`
# iptables -t nat -A POSTROUTING -o vlan3 -s 192.168.1.0/24 -j SNAT --to-source ${ipVLAN3}
 

 

# I. Servicio de acceso a Internet (vlan6)

Como acabo de mencionar, recibimos Internet por la VLAN-6 y se utiliza PPPoE (PPP over Ethernet) para recibir la dirección IP, así que lo único que hay que hacer es activar PPPoE sobre el interfaz VLAN6 (ver el ejemplo anterior /etc/conf.d/net)

Si tienes problemas te recomiendo que añadas una linea que simplemente ponga "debug" sin comillas, dentro de la opción pppd_ppp0="...". Así podrás observar en el syslog lo que ocurre. Una vez lo tengas estable quita dicha línea. Tanto si has contratado una IP fija como una dinámica la configuración es la misma, al arrancar el daemon PPP el equipo recibirá su IP, instalará una ruta por defecto por dicho interfaz y listo.

OJO!: Una de las desventajsa de PPPoE es que reduce la MTU a 1492 y el MSS (Maximum Segment Size) negociado de TCP a 1452, así que tenemos que hacer lo mismo en nuestro Linux. ¿Dónde?, pues la MTU en un sitio y el MSS en otro...:

- MTU: El PPPD se encarga de definir la MTU en el fichero anterior de configuración (/etc/conf.d/net)
- MSS: El MSS se tiene que configurar con "iptables"

Dentro de iptables tenemos dos opciones para especificar el MSS:

- \--clamp-mss-to-pmtu Restringe el MSS al valor del Path MTU menos 40 bytes = 1452
- \--set-mss Pone el valor a "pelo", (equivale al comando IOS: ip tcp adjust-mss 1452)

En mi caso uso la primera opción, he añadido las líneas siguientes al "principio" de mi script donde tengo todos los comandos iptables, de modo que afecte a todos los paquetes:

:
iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
:

Preparamos el arranque futuro

 
# ln -s /etc/init.d/net.lo net.ppp0
# rc-update add net.ppp0 default
 

Arranque en Gentoo:

 
# /etc/init.d/net.ppp0 start
 

Recibirás una IP fija o dinámica dependiendo de tu contrato. Dicha IP será del tipo 80.28.PP.PP. Nota que en mi caso empieza así y termina con la IP que tengo asignada (contraté una IP fija), pero en el tuyo puede ser cualquier otra cosa, depende de lo que Movistar haya provisionado en tu caso...  

# II. Servicio de Voz VoIP (vlan 3)

El Servicio VoIP nos llega por la VLAN-3. La configuración es sencilla, el equipo linux debe recibir una dirección IP mediante DHCP, hacer Source NAT por esta interfaz e instalar una única ruta (Ojo!, instalar un único prefijo específico para dicha ruta, no ponerla como ruta por defecto, o default route).

## Cliente dhcp

En la configuración cliente DHCP de linux hay que especificar que "no" sobreescriba NIS, NTP ni DNS, y además que "no" se instale una ruta por defecto por dicha VLAN3. Lo vimos en la configuración de la red al principio, pero como recordatorio estas son las líneas específicas en /etc/conf.d/net

 
vlan3_name="vlan3"
modules="dhclient"
config_vlan3="dhcp"
dhcp_vlan3="nogateway nodns nontp nosendhost nonis"

## Source NAT

Debes hacer source NAT, de modo que el tráfico originado por tu cliente SIP (que reside en la VLAN100 con dirección 192.168.1.xxx)  que salga por la vlan3 lo haga con la dirección IP fuente del linux (recibida por dhcp y del estilo 10.25.ZZZ.ZZZ), como recordatorio estos son los comandos que ejecuto:

 
# export ipVLAN3=\`ip addr show dev vlan3 | grep inet | awk '{print $2}' | sed 's;\/.*;;'\`
# iptables -t nat -A POSTROUTING -o vlan3 -s 192.168.1.0/24 -j SNAT --to-source ${ipVLAN3}
 

## Routing: "la ruta"

Por este interfaz solo vamos a necesitar una única ruta y podemos aprenderla por RIP pasivo o bien instalarla manualmente. En mi caso he preferido usar RIP.  Lo vimos al principio, estas son las líneas específicas en /etc/quagga/ripd.conf

 router rip
 network vlan3
 passive-interface vlan3

Para que puedas comprobar si lo estás configurando bien, estas son las rutas que deberías recibir:

 
# ip route
:
10.25.192.0/19 dev vlan3 proto kernel scope link src 10.25.ZZZ.ZZZ metric 5
10.31.255.128/27 via 10.25.192.1 dev vlan3 proto zebra metric 3
:
 

 

## Clientes SIP

{% include showImagen.html
    src="/assets/img/original/Comparison_of_VoIP_software"
    caption="artículo donde compara muchos clientes VoIP"
    width="600px"
    %}

Los datos que necesitas son los siguientes:

 
Proxy/registrar: 10.31.255.134:5070
Domain/realm: telefonica.net
STUN: [vacío]
Nombre de usuario: [tu teléfono]
Contraseña: [tu teléfono]

{% include showImagen.html
    src="/assets/img/original/en"
    caption="Zoiper"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/zoiper_0_o.png"
    caption="zoiper_0_o"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/www.tlphn.com"
    caption="Telephone"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/voip-1.png"
    caption="voip-1"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/voip-2.png"
    caption="voip-2"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/voip-3.png"
    caption="voip-3"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/index_en.htm)" para Windows (en mi caso ejecutado en Parallels para MacOSX), y tengo que decir que ha funcionado mucho mejor, (muy limpio y sin errores al ver el tráfico de registro, llamadas, recepción de llamadas"
    caption="PhonerLite"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/phonerlite_0_o.jpg"
    caption="phonerlite_0_o"
    width="600px"
    %}

Durante las pruebas de VoIP me he quedado con una sensación de inestabilidad, aparentemente no se registra a veces, alguna llamada no llega a sonar en el Softphone, por lo que tengo seguir investigando. También he detectado mucha diferencia entre un software y otro (en cuanto a estabilidad). El tráfico entre el softphone y el servidor de registro ocurre en UDP y es importante que tengas activo SourceNAT en el linux tal como describí en la sección de red.

   

# III. Servicio de Televisión (vlan2)

El tráfico IPTV es entregado desde el ONT a través de la VLAN-2, por donde encontraremos los servicios OPCH, DVBSTP y Streams Multicast.

- OPCH: Servidores Imagenio que indican al deco la configuracion del portal, pelis, etc..
{% include showImagen.html
    src="/assets/img/original/ts_102034v010401p.pdf"
    caption="Aquí tienes un enlace al estándar"
    width="600px"
    %}
- Streams Multicast: Son los flujos de tráfico con dirección destino "multicast", es decir entre otros, los streams MPEG con los datos del canal de televisión al que se haya suscrito el Deco.

En la VLAN2 es importante que utilices la misma dirección IP estática asignada por Movistar al Router original, es decir, debes averiguar qué dirección del tipo 10.214.X.Y/9 tiene. Para encontrar dicha IP tienes un par de opciones: 1) acceder a la configuración del router original o 2) "espiar" con tcpdump o wireshark el tráfico de la van 2 (si tu switch soporta port-mirroring).

**Nota**: Si quieres intentar la opción (1),configuración del router original, tendrás que cambiarle la contraseña del Router de Movistar. Ojo! que dejará de ser gestionable desde el portal de Movistar así que haz esto bajo tu responsabilidad y sigue este sencillo proceso: Haz un reset del router a factory defaults, arráncalo de nuevo y conéctalo al ONT, se auto-provisionará y se le asigna una contraseña aleatoria, espera a que todo funcione de nuevo. Entra a la configuración del router vía Alejandra (movistar.es->Mi Movistar->Configura tu router). Entre los menús verás una opción “Contraseña”, sigue todos los pasos (pedirá múltiples confirmaciones) para cambiar la contraseña. A partir de ahí ya puedes conectar al router desde tu intranet, usando http://192.168.1.1, usuario 1234 y la contraseña que hayas puesto.

 

## Tipo de tráfico en la vlan 2

A continuación el tipo de tráfico que he visto en la vlan2 con WireShark:

- Desde el Deco hacia Imagenio:
    
    - Consultas via udp al DNS Server (172.26.23.3)
    - Conexión vía HTTP/TCP a Servicios Imagenio (172.26.22.23), por ejemplo Grabaciones, Configuración, Personalización, …
- Desde Imagenio hacia el Deco [UDP - Flujos Multicast]:
    
    - 239.0.[0,3,4,5,6,7,8,9].* CANALES.
    - 239.0.2.30:22222 OPCH
    - 239.0.2.129:3937 DVBSTP
    - 239.0.2.131:3937 DVBSTP
    - 239.0.2.132:3937 DVBSTP
    - 239.0.2.155:3937 DVBSTP

 

## DHCP para los Decos

En la VLAN-100 tengo los equipos normales que acceden a internet, ordenador, portátil. Además tenemos el Decodificador (o decodificadores). Para facilitar el trabajo de provisión (asignación de IP's, etc...) empleo un DHCP server en Linux y entrego a cada equipo de la red su dirección IP, la IP del DNS server, etc. Creo un pool para los equipos normales y asigno IPs estáticas y específicas para cada dirección MAC del Deco (su dirección MAC la tienes en una pegatina en la parte de atrás del mismo). Verás que además le entrego la dirección del OPCH.

{% include showImagen.html
    src="/assets/img/original/DHCP"
    caption="DHCP Server de ISC"
    width="600px"
    %}

 
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

 

## IGMP Proxy

{% include showImagen.html
    src="/assets/img/original/"
    caption="igmpproxy"
    width="600px"
    %}

Este pequeño programa hace dos cosas:

- 1) Escucha los Joins/Leaves IGMP de los Deco’s en el interface downstream (VLAN100, donde están los decos) y los replica en el interfaz upstream (VLAN2 donde están las fuentes). En el mismo instante en que replica (envía a movistar) el JOIN se empezará a recibir por el interfaz upstream (VLAN2) el tráfico multicast (el video).
- 2) Instala y "Activa" rutas en el kernel del Linux para que este (kernel) conmute los paquetes multicast. En el mismo momento en que recibió el JOIN (1) intentará instalar y "Activar" una ruta en el Kernel. Si lo consigue entonces el Kernel empezará a conmutar (forwarding) los paquetes que está recibiendo por el VLAN2 hacia los el(los) Deco(s) en el interfaz VLAN100 (downstream).

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**IMPORTANTE**: igmpproxy no conmuta los paquetes Multicast, solo replica los Joing/Leave e instala/activa las rutas en el Kernel. Será este, el kernel, el que se encargue de conmutar los paquetes que vienen desde Movistar (upstream) hacia los decos (downstream).

[/dropshadowbox]

 

### Preparar el Kernel para la Conmutación Multicast

Nos concentramos en la capa de conmutación, asumimos que lo anterior está ya funcionando y empiezan a llegarnos paquetes multicast UDP por el interfaz upstream (VLAN2). Tenemos que instalar/activar rutas en el Kernel y "convencerle" de que conmute el tráfico, tiene que hacer routing multicast, por lo tanto es muy importante que tengas configurado lo siguiente en el Kernel:

 
:
CONFIG_IP_MULTICAST=y
CONFIG_IP_MROUTE=y
:

Después viene la parte que más dolores de cabeza genera, ya tenemos todo, pero "no funciona", el tráfico llega por la VLAN2, el multicast está activo en el kernel, igmproxy arrancado, pero "NO SE ACTIVAN" las rutas. Sí parece que las instala en el kernel pero "no se activan".

¿Cual es la solución?, pues consiste en desactivar la comprobación RPF (Reverse Path Forwarding) en "ALL" y en el interfaz upstream (VLAN2), que es por donde viene el tráfico desde las fuentes, debes ejecutar los dos comandos siguientes durante el boot de tu equipo:

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**IMPORTANTE**: No te olvides de desactivar RPF en la opción "All" además de la "vlan2" o no funcionará.

[/dropshadowbox]

 

___ Pon a "0" la opción "All" ____
# echo "0" > /proc/sys/net/ipv4/conf/all/rp_filter

___ Pon a "0" el Interfaz Upstream ____
# echo "0" > /proc/sys/net/ipv4/conf/vlan2/rp_filter

{% include showImagen.html
    src="/assets/img/original/Reverse_path_forwarding)?. Porque lo normal es que las fuentes envían su tráfico desde direcciones IP que no tengo en mi tabla de routing y en linux por defecto tenemos activo ("1") el RPF, así que se “bloquean” dichos paquetes. La forma más sencilla de solucionarlo es 1) insertar rutas a dichas fuentes a través de la vlan2 o 2) desactivar RPF (opción que he elegido en mi caso"
    caption="RPF"
    width="600px"
    %}

Tienes que desactivar (0) en All y en vlan2, dejando el resto activas (1), donde el RPF seguirá actuando. Notarás que la loopback (lo) también está desactivado, es correcto.

 
/proc/sys/net/ipv4/conf/all/rp_filter        0
/proc/sys/net/ipv4/conf/default/rp_filter    1
/proc/sys/net/ipv4/conf/vlan100/rp_filter    1
/proc/sys/net/ipv4/conf/vlan2/rp_filter      0
:
/proc/sys/net/ipv4/conf/lo/rp_filter         0
/proc/sys/net/ipv4/conf/ppp0/rp_filter       1

___ COMPRUEBA TU INSTALACIÓN ___
# for i in /proc/sys/net/ipv4/conf/*/rp_filter ; do echo $i; cat $i; done

 

### Source NAT y Firewall (iptables)

Aunque ya lo expliqué antes, recordatorio: para que los paquetes de los Decos salgan hacia la VLAN2 con tú dirección IP (en la vlan2) es necesario hacer Source NAT.

 
iptables -t nat -A POSTROUTING -o vlan2 -s 192.168.1.0/24 -j SNAT --to-source 10.214.XX.YY

Opcional, si tu Linux es un router de internet y usas iptables para hacer de firewall, recuerda aceptar los paquetes multicast. Te dejo un recordatorio:

 
iptables -I INPUT -d 224.0.0.0/4 -j ACCEPT
iptables -I OUTPUT -d 224.0.0.0/4 -j ACCEPT
iptables -I FORWARD -d 224.0.0.0/4 -j ACCEPT
 

### Instalación y configuración de igmpproxy

Primero tenemos que instalar el programa, aquí tienes un ejemplo en Gentoo: emerge -v igmpproxy

A continuación debes modificar el fichero de configuración: **Nota**: En la configuración es importante que se añada el prefijo de las fuentes en el upstream (línea donde pongo altnet 172.0.0.0/8). Notar que hago un agregado muy exagerado pero no importa en mi caso porque no tengo más fuentes multicast en mi red.

 
quickleave

phyint vlan2 upstream  ratelimit 0  threshold 1
        altnet 172.0.0.0/8

phyint vlan100 downstream  ratelimit 0  threshold 1

phyint enp2s0f0 disabled
phyint lo disabled
phyint ppp0 disabled
phyint vlan6 disabled

Arranque en Gentoo:

 
# rc-update add igmpproxy default
# /etc/init.d/igmpproxy start
 

### Resolución de problemas

Comprueba varias cosas si estás teniendo problemas con el servicio de IPTV. Para empezar deberías poder hacer ping al DNS Server interno que tiene Movistar en su propia red para este servicio de Televisión.

 
# ping 172.26.23.3 
64 bytes from 172.26.23.3: icmp_seq=1 ttl=126 time=7.54 ms
64 bytes from 172.26.23.3: icmp_seq=2 ttl=126 time=4.24 ms
:

OJo!. Algunos me han comentado que a ellos no les funciona este "ping" pero sí les va el resto de funciones. De hecho a mi me ha estado funcionando muchos meses y de repente ha dejado de funcionar, así que mejor usa lo siguiente, esto Sí que debería funcionar y es consultas DNS. Prueba por ejemplo a consultar el registro SOA del dicho DNS Server:

 
# dig @172.26.23.3 imagenio.telefonica.net | grep SOA
imagenio.telefonica.net. 10800  IN  SOA mmsdmco1-01.imagenio.telefonica.net. postmaster.imagenio.telefonica.net. 2015080901 86400 7200 2592000 345600
:

En vez de arrancar el daemon en el background, durante las pruebas o para resolver problemas y ver "qué está pasando" ejecuta igmpproxy manualmente de la siguiente forma:

 
# /usr/sbin/igmpproxy -d -vv /etc/igmpproxy.conf
 

Además puedes ir comprobando en otros terminales cómo se van insertando las rutas multicast en el kernel, el tráfico que pasa por cada fuente, etc...

 

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
 

Verificar que tienes activo el routing (y desactivo el RPF) en el kernel:

 
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

Verificar cómo tienes el RPF

 
# for i in /proc/sys/net/ipv4/conf/*/rp_filter ; do echo $i; cat $i; done

 

## IGMP Snooping

Es importante evitar que la intranet donde están los DECO’s (u otros receptores) se llene de tráfico Multicast en todos sus puertos. Si no hacemos nada, al enviar tráfico multicast hacia la VLAN100 el switch replicará en todos los puertos que pertenezcan a dicha vlan, es decir, una tormenta de tráfico innecesario que no necesitamos, de hecho donde menos lo queremos es en los puntos de acceso Wifi, imagínate recibiendo 10, 20, 30Mbps extra, supondrá un desastre para la calidad de los clientes Wifi.

Para solucionarlo no hay que hacer nada en el linux, solo en el switch ethernet. Es tan simple como activar IGMP Snooping, que normalmente podrás hacer por puerto, grupos de puertos, por vlan, etc. depende del switch.

Al activarlo estamos pidiendo al switch que espíe el tráfico IGMP, mantenga un mapa de qué puertos piden suscribirse a los flujos (multicast) y así saber a quién mandar y a quién no.

 

## Ver la TV

Si has llegado hasta aquí entonces estarás deseando “ver” la TV y para hacerlo tenemos varias opciones. La primera y más evidente es utilizar el "Deco" que nos entrega Movistar con el servicio, pero también podrías intentar usar algún cliente IPTV.

### Cliente "Deco" de Movistar

Es el método más claro y sencillo de todos, para configurarlo pulsa repetidamente la tecla menú después de arrancarlo; cuando está parpadeando el último cuadro durante el boot. Entrarás en el menú de configuración del firmware y desde ahí podrás activar (viene así por defecto) que use DHCP. Lo de entrar con la tecla menú realmente no hace falta, solo es para ver que recibe la IP correcta desde el DHCP Server.

Una vez que lo tengas encendido y conectado a tu TV debería funcionar todo, bueno, casi todo (más adelante verás el tema de Acceso a videos bajo demanda).

### Cliente IPTV "VLC"

Otro método evidente y sencillo, usar el mejor cliente de video que existe: VLC. De hecho, antes de intentar otras opciones es la que te recomiendo, una vez arrancado en tu ordenador, selecciona “Abrir Red” y utiliza el URL siguiente: rtp://@239.0.0.76:8208, para ver TVE-1. Ya está, no hay mucho más que hacer, has utilizado VLC como cliente IPTV con protocolo multicast.

{% include showImagen.html
    src="/assets/img/original/iptvvlc1.png"
    caption="iptvvlc1"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iptvvlc2-1024x659.png"
    caption="iptvvlc2"
    width="600px"
    %}

Lista de canales, puedes salvarlas en un fichero con el nombre Movistar.m3u y usarlo desde VLC:

 
    #EXTINF:-1,[000] Movistar TV - Promocional
    rtp://@239.0.0.77:8208
    #EXTINF:-1,[001] La 1
    rtp://@239.0.0.76:8208
    #EXTINF:-1,[002] La 2
    rtp://@239.0.0.2:8208
    #EXTINF:-1,[003] Antena 3
    rtp://@239.0.0.3:8208
    #EXTINF:-1,[004] Cuatro
    rtp://@239.0.0.4:8208
    #EXTINF:-1,[005] Tele 5
    rtp://@239.0.0.5:8208
    #EXTINF:-1,[006] La sexta
    rtp://@239.0.0.58:8208
     
     
    AUTONOMICOS (* sÛlo en Comunidad de origen)
     
    Comunidad de Madrid
     
    #EXTINF:-1,[007] Telemadrid *
    rtp://@239.0.0.25:8208
    #EXTINF:-1,[008] La Otra *
    rtp://@239.0.0.26:8208
     
    CataluÒa
     
    #EXTINF:-1,[007] TV3 *
    rtp://@239.0.0.23:8208
    #EXTINF:-1,[008] Canal 33 *
    rtp://@239.0.0.24:8208
    #EXTINF:-1,[009] 8 TV *
    rtp://@239.0.0.82:8208
     
    Comunidad Valenciana
     
    #EXTINF:-1,[007] Canal 9 *
    rtp://@239.0.0.6:8208
    #EXTINF:-1,[008] 24/9 *
    rtp://@239.0.0.7:8208
     
    Euskadi
     
    #EXTINF:-1,[007] ETB 1 *
    rtp://@239.0.0.35:8208
    #EXTINF:-1,[008] ETB 2 *
    rtp://@239.0.0.36:8208
     
    AndalucÌa
     
    #EXTINF:-1,[007] Canal Sur *
    rtp://@239.0.0.49:8208
    #EXTINF:-1,[008] Canal Sur 2 *
    rtp://@239.0.0.50:8208
     
    Islas Canarias
     
    #EXTINF:-1,[007] TV Canaria *
    rtp://@239.0.0.54:8208
     
    Castilla La Mancha
     
    #EXTINF:-1,[007] CMT *
    rtp://@239.0.0.55:8208
     
    Galicia
     
    #EXTINF:-1,[007] TV Galicia *
    rtp://@239.0.0.53:8208
     
    Islas Baleares
     
    #EXTINF:-1,[007] IB3 *
    rtp://@239.0.0.56:8208
     
    AragÛn
     
    #EXTINF:-1,[007] Aragon TV *
    rtp://@239.0.0.88:8208
     
    Murcia
     
    #EXTINF:-1,[007] 7 Region de Murcia *
    rtp://@239.0.0.87:8208
     
    Asturias
     
    #EXTINF:-1,[007] TV Principado de Asturias *
    rtp://@239.0.0.86:8208
     
    Extremadura
     
    #EXTINF:-1,[007] Extremadura TV *
    rtp://@239.0.0.73:8208
     
    Castilla y LeÛn
     
    #EXTINF:-1,[007] Castilla y Leon 7 *
    rtp://@239.0.0.109:8208
     
     
    #EXTINF:-1,[009] Canal del Mes
    rtp://@239.0.0.99:8208
    #EXTINF:-1,[010] FOX
    rtp://@239.0.0.74:8208
    #EXTINF:-1,[011] AXN
    rtp://@239.0.0.14:8208
    #EXTINF:-1,[012] Calle 13
    rtp://@239.0.0.13:8208
    #EXTINF:-1,[013] TNT
    rtp://@239.0.0.44:8208
    #EXTINF:-1,[014] Fox Crime
    rtp://@239.0.0.112:8208
    #EXTINF:-1,[015] Cosmo TV
    rtp://@239.0.0.15:8208
    #EXTINF:-1,[016] AXN White
    rtp://@239.0.0.62:8208
    #EXTINF:-1,[017] Paramount Comedy
    rtp://@239.0.0.68:8208
    #EXTINF:-1,[018] SyFy
    rtp://@239.0.0.111:8208
    #EXTINF:-1,[019] Crimen & Investigacion
    rtp://@239.0.0.57:8208
    #EXTINF:-1,[020] FDF
    rtp://@239.0.0.84:8208
    #EXTINF:-1,[021] Neox
    rtp://@239.0.0.107:8208
    #EXTINF:-1,[022] Energy
    rtp://@239.0.0.59:8208
    #EXTINF:-1,[023] Nitro
    rtp://@239.0.0.85:8208
    #EXTINF:-1,[024] Divinity
    rtp://@239.0.0.48:8208
    #EXTINF:-1,[026] La Siete
    rtp://@239.0.0.83:8208
    #EXTINF:-1,[027] Nova
    rtp://@239.0.0.106:8208
    #EXTINF:-1,[028] MTV Espana
    rtp://@239.0.0.110:8208
    #EXTINF:-1,[029] Sundance Channel
    rtp://@239.0.0.102:8208
    #EXTINF:-1,[031] Hollywood
    rtp://@239.0.0.16:8208
    #EXTINF:-1,[032] MGM
    rtp://@239.0.0.8:8208
    #EXTINF:-1,[033] Disney Cinemagic
    rtp://@239.0.0.9:8208
    #EXTINF:-1,[034] TCM
    rtp://@239.0.6.5:8208
    #EXTINF:-1,[038] Paramount Channel
    rtp://@239.0.0.90:8208
    #EXTINF:-1,[039] La Sexta3
    rtp://@239.0.0.95:8208
    #EXTINF:-1,[040] Eurosport
    rtp://@239.0.0.18:8208
    #EXTINF:-1,[041] Eurosport 2
    rtp://@239.0.0.37:8208
    #EXTINF:-1,[042] Sportmania
    rtp://@239.0.0.17:8208
    #EXTINF:-1,[043] Teledeporte
    rtp://@239.0.0.79:8208
    #EXTINF:-1,[044] Iberalia
    rtp://@239.0.5.6:8208
    #EXTINF:-1,[050] Canal+ Liga
    rtp://@239.0.0.42:8208
    #EXTINF:-1,[051] Canal+ Liga Multi
    rtp://@239.0.0.119:8208
    #EXTINF:-1,[052] Canal+ Liga Multi 2
    rtp://@239.0.0.120:8208
    #EXTINF:-1,[053] Canal+ Liga Multi 3
    rtp://@239.0.0.121:8208
    #EXTINF:-1,[054] Canal+ Liga Multi 4
    rtp://@239.0.0.122:8208
    #EXTINF:-1,[055] Canal+ Liga de Campeones
    rtp://@239.0.0.118:8208
    #EXTINF:-1,[056] Gol 2 Internacional - Europa League
    rtp://@239.0.0.52:8208
    #EXTINF:-1,[057] Canal+ Liga de Campeones 2
    rtp://@239.0.3.3:8208
    #EXTINF:-1,[058] Canal+ Liga de Campeones 3/Europa League 2/Canal+ Liga Multi 5
    rtp://@239.0.3.4:8208
    #EXTINF:-1,[059] Canal+ Liga de Campeones 4/Europa League 3
    rtp://@239.0.3.5:8208
    #EXTINF:-1,[060] Canal+ Liga de Campeones 5/Europa League 4
    rtp://@239.0.3.6:8208
    #EXTINF:-1,[061] Canal+ Liga de Campeones 6/Europa League 5
    rtp://@239.0.3.7:8208
    #EXTINF:-1,[062] Canal+ Liga de Campeones 7/Europa League 6
    rtp://@239.0.0.123:8208
    #EXTINF:-1,[063] Canal+ Liga de Campeones 8/Europa League 7
    rtp://@239.0.0.124:8208
    #EXTINF:-1,[064] Futbol Replay
    rtp://@239.0.0.97:8208
    #EXTINF:-1,[069] Xplora
    rtp://@239.0.0.61:8208
    #EXTINF:-1,[070] National Geographic
    rtp://@239.0.0.103:8208
    #EXTINF:-1,[071] NAT GEO Wild
    rtp://@239.0.0.89:8208
    #EXTINF:-1,[072] Viajar
    rtp://@239.0.0.20:8208
    #EXTINF:-1,[073] Discovery Channel
    rtp://@239.0.0.21:8208
    #EXTINF:-1,[074] Odisea
    rtp://@239.0.0.22:8208
    #EXTINF:-1,[075] Historia
    rtp://@239.0.0.19:8208
    #EXTINF:-1,[076] Biography Channel
    rtp://@239.0.0.38:8208
    #EXTINF:-1,[077] Cocina
    rtp://@239.0.0.27:8208
    #EXTINF:-1,[078] Decasa
    rtp://@239.0.0.71:8208
    #EXTINF:-1,[079] Discovery MAX
    rtp://@239.0.0.32:8208
    #EXTINF:-1,[080] Baby TV
    rtp://@239.0.0.113:8208
    #EXTINF:-1,[081] Disney Junior
    rtp://@239.0.0.10:8208
    #EXTINF:-1,[082] Canal Panda
    rtp://@239.0.0.117:8208
    #EXTINF:-1,[084] Nickelodeon
    rtp://@239.0.0.69:8208
    #EXTINF:-1,[085] Disney XD
    rtp://@239.0.0.11:8208
    #EXTINF:-1,[086] Disney Channel
    rtp://@239.0.0.64:8208
    #EXTINF:-1,[087] Boing
    rtp://@239.0.0.66:8208
    #EXTINF:-1,[088] Clan TVE
    rtp://@239.0.0.80:8208
    #EXTINF:-1,[090] Sol Musica
    rtp://@239.0.0.39:8208
    #EXTINF:-1,[091] 40 TV
    rtp://@239.0.0.12:8208
    #EXTINF:-1,[092] VH1
    rtp://@239.0.0.75:8208
    #EXTINF:-1,[099] Descubre Mas
    rtp://@239.0.0.164:8208
    #EXTINF:-1,[100] Fox News
    rtp://@239.0.7.65:8208
    #EXTINF:-1,[101] BBC world
    rtp://@239.0.0.30:8208
    #EXTINF:-1,[102] CNNi
    rtp://@239.0.0.40:8208
    #EXTINF:-1,[103] Euronews
    rtp://@239.0.0.28:8208
    #EXTINF:-1,[104] Canal 24 Horas
    rtp://@239.0.0.78:8208
    #EXTINF:-1,[105] Al Jazeera (InglÈs)
    rtp://@239.0.7.66:8208
    #EXTINF:-1,[106] France 24 (InglÈs)
    rtp://@239.0.7.67:8208
    #EXTINF:-1,[107] Russia Today (InglÈs)
    rtp://@239.0.7.68:8208
    #EXTINF:-1,[108] CNBC Europe
    rtp://@239.0.7.69:8208
    #EXTINF:-1,[109] CCTV-E
    rtp://@239.0.0.65:8208
    #EXTINF:-1,[110] TV5 Monde Europe
    rtp://@239.0.0.31:8208
    #EXTINF:-1,[111] Bloomberg
    rtp://@239.0.0.29:8208
    #EXTINF:-1,[112] Intereconomia TV
    rtp://@239.0.0.63:8208
    #EXTINF:-1,[113] Inter TV
    rtp://@239.0.0.101:8208
    #EXTINF:-1,[114] 13 TV
    rtp://@239.0.0.91:8208
    #EXTINF:-1, [116] I24 News
    rtp://@239.0.0.220:8208
    #EXTINF:-1, [117] CNC World
    rtp://@239.0.0.221:8208
    #EXTINF:-1,[200] La Tienda en Casa
    rtp://@239.0.0.98:8208
    #EXTINF:-1,[288] Canal+ Liga de campeones 9
    rtp://@239.0.3.2:8208
     
     
    EXTRAS HD PARA FTTH Y VDSL (Canales HD VDSL hasta 31/03/14)
     
     
    #EXTINF:-1,[504] Cuatro HD
    rtp://@239.0.0.177:8208
    #EXTINF:-1,[505] Tele 5 HD
    rtp://@239.0.0.176:8208
     
    #EXTINF:-1,[520] FOX HD
    rtp://@239.0.9.134:8208
    #EXTINF:-1,[521] AXN HD
    rtp://@239.0.9.131:8208
    #EXTINF:-1,[541] MGM HD
    rtp://@239.0.9.132:8208
    #EXTINF:-1,[556] Gol 2 Internacional HD
    rtp://@239.0.9.146:8208
    #EXTINF:-1,[592] Nat Geo Wild HD
    rtp://@239.0.9.136:8208
    #EXTINF:-1,[594] Canal+ F˙tbol Contingencia HD
    rtp://@239.0.9.140:8208
    #EXTINF:-1,[597] Canal+ Liga de Campeones 2 HD/Canal+ Liga Multi HD
    rtp://@239.0.9.139:8208
    #EXTINF:-1,[598] Canal+ Liga de Campeones HD
    rtp://@239.0.9.138:8208
    #EXTINF:-1,[599] Canal+ Liga HD
    rtp://@239.0.9.129:8208
    #EXTINF:-1,[600] Eurosport HD
    rtp://@239.0.9.135:8208
    #EXTINF:-1,[629] Unitel Classica HD
    rtp://@239.0.9.137:8208
     
     
    EXTRAS HD SOLO PARA FTTH
     
     
    #EXTINF:-1,[515] FOX Crime HD
    rtp://@239.0.5.86:8208
    #EXTINF:-1,[522] TNT HD
    rtp://@239.0.5.87:8208
    #EXTINF:-1,[523] Canal 13 HD
    rtp://@239.0.5.74:8208
    #EXTINF:-1,[526] Cosmopolitan HD
    rtp://@239.0.5.71:8208
    #EXTINF:-1,[527] AXN White HD
    rtp://@239.0.5.79:8208
    #EXTINF:-1,[529] Sundance Channel HD
    rtp://@239.0.5.72:8208
    #EXTINF:-1,[530] Sy-Fy HD
    rtp://@239.0.5.75:8208
    #EXTINF:-1,[533] Disney Cinemagic HD
    rtp://@239.0.5.81:8208
    #EXTINF:-1,[534] TCM HD
    rtp://@239.0.5.89:8208
    #EXTINF:-1,[540] Hollywood HD
    rtp://@239.0.5.76:8208
    #EXTINF:-1,[572] Viajar HD
    rtp://@239.0.5.73:8208
    #EXTINF:-1,[580] Discovery Channel HD
    rtp://@239.0.5.77:8208
    #EXTINF:-1,[581] National Geographic HD
    rtp://@239.0.5.78:8208
    #EXTINF:-1,[583] Odisea HD
    rtp://@239.0.5.82:8208
    #EXTINF:-1,[586] Disney Channel HD
    rtp://@239.0.5.80:8208
     
     
    EXTRAS FAVORITOS Y CANALES A LA CARTA
     
     
    #EXTINF:-1,[030] Canal + 1
    rtp://@239.0.4.129:8208
    #EXTINF:-1,[035] Extreme
    rtp://@239.0.6.1:8208
    #EXTINF:-1,[036] Somos
    rtp://@239.0.6.4:8208
    #EXTINF:-1,[037] Cinematek
    rtp://@239.0.6.3:8208
    #EXTINF:-1,[045] Barca TV
    rtp://@239.0.3.65:8208
    #EXTINF:-1,[093] Unitel Classica
    rtp://@239.0.3.193:8208
    #EXTINF:-1,[120] Telefe Internacional
    rtp://@239.0.8.3:8208
    #EXTINF:-1,[121] Canal Estrellas
    rtp://@239.0.8.193:8208
    #EXTINF:-1,[122] Caracol TV Int.
    rtp://@239.0.7.129:8208
    #EXTINF:-1,[123] TV Record
    rtp://@239.0.8.2:8208
    #EXTINF:-1,[124] TV Chile Intern.
    rtp://@239.0.8.1:8208
    #EXTINF:-1,[125] TV Colombia
    rtp://@239.0.7.131:8208
    #EXTINF:-1,[126] Azteca Intern.
    rtp://@239.0.8.68:8208
    #EXTINF:-1,[127] Cubavision
    rtp://@239.0.8.67:8208
    #EXTINF:-1,[128] Telesur
    rtp://@239.0.8.69:8208
    #EXTINF:-1,[140] Phoenix CNE
    rtp://@239.0.7.193:8208
    #EXTINF:-1,[141] InfoNews Channel
    rtp://@239.0.7.194:8208
     
     
     
    FORMULA 1 (En abierto hasta Abril)
     
    Canales SD
    #EXTINF:-1, [047] Movistar F1 / F1 Camara 1
    rtp://@239.0.0.134:8208
    #EXTINF:-1, [224] F1 Camara 2
    rtp://@239.0.0.135:8208
    #EXTINF:-1, [225] F1 Camara 3
    rtp://@239.0.0.136:8208
    #EXTINF:-1, [226] F1 Camara 4
    rtp://@239.0.0.137:8208
    #EXTINF:-1, [227] F1 Camara 5
    rtp://@239.0.0.138:8208
    #EXTINF:-1, [228] F1 Camara 6
    rtp://@239.0.0.139:8208
    #EXTINF:-1, [204] Multicamara 1
    rtp://@239.0.3.28:8208
    #EXTINF:-1, [205] Multicamara 2
    rtp://@239.0.3.37:8208
    #EXTINF:-1, [206] Multicamara 3
    rtp://@239.0.3.29:8208
    #EXTINF:-1, [207] Multicamara 4
    rtp://@239.0.3.30:8208
    #EXTINF:-1, [208] Multicamara 5
    rtp://@239.0.3.31:8208
    #EXTINF:-1, [209] Multicamara 6
    rtp://@239.0.3.32:8208
     
     
    Canales HD
    #EXTINF:-1, [047] Movistar F1 HD /F1 Camara 1 HD
    rtp://@239.0.0.170:8208
    #EXTINF:-1, [224] F1 Camara 2 HD
    rtp://@239.0.0.171:8208
    #EXTINF:-1, [225] F1 Camara 3 HD
    rtp://@239.0.0.172:8208
    #EXTINF:-1, [226] F1 Camara 4 HD
    rtp://@239.0.0.173:8208
    #EXTINF:-1, [227] F1 Camara 5 HD
    rtp://@239.0.0.174:8208
    #EXTINF:-1, [228] F1 Camara 6 HD
    rtp://@239.0.0.175:8208
    #EXTINF:-1, [204] Multicamara 1 HD
    rtp://@239.0.0.178:8208
    #EXTINF:-1, [205] Multicamara 2 HD
    rtp://@239.0.0.179:8208
    #EXTINF:-1, [206] Multicamara 3 HD
    rtp://@239.0.0.180:8208
    #EXTINF:-1, [207] Multicamara 4 HD
    rtp://@239.0.0.181:8208
    #EXTINF:-1, [208] Multicamara 5 HD
    rtp://@239.0.0.182:8208
    #EXTINF:-1, [209] Multicamara 6 HD
    rtp://@239.0.0.183:8208

 

### TVHeadend (como cliente IPTV)

{% include showImagen.html
    src="/assets/img/original/tvheadend)), se trata de un DVR (Digital Video Recorder) y un servidor de streaming de TV que soporta todo tipo de fuentes: DVB-C, DVB-T(2), DVB-S(2), ATSC y además "**IPTV (UDP o HTTP"
    caption="Tvheadend](https://tvheadend.org/projects/tvheadend) ([GitHub tvheadend"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/Htsp"
    caption="HTSP"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/?p=1225)"
    caption="Media Center integrado con Movistar TV"
    width="600px"
    %}

El proceso de instalación es el siguinete, notar que estoy instalando la última versión disponible en GitHub porque me interesa que la versión sea 3.9+ para poder aprovechar toda su potencia:

totobo ~ # echo "=media-video/libav-11.3 ~amd64" >> /etc/portage/package.accept_keywords
totobo ~ # echo "=media-tv/tvheadend-9999 **" >> /etc/portage/package.accept_keywords
totobo ~ # echo "media-tv/tvheadend avahi dvb dvbscan ffmpeg zlib xmltv"  >> /etc/portage/package.use
totobo ~ # emerge -v media-tv/tvheadend
:
totobo ~ # /etc/init.d/tvheadend start

Una vez que lo he arrancado ya puedo conectar con su interfaz web usando el puerto 9981 (http://dirección_ip_de_tu_linux:9981), podré dar de alta las fuentes IPTV, los canales y "ver" quién está accediendo a ellos. En el ejemplo siguiente he configurado dos canales:

{% include showImagen.html
    src="/assets/img/original/tvheadend1.png"
    caption="tvheadend1"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/tvheadend2.png"
    caption="tvheadend2"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/?p=1225"
    caption="Raspberry Pi con OpenElec"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/tvheadend5-1024x578.png"
    caption="tvheadend5"
    width="600px"
    %}

Una de las ventajas que tenemos es la posibildiad de monitorizar quién está usando el servicio y cuando ancho de banda está consumiendo (un canal HD de movistar suelen ser ~10Mbps).

{% include showImagen.html
    src="/assets/img/original/tvheadend3-1024x186.png"
    caption="tvheadend3"
    width="600px"
    %}

 

### udpxy

Para conseguirlo tenemos este pequeño paquete que es simplemente genial. Se trata de un Daemon que permite hacer relay del tráfico multicast UDP hacia clientes TCP (HTTP). Es decir, él va a tratar por un lado el tráfico multicast y por otro nos dejará ver los canales en HTTP. Traducido: sirve para que desde cualquier clientes PC’s, Mac’s, Linux, etc. con un cliente IPTV que solo soporta HTTP podamos ver los canales.

Primero lo instalo (Gentoo): emerge -v udpxy y lo configuro:

UDPXYOPTS="-a vlan100 -p 4022 -m vlan2 -c 16"

En este caso estamos diciendo que escuche por el puerto tcp:4022 en la vlan100, que se suscriba a los grupos multicast a través de la interfaz vlan2 y **con el argumento -c 16 le decimos que soporte hasta 16 clientes (ojo que por defecto sirve un máximo de 3 clientes)**. Cuando un cliente le pida ver un canal concreto por la vlan100 (en http), él se suscribirá a dicho canal por la vlan2 y en cuanto empiece a recibir el video (vía multicast por vlan2) lo reenviará al cliente pero en HTTP por la vlan100

Arranque en Gentoo: /etc/init.d/udpxy start

A partir de aquí ya podremos conectar con las fuentes usando el protocolo HTTP. A modo de ejemplo con VLC usando la siguiente dirección de Red deberías ver TVE2:

- http://192.168.1.1:4022/udp/239.0.0.2:8208

De nuevo dejo la lista de canales completa pero ahora con el formato HTTP por si quieres usarlo así desde VLC, es decir por si prefieres la opción de UDPXY en vez de IGMP Proxy y el protocolo RTP.

 
    #EXTINF:-1,[000] Movistar TV - Promocional
    http://192.168.1.1:4022/udp/239.0.0.77:8208
    #EXTINF:-1,[001] La 1
    http://192.168.1.1:4022/udp/239.0.0.76:8208
    #EXTINF:-1,[002] La 2
    http://192.168.1.1:4022/udp/239.0.0.2:8208
    #EXTINF:-1,[003] Antena 3
    http://192.168.1.1:4022/udp/239.0.0.3:8208
    #EXTINF:-1,[004] Cuatro
    http://192.168.1.1:4022/udp/239.0.0.4:8208
    #EXTINF:-1,[005] Tele 5
    http://192.168.1.1:4022/udp/239.0.0.5:8208
    #EXTINF:-1,[006] La sexta
    http://192.168.1.1:4022/udp/239.0.0.58:8208
     
     
    AUTONOMICOS (* sÛlo en Comunidad de origen)
     
    Comunidad de Madrid
     
    #EXTINF:-1,[007] Telemadrid *
    http://192.168.1.1:4022/udp/239.0.0.25:8208
    #EXTINF:-1,[008] La Otra *
    http://192.168.1.1:4022/udp/239.0.0.26:8208
     
    CataluÒa
     
    #EXTINF:-1,[007] TV3 *
    http://192.168.1.1:4022/udp/239.0.0.23:8208
    #EXTINF:-1,[008] Canal 33 *
    http://192.168.1.1:4022/udp/239.0.0.24:8208
    #EXTINF:-1,[009] 8 TV *
    http://192.168.1.1:4022/udp/239.0.0.82:8208
     
    Comunidad Valenciana
     
    #EXTINF:-1,[007] Canal 9 *
    http://192.168.1.1:4022/udp/239.0.0.6:8208
    #EXTINF:-1,[008] 24/9 *
    http://192.168.1.1:4022/udp/239.0.0.7:8208
     
    Euskadi
     
    #EXTINF:-1,[007] ETB 1 *
    http://192.168.1.1:4022/udp/239.0.0.35:8208
    #EXTINF:-1,[008] ETB 2 *
    http://192.168.1.1:4022/udp/239.0.0.36:8208
     
    AndalucÌa
     
    #EXTINF:-1,[007] Canal Sur *
    http://192.168.1.1:4022/udp/239.0.0.49:8208
    #EXTINF:-1,[008] Canal Sur 2 *
    http://192.168.1.1:4022/udp/239.0.0.50:8208
     
    Islas Canarias
     
    #EXTINF:-1,[007] TV Canaria *
    http://192.168.1.1:4022/udp/239.0.0.54:8208
     
    Castilla La Mancha
     
    #EXTINF:-1,[007] CMT *
    http://192.168.1.1:4022/udp/239.0.0.55:8208
     
    Galicia
     
    #EXTINF:-1,[007] TV Galicia *
    http://192.168.1.1:4022/udp/239.0.0.53:8208
     
    Islas Baleares
     
    #EXTINF:-1,[007] IB3 *
    http://192.168.1.1:4022/udp/239.0.0.56:8208
     
    AragÛn
     
    #EXTINF:-1,[007] Aragon TV *
    http://192.168.1.1:4022/udp/239.0.0.88:8208
     
    Murcia
     
    #EXTINF:-1,[007] 7 Region de Murcia *
    http://192.168.1.1:4022/udp/239.0.0.87:8208
     
    Asturias
     
    #EXTINF:-1,[007] TV Principado de Asturias *
    http://192.168.1.1:4022/udp/239.0.0.86:8208
     
    Extremadura
     
    #EXTINF:-1,[007] Extremadura TV *
    http://192.168.1.1:4022/udp/239.0.0.73:8208
     
    Castilla y LeÛn
     
    #EXTINF:-1,[007] Castilla y Leon 7 *
    http://192.168.1.1:4022/udp/239.0.0.109:8208
     
     
    #EXTINF:-1,[009] Canal del Mes
    http://192.168.1.1:4022/udp/239.0.0.99:8208
    #EXTINF:-1,[010] FOX
    http://192.168.1.1:4022/udp/239.0.0.74:8208
    #EXTINF:-1,[011] AXN
    http://192.168.1.1:4022/udp/239.0.0.14:8208
    #EXTINF:-1,[012] Calle 13
    http://192.168.1.1:4022/udp/239.0.0.13:8208
    #EXTINF:-1,[013] TNT
    http://192.168.1.1:4022/udp/239.0.0.44:8208
    #EXTINF:-1,[014] Fox Crime
    http://192.168.1.1:4022/udp/239.0.0.112:8208
    #EXTINF:-1,[015] Cosmo TV
    http://192.168.1.1:4022/udp/239.0.0.15:8208
    #EXTINF:-1,[016] AXN White
    http://192.168.1.1:4022/udp/239.0.0.62:8208
    #EXTINF:-1,[017] Paramount Comedy
    http://192.168.1.1:4022/udp/239.0.0.68:8208
    #EXTINF:-1,[018] SyFy
    http://192.168.1.1:4022/udp/239.0.0.111:8208
    #EXTINF:-1,[019] Crimen & Investigacion
    http://192.168.1.1:4022/udp/239.0.0.57:8208
    #EXTINF:-1,[020] FDF
    http://192.168.1.1:4022/udp/239.0.0.84:8208
    #EXTINF:-1,[021] Neox
    http://192.168.1.1:4022/udp/239.0.0.107:8208
    #EXTINF:-1,[022] Energy
    http://192.168.1.1:4022/udp/239.0.0.59:8208
    #EXTINF:-1,[023] Nitro
    http://192.168.1.1:4022/udp/239.0.0.85:8208
    #EXTINF:-1,[024] Divinity
    http://192.168.1.1:4022/udp/239.0.0.48:8208
    #EXTINF:-1,[026] La Siete
    http://192.168.1.1:4022/udp/239.0.0.83:8208
    #EXTINF:-1,[027] Nova
    http://192.168.1.1:4022/udp/239.0.0.106:8208
    #EXTINF:-1,[028] MTV Espana
    http://192.168.1.1:4022/udp/239.0.0.110:8208
    #EXTINF:-1,[029] Sundance Channel
    http://192.168.1.1:4022/udp/239.0.0.102:8208
    #EXTINF:-1,[031] Hollywood
    http://192.168.1.1:4022/udp/239.0.0.16:8208
    #EXTINF:-1,[032] MGM
    http://192.168.1.1:4022/udp/239.0.0.8:8208
    #EXTINF:-1,[033] Disney Cinemagic
    http://192.168.1.1:4022/udp/239.0.0.9:8208
    #EXTINF:-1,[034] TCM
    http://192.168.1.1:4022/udp/239.0.6.5:8208
    #EXTINF:-1,[038] Paramount Channel
    http://192.168.1.1:4022/udp/239.0.0.90:8208
    #EXTINF:-1,[039] La Sexta3
    http://192.168.1.1:4022/udp/239.0.0.95:8208
    #EXTINF:-1,[040] Eurosport
    http://192.168.1.1:4022/udp/239.0.0.18:8208
    #EXTINF:-1,[041] Eurosport 2
    http://192.168.1.1:4022/udp/239.0.0.37:8208
    #EXTINF:-1,[042] Sportmania
    http://192.168.1.1:4022/udp/239.0.0.17:8208
    #EXTINF:-1,[043] Teledeporte
    http://192.168.1.1:4022/udp/239.0.0.79:8208
    #EXTINF:-1,[044] Iberalia
    http://192.168.1.1:4022/udp/239.0.5.6:8208
    #EXTINF:-1,[050] Canal+ Liga
    http://192.168.1.1:4022/udp/239.0.0.42:8208
    #EXTINF:-1,[051] Canal+ Liga Multi
    http://192.168.1.1:4022/udp/239.0.0.119:8208
    #EXTINF:-1,[052] Canal+ Liga Multi 2
    http://192.168.1.1:4022/udp/239.0.0.120:8208
    #EXTINF:-1,[053] Canal+ Liga Multi 3
    http://192.168.1.1:4022/udp/239.0.0.121:8208
    #EXTINF:-1,[054] Canal+ Liga Multi 4
    http://192.168.1.1:4022/udp/239.0.0.122:8208
    #EXTINF:-1,[055] Canal+ Liga de Campeones
    http://192.168.1.1:4022/udp/239.0.0.118:8208
    #EXTINF:-1,[056] Gol 2 Internacional - Europa League
    http://192.168.1.1:4022/udp/239.0.0.52:8208
    #EXTINF:-1,[057] Canal+ Liga de Campeones 2
    http://192.168.1.1:4022/udp/239.0.3.3:8208
    #EXTINF:-1,[058] Canal+ Liga de Campeones 3/Europa League 2/Canal+ Liga Multi 5
    http://192.168.1.1:4022/udp/239.0.3.4:8208
    #EXTINF:-1,[059] Canal+ Liga de Campeones 4/Europa League 3
    http://192.168.1.1:4022/udp/239.0.3.5:8208
    #EXTINF:-1,[060] Canal+ Liga de Campeones 5/Europa League 4
    http://192.168.1.1:4022/udp/239.0.3.6:8208
    #EXTINF:-1,[061] Canal+ Liga de Campeones 6/Europa League 5
    http://192.168.1.1:4022/udp/239.0.3.7:8208
    #EXTINF:-1,[062] Canal+ Liga de Campeones 7/Europa League 6
    http://192.168.1.1:4022/udp/239.0.0.123:8208
    #EXTINF:-1,[063] Canal+ Liga de Campeones 8/Europa League 7
    http://192.168.1.1:4022/udp/239.0.0.124:8208
    #EXTINF:-1,[064] Futbol Replay
    http://192.168.1.1:4022/udp/239.0.0.97:8208
    #EXTINF:-1,[069] Xplora
    http://192.168.1.1:4022/udp/239.0.0.61:8208
    #EXTINF:-1,[070] National Geographic
    http://192.168.1.1:4022/udp/239.0.0.103:8208
    #EXTINF:-1,[071] NAT GEO Wild
    http://192.168.1.1:4022/udp/239.0.0.89:8208
    #EXTINF:-1,[072] Viajar
    http://192.168.1.1:4022/udp/239.0.0.20:8208
    #EXTINF:-1,[073] Discovery Channel
    http://192.168.1.1:4022/udp/239.0.0.21:8208
    #EXTINF:-1,[074] Odisea
    http://192.168.1.1:4022/udp/239.0.0.22:8208
    #EXTINF:-1,[075] Historia
    http://192.168.1.1:4022/udp/239.0.0.19:8208
    #EXTINF:-1,[076] Biography Channel
    http://192.168.1.1:4022/udp/239.0.0.38:8208
    #EXTINF:-1,[077] Cocina
    http://192.168.1.1:4022/udp/239.0.0.27:8208
    #EXTINF:-1,[078] Decasa
    http://192.168.1.1:4022/udp/239.0.0.71:8208
    #EXTINF:-1,[079] Discovery MAX
    http://192.168.1.1:4022/udp/239.0.0.32:8208
    #EXTINF:-1,[080] Baby TV
    http://192.168.1.1:4022/udp/239.0.0.113:8208
    #EXTINF:-1,[081] Disney Junior
    http://192.168.1.1:4022/udp/239.0.0.10:8208
    #EXTINF:-1,[082] Canal Panda
    http://192.168.1.1:4022/udp/239.0.0.117:8208
    #EXTINF:-1,[084] Nickelodeon
    http://192.168.1.1:4022/udp/239.0.0.69:8208
    #EXTINF:-1,[085] Disney XD
    http://192.168.1.1:4022/udp/239.0.0.11:8208
    #EXTINF:-1,[086] Disney Channel
    http://192.168.1.1:4022/udp/239.0.0.64:8208
    #EXTINF:-1,[087] Boing
    http://192.168.1.1:4022/udp/239.0.0.66:8208
    #EXTINF:-1,[088] Clan TVE
    http://192.168.1.1:4022/udp/239.0.0.80:8208
    #EXTINF:-1,[090] Sol Musica
    http://192.168.1.1:4022/udp/239.0.0.39:8208
    #EXTINF:-1,[091] 40 TV
    http://192.168.1.1:4022/udp/239.0.0.12:8208
    #EXTINF:-1,[092] VH1
    http://192.168.1.1:4022/udp/239.0.0.75:8208
    #EXTINF:-1,[099] Descubre Mas
    http://192.168.1.1:4022/udp/239.0.0.164:8208
    #EXTINF:-1,[100] Fox News
    http://192.168.1.1:4022/udp/239.0.7.65:8208
    #EXTINF:-1,[101] BBC world
    http://192.168.1.1:4022/udp/239.0.0.30:8208
    #EXTINF:-1,[102] CNNi
    http://192.168.1.1:4022/udp/239.0.0.40:8208
    #EXTINF:-1,[103] Euronews
    http://192.168.1.1:4022/udp/239.0.0.28:8208
    #EXTINF:-1,[104] Canal 24 Horas
    http://192.168.1.1:4022/udp/239.0.0.78:8208
    #EXTINF:-1,[105] Al Jazeera (InglÈs)
    http://192.168.1.1:4022/udp/239.0.7.66:8208
    #EXTINF:-1,[106] France 24 (InglÈs)
    http://192.168.1.1:4022/udp/239.0.7.67:8208
    #EXTINF:-1,[107] Russia Today (InglÈs)
    http://192.168.1.1:4022/udp/239.0.7.68:8208
    #EXTINF:-1,[108] CNBC Europe
    http://192.168.1.1:4022/udp/239.0.7.69:8208
    #EXTINF:-1,[109] CCTV-E
    http://192.168.1.1:4022/udp/239.0.0.65:8208
    #EXTINF:-1,[110] TV5 Monde Europe
    http://192.168.1.1:4022/udp/239.0.0.31:8208
    #EXTINF:-1,[111] Bloomberg
    http://192.168.1.1:4022/udp/239.0.0.29:8208
    #EXTINF:-1,[112] Intereconomia TV
    http://192.168.1.1:4022/udp/239.0.0.63:8208
    #EXTINF:-1,[113] Inter TV
    http://192.168.1.1:4022/udp/239.0.0.101:8208
    #EXTINF:-1,[114] 13 TV
    http://192.168.1.1:4022/udp/239.0.0.91:8208
    #EXTINF:-1, [116] I24 News
    http://192.168.1.1:4022/udp/239.0.0.220:8208
    #EXTINF:-1, [117] CNC World
    http://192.168.1.1:4022/udp/239.0.0.221:8208
    #EXTINF:-1,[200] La Tienda en Casa
    http://192.168.1.1:4022/udp/239.0.0.98:8208
    #EXTINF:-1,[288] Canal+ Liga de campeones 9
    http://192.168.1.1:4022/udp/239.0.3.2:8208
     
     
    EXTRAS HD PARA FTTH Y VDSL (Canales HD VDSL hasta 31/03/14)
     
     
    #EXTINF:-1,[504] Cuatro HD
    http://192.168.1.1:4022/udp/239.0.0.177:8208
    #EXTINF:-1,[505] Tele 5 HD
    http://192.168.1.1:4022/udp/239.0.0.176:8208
     
    #EXTINF:-1,[520] FOX HD
    http://192.168.1.1:4022/udp/239.0.9.134:8208
    #EXTINF:-1,[521] AXN HD
    http://192.168.1.1:4022/udp/239.0.9.131:8208
    #EXTINF:-1,[541] MGM HD
    http://192.168.1.1:4022/udp/239.0.9.132:8208
    #EXTINF:-1,[556] Gol 2 Internacional HD
    http://192.168.1.1:4022/udp/239.0.9.146:8208
    #EXTINF:-1,[592] Nat Geo Wild HD
    http://192.168.1.1:4022/udp/239.0.9.136:8208
    #EXTINF:-1,[594] Canal+ F˙tbol Contingencia HD
    http://192.168.1.1:4022/udp/239.0.9.140:8208
    #EXTINF:-1,[597] Canal+ Liga de Campeones 2 HD/Canal+ Liga Multi HD
    http://192.168.1.1:4022/udp/239.0.9.139:8208
    #EXTINF:-1,[598] Canal+ Liga de Campeones HD
    http://192.168.1.1:4022/udp/239.0.9.138:8208
    #EXTINF:-1,[599] Canal+ Liga HD
    http://192.168.1.1:4022/udp/239.0.9.129:8208
    #EXTINF:-1,[600] Eurosport HD
    http://192.168.1.1:4022/udp/239.0.9.135:8208
    #EXTINF:-1,[629] Unitel Classica HD
    http://192.168.1.1:4022/udp/239.0.9.137:8208
     
     
    EXTRAS HD SOLO PARA FTTH
     
     
    #EXTINF:-1,[515] FOX Crime HD
    http://192.168.1.1:4022/udp/239.0.5.86:8208
    #EXTINF:-1,[522] TNT HD
    http://192.168.1.1:4022/udp/239.0.5.87:8208
    #EXTINF:-1,[523] Canal 13 HD
    http://192.168.1.1:4022/udp/239.0.5.74:8208
    #EXTINF:-1,[526] Cosmopolitan HD
    http://192.168.1.1:4022/udp/239.0.5.71:8208
    #EXTINF:-1,[527] AXN White HD
    http://192.168.1.1:4022/udp/239.0.5.79:8208
    #EXTINF:-1,[529] Sundance Channel HD
    http://192.168.1.1:4022/udp/239.0.5.72:8208
    #EXTINF:-1,[530] Sy-Fy HD
    http://192.168.1.1:4022/udp/239.0.5.75:8208
    #EXTINF:-1,[533] Disney Cinemagic HD
    http://192.168.1.1:4022/udp/239.0.5.81:8208
    #EXTINF:-1,[534] TCM HD
    http://192.168.1.1:4022/udp/239.0.5.89:8208
    #EXTINF:-1,[540] Hollywood HD
    http://192.168.1.1:4022/udp/239.0.5.76:8208
    #EXTINF:-1,[572] Viajar HD
    http://192.168.1.1:4022/udp/239.0.5.73:8208
    #EXTINF:-1,[580] Discovery Channel HD
    http://192.168.1.1:4022/udp/239.0.5.77:8208
    #EXTINF:-1,[581] National Geographic HD
    http://192.168.1.1:4022/udp/239.0.5.78:8208
    #EXTINF:-1,[583] Odisea HD
    http://192.168.1.1:4022/udp/239.0.5.82:8208
    #EXTINF:-1,[586] Disney Channel HD
    http://192.168.1.1:4022/udp/239.0.5.80:8208
     
     
    EXTRAS FAVORITOS Y CANALES A LA CARTA
     
     
    #EXTINF:-1,[030] Canal + 1
    http://192.168.1.1:4022/udp/239.0.4.129:8208
    #EXTINF:-1,[035] Extreme
    http://192.168.1.1:4022/udp/239.0.6.1:8208
    #EXTINF:-1,[036] Somos
    http://192.168.1.1:4022/udp/239.0.6.4:8208
    #EXTINF:-1,[037] Cinematek
    http://192.168.1.1:4022/udp/239.0.6.3:8208
    #EXTINF:-1,[045] Barca TV
    http://192.168.1.1:4022/udp/239.0.3.65:8208
    #EXTINF:-1,[093] Unitel Classica
    http://192.168.1.1:4022/udp/239.0.3.193:8208
    #EXTINF:-1,[120] Telefe Internacional
    http://192.168.1.1:4022/udp/239.0.8.3:8208
    #EXTINF:-1,[121] Canal Estrellas
    http://192.168.1.1:4022/udp/239.0.8.193:8208
    #EXTINF:-1,[122] Caracol TV Int.
    http://192.168.1.1:4022/udp/239.0.7.129:8208
    #EXTINF:-1,[123] TV Record
    http://192.168.1.1:4022/udp/239.0.8.2:8208
    #EXTINF:-1,[124] TV Chile Intern.
    http://192.168.1.1:4022/udp/239.0.8.1:8208
    #EXTINF:-1,[125] TV Colombia
    http://192.168.1.1:4022/udp/239.0.7.131:8208
    #EXTINF:-1,[126] Azteca Intern.
    http://192.168.1.1:4022/udp/239.0.8.68:8208
    #EXTINF:-1,[127] Cubavision
    http://192.168.1.1:4022/udp/239.0.8.67:8208
    #EXTINF:-1,[128] Telesur
    http://192.168.1.1:4022/udp/239.0.8.69:8208
    #EXTINF:-1,[140] Phoenix CNE
    http://192.168.1.1:4022/udp/239.0.7.193:8208
    #EXTINF:-1,[141] InfoNews Channel
    http://192.168.1.1:4022/udp/239.0.7.194:8208
     
     
     
    FORMULA 1 (En abierto hasta Abril)
     
    Canales SD
    #EXTINF:-1, [047] Movistar F1 / F1 Camara 1
    http://192.168.1.1:4022/udp/239.0.0.134:8208
    #EXTINF:-1, [224] F1 Camara 2
    http://192.168.1.1:4022/udp/239.0.0.135:8208
    #EXTINF:-1, [225] F1 Camara 3
    http://192.168.1.1:4022/udp/239.0.0.136:8208
    #EXTINF:-1, [226] F1 Camara 4
    http://192.168.1.1:4022/udp/239.0.0.137:8208
    #EXTINF:-1, [227] F1 Camara 5
    http://192.168.1.1:4022/udp/239.0.0.138:8208
    #EXTINF:-1, [228] F1 Camara 6
    http://192.168.1.1:4022/udp/239.0.0.139:8208
    #EXTINF:-1, [204] Multicamara 1
    http://192.168.1.1:4022/udp/239.0.3.28:8208
    #EXTINF:-1, [205] Multicamara 2
    http://192.168.1.1:4022/udp/239.0.3.37:8208
    #EXTINF:-1, [206] Multicamara 3
    http://192.168.1.1:4022/udp/239.0.3.29:8208
    #EXTINF:-1, [207] Multicamara 4
    http://192.168.1.1:4022/udp/239.0.3.30:8208
    #EXTINF:-1, [208] Multicamara 5
    http://192.168.1.1:4022/udp/239.0.3.31:8208
    #EXTINF:-1, [209] Multicamara 6
    http://192.168.1.1:4022/udp/239.0.3.32:8208
     
     
    Canales HD
    #EXTINF:-1, [047] Movistar F1 HD /F1 Camara 1 HD
    http://192.168.1.1:4022/udp/239.0.0.170:8208
    #EXTINF:-1, [224] F1 Camara 2 HD
    http://192.168.1.1:4022/udp/239.0.0.171:8208
    #EXTINF:-1, [225] F1 Camara 3 HD
    http://192.168.1.1:4022/udp/239.0.0.172:8208
    #EXTINF:-1, [226] F1 Camara 4 HD
    http://192.168.1.1:4022/udp/239.0.0.173:8208
    #EXTINF:-1, [227] F1 Camara 5 HD
    http://192.168.1.1:4022/udp/239.0.0.174:8208
    #EXTINF:-1, [228] F1 Camara 6 HD
    http://192.168.1.1:4022/udp/239.0.0.175:8208
    #EXTINF:-1, [204] Multicamara 1 HD
    http://192.168.1.1:4022/udp/239.0.0.178:8208
    #EXTINF:-1, [205] Multicamara 2 HD
    http://192.168.1.1:4022/udp/239.0.0.179:8208
    #EXTINF:-1, [206] Multicamara 3 HD
    http://192.168.1.1:4022/udp/239.0.0.180:8208
    #EXTINF:-1, [207] Multicamara 4 HD
    http://192.168.1.1:4022/udp/239.0.0.181:8208
    #EXTINF:-1, [208] Multicamara 5 HD
    http://192.168.1.1:4022/udp/239.0.0.182:8208
    #EXTINF:-1, [209] Multicamara 6 HD
    http://192.168.1.1:4022/udp/239.0.0.183:8208

## udpxrec

Otra joya... que viene con updxy y nos permite programar grabaciones. No está nada mal !!

Ejemplo:

 
udpxrec -b 15:45.00 -e +2:00.00 -M 1.5Gb -n 2 -B 64K -c 239.0.0.2:8208 /mnt/Multimedia/0.MASTER/videos/Pelicula.mpg
 

Programa una grabación del canal multicast 239.0.0.2:8208 a las 15:45 hoy, con un tiempo de grabación de dos horas o que también pare si el tamaño del fichero es mayor de 1.5Gb. Se establece el tamaño del buffer de socket a 64Kb; incrementa el nice value en 2 (prioridad del proceso en linux) y se especifica cual es el fichero de salida.

### xupnpd

{% include showImagen.html
    src="/assets/img/original/#.VDrTD1v0Af4)) que permite anunciar canales y contenido multimedia a través de DLNA. Vía DLNA (UPnP"
    caption="http://xupnpd.org/"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/Layman"
    caption="layman"
    width="600px"
    %}

\=app-portage/layman-2.3.0 ~amd64

app-portage/layman  git mercurial

# emerge -v layman
# mkdir /etc/portage/repos.conf
# layman-updater -R
# layman -L

Instalo xupnpd

 
# layman -a arcon 

 
=net-misc/xupnpd-9999

 
=net-misc/xupnpd-9999 **

 
# emerge -v xupnpd
 

Configuración: notar que solo muestro qué opciones he cambiado respecto al fichero original

 
:
cfg.ssdp_interface='vlan100'
cfg.embedded=true <== Desactivo el Logging
cfg.udpxy_url='http://192.168.1.1:4022'
cfg.mcast_interface='vlan100'
cfg.name='TV Casa’
:

El siguiente es preparar un fichero "m3u", te recomiendo que copies/pegues todos los canales del fichero que mostré en la sección IGMP Proxy -> Cliente VLC -> "Movistar.m3u vía RTP", no uses el de HTTP. Copia/pega los canales que te interesen y crea un archivo M3U en el directorio de playlists con cualquier nombre: **/etc/xupnpd/playlists/Movistar TV.m3u**

Arranque del daemon (gentoo):

 
# /etc/init.d/xupnpd start
 

Ya lo tienes, ahora solo hay que consumir este servicio, con cualquier cliente UPnP, por ejemplo Televisiones SmartTV (para las que no tengas un Descodificador) o con VLC o con mediacenters basados en XBMC.

- Desde un SmartTV busca la opción de Plug’n’Play
- VLC, selecciona Red local->Plug’n’Play Universal
{% include showImagen.html
    src="/assets/img/original/?p=1225"
    caption="Add-On "PVR IPTV Simple Client""
    width="600px"
    %}

En el caso de dicho PVR IPTV Simple Client se configura así:

 
:
General
 Location: Remote Path (internet address)
 MRU Play List URL: http://192.168.1.1:4044/ui/Movistar%20TV.m3u
 Cache m3u at local storage (x)
 Numbering channels starts at: 1
:

### Acceso a videos bajo demanda

Falta un último detalle que he dejado para el final, el servicio de Video de Movistar Fusión permite seleccionar y ver videos bajo demanda en dos situaciones: 1) reproducir una grabación que hayamos programado o 2) reproducir un video desde la parrilla de Movistar TV.

{% include showImagen.html
    src="/assets/img/original/?p=378"
    caption="Movistar: Video bajo demanda con router Linux"
    width="600px"
    %}

# Orden de arranque de los scripts

El orden de arranque de todos los scripts vistos en este artículo es el que tienes más abajo. Nota que los he programado para que arranquen durante el boot (en gentoo se haría por ejemplo así: rc-update add zebra default).

 
# /etc/init.d/zebra start
# /etc/init.d/ripd start
# echo "0" > /proc/sys/net/ipv4/conf/vlan2/rp_filter
# /etc/init.d/igmpproxy start
# /etc/init.d/udpxy start
# /etc/init.d/xupnpd start
 

### Enlaces

Dejo aquí algunos enlaces interesantes:

{% include showImagen.html
    src="/assets/img/original/MythTV_or_TVheadend_on_QNAP"
    caption="QNAP con TVHeadend"
    width="600px"
    %}
