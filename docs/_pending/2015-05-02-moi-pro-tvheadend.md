---
title: "Servidor de Streaming IPTV casero"
date: "2015-05-02"
categories: 
  - "apuntes"
  - "media-center"
tags: 
  - "moi"
  - "moipro"
  - "tvheadend"
---

Por fin he dado con la mejor alternativa para montar un Servidor de Streaming IPTV casero. Si has seguido estos apuntes habrás observado que llevo tiempo investigando y documentando varias alternativas. Actualizo (Julio 2016): es el mejor Servidor si tienes MUCHAS fuentes externas (SAT o TDT y/o IPTV), pero si solo vas a usar fuentes IPTV (sin sintonizadoras) te recomiendo también explorar la opción de montarlo en tu propio Linux (mira este otro [apunte](https://www.luispa.com/archivos/4571)).

[![MoiProTvheadend](https://www.luispa.com/wp-content/uploads/2015/05/MoiProTvheadend-830x1024.png)](https://www.luispa.com/wp-content/uploads/2015/05/MoiProTvheadend.png)

Se trata de [MOI Pro](http://www.tbsdtv.com/products/tbs2911-moi-pro.html) + **Tvheadend**, un servidor de Streaming IP basado en Linux capaz de entregar entre 80-100 canales, es uno de los mejores servidores de IPTV que he encontrado en el mercado y además con un precio asequible (equiparable a equipos de gama alta estilo Dreambox, VUPlus basados en Linux).

Una alternativa algo más barata, si te vale con una única sintonizadora (o SIN sintonizadoras si solo quieres IPTV) es el [MOI+](http://www.tbsdtv.com/products/tbs2923-moi-plus.html). En mi caso he optado por la MOIpro, que me ha permitido instalar dos tarjetas PCI, una para sintonizar 2xSatélite y la otra para sintonizar 2xTDT. El equipo cuenta con una CPU Quad ARM Cortex-A9, 2GB de RAM DDR3, una Flash de 16G EMMC y tarjeta Ethernet de 100M/1Gb (también incluye Wifi: 802.11n aunque no la uso), soporta hasta 2 tarjetas sintonizadoras y como decía, su firmware está basado en Linux.

Respecto al Linux, no lo se a ciencia cierta pero creo que está basado en Ubuntu (tienen otro producto llamado [MatrixTV](http://www.tbsdtv.com/launch/tbs-2910-matrix-arm-mini-pc.html) y parece que usan la misma fuente. Eso sí, el Linux del MOI está muy limitado (incluye muy pocas cosas, no trae compilador, ni el gestor de paquetes), pero puedes conectar vía SSH y meterle bastante mano, hacerte scripts, retocar/manipular las configuraciones desde línea de comandos, como veremos a continuación.

**Lo mejor** de este equipo es que **incluye Tvheadend** **y soporta** tarjetas de **Satélite, Cable o TDT**, así como fuentes **IPTV**. Esto me permite aunar en un solo sitio la agregación de todas mis fuentes de video para poder servirlas a los equipos IP de mi red (Raspberry's, ordenadores, tablets, móviles, TV con KODI, etc..). He instalado dos tarjetas, una para Satélite (con dos sintonizadores) y una para TDT (también con dos sintonizadores):

[![MOIPRO-Sintonizadores](https://www.luispa.com/wp-content/uploads/2015/05/MOIPRO-Sintonizadores.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOIPRO-Sintonizadores.png)

**Combinar el "MOI" + Tvheadend y clientes [RaspberryPiv2 + KODI](https://www.luispa.com/?p=1284) en la(s) TV de tu casa es de momento mi solución ideal para un servicio de TV IP casero multi-cliente**, es decir, que puedes ver varios canales o contenidos multmedia simultaneamente en varias TV's, tablets, teléfonos, ordenadores, etc.

 

* * *

 

Primero voy a describir la configuración básica del equipo MOI, después entraré a su Linux para hacer un ajuste fino, a continuación Tvheadend y la configuración de las fuentes y por último describo cómo he solucionado el EPG.

# MoiPro

Una vez que terminas de montar el hardware del equipo (las tarjetas sintonizadoras vienen por separado) lo conectas a tu red, lo normal es que reciba una IP vía DHCP (puedes ver cual ha sido en el frontal del equipo). Conecta con ella desde un navegador, el usuario es root y la contraseña root. Lo primero que te recomiendo que hagas es cambiarle a una dirección IP fija.

[![MOIPro-01](https://www.luispa.com/wp-content/uploads/2015/05/MOIPro-01-1024x765.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOIPro-01.png)

Configura una dirección IP estática, la puerta de enlace y la dirección de tu DNS Server interno (si lo tienes), en caso contratrio deberás usar siempre direcciones IP en vez de nombres.

[![MOIPro-02](https://www.luispa.com/wp-content/uploads/2015/05/MOIPro-02-1024x765.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOIPro-02.png) [![MOIPro-03](https://www.luispa.com/wp-content/uploads/2015/05/MOIPro-03-1024x730.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOIPro-03.png)

hago click en Tvheadend y al cabo de unos segundos arranca el servicio, conectacto automáticamente por el puerto 9981 con el Web UI del mismo.

[![TvheadendConf](https://www.luispa.com/wp-content/uploads/2015/05/TvheadendConf.png)](https://www.luispa.com/wp-content/uploads/2015/05/TvheadendConf.png)

## Retocar el MOI Pro desde Linux

Como has visto, el interfaz Web del MOI Pro es sencillo y simple, de hecho ya tenemos acceso al Tvheadend, antes de ir corriendo a trastear vamos a tunear el equipo, así que aguanta y no configures todavía Tvheadend.

Conectar vía SSH y trabajar con él desde la línea de comandos. **El usuario por defecto es "root" y la contraseña "root"**.

 
$ ssh -l root moipro.parchis.org
\[root@MOIPro ~\]# 

### Timezone

La zona horaria que trae por defecto no es buena para mi, adáptala a tu zona horaria:

 
\[root@MOIPro ~\]# ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime

Si tienes un NTP Server identificado, configúralo modificando la línea apropiada en el fichero /etc/network.

### Gestión de Tvheadend

Podrás hacer la activación, desactivación, arranque o parada de Tvheadend desde la línea de comandos. En mi caso nunca uso el Web UI inicial del MOI Pro.

- systemctl enable tvheadend Arrancar tvheadend durante el boot
- systemctl disable tvheadend Deshabilitar Tvheadend durante el boot
- systemctl start tvheadend Arrancar tvheadend
- systemctl stop tvheadend Parar tvheadend
- syjournalctl -f Ver el log del Moi Pro (y por tanto de Tvheadend)

### MOI: Acceso vía NFS a /media/Recordings

Para poder grabar los programas de TV es necesario indicarle a Tvheadend el directorio donde debe dejar dichas grabaciones. Dado que no tiene sentido usar el disco duro propio del MOI lo lógico es hacerlo en un disco remoto usando el protocolo NFS.

Configuro el MOI para poder acceder a un servidor NFS externo. Necesito acceso a dos servicios de ficheros externos. El primero es para poder realizar las grabaciones (Recordings) desde Tvheadend y el segundo es para poder dejar la guía EPG de Movistar TV (lo veremos más adelante, pero ya voy avisando), de momento solo explico cómo configurar el primero.

Creo dos ficheros bajo /etc/systemd/system para montar automáticamente: /media/Recordings.

\[Unit\]
Description=Montar por NFS el directorio Recordings
After=syslog.target
Before=tvheadend.service

\[Mount\]
What=panoramix.parchis.org:/Recordings
Where=/media/Recordings
Options=
Type=nfs

\[Install\]
WantedBy=multi-user.target

\[Unit\]
Description=Automount /media/Recordings

\[Automount\]
Where=/media/Recordings

\[Install\]
WantedBy=multi-user.target

Habilito las units de Systemd y rearranco el equipo.

 
\[root@MOIPro /etc/systemd/system\]# systemctl enable media-Recordings.mount
\[root@MOIPro /etc/systemd/system\]# systemctl enable media-Recordings.automount
\[root@MOIPro /etc/systemd/system\]# reboot

### MOI: Asegurar la red

¿Qué quiero decir con asegurar la red?. Durante las pruebas experimenté ciertas inestabilidades en la red y descubrí que sin venir a cuento me desconfiguraba el DNS server, o mejor dicho el programa "Connection Manager (connmand)" activa su propio DNS Proxy y no siempre funciona con demasiado acierto.

Copio el archivo original "connman.service" y lo modifico para adaptarlo a mi gusto.

 
\[root@MOIPro /etc/systemd/system\]# cp /lib/systemd/system/connman.service /etc/systemd/system

\[Unit\]
Description=Connection service
After=syslog.target network-link.service
ConditionPathExists=/run/geexbox/network/connman

\[Service\]
Type=dbus
BusName=net.connman
ExecStartPre=/usr/lib/connman/connman-parse-configuration
#ExecStartPre=/usr/lib/connman/connman-parse-configuration2
ExecStart=/usr/sbin/connmand -n -r

\[Install\]
WantedBy=network.target

NETWORK\_BACKEND="connman"
NETWORK="LAN"
IFACE="eth0"
ADDRESS="192.168.1.239/24"
GATEWAY="192.168.1.1"
DNS\_SERVER="192.168.1.1 192.168.1.246"
SSID=""
HIDDEN=""
SECURITY="$"
PASSPHRASE=""
TIMESERVERS="0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"
TELNET\_SERVER=true
FTP\_SERVER=true
HTTP\_SERVER="false"
SAMBA\_SERVER=true
ZEROCONF="true"
WAIT\_FOR\_SLOW\_DEVICE="true"
static="false"
dynamic="false"

Rearranco el Connection Manager y confirmo que el fichero /etc/resolv.conf queda bien configurado.

 
\[root@MOIPro ~\]# systemctl daemon-reload
\[root@MOIPro ~\]# systemctl restart connman
\[root@MOIPro ~\]# cat /etc/resolv.conf
# Generated by Connection Manager
nameserver 192.168.1.1
nameserver 192.168.1.246

 

* * *

# Tvheadend

A continuación vamos a ver cómo configurar Tvheadend y cómo dar de alta cada una de las fuentes.

Antes de empezar voy a desactivar la Guía (EPG) OTA (Over The Air), ¿qué es eso de EPG OTA?, pues se trata de aprender la guía electrónica de programación (EPG) a través de la señal de la fuente. De hecho hay dos métodos. El primero consiste en usar OTA (Over The Air), es decir aprovechar que la propia señal incluye la Guía (EPG) o programación de los canales. La segunda opción es completamente distinta, consiste en usar algún tipo de script externo para que se baje dicha Guía a través de Internet.

Recomiendo usar la segunda opción, ¿porqué? pues porque las guías OTA suelen estar bastante limitadas, el ejemplo extremo es IPTV (Movistar TV) donde simplemente no existe OTA, otro ejemplos de limitación es cuando traen muy poca información (solo las próximas 2 horas) o incluso no funcionan o viene la guía de pocos canales.

Lo primero que hago es quitar el OTA a nivel general y después en cada una de las tarjetas sintonizadoras.

Desde **Configuration->Channel/EPG->EPG Grabber**, desactivo Over-the-air Grabbers:

[![EPGnoOTA](https://www.luispa.com/wp-content/uploads/2015/05/EPGnoOTA.png)](https://www.luispa.com/wp-content/uploads/2015/05/EPGnoOTA.png)

Desde **Configuration->DVB Inputs->TV Adapters**, desactivo Over-the-air Grabbers en las tarjetas sintonizadoras.

[![noOTA](https://www.luispa.com/wp-content/uploads/2015/05/noOTA.png)](https://www.luispa.com/wp-content/uploads/2015/05/noOTA.png)

Al final del apunte explico cómo hacer la inserción del EPG (Guía) mediante Scripts.

# Fuentes

A partir de aquí describo cómo he configurado las tres fuentes (TDT, Movistar TV y Satélite), notar que este artículo está parcialmente "Work in Progress" porque el proyecto [Tvheadend](https://tvheadend.org/) es joven y está muy activo, así que iré actualizando según continúe mi investigación.

## Fuentes TDT

Para poder sintonizar las frecuencias TDT he instalado la tarjeta "TBS6281 DVB-T2/T/C Dual Tuner PCIe Card" que incluye dos sintonizadores.

[![MoiPHTS-TDT](https://www.luispa.com/wp-content/uploads/2015/05/MoiPHTS-TDT-1024x675.png)](https://www.luispa.com/wp-content/uploads/2015/05/MoiPHTS-TDT.png) [![MOI-TDT-card](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT-card.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT-card.png)

### Preparar Muxes Pre-Definidos

Tvheadend permite, cuando se configuran las sintonizadoras, seleccionar **muxes predefinidos** y es recomendable actualizar los que incluye el paquete de sofware con los originales, que están disponibles en internet.

Baja una copia de las [DTV Scan Tables](http://git.linuxtv.org/cgit.cgi/dtv-scan-tables.git/tree/) y copialas al servidor MOIPro.

En otro ordenador donde tengas git instalado: 
$ cd tmp
$ git clone https://git.linuxtv.org//dtv-scan-tables.git
$ cd dtv-scan-tables
$ scp -r \* root@moipro.parchis.org:/usr/share/tvheadend/data/dvb-scan

Conecta con el MOIPro vía SSH:
# ssh -l root moipro.parchis.org
# ln -s /usr/share/tvheadend/data/dvb-scan /usr/share/dvb
# systemctl restart tvheadend

Además en el caso de TDT puede que te interese actualizar el fichero concreto de tu zona donde vives. En este ejemplo enseño cómo hacer el de Madrid, ya que el que he bajado de internet está desactualizado. Actualizo el fichero con las frecuencias actualizadas a fecha de Mayo de 2015 para Madrid. Nota que tienes todos los datos para hacerte el tuyo propio en esta [fuente](http://www.tdt1.com/canales-madrid/):

#------------------------------------------------------------------------------
# Fichero generado por LuisPa desde el original generado por w\_scan
#
# Lo he editado a mano, en teoría debería poderse auto-generar usando 
# el comando siguiente en el MOI Pro, pero no me funcionó:
#   # w\_scan -ft -c ES -x 
#
# ssh -l root moipro.parchis.org
# cd /media/mmcblk0p1/usr/share/tvheadend/data/dvb-scan/dvb-t
# cat > es-Madrid      (COPY / PASTE este fichero)
# chown 1000:1000 es-Madrid
# systemctl restart tvheadend
#
#
# Network->Add->DBVB-T "TDT-Madrid". Pre-dfined Muxes: es-Madrid
#
#
# (http://wirbel.htpc-forum.de/w\_scan/index2.html)
#!  20110306 2 0 OFDM ES 
#------------------------------------------------------------------------------
#
# date (yyyy-mm-dd)    : 2015-05-01
# Fuente de los datos  : http://www.tdt1.com/canales-madrid/
#
#------------------------------------------------------------------------------

#
# CANAL 26, Boing, Energy, Gol Television
#
\[CHANNEL\]
    DELIVERY\_SYSTEM = DVBT
    FREQUENCY = 514000000
    BANDWIDTH\_HZ = 8000000
    CODE\_RATE\_HP = 2/3
    CODE\_RATE\_LP = NONE
    MODULATION = QAM/64
    TRANSMISSION\_MODE = 8K
    GUARD\_INTERVAL = 1/4
    HIERARCHY = NONE
    INVERSION = AUTO

#
# CANAL 33, 13TV, Discovery MAX, Disney Channel, Paramount Channel
#
\[CHANNEL\]
    DELIVERY\_SYSTEM = DVBT
    FREQUENCY = 570000000
    BANDWIDTH\_HZ = 8000000
    CODE\_RATE\_HP = 2/3
    CODE\_RATE\_LP = NONE
    MODULATION = QAM/64
    TRANSMISSION\_MODE = 8K
    GUARD\_INTERVAL = 1/4
    HIERARCHY = NONE
    INVERSION = AUTO

#
# CANAL 39, 8Madrid, 13TV Madrid, Kiss TV, Intereconomia
#
\[CHANNEL\]
    DELIVERY\_SYSTEM = DVBT
    FREQUENCY = 618000000
    BANDWIDTH\_HZ = 8000000
    CODE\_RATE\_HP = 2/3
    CODE\_RATE\_LP = NONE
    MODULATION = QAM/64
    TRANSMISSION\_MODE = 8K
    GUARD\_INTERVAL = 1/4
    HIERARCHY = NONE
    INVERSION = AUTO

#
# CANAL 41, La 1 HD, TDP, TDP HD, 
#
\[CHANNEL\]
    DELIVERY\_SYSTEM = DVBT
    FREQUENCY = 634000000
    BANDWIDTH\_HZ = 8000000
    CODE\_RATE\_HP = 2/3
    CODE\_RATE\_LP = NONE
    MODULATION = QAM/64
    TRANSMISSION\_MODE = 8K
    GUARD\_INTERVAL = 1/4
    HIERARCHY = NONE
    INVERSION = AUTO

#
# CANAL 49, Telecinco, Telecinco HD, Cuatro, Cuatro HD, FDF, Divinity,
#
\[CHANNEL\]
    DELIVERY\_SYSTEM = DVBT
    FREQUENCY = 698000000
    BANDWIDTH\_HZ = 8000000
    CODE\_RATE\_HP = 2/3
    CODE\_RATE\_LP = NONE
    MODULATION = QAM/64
    TRANSMISSION\_MODE = 8K
    GUARD\_INTERVAL = 1/4
    HIERARCHY = NONE
    INVERSION = AUTO

#
# CANAL 50, 8Madrid, Ver-t, TBN
#
\[CHANNEL\]
    DELIVERY\_SYSTEM = DVBT
    FREQUENCY = 706000000
    BANDWIDTH\_HZ = 8000000
    CODE\_RATE\_HP = 2/3
    CODE\_RATE\_LP = NONE
    MODULATION = QAM/64
    TRANSMISSION\_MODE = 8K
    GUARD\_INTERVAL = 1/4
    HIERARCHY = NONE
    INVERSION = AUTO

#
# CANAL 55, Telemadrid, La Otra, Telemadrid HD, EHS TV
#
\[CHANNEL\]
    DELIVERY\_SYSTEM = DVBT
    FREQUENCY = 746000000
    BANDWIDTH\_HZ = 8000000
    CODE\_RATE\_HP = 2/3
    CODE\_RATE\_LP = NONE
    MODULATION = QAM/64
    TRANSMISSION\_MODE = 8K
    GUARD\_INTERVAL = 1/4
    HIERARCHY = NONE
    INVERSION = AUTO

#
# CANAL 58, La 1, La 1 HD, La 2, 24h, Clan
#
\[CHANNEL\]
    DELIVERY\_SYSTEM = DVBT
    FREQUENCY = 770000000
    BANDWIDTH\_HZ = 8000000
    CODE\_RATE\_HP = 2/3
    CODE\_RATE\_LP = NONE
    MODULATION = QAM/64
    TRANSMISSION\_MODE = 8K
    GUARD\_INTERVAL = 1/4
    HIERARCHY = NONE
    INVERSION = AUTO

#
# CANAL 59, Antena 3, Antena 3 HD, laSexta, laSexta HD, Neox, Nova
#
\[CHANNEL\]
    DELIVERY\_SYSTEM = DVBT
    FREQUENCY = 778000000
    BANDWIDTH\_HZ = 8000000
    CODE\_RATE\_HP = 2/3
    CODE\_RATE\_LP = NONE
    MODULATION = QAM/64
    TRANSMISSION\_MODE = 8K
    GUARD\_INTERVAL = 1/4
    HIERARCHY = NONE
    INVERSION = AUTO

 
 $ ssh -l root moipro.parchis.org
 # cd /media/mmcblk0p1/usr/share/tvheadend/data/dvb-scan/dvb-t
 # cat > es-Madrid
 
  \_\_(PEGAR EL CONTENIDO DEL FICHERO ANTERIOR)\_\_\_

 # chown 1000:1000 es-Madrid
 # systemctl restart tvheadend

### Crear la "Network" para TDT

El siguiente paso consiste en Añadir una "Network" de tipo TDT usando el listado de frecuencias pre-definido que vimos antes. En mi caso la voy a llamar "TDT-Madrid".

- Network->Add
- DBVB-T "TDT-Madrid"
- Pre-defined Muxes: es-Madrid
- Ok

[![MOI-TDT1](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT1.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT1.png) [![MOI-TDT2](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT2.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT2.png) [![MOI-TDT3](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT3.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT3.png)

### Vincular la "Network" TDT con la Sintonizadora

Vinculamos esta "Network" recién creada con la sintonizadora TDT del equipo.

[![MOI-TDT4](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT4.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT4.png)

Si dejas un Terminal conectado por SSH con el MOI Pro y visualizas el "log" (journalctl -f) observarás cómo se van "descubriendo" servicios nuevos. Otra forma de "ver" cómo va detectando los servicios es porque así nos lo va indicando en las diferentes lengüetas debajo de DVB-Inputs: verás cómo poco a poco se incrementa el número de Servicios en "Networks" o en "Services".

[![MOI-TDT5](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT5.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT5.png)

Si te encuentras con que Services tienen como resultado de Scan "Fallido (Fail)", ignóralo de momento, lo importante es ir viendo cómo algunos otros dicen "OK" y crece el número de servicios detectados.

 
$ ssh -l root moipro.parchis.org

\[root@MOIPro ~\]# journalctl -f
: 
May 01 14:54:34 MOIPro tvheadend\[23806\]: 2015-05-01 14:54:34.163 \[   INFO\] mpegts: 706MHz in TDT-Madrid - scan no data, failed
May 01 14:54:34 MOIPro tvheadend\[23806\]: 2015-05-01 14:54:34.163 \[   INFO\] subscription: 0012: "scan" unsubscribing
May 01 14:54:34 MOIPro tvheadend\[23806\]: mpegts: 680MHz in TDT-Madrid - tuning on TurboSight TBS 62x1 DVBT/T2 frontend : DVB-T #0
May 01 14:54:34 MOIPro tvheadend\[23806\]: opentv-ausat: registering mux 680MHz in TDT-Madrid
May 01 14:54:34 MOIPro tvheadend\[23806\]: 2015-05-01 14:54:34.574 \[   INFO\] mpegts: 680MHz in TDT-Madrid - tuning on TurboSight TBS 62x1 DVBT/T2 frontend : DVB-T #0
May 01 14:54:34 MOIPro tvheadend\[23806\]: 2015-05-01 14:54:34.574 \[   INFO\] opentv-ausat: registering mux 680MHz in TDT-Madrid
May 01 14:54:34 MOIPro tvheadend\[23806\]: 2015-05-01 14:54:34.583 \[   INFO\] subscription: 0013: "scan" subscribing to mux, weight: 5, adapter: "TurboSight TBS 62x1 DVBT/T2 frontend : DVB-T #0", network: "TDT-Madrid", mux: "680MHz", hostname: "<N/A>", username: "<N/A>", client: "<N/A>"
May 01 14:54:34 MOIPro tvheadend\[23806\]: subscription: 0013: "scan" subscribing to mux, weight: 5, adapter: "TurboSight TBS 62x1 DVBT/T2 frontend : DVB-T #0", network: "TDT-Madrid", mux: "680MHz", hostname: "<N/A>", username: "<N/A>", client: "<N/A>"
:

 

### Crear los Canales

Una vez que los **Muxes** han descubierto y "creado" los **Services** ya podemos crear **Canales** y **vincularlos** a dichos **Services**. Podrías hacerlo manualmente, uno por uno, vinculándolos al "Service" que corresponda, o mucho más sencillo, apoyarte en una función que trae Tvheadend: "**Map Services**".

Desde **Configuration->DVB Input->Services**, haz una selección múltiple en el navegador de todas las líneas con los Servicios que te interesan, haz click en **Map Selected**, a continuación haz clic en todos los campos y pulsa en **Map**:

[![MOI-TDT6](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT6-1024x450.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT6.png)

En la sección **Configuration->Channels/EPG->Channels** podrás observar cómo se han creado automáticamente los canales. A partir de aquí puedes cambiar los Tags y el número de canal a tu gusto.

[![MOI-TDT8](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT8-1024x637.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT8.png)

Fíjate en un dato importante, Tvheadend ha asignado un nombre de icono muy especial a cada canal. Es correcto, déjalo tal cual. Lo que ha hecho es usar como nombre de icono una combinación de los detalles técnicos del canal. En internet hay paquetes que incluyen todos los logos de los canales usando dicha nomenclatura y va a sernos muy útil en el siguiente paso.

### Iconos de los canales

Vamos con los iconos. Tienes que buscar un "pack" de logos que contenga todos los canales TDT. Para facilitarlo dejo aquí uno que te vale, descárgalo: [LuisPa-Picon-TDT.tgz](https://github.com/LuisPalacios/iptv2hts/raw/master/picons/LuisPa-Picon-TDT.tgz)). Copia todos los logos debajo el directorio /root/.hts/picon del MOI Pro y por último le indicarás dicho directorio a la configuraicón de Tvheadend.

- Copia todos los ficheros PNG al directorio de picons

 

$ scp LuisPa-Picon-TDT.tgz root@moipro.parchis.org:.

$ ssh -l root moipro.parchis.org
:
\[root@MOIPro ~\]# cd .hts/
\[root@MOIPro ~/.hts\]# mkdir picon
\[root@MOIPro ~/.hts\]# cd picon
\[root@MOIPro ~/.hts/picon\]# tar xvfz ../LuisPa-Picon-TDT.tgz
: 
\[root@MOIPro ~/.hts\]# systemctl restart tvheadend

- Configuration->General->Picon path:

[![MOI-TDT9](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT91.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT91.png) [![MHTSLogos](https://www.luispa.com/wp-content/uploads/2015/05/MHTSLogos.png)](https://www.luispa.com/wp-content/uploads/2015/05/MHTSLogos.png)

- Rearranca Tvheadend

\[root@MOIPro ~\]# systemctl restart tvheadend

[![MOI-TDT10](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT10.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT10.png)

### Usar más de un sintonizador TDT

La tarjeta "TBS6281 DVB-T2/T/C Dual Tuner PCIe Card" incluye un unico conector pero por dentro tiene dos sintonizadores que pueden usarse simultáneamente:

- Configuration->DVB Input->TV Adapters

Selecciono el segundo adaptador y le asigno el mismo network que al primero, es decir: "Network" TDT-Madrid. Esta es la forma correcta de configurarlo, en vez de utilizar la opción de "Linked input".

[![MOI-TDT11](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT11.png)](https://www.luispa.com/wp-content/uploads/2015/05/MOI-TDT11.png)

Con dos o más sintonizadores es posible ver al menos dos (o más) canales (de distintas frecuencias) simultáneamente, o incluso grabar uno y visualizar otro.

Solo nos queda el EPG, pero eso lo vemos en la sección final de este apunte.

## Fuentes Movistar TV

Para poder sintonizar los canales IPTV de Movistar TV necesitas tener un contrato de Fusión o Fusión Fibra. Si es el caso, puede usar el equipo MOI Pro como un agregador único para todas las fuentes, incluidos los canales IPTV.

[![MoiPHTS-IPTV](https://www.luispa.com/wp-content/uploads/2015/05/MoiPHTS-IPTV-1024x675.png)](https://www.luispa.com/wp-content/uploads/2015/05/MoiPHTS-IPTV.png) [![cableeth](https://www.luispa.com/wp-content/uploads/2015/05/cableeth.jpg)](https://www.luispa.com/wp-content/uploads/2015/05/cableeth.jpg)

Al usar como fuente los canales IPTV no es necesario instalar ningun sintonizador (El MOI Pro usará su tarjeta NIC para conectar por TCP/IP a las fuentes). Lo que sí es importante es que tengas bien configurado el acceso a los canales, es decir, el MOI tiene que ser capaz de "hablar" con el router de Movistar.

En [este apunte: Movistar Fusión Fibra + TV + VoIP con router Linux](https://www.luispa.com/?p=266) describo cómo funciona el IPTV de Movistar TV. Recuerdo brevemente: El tráfico IPTV es entregado en Multicast UDP desde el ONT a través de la VLAN-2 hacia el router, si es el original entonces los clientes solo pueden suscribirse a los canales utilizando el protocolo RTP (ejemplo: rtp://239.0.0.76:8208 donde 239.0.0.76:8288 es el canal de TVE, Tvheadend soporta RTP). Ahora bien, si optas por cambiar a un router con soporte de udpxy entonces podrías solicitar los canales mediante HTTP (ejemplo: http://192.168.1.1:4022/udp/239.0.0.76:8208 donde 192.168.1.1:4022 es la dirección:puerto del udpxy y 239.0.0.76:8288 vuelve a ser TVE, Tvheadend también soporta HTTP).

El udpxy es una Daemon que se ejecuta en Linux y permite hacer relay del tráfico multicast UDP hacia clientes TCP (HTTP). Es decir, él va a tratar por un lado el tráfico/protocolo multicast (hacia el ONT/Movistar) y por otro nos ofrecerá los canales en HTTP (hacia la red casera y el Tvheadend/MOI).

Utilizo udpxy porque yo uso este [router linux](https://www.luispa.com/?p=266), así que tenlo en cuenta cuando veas más adelante HTTP en mi configuración de los **Muxes**.

Da igual el protocolo que uses para acceder a los canales, el problema es que hay que dar de alta bastantes y manualmente sería una pesadilla, voy enseñarte cómo crearlos de forma automática con un par de scripts disponibles aquí: [luispa/iptv2hts](https://github.com/LuisPalacios/iptv2hts) (son forks de dos proyectos independientes: **movistartv2xmltv** e **iptv2hts**).

### 1\. Parar Tvheadend y hacer un backup

Antes de nada, haz un backup por si las moscas...

obelix:~ luis$ ssh -l root moipro.parchis.org
root@moipro.parchis.org's password:
:
\[root@MOIPro ~\]# cd /(null)/.hts/
\[root@MOIPro /(null)/.hts\]# systemctl stop tvheadend
\[root@MOIPro /(null)/.hts\]#
\[root@MOIPro /(null)/.hts\]# tar cvfz 2015-05-01-tvheadend-backup.tgz tvheadend/

### 2\. Preparar el fichero movistartv-canales.m3u

Preparo el fichero movistartv-canales.m3u. Puede crearse usando el script **movistartv2xmltv** o copiar el que dejo a continuación.

#EXTM3U
#EXTINF:-1,0 - Movistar TV
#EXTTV:Ocio y cultura;es;CPROM;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/597.jpg
rtp://239.0.0.77:8208
#EXTINF:-1,1 - La 1 HD
#EXTTV:Ocio y cultura;es;LA1HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2543.jpg
rtp://239.0.0.185:8208
#EXTINF:-1,2 - La 2
#EXTTV:Ocio y cultura;es;La 2;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/3.jpg
rtp://239.0.0.2:8208
#EXTINF:-1,3 - Antena 3 HD
#EXTTV:Ocio y cultura;es;A3HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2524.jpg
rtp://239.0.0.186:8208
#EXTINF:-1,4 - Cuatro HD
#EXTTV:Toros;es;4HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1825.jpg
rtp://239.0.0.177:8208
#EXTINF:-1,5 - Tele 5 HD
#EXTTV:Ocio y cultura;es;T5HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1826.jpg
rtp://239.0.0.176:8208
#EXTINF:-1,6 - laSexta HD
#EXTTV:Ocio y cultura;es;LSXHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2526.jpg
rtp://239.0.0.187:8208
#EXTINF:-1,7 - Telemadrid
#EXTTV:Programas;es;TMAD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/58.jpg
rtp://239.0.0.25:8208
#EXTINF:-1,8 - La Otra
#EXTTV:Programas;es;OTRA;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/59.jpg
rtp://239.0.0.26:8208
#EXTINF:-1,9 - Movistar Series
#EXTTV:Series
juveniles;es;SERHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2383.jpg
rtp://239.0.0.184:8208
#EXTINF:-1,10 - FOX HD
#EXTTV:Policíacas;es;FOXHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1607.jpg
rtp://239.0.9.134:8208
#EXTINF:-1,11 - AXN HD
#EXTTV:Policíacas;es;AXNHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1608.jpg
rtp://239.0.9.131:8208
#EXTINF:-1,12 - Movistar Cine
#EXTTV:Programas;es;CINHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2608.jpg
rtp://239.0.0.178:8208
#EXTINF:-1,13 - Calle 13HD
#EXTTV:Policíacas;es;C13HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1705.jpg
rtp://239.0.5.74:8208
#EXTINF:-1,14 - TNT HD
#EXTTV:Programas;es;TNTHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1609.jpg
rtp://239.0.5.87:8208
#EXTINF:-1,15 - FOX life HD
#EXTTV:Programas;es;FXLHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2203.jpg
rtp://239.0.5.86:8208
#EXTINF:-1,16 - Deportes
#EXTTV:Programas;es;DEPHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2607.jpg
rtp://239.0.0.180:8208
#EXTINF:-1,17 - COSMO HD
#EXTTV:Policíacas;es;CosHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1610.jpg
rtp://239.0.5.71:8208
#EXTINF:-1,18 - AXN W. HD
#EXTTV:Policíacas;es;FCRHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1611.jpg
rtp://239.0.5.79:8208
#EXTINF:-1,19 - SyFyHD
#EXTTV:Policíacas;es;SYFHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1703.jpg
rtp://239.0.5.75:8208
#EXTINF:-1,20 - Comedy Central HD
#EXTTV:Policíacas;es;COCHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2224.jpg
rtp://239.0.0.174:8208
#EXTINF:-1,21 - MTV España
#EXTTV:Programas;es;MTVES;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2533.jpg
rtp://239.0.0.211:8208
#EXTINF:-1,22 - Crimen e Inv.
#EXTTV:Policíacas;es;CREIN;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/697.jpg
rtp://239.0.0.57:8208
#EXTINF:-1,24 - FDF
#EXTTV:Policíacas;es;FDFT5;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/747.jpg
rtp://239.0.0.84:8208
#EXTINF:-1,25 - Neox
#EXTTV:Programas;es;NEOX;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/934.jpg
rtp://239.0.0.107:8208
#EXTINF:-1,26 - Energy
#EXTTV:Toros;es;energ;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/884.jpg
rtp://239.0.0.59:8208
#EXTINF:-1,27 - Divinity
#EXTTV:Drama;es;DIVIN;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/663.jpg
rtp://239.0.0.48:8208
#EXTINF:-1,28 - Nova
#EXTTV:Programas;es;NOVA;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/935.jpg
rtp://239.0.0.106:8208
#EXTINF:-1,29 - Sundance HD
#EXTTV:Programas;es;SunHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1615.jpg
rtp://239.0.5.72:8208
#EXTINF:-1,31 - HWD HD
#EXTTV:Policíacas;es;HOLHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1612.jpg
rtp://239.0.5.76:8208
#EXTINF:-1,32 - AMC HD
#EXTTV:Programas;es;MGMHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1613.jpg
rtp://239.0.9.132:8208
#EXTINF:-1,34 - TCM HD
#EXTTV:Programas;es;TCMHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2204.jpg
rtp://239.0.5.89:8208
#EXTINF:-1,38 - Paramount C.
#EXTTV:Cine clásico;es;PARCH;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1221.jpg
rtp://239.0.0.90:8208
#EXTINF:-1,40 - EurosportHD
#EXTTV:Policíacas;es;EURHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1623.jpg
rtp://239.0.9.135:8208
#EXTINF:-1,41 - Eurosport 2
#EXTTV:Policíacas;es;EUSP2;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/338.jpg
rtp://239.0.0.37:8208
#EXTINF:-1,42 - Sportmania
#EXTTV:Policíacas;es;SPMA;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/16.jpg
rtp://239.0.0.17:8208
#EXTINF:-1,43 - Teledeporte HD
#EXTTV:Policíacas;es;TDPHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2544.jpg
rtp://239.0.0.188:8208
#EXTINF:-1,44 - Iberalia
#EXTTV:Programas;es;IBER;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/936.jpg
rtp://239.0.5.6:8208
#EXTINF:-1,47 - MovistarF1 HD
#EXTTV:Programas;es;MF1HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2064.jpg
rtp://239.0.5.90:8208
#EXTINF:-1,48 - Movistar MotoGP HD
#EXTTV:Programas;es;MGPHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2065.jpg
rtp://239.0.5.107:8208
#EXTINF:-1,50 - C+LigaHD
#EXTTV:Fútbol;es;GOLHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1622.jpg
rtp://239.0.9.129:8208
#EXTINF:-1,51 - C+Liga Multi
#EXTTV:Fútbol;es;FUT3;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1063.jpg
rtp://239.0.0.119:8208
#EXTINF:-1,54 - Movistar Fútbol HD
#EXTTV:Programas;es;QU1HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2268.jpg
rtp://239.0.5.185:8208
#EXTINF:-1,55 - C+L.CampHD
#EXTTV:Programas;es;CP3D;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1621.jpg
rtp://239.0.9.138:8208
#EXTINF:-1,56 - Gol 2 IntHD
#EXTTV:Programas;es;G2INT;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1667.jpg
rtp://239.0.9.146:8208
#EXTINF:-1,64 - Futbol R.
#EXTTV:Fútbol;es;fut;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/12.jpg
rtp://239.0.0.97:8208
#EXTINF:-1,70 - NAT GEO HD
#EXTTV:Policíacas;es;NATHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1643.jpg
rtp://239.0.5.78:8208
#EXTINF:-1,71 - NG Wild HD
#EXTTV:Programas;es;NGEHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1619.jpg
rtp://239.0.9.136:8208
#EXTINF:-1,72 - Viajar HD
#EXTTV:Policíacas;es;ViaHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1617.jpg
rtp://239.0.5.73:8208
#EXTINF:-1,73 - DSC HD
#EXTTV:Policíacas;es;DSCHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2205.jpg
rtp://239.0.5.77:8208
#EXTINF:-1,74 - ODISEA HD
#EXTTV:Policíacas;es;FHD2;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1618.jpg
rtp://239.0.5.82:8208
#EXTINF:-1,75 - Historia
#EXTTV:Policíacas;es;HIST;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/17.jpg
rtp://239.0.0.19:8208
#EXTINF:-1,76 - A&E
#EXTTV:Policíacas;es;A&E;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/340.jpg
rtp://239.0.0.38:8208
#EXTINF:-1,77 - Cocina
#EXTTV:Policíacas;es;COCI;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/22.jpg
rtp://239.0.0.27:8208
#EXTINF:-1,78 - Decasa
#EXTTV:Policíacas;es;DCASA;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/850.jpg
rtp://239.0.0.71:8208
#EXTINF:-1,79 - Discov.Max
#EXTTV:Policíacas;es;TVCi;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/657.jpg
rtp://239.0.0.32:8208
#EXTINF:-1,80 - Baby TV
#EXTTV:Policíacas;es;BABTV;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/778.jpg
rtp://239.0.0.113:8208
#EXTINF:-1,81 - Disney Junior
#EXTTV:Policíacas;es;PLAY;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/10.jpg
rtp://239.0.0.10:8208
#EXTINF:-1,82 - Canal Panda
#EXTTV:Programas;es;PANDA;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1019.jpg
rtp://239.0.0.117:8208
#EXTINF:-1,83 - Nick Jr
#EXTTV:Series niños;es;NIKJR;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2532.jpg
rtp://239.0.0.115:8208
#EXTINF:-1,84 - Nickelodeon
#EXTTV:Policíacas;es;NICKE;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/579.jpg
rtp://239.0.0.69:8208
#EXTINF:-1,85 - Disney XD
#EXTTV:Policíacas;es;DISXD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/11.jpg
rtp://239.0.0.11:8208
#EXTINF:-1,86 - Disney HD
#EXTTV:Policíacas;es;DISHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1616.jpg
rtp://239.0.0.173:8208
#EXTINF:-1,87 - Boing
#EXTTV:Policíacas;es;ARSAT;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/578.jpg
rtp://239.0.0.66:8208
#EXTINF:-1,88 - Clan TVE
#EXTTV:Policíacas;es;CLAN;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/745.jpg
rtp://239.0.0.80:8208
#EXTINF:-1,90 - Sol Música
#EXTTV:Policíacas;es;SOLM;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/341.jpg
rtp://239.0.0.39:8208
#EXTINF:-1,91 - 40 TV
#EXTTV:Policíacas;es;40TV;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/741.jpg
rtp://239.0.0.12:8208
#EXTINF:-1,92 - VH1
#EXTTV:Policíacas;es;VH1;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/581.jpg
rtp://239.0.0.75:8208
#EXTINF:-1,100 - Fox News
#EXTTV:Policíacas;es;FOXNW;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/845.jpg
rtp://239.0.7.65:8208
#EXTINF:-1,101 - BBC World
#EXTTV:Policíacas;es;BBCW;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/197.jpg
rtp://239.0.0.30:8208
#EXTINF:-1,102 - CNN Int.
#EXTTV:Policíacas;es;CNNI;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/342.jpg
rtp://239.0.0.40:8208
#EXTINF:-1,103 - Euronews
#EXTTV:Policíacas;es;Eurnw;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/119.jpg
rtp://239.0.0.28:8208
#EXTINF:-1,104 - Canal 24 H.
#EXTTV:Policíacas;es;C24H;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/743.jpg
rtp://239.0.0.78:8208
#EXTINF:-1,105 - Al Jazeera
#EXTTV:Policíacas;es;ALJAZ;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/846.jpg
rtp://239.0.7.66:8208
#EXTINF:-1,106 - France 24
#EXTTV:Policíacas;es;FRA24;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/847.jpg
rtp://239.0.7.67:8208
#EXTINF:-1,107 - Russia T.
#EXTTV:Policíacas;es;RUSSI;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/848.jpg
rtp://239.0.7.68:8208
#EXTINF:-1,108 - CNBC Eur.
#EXTTV:Policíacas;es;CNBC;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/849.jpg
rtp://239.0.7.69:8208
#EXTINF:-1,109 - CCTV E
#EXTTV:Ocio y cultura;es;CCTVE;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/752.jpg
rtp://239.0.0.65:8208
#EXTINF:-1,110 - TV5 Monde
#EXTTV:Policíacas;es;TV5eu;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/198.jpg
rtp://239.0.0.31:8208
#EXTINF:-1,111 - Bloomberg
#EXTTV:Policíacas;es;Bloom;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/120.jpg
rtp://239.0.0.29:8208
#EXTINF:-1,112 - Intereconomía
#EXTTV:Policíacas;es;INTTV;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/582.jpg
rtp://239.0.0.63:8208
#EXTINF:-1,114 - 13 TV
#EXTTV:Policíacas;es;13TV;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/844.jpg
rtp://239.0.0.91:8208
#EXTINF:-1,116 - I 24 News
#EXTTV:Programas;es;I24NW;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1807.jpg
rtp://239.0.0.220:8208
#EXTINF:-1,117 - CNC World
#EXTTV:Programas;es;CNCWD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1805.jpg
rtp://239.0.0.221:8208
#EXTINF:-1,118 - Canal Orbe 21
#EXTTV:Programas;es;COR21;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2463.jpg
rtp://239.0.0.45:8208
#EXTINF:-1,150 - Canal Sur Andalucía
#EXTTV:Programas;es;ANDSA;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2275.jpg
rtp://239.0.0.1:8208
#EXTINF:-1,151 - Galicia TV Europa
#EXTTV:Programas;es;TVGEU;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2273.jpg
rtp://239.0.3.37:8208
#EXTINF:-1,152 - TV3CAT
#EXTTV:Programas;es;TV3SA;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2271.jpg
rtp://239.0.3.36:8208
#EXTINF:-1,153 - ETB Sat.
#EXTTV:Programas;es;ETBSA;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2269.jpg
rtp://239.0.0.60:8208
#EXTINF:-1,200 - LTC
#EXTTV:Policíacas;es;TIEND;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/886.jpg
rtp://239.0.0.98:8208
#EXTINF:-1,215 - Multicámara6 HD F1
#EXTTV:Programas;es;MT6HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2163.jpg
rtp://239.0.5.127:8208
#EXTINF:-1,216 - Multicámara5 HD F1
#EXTTV:Programas;es;MCHD5;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2084.jpg
rtp://239.0.5.126:8208
#EXTINF:-1,217 - Multicámara4 HD F1
#EXTTV:Programas;es;MCHD4;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2086.jpg
rtp://239.0.5.125:8208
#EXTINF:-1,218 - Multicámara3 HD F1
#EXTTV:Programas;es;MCHD3;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2087.jpg
rtp://239.0.5.124:8208
#EXTINF:-1,219 - Multicámara2 HD F1
#EXTTV:Programas;es;MCHD2;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2088.jpg
rtp://239.0.5.123:8208
#EXTINF:-1,220 - Multicámara1 HD F1
#EXTTV:Programas;es;MCHD1;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2090.jpg
rtp://239.0.5.121:8208
#EXTINF:-1,221 - Multi1 HD F1
#EXTTV:Programas;es;GPC1H;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2025.jpg
rtp://239.0.0.175:8208
#EXTINF:-1,222 - Multi2 HD F1
#EXTTV:Programas;es;M2HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2085.jpg
rtp://239.0.5.122:8208
#EXTINF:-1,223 - Multi3 HD F1
#EXTTV:Programas;es;MHD3;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2091.jpg
rtp://239.0.5.117:8208
#EXTINF:-1,224 - Multi4 HD F1
#EXTTV:Programas;es;M4HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2094.jpg
rtp://239.0.5.118:8208
#EXTINF:-1,225 - Multi5 HD F1
#EXTTV:Programas;es;M5HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2096.jpg
rtp://239.0.5.119:8208
#EXTINF:-1,226 - Multi6 HD F1
#EXTTV:Programas;es;M6HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2097.jpg
rtp://239.0.5.120:8208
#EXTINF:-1,255 - Multicámara6 HD MotoGP
#EXTTV:Automovilismo;es;M6HDF;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2255.jpg
rtp://239.0.5.149:8208
#EXTINF:-1,256 - Multicámara5 HD MotoGP
#EXTTV:Automovilismo;es;M5HDF;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2256.jpg
rtp://239.0.5.150:8208
#EXTINF:-1,257 - Multicámara4 HD MotoGP
#EXTTV:Automovilismo;es;M4HDF;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2257.jpg
rtp://239.0.5.151:8208
#EXTINF:-1,258 - Multicámara3 HD MotoGP
#EXTTV:Automovilismo;es;M3HDF;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2258.jpg
rtp://239.0.5.152:8208
#EXTINF:-1,259 - Multicámara2 HD MotoGP
#EXTTV:Automovilismo;es;M2HDF;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2259.jpg
rtp://239.0.5.153:8208
#EXTINF:-1,260 - Multicámara1 HD MotoGP
#EXTTV:Automovilismo;es;M1HDF;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2260.jpg
rtp://239.0.5.154:8208
#EXTINF:-1,261 - Multi1 HD MotoGP
#EXTTV:Automovilismo;es;MLHF1;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2261.jpg
rtp://239.0.5.155:8208
#EXTINF:-1,262 - Multi2 HD MotoGP
#EXTTV:Automovilismo;es;ML2HF;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2262.jpg
rtp://239.0.5.156:8208
#EXTINF:-1,263 - Multi3 HD MotoGP
#EXTTV:Automovilismo;es;ML3HF;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2263.jpg
rtp://239.0.5.157:8208
#EXTINF:-1,264 - Multi4 HD MotoGP
#EXTTV:Automovilismo;es;ML4HF;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2264.jpg
rtp://239.0.5.158:8208
#EXTINF:-1,265 - Multi5 HD MotoGP
#EXTTV:Automovilismo;es;ML5HF;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2265.jpg
rtp://239.0.5.159:8208
#EXTINF:-1,266 - Multi6 HD MotoGP
#EXTTV:Automovilismo;es;ML6HF;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/2266.jpg
rtp://239.0.5.160:8208
#EXTINF:-1,504 - Cuatro
#EXTTV:Toros;es;CUATR;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1843.jpg
rtp://239.0.0.4:8208
#EXTINF:-1,505 - Tele 5
#EXTTV:Ocio y cultura;es;TELE5;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1844.jpg
rtp://239.0.0.5:8208
#EXTINF:-1,523 - Calle 13
#EXTTV:Policíacas;es;CA13;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1706.jpg
rtp://239.0.0.13:8208
#EXTINF:-1,598 - C+L.Camp
#EXTTV:Programas;es;CLSD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1597.jpg
rtp://239.0.0.118:8208
#EXTINF:-1,599 - C+Liga
#EXTTV:Fútbol;es;CLISD;http://172.26.22.23:2001/appclient/incoming/epg/MAY\_1/imSer/1603.jpg
rtp://239.0.0.42:8208

Si quieres crearlo tú mismo hazlo desde cualquier Linux que tenga Python 2.7 y Xmltv (no lo hago desde MOI Pro porque no tiene instalado Xmltv):

luis@aplicacionix ~ # echo "media-tv/xmltv tv\_combiner" > /etc/portage/package.use/xmltv

luis@aplicacionix ~ # emerge -v xmltv
luis@aplicacionix ~ # export EPYTHON=python2.7
luis@aplicacionix ~ # easy\_install --upgrade pytz
:
luis@aplicacionix ~ $ curl -L -Ok https://github.com/LuisPalacios/iptv2hts/archive/master.zip
luis@aplicacionix ~ $ unzip master.zip
luis@aplicacionix ~ $ cd iptv2hts-master/movistartv2xmltv/
luis@aplicacionix ~/iptv2hts-master/movistartv2xmltv $ chmod 755 \*.py

luis@aplicacionix ~/iptv2hts-master/movistartv2xmltv $ cat tv\_grab\_es\_movistar.config
{
"demarcation": "",
"days": "6",
"filename": "/tmp/movistartv-guia.xml",
"quiet": "False",
"offset": "0",
"logfile": "/tmp/movistartv.log"
}

luis@aplicacionix ~/iptv2hts-master/movistartv2xmltv $ export EPYTHON=python2.7
luis@aplicacionix ~/iptv2hts-master/movistartv2xmltv $ ./tv\_grab\_es\_movistar.py -h
luis@aplicacionix ~/iptv2hts-master/movistartv2xmltv $ ./tv\_grab\_es\_movistar.py --m3u --output movistartv-canales.m3u

luis@aplicacionix ~/iptv2hts-master/movistartv2xmltv $ sed -i "s/rtp://@/rtp:///" movistartv-canales.m3u

(Este fichero movistartv-canales.m3u lo compiaré más adelante al MOI Pro)

### 3\. Inserta los canales Movistar TV en Tvheadend

El siguiente paso consiste en insertar los canales que tenemos en este fichero movistartv-canales.m3u.

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**AVISO!!**: El script no comprueba si ya has hecho una inserción previa, de hecho si lo haces añadirás una y otra vez los canales. Si quieres repetir el script te recomiendo que borres la Network "IPTV Movistar" (borrará los Muxes y Servicios) y todos los Canales de Movistar TV.

\[/dropshadowbox\]

Antes de explicarte cómo insertarlos te voy a explicar cómo borrarlos, por si acaso ya los insertaste en el pasado y necesitas hacer una limpieza previa. Aunque ya lo dice al principio de este apunte, vuelvo a recordar que desactivo OverTheAir EPG en todos sitios, ya hablaré más adelante del EPG.

- Arranca tvheadend: \[root@MOIPro ~\]# systemctl start tvheadend
- TV Adapters: Desactivar Over the Air EPG en todos
- Web UI: Borra la Network "IPTV Movistar" (borrará los Muxes y Servicios)
- Web UI: Borra todos los Canales de Movistar TV
- Web UI: Config->Channel/EPG->EPG Grabber->OTE Grabbers: force initial EPG scan at startup: desactivo
- Web UI: Config->Channel/EPG->Channel Tags: Eliminar los tags de Movistar TV o se volverán a crear.
- Parar tvheadend: \[root@MOIPro ~\]# systemctl stop tvheadend
- SSH: \[root@MOIPro /(null)/.hts/tvheadend\]# rm epgdb.v2
- SSH: \[root@MOIPro /(null)/.hts/tvheadend/epggrab/otamux\]# rm \*
- SSH: \[root@MOIPro /(null)/.hts/tvheadend/epggrab/xmltv/channels\]# rm \*
- Arranca tvheadend: \[root@MOIPro ~\]# systemctl start tvheadend

Asumiendo que tienes la configuración limpia el proceso para insertar los canales consiste en conectar por SSH con el MOI, descargar el proyecto iptv2hts desde GitHub y ejecutar el script iptv2hts.py para que inserte los canales en la configuración de Tvheadend:

\_\_\_RECUERDA ENVIAR EL FICHERO "movistartv-canales.m3u" al MOI\_\_\_
luis@aplicacionix ~/iptv2hts-master/movistartv2xmltv $ scp movistartv-canales.m3u root@moipro.parchis.org:.
:

\_\_\_CONECTO CON EL MOI PRO\_\_\_
obelix:~ luis$ ssh -l root moipro.parchis.org
root@moipro.parchis.org's password:
:

\_\_\_ME BAJO LOS SCRIPTS\_\_\_
\[root@MOIPro ~\]# cd /(null)/.hts/
\[root@MOIPro /(null)/.hts\]# curl -L -Ok https://github.com/LuisPalacios/iptv2hts/archive/master.zip
\[root@MOIPro /(null)/.hts\]# unzip master.zip

\_\_\_PREPARO el Script y el Fichero de Canales\_\_\_
\[root@MOIPro /(null)/.hts\]# cd tvheadend/
\[root@MOIPro /(null)/.hts/tvheadend\]# cp ../iptv2hts-master/iptv2hts.py .
\[root@MOIPro /(null)/.hts/tvheadend\]# cp $HOME/movistartv-canales.m3u .

\_\_\_EJECUTO LA INSERCIÓN\_\_\_
\[root@MOIPro /(null)/.hts/tvheadend\]# systemctl stop tvheadend
\[root@MOIPro /(null)/.hts/tvheadend\]# ./iptv2hts.py -x 192.168.1.1:4022 -o canales -n 2 -r -c utf-8 movistartv-canales.m3u
OK

\_\_\_REARRANCO Tvheadend\_\_\_
\[root@MOIPro /(null)/.hts/tvheadend\]# systemctl start tvheadend

Explicación de los argumentos del programa iptv2hts.py:

- ./iptv2hts.py. Creará tantos Muxes como canales existan en el fichero movistartv-canales.m3u
- \-x 192.168.1.1:4022. Dirección de mi servidor udpxy.
- \-o canales. Crear los Canales.
- \-n 2. Usar como número de canal el que viene justo delante del guión (-) en la línea #EXTINF.
- \-r. Eliminar el número de canal del nombre del canal.
- \-c utf-8. Indicar que el fichero .M3U viene en formato UTF-8.

### 4\. Detección de los Servicios

Ahora que se han insertado **Muxes** y **Canales** vamos a pedir que se detecten los **Servicios** y a conectarlos con los Canales.

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**NOTA**: Antes de hacer el scan de los Servicios, te recomiendo que borres los Muxes que no te interesan: otras autonomías, canales no contratados, etc.

\[/dropshadowbox\] \[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**NOTA**: Te recomiendo tener un Terminal conectado a tu MOI Pro y ver el logging, aprenderás cómo funciona Tvheadend: journalctl -f

\[/dropshadowbox\]

Conecta con el Interfaz Web de Tvheadend y edita **Configuration->DVB Inputs->Networks->"IPTV Movistar"**.

- Activar Network Discovery
- Activar Idle Scan Muxes
- Poner "4" en el número de Max Input Streams

[![MTV-1](https://www.luispa.com/wp-content/uploads/2015/05/MTV-1.png)](https://www.luispa.com/wp-content/uploads/2015/05/MTV-1.png)

Verás en el logging cómo empieza el scanning. En la sección Status podrás ver cómo se van escaneando cuatro canales de forma simultánea (esa es la razón por la que pongo el Max Input Streams en '4', para no saturar). Observa en la ventana Web cómo, poco a poco, se van añadiendo servicios (puede llegar a tardar bastante tiempo, en mi caso fue casi una hora).

[![MTV-2](https://www.luispa.com/wp-content/uploads/2015/05/MTV-2.png)](https://www.luispa.com/wp-content/uploads/2015/05/MTV-2.png)

### 5\. Asociación de los Canales

Una vez que ha terminado de hacer el scan y tenemos el mismo número de Muxes que de Servicios, ya podemos ir a la lengüeta de **Configuration->DVB Inputs->Services**, **_seleccionamos_** todos los servicios de "Movistar TV" y hacermos click en **Map Services**, marcamos las tres últimas opciones y pulsamos en **MAP**.

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**AVISO**: No te olvides de Seleccionar los Services que quieres asociar a canales antes de hacer el Map.

\[/dropshadowbox\] [![MTV-3](https://www.luispa.com/wp-content/uploads/2015/05/MTV-3-1024x582.png)](https://www.luispa.com/wp-content/uploads/2015/05/MTV-3.png) [![MTV-4](https://www.luispa.com/wp-content/uploads/2015/05/MTV-41.png)](https://www.luispa.com/wp-content/uploads/2015/05/MTV-41.png)

Recuerda que durante la ejecución de iptv2hts.py había usado la opción \-o canales para que se creasen los **Canales**. Ahora, durante el **Map Services**, los ha encontrado y asociado automáticamente a cada **Service**, ahorrándonos mucho trabajo.

### 6\. Terminar la configuración

Una vez que terminas de configurar los canales ya puedes eliminar los que no deseas y tendrás todo configurado. Puedes deshabilitar el Network Discovery, Idle Scan Muxes y quitar el límite al número de streams disponibles:

[![MTV-5](https://www.luispa.com/wp-content/uploads/2015/05/MTV-5.png)](https://www.luispa.com/wp-content/uploads/2015/05/MTV-5.png)

Solo nos queda el EPG, pero eso lo vemos en la sección final de este apunte.

## Fuentes Satélite

Para los canales que se reciben por Satélite utilizo la "TBS6991SE PCI-E DVB-S2 Dual Tuner TV card", una tarjeta soportada en el MOI Pro que además permite conectar la tarjeta de abonado. [![MoiPHTS-SAT](https://www.luispa.com/wp-content/uploads/2015/05/MoiPHTS-SAT-1024x675.png)](https://www.luispa.com/wp-content/uploads/2015/05/MoiPHTS-SAT.png)

### Preparar Muxes Pre-Definidos

Tvheadend permite, cuando se configuran las sintonizadoras, seleccionar **muxes predefinidos** y es recomendable actualizar los que incluye el paquete de sofware con los originales, que están disponibles en internet.

Baja una copia de las [DTV Scan Tables](http://git.linuxtv.org/cgit.cgi/dtv-scan-tables.git/tree/) y copialas al servidor MOIPro.

 

En otro ordenador donde tengas git instalado: 
$ cd tmp
$ git clone https://git.linuxtv.org//dtv-scan-tables.git
$ cd dtv-scan-tables
$ scp -r \* root@moipro.parchis.org:/usr/share/tvheadend/data/dvb-scan

Conecta con el MOIPro vía SSH:
# ssh -l root moipro.parchis.org
# ln -s /usr/share/tvheadend/data/dvb-scan /usr/share/dvb
# systemctl restart tvheadend

### Crear la "Network" para Satélite

El siguiente paso consiste en Añadir una "Network" de tipo DVB-S usando el listado de frecuencias pre-definido que vimos antes. En mi caso la voy a llamar "TDT-Madrid".

- Network->Add
- DVB-S
- Pre-defined Muxes: (El que corresponda en tu caso)
- Ok A partir de aquí configuras tus muxes, servicios, etc.

# EPG

Al principio de este apunte describía mi estrategia respecto a la Guía de Programación (EPG). He optado por "no" utilizar la Guía OTA (Over The Air) de las tarjetas sintonizadoras. Voy a usar Scripts en Python capaces de descargarla desde internet (para las fuentes TDT y Satélite) y desde el servicio SD&S (Service Discovery & Selection de la propia Movistar TV). Después los fusionaré en un único archivo XMLTV que enviaré a Tvheadend.

Hay un pequeño problema, no puedo ejecutar los scripts Python en el propio MOI Pro. Estoy estudiando cómo compilar los paquetes necesarios y el día que lo consiga documentaré aquí cómo hacerlo. Mientras tanto verás que hay que ejecutar en cualquier otro Linux de tu instalación la descarga de los EPG's y usar NFS para enviar el resultado al MOI.

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**AVISO**: En cuanto sepa cómo ejecutar los scripts en el propio MOI lo documentaré aquí.

\[/dropshadowbox\]

## 1\. Generar el fichero guia.xml

He preparado un script llamado do\_grab.sh que se apoya en [WebGrab+Plus](http://www.webgrabplus.com/) para recolectar el EPG de TDT y Satélite y en **movistartv2xmltv** para la parte de Movistar TV. Además combina ambos en un único fichero de salida: guia.xml

### 1.1. EPG de TDT/Satélite con **WebGrab+Plus**

Para ver un ejemplo sobre cómo instalarlo, consulta este apunte: [WebGrab+Plus con TVHeadEnd en Linux](https://www.luispa.com/?p=1587).

Script para ejecutarlo y ejemplo del fichero de configuración.

#!/bin/bash
#
cd /home/luis/wg++
mono Webgrab+Plus.exe "/home/luis/wg++"

  

  
  /home/luis/wg++/guide.xml

  
  

  
  
  
  

  
  on

  
  4

  
  2

  
  
  

 
 La 1

### 1.2. EPG de Movistar TV con **movistartv2xmltv**

El script **movistartv2xmltv** lo vimos antes, está disponible aquí: [luispa/iptv2hts](https://github.com/LuisPalacios/iptv2hts).

Lo descargo e instalo en mi equipo externo Linux (con Gentoo).

luis@aplicacionix ~ # echo "media-tv/xmltv tv\_combiner" > /etc/portage/package.use/xmltv

luis@aplicacionix ~ # emerge -v xmltv
luis@aplicacionix ~ # export EPYTHON=python2.7
luis@aplicacionix ~ # easy\_install --upgrade pytz
:
luis@aplicacionix ~ $ curl -L -Ok https://github.com/LuisPalacios/iptv2hts/archive/master.zip
luis@aplicacionix ~ $ unzip master.zip
luis@aplicacionix ~ $ cd iptv2hts-master/movistartv2xmltv/
luis@aplicacionix ~/iptv2hts-master/movistartv2xmltv $ chmod 755 \*.py
luis@aplicacionix ~/iptv2hts-master/movistartv2xmltv $ cat tv\_grab\_es\_movistar.config
{
"demarcation": 19,
"mcast\_port": 3937,
"tvpackages": \["UTX6B", "UTX6C"\],
"quiet": "False",
"mcast\_grp\_start": "239.0.2.129",
"days": "6",
"filename": "/home/luis/iptv2hts-master/movistartv2xmltv/movistartv-guia.xml",
"offset": "0",
"logfile": "/home/luis/iptv2hts-master/movistartv2xmltv/movistartv.log"

### Script do\_grab.sh

Ejecuta los dos "grabbers" o recolectores anteriores, cada uno genera un fichero XMLTV como salida que combino en un único fichero XMLTV final para que sea consumido por Tvheadend. El resultado se llama guia.xml y se copia en el directorio NFS.

Tienes una copia de este script en el proyecto [luispa/iptv2hts](https://github.com/LuisPalacios/iptv2hts) en GitHub. Descárgalo, copialo en cualquier directorio de tu Linux externo, adáptalo para que apunte a los directorios donde tienes instalado tanto WebGrab+Plus como movistartv2xmltv, el nombre del directorio destino NFS, etc... y prográmalo con crontab.

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**NOTA**: Todos los nombres de directorios que utilizo son los que empleo en mi caso, tendrás que revisar todos estos scripts para adecuarlos a tu instalación.

\[/dropshadowbox\]

## 2\. Insertar el fichero guia.xml en Tvheadend

Nos volvemos al MOI. Para que pueda acceder al fichero guia.xml usaré NFS, así que adapta todo esto a tu instalación y mira un ejemplo donde monto el directorio /media/NAS. Para hacerlo creo dos ficheros bajo /etc/systemd/system para montar automáticamente el directorio /media/NAS.

\[Unit\]
Description=Montar por NFS el directorio NAS
After=syslog.target
Before=tvheadend.service

\[Mount\]
What=panoramix.parchis.org:/NAS
Where=/media/NAS
Options=nolock
Type=nfs

\[Install\]
WantedBy=multi-user.target

\[Unit\]
Description=Automount /media/NAS

\[Automount\]
Where=/media/NAS

\[Install\]
WantedBy=multi-user.target

Habilito el servicio y rearranco:

 
\[root@MOIPro /etc/systemd/system\]# systemctl enable media-NAS.mount
\[root@MOIPro /etc/systemd/system\]# systemctl enable media-NAS.automount
\[root@MOIPro /etc/systemd/system\]# reboot

#### Configurar TVheadend para que consuma el fichero guia.xml

El último paso consiste en configurar Tvheadend para que lea el fichero guia.xml que se genera de forma externa al menos una vez al día. Tienes que crear un fichero /usr/bin/tv\_grab\_guia. Es importante que lo crees en /usr/bin

#!/bin/bash
xmltv\_file\_location=/media/NAS/moipro/guia.xml
dflag=
vflag=
cflag=
qflag=
if (( $# < 1 )) then cat "$xmltv\_file\_location" exit 0 fi for arg do delim="" case "$arg" in #translate --gnu-long-options to -g (short options) --description) args="${args}-d ";; --version) args="${args}-v ";; --capabilities) args="${args}-c ";; --quiet) args="${args}-q ";; #pass through anything else \*) \[\[ "${arg:0:1}" == "-" \]\] || delim=""" args="${args}${delim}${arg}${delim} ";; esac done #Reset the positional parameters to the short options eval set -- $args while getopts "dvcq" option do case $option in d) dflag=1;; v) vflag=1;; c) cflag=1;; q) qflag=1;; ?) printf "unknown option: -%sn" $OPTARG printf "Usage: %s: \[--description\] \[--version\] \[--capabilities\] n" $(basename $0) exit 2 ;; esac >&2
done

if \[ "$dflag" \]
then
   printf "$0 is a wrapper grabber around Movistar TVn"
fi
if \[ "$vflag" \]
then
   printf "0.2n"
fi
if \[ "$cflag" \]
then
   printf "baselinen"
fi
if \[ "$qflag" \]
then
   printf ""
fi

exit 

- Da permisos de ejecución al script y rearranca Tvheadend para que lo detecte

\[root@MOIPro /usr/bin\]# chmod 755 /usr/bin/tv\_grab\_guia

\[root@MOIPro /usr/bin\]# systemctl restart tvheadend

\*

Conecta a través del interfaz Web y modifica **Configuration-> Channel/EPG-> EPG Grabber-> Internal Grabber**. Selecciona el ejecutable tv\_grab\_guia y cambia la programación sobre "cuando" debe ejecutarse:

[![MTV-66](https://www.luispa.com/wp-content/uploads/2015/05/MTV-66.png)](https://www.luispa.com/wp-content/uploads/2015/05/MTV-66.png)

#### Ajuste fino del EPG

Probablemente tengas varios canales de Movistar TV que no muestran el EPG. Eso se debe a que durante la inserción de los canales Tvheadend hizo un buen trabajo asociando el EPG correspondiente, pero no en todos los casos. Repasa qué canales "no" tienen EPG y desde el administrador Web asociale el adecuado.

Un ejemplo: El canal Divinity NO me mostraba el EPG, desde el configurador desactivé la asociación incorrecta (rojo) y activé la asociación correcta (verde).

[![div0](https://www.luispa.com/wp-content/uploads/2015/05/div0-1024x265.png)](https://www.luispa.com/wp-content/uploads/2015/05/div0.png) El resultado final es el siguiente: [![div1](https://www.luispa.com/wp-content/uploads/2015/05/div1-1024x268.png)](https://www.luispa.com/wp-content/uploads/2015/05/div1.png)

Después forcé que Tvheadend re-ejecutase el Grabber. El truco para hacerlo es sencillo. Ve a la ventana de configuración, modifica cualquier campo de la sección Multi-grabber, por ejemplo añade un punto al final de la línea de comentario "Cron multi-line" y vuelve a borrarlo (es decir, en realidad no estás cambiando nada pero Tvheadend creeará que lo has hecho), después pulsa el botón de "Save", en ese momento se ejecuta el grabber de nuevo. En los clientes KODI: Programa->Configuración->TV->EPG/Guía->"Reset DB guía". Cuando vuelvas a la lista de canales deberías ver la Guía que antes te faltaba.

Hay más casos donde necesitarás ajuste fino: uno es si asoció dos EPG's (en vez de uno). Puedes eliminar la asociación redundante, por ejemplo: El canal Baby TV que ves a continuación, tiene como ID EPG del canal el código "BABTV" y estaba asociado a un EPG con un uuid muy largo (rojo), que he quitado para dejar solo el bueno (verde).

[![babtv](https://www.luispa.com/wp-content/uploads/2015/05/babtv-1024x55.png)](https://www.luispa.com/wp-content/uploads/2015/05/babtv.png)

Hay otro caso que despista bastante, por ejemplo donde el código a asociar es distinto al lógico, mira en este caso donde el canal Movistar F1 tiene como código (DEP1), bueno, pues funciona.

[![mf1](https://www.luispa.com/wp-content/uploads/2015/05/mf1-1024x37.png)](https://www.luispa.com/wp-content/uploads/2015/05/mf1.png)

# Compilar Tvheadend desde GitHub

Si quieres aventurarte a actualizar tú mismo el ejecutable de Tvheadend solo necesitas un equipo ARM donde puedas instalar el entorno de desarrollo. Puedes optar por montarte un sistema de crosscompilación (desde un x86) o bien instalarte Linux en un equipo nativo ARM. En mi caso he optado por esto último usando una Raspberry Pi2. En el apunte [Gentoo en Raspberry Pi 2](https://www.luispa.com/?p=3128) tienes descrito todo el proceso. Además, al final del mismo encontrarás una sección llamada **Compilar Tvheadend para MOI Pro**.

# Reboot automático diario

Si no te fias de la estabilidad del equipo o hace cosas raras igual te vendría bien re-arrancarlo todos los días, a mi es algo que me ha funcionado bastante bien. Le meto un "reboot" diario :-). Esto es lo que he hecho:

Conecto por SSH con el equipo, creo los ficheros para systemd: reboot.timer y reboot.service, habilito el primero (.timer) y lo arranco. A partir de ese momento todos los días se ejecutará un reboot a las 4 de la mañana, aquí los ficheros:

$ ssh -l root moipro.parchis.org -p 22
root@moipro.parchis.org's password:
\[root@MOIPro ~\]#
\[root@MOIPro ~\]# cd /etc/systemd/system
\[root@MOIPro /etc/systemd/system\]# cat > reboot.timer
\[Unit\]
Description=Rearrancar el equipo a las 04:00

\[Timer\]
OnCalendar=\*-\*-\* 04:00:00
Unit=reboot.service

\[Install\]
WantedBy=timers.target
                       <==== (pulsar CTRL-D)

\[root@MOIPro /etc/systemd/system\]#
\[root@MOIPro /etc/systemd/system\]# cat > reboot.service
\[Unit\]
Description=Rearrancar el equipo

\[Service\]
Type=oneshot
ExecStart=/sbin/reboot
                        <==== (pulsar CTRL-D)

\[root@MOIPro /etc/systemd/system\]# systemctl enable reboot.timer
\[root@MOIPro /etc/systemd/system\]# systemctl start reboot.timer
\[root@MOIPro /etc/systemd/system\]#

 

# Backup

Si tienes un disco o pastilla USB antigua por ahí guardada en un cajón, te recomiendo darle una utilidad mucho mejor, hacer backups incrementales de tu instalación, en concreto el directorio más importante es /(null)/.hts/tvheadend, aunque ya de paso salvaré también /etc.

Conecta el disco USB a tu MOI y averigua qué nombre de dispositivo le asigna el kernel:

 
\[root@MOIPro ~\]# dmesg
usb 2-1.3: new high speed USB device number 4 using fsl-ehci
scsi0 : usb-storage 2-1.3:1.0
input: LaCie    little disk (button) as /devices/platform/fsl-ehci.1/usb2/2-1/2-1.3/2-1.3:1.1/input/input1
generic-usb 0003:059F:1006.0001: input,hidraw0: USB HID v1.11 Device \[LaCie    little disk (button)\] on usb-fsl-ehci.1-1.3/input1
scsi 0:0:0:0: Direct-Access     LaCie    little Disk           PQ: 0 ANSI: 4
sd 0:0:0:0: \[sda\] 625142448 512-byte logical blocks: (320 GB/298 GiB)
sd 0:0:0:0: \[sda\] Write Protect is off
sd 0:0:0:0: \[sda\] Mode Sense: 10 00 00 00
sd 0:0:0:0: \[sda\] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2
sd 0:0:0:0: \[sda\] Attached SCSI disk
usb 2-1.3: reset high speed USB device number 4 using fsl-ehci
usb 2-1.3: reset high speed USB device number 4 using fsl-ehci
usb 2-1.3: reset high speed USB device number 4 using fsl-ehci
usb 2-1.3: reset high speed USB device number 4 using fsl-ehci
usb 2-1.3: reset high speed USB device number 4 using fsl-ehci
usb 2-1.3: reset high speed USB device number 4 using fsl-ehci
sd 0:0:0:0: \[sda\] Unhandled error code
sd 0:0:0:0: \[sda\]  Result: hostbyte=0x07 driverbyte=0x00
sd 0:0:0:0: \[sda\] CDB: cdb\[0\]=0x28: 28 00 00 00 03 00 00 00 08 00
end\_request: I/O error, dev sda, sector 768
Buffer I/O error on device sda, logical block 96
usb 2-1.3: reset high speed USB device number 4 using fsl-ehci
usb 2-1.3: reset high speed USB device number 4 using fsl-ehci
usb 2-1.3: reset high speed USB device number 4 using fsl-ehci
usb 2-1.3: reset high speed USB device number 4 using fsl-ehci

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**AVISO**: Si el disco traía una partición ya creada, la voy a borrar, pero puede que el MOI la "monte", así que fíjate y desmonta el file system antes de continuar.

\[/dropshadowbox\]

Como puedes observar, en mi caso asocia el device /dev/sda. Este dato es importantísimo, utiliza el nombre que haya asignado en tu propio caso, no te fies, podrías borrar el disco incorrecto.

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**ATENCIÓN**: Mucho cuidado con los comandos siguientes. Voy a borrar el disco, en mi caso lo ha reconocido como /dev/sda, fíjate cómo lo ha reconocido en el tuyo y usa el nombre del dispositivo adecuado.

\[/dropshadowbox\]

Borro todo el contenido del disco y creo una única partición de tipo Linux (tipo 83) que ocupa el disco entero. Último aviso, no hagas lo siguiente si no entiendes lo que estás haciendo.

 
\[root@MOIPro ~\]# dd if=/dev/zero of=/dev/sda  bs=512 count=1    
1+0 records in
1+0 records out
512 bytes (512B) copied, 0.001293 seconds, 386.7KB/s

\[root@MOIPro ~\]# fdisk /dev/sda
Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-38913, default 1): Using default value 1
Last cylinder or +size or +sizeM or +sizeK (1-38913, default 38913): Using default value 38913

Command (m for help): p
Disk /dev/sda: 320.0 GB, 320072933376 bytes
255 heads, 63 sectors/track, 38913 cylinders
Units = cylinders of 16065 \* 512 = 8225280 bytes

   Device Boot      Start         End      Blocks  Id System
/dev/sda1               1       38913   312568641  83 Linux

Command (m for help): w
\[root@MOIPro ~\]# 

Creo un File System de tipo EXT4.

 
\[root@MOIPro ~\]# mkfs.ext4 /dev/sda1

\_\_\_IMPORTANTE !!!: Puede que monte el nuevo filesystem, así que desmóntalo manualmente
\[root@MOIPro ~\]# umount /dev/sda1

Creo el directorio donde montaré el USB.

 
\[root@MOIPro ~\]# mkdir /media/backup

Preparo el montaje durante el boot:

\[Unit\]
Description=Montar el USB para Backups
Conflicts=umount.target
After=syslog.target

\[Mount\]
What=/dev/sda1
Where=/media/backup
Type=ext4

\[Install\]
WantedBy=multi-user.target

Habilito en Unit y rearranco el equipo.

 
\[root@MOIPro /etc/systemd/system\]# systemctl enable media-backup.mount
\[root@MOIPro /etc/systemd/system\]# reboot

Para el backup usaré la técnica [descrita en este apunte](https://www.luispa.com/?p=18), basada en Rsync y backups incrementales usando Hard Links con un script llamado rbme que facilita todo el proceso.

 
\[root@MOIPro ~\]# cd /usr/bin
\[root@MOIPro /usr/bin\]# curl -L -Ok https://raw.githubusercontent.com/LuisPalacios/rbme/master/rbme\_moipro
\[root@MOIPro /usr/bin\]# mv rbme\_moipro rbme
\[root@MOIPro /usr/bin\]# chmod 755 rbme

Preparo el fichero de configuración y programación en el cron.

BACKUP\_PATH="/media/backup"
MIN\_FREE\_BEFORE\_HOST\_BACKUP="30000"
MIN\_INODES\_BEFORE\_HOST\_BACKUP="100000"
MIN\_FREE\_AFTER\_HOST\_BACKUP="40000"
MIN\_INODES\_AFTER\_HOST\_BACKUP="300000"
MIN\_KEEP\_OLD\_BACKUPS="30"
VERBOSE=${VERBOSE=}
STATISTICS="yes"
MAILTO=""
MAILFROM=""
MAILSTYLE="all"
LOGFILE=$(date +"/var/log/$ME.log.%d")
RSYNC\_RSH="ssh -c blowfish-cbc”

NOTA: LO SIGUIENTE ESTÁ TODAVÍA WORK IN PROGRESS

Creo un archivo de control en mi disco USB.

 
\[root@MOIPro ~\]# touch /media/backup/.mi-disco-usb.txt

Creo un script para ejecutar rbme.

#!/bin/bash
#
if \[ -f "/media/backup/.mi-disco-usb.txt" \];
then
    rbme totobo:/Apps
fi
