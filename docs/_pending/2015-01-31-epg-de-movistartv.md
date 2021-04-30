---
title: "Tvheadend y Movistar TV (2015)"
date: "2015-01-31"
categories: apuntes
tags: linux nuc
excerpt_separator: <!--more-->
---

Veremos cómo instalar Tvheadend en un servidor Linux (Gentoo) para ver canales IPTV que recibo a través de mi contrato Movistar Fusión TV. Aunque esta información fue válida durante el 2015 tanto Tvheadend (nueva versión) como el propio Movistar TV (EPG) han evolucionado, así que dejo este apunte como documentación de referencia pero te recomiendo consultar el nuevo apunte ![Tvheadend y Movistar TV (2016)](/assets/img/original/?p=4571){: width="730px" padding:10px }.

Aviso a navegantes: En mi caso no utilizo el router de Movistar, lo he sustituido por un equipo linux, por lo tanto todo lo descrito en este artículo es válido para esta forma de trabajar, te recomiendo echarle un ojo también a este apunte: [Movistar Fusión Fibra + TV + VoIP con router Linux.](https://www.luispa.com/?p=266) Quizá también te podrían interesar otros apuntes cómo el que va sobre [WebGrab+Plus con TVHeadEnd en Linux](https://www.luispa.com/?p=1587), mi ![Media Center casero](https://www.luispa.com/?p=1025) y por último la "[Raspberry Pi OpenElec con XBMC](/assets/img/original/?p=1284){: width="730px" padding:10px }".

![fuentesstb2015](/assets/img/original/fuentesstb2015.png){: width="730px" padding:10px }

## Tvheadend y Movistar TV + XBMC/KODI

 

### Instalación de Tvheadend en Linux Gentoo (systemd)

Estas son las opciones que utilicé en el 2015, el comando para instalar [Tvheadend](https://tvheadend.org/) en un linux Gentoo con **systemd**. Si prefieres **openrc** consulta ![este otro apunte](/assets/img/original/?p=266){: width="730px" padding:10px }.

[code language="bash" light="true"] lunatv # cat /etc/portage/package.accept_keywords # tvheadend ~media-tv/tvheadend-9999 **

lunatv ~ # cat /etc/portage/package.use/tvheadend media-tv/tvheadend avahi capmt constcw cwc dbus dvb dvbscan ffmpeg -hdhomerun imagecache inotify iptv -libav satip timeshift uriparser xmltv zlib

lunatv ~ # emerge -v tvheadend : [/code]

 

Si en el futuro quieres actualizar simplemente ejecuta lo siguiente:

[code language="bash" light="true"] lunatv ~ # emerge -DuvNp system world [/code]

 

Aquí tienes el fichero **.service**. Ten en cuenta que esta versión está ligeramente retocada, dependo del servicio igmpproxy (más ![aquí](/assets/img/original/?p=266)){: width="730px" padding:10px }.

[code language="bash" light="true"] lunatv ~ # cat /etc/systemd/system/tvheadend.service

[Unit] Description=UDP-to-HTTP multicast traffic relay daemon After=network-online.target igmpproxy.service

[Service] Type=forking EnvironmentFile=/etc/conf.d/tvheadend ExecStart=/usr/bin/tvheadend -f -C -u $TVHEADEND_USER -g $TVHEADEND_GROUP -c $TVHEADEND_CONFIG $TVHEADEND_OPTIONS Restart=always RestartSec=3

[Install] WantedBy=multi-user.target [/code]  

Por último, el fichero de configuración. El parámetro más importante es el directorio al que apunta TVHEADEND_CONFIG. Ese directorio es en el que debes trabajar cuando quieras cambiar la configuración de tvheadend.

[code language="bash" light="true"] lunatv ~ # cat /etc/conf.d/tvheadend # See the tvheadend(1) manpage for more info.

# Run Tvheadend as this user. TVHEADEND_USER="tvheadend"

# Run Tvheadend as this group. TVHEADEND_GROUP="video"

# Path to Tvheadend config. TVHEADEND_CONFIG="/etc/tvheadend"

# Other options you want to pass to Tvheadend. TVHEADEND_OPTIONS="" [/code]  

Estos son los comandos necesarios para habilitar, arrancar y parar el servicio

[code language="bash" light="true"] lunatv ~ # systemctl enable tvheadend lunatv ~ # systemctl start tvheadend lunatv ~ # systemctl stop tvheadend [/code]

   

### ![TVheadEnd](/assets/img/original/tvheadend){: width="730px" padding:10px } + Add-On "Tvheadend HTSP Client"

En este artículo documento la siguiente opción: TVHeadEnd + Add-On "Tvheadend HTSP Client". Es una opción muy buena con una arquitectura sencilla: El XBMC usa el addon Tvheadend HTSP Client para conectar vía [HTSP](https://tvheadend.org/projects/tvheadend/wiki/Htsp) con el daemon TVHeadEnd que se ejecuta en el Linux que a su vez se suscribe a la fuente multicast para recibir y reenviar el canal de TV. Además soporta intepretar el EPG en formato ![XMLTV](/assets/img/original/Main_Page){: width="730px" padding:10px }.

En cada uno de los XBMC se añade el Add-On “Tvheadend HTSP Client” y se configura para acceder por HTSP al servidor donde se ejecuta el daemon de TVHeadEnd, por donde recibirá “lista” de canales, cómo llegar hasta ellos y más adelante el EPG.

![tvheaden_cl1](/assets/img/original/tvheaden_cl1-1024x578.png){: width="730px" padding:10px }

![tvheaden_cl2](/assets/img/original/tvheaden_cl2-1024x578.png){: width="730px" padding:10px }  

## Lista de canales y EPG

A continuación vamos a bajarnos el listado de canales y el EPG y para conseguirlo contamos con un script fantástico llamado ![movistartv2xmltv](/assets/img/original/movistartv2xmltv), un proyecto muy activo que es capaz de conectar con el servicio SD&S (Service Discovery & Selection) de Movistar TV para recoger la información de canales y programación (EPG){: width="730px" padding:10px }. Una vez tenga ambos alimentaré a TVHeadEnd y será el quien los presente a los clientes XBMC.

Instalo el script en mi ![servidor Linux casero](/assets/img/original/?p=725){: width="730px" padding:10px }, primero instalo como root unas dependencias para después, como un usuario normal, bajarme el script.

[code language="bash" light="true"] totobo ~ # emerge -v xmltv totobo ~ # export EPYTHON=python2.7 totobo ~ # easy_install --upgrade pytz : totobo ~ $ curl -L -Ok https://github.com/ese/movistartv2xmltv/archive/master.zip totobo ~ $ unzip master.zip totobo ~ $ rm master.zip totobo ~ $ mv movistartv2xmltv-master/ movistartv2xmltv totobo ~ $ cd movistartv2xmltv/ totobo movistartv2xmltv $ chmod 755 *.py [/code]

Creo su fichero de configuración (formato json). Utilizo el nombre tv_grab_es_movistar.config, es el que por defecto buscará el programa al llamarlo sin argumentos:

[code light="true"] { "demarcation": "", "days": "6", "filename": "/home/luis/movistartv2xmltv/movistartv-guia.xml", "quiet": "False", "offset": "0", "logfile": "/home/luis/movistartv2xmltv/movistartv.log" } [/code]

- Nota: después de la primera ejecución el programa modifica el json y quedará tal que así:

[code light="true"] { "demarcation": 19, "mcast_port": 3937, "tvpackages": ["UTX6C", "UTX8F"], "days": "6", "mcast_grp_start": "239.0.2.129", "filename": "/home/luis/movistartv2xmltv/movistartv-guia.xml", "quiet": "False", "offset": "0", "logfile": "/home/luis/movistartv2xmltv/movistartv.log" } [code]

&nbsp;

<h4>Primer paso: La lista de canales</h4>

<p style="text-align: justify;">Necesito esta lista para alimentar a TVHeadEnd, para saber dónde están los iconos de los canales, etc.</p>

[code language="bash" light="true"] totobo movistartv2xmltv $ export EPYTHON=python2.7 totobo movistartv2xmltv $ ./tv_grab_es_movistar.py -h : totobo movistartv2xmltv $ ./tv_grab_es_movistar.py --m3u --output movistartv-canales.m3u [/code]

#EXTM3U
#EXTINF:-1,0 - Movistar TV
#EXTTV:CULTURA,ESPECTÁCULOS;es;CPROM;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/597.jpg
rtp://@239.0.0.77:8208
#EXTINF:-1,1 - La 1
#EXTTV:CULTURA,ESPECTÁCULOS;es;TVE;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1.jpg
rtp://@239.0.0.76:8208
#EXTINF:-1,2 - La 2
#EXTTV:CULTURA,ESPECTÁCULOS;es;La 2;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/3.jpg
rtp://@239.0.0.2:8208
#EXTINF:-1,3 - Antena 3
#EXTTV:CULTURA,ESPECTÁCULOS;es;A3;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/4.jpg
rtp://@239.0.0.3:8208
#EXTINF:-1,4 - Cuatro HD
#EXTTV:VARIEDADES;es;4HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1825.jpg
rtp://@239.0.0.177:8208
#EXTINF:-1,5 - Tele 5 HD
#EXTTV:CULTURA,ESPECTÁCULOS;es;T5HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1826.jpg
rtp://@239.0.0.176:8208
#EXTINF:-1,6 - laSexta
#EXTTV:CULTURA,ESPECTÁCULOS;es;Sexta;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/717.jpg
rtp://@239.0.0.58:8208
#EXTINF:-1,7 - Telemadrid
#EXTTV:ENTRETENIMIENTO;es;TMAD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/58.jpg
rtp://@239.0.0.25:8208
#EXTINF:-1,8 - La Otra
#EXTTV:ENTRETENIMIENTO;es;OTRA;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/59.jpg
rtp://@239.0.0.26:8208
#EXTINF:-1,9 - Movistar Series
#EXTTV:ANIMACIÓN;es;SERHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/2383.jpg
rtp://@239.0.0.184:8208
#EXTINF:-1,10 - FOX HD
#EXTTV:POLICIACAS;es;FOXHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1607.jpg
rtp://@239.0.9.134:8208
#EXTINF:-1,11 - AXN HD
#EXTTV:POLICIACAS;es;AXNHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1608.jpg
rtp://@239.0.9.131:8208
#EXTINF:-1,12 - Calle 13HD
#EXTTV:POLICIACAS;es;C13HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1705.jpg
rtp://@239.0.5.74:8208
#EXTINF:-1,13 - TNT HD
#EXTTV:ENTRETENIMIENTO;es;TNTHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1609.jpg
rtp://@239.0.5.87:8208
#EXTINF:-1,14 - FOX life HD
#EXTTV:ENTRETENIMIENTO;es;FXLHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/2203.jpg
rtp://@239.0.5.86:8208
#EXTINF:-1,15 - Cosmo HD
#EXTTV:POLICIACAS;es;CosHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1610.jpg
rtp://@239.0.5.71:8208
#EXTINF:-1,16 - AXN W. HD
#EXTTV:POLICIACAS;es;FCRHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1611.jpg
rtp://@239.0.5.79:8208
#EXTINF:-1,17 - Comedy Central HD
#EXTTV:POLICIACAS;es;COCHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/2224.jpg
rtp://@239.0.0.174:8208
#EXTINF:-1,18 - SyFyHD
#EXTTV:POLICIACAS;es;SYFHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1703.jpg
rtp://@239.0.5.75:8208
#EXTINF:-1,19 - Crimen e Inv.
#EXTTV:POLICIACAS;es;CREIN;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/697.jpg
rtp://@239.0.0.57:8208
#EXTINF:-1,20 - FDF
#EXTTV:POLICIACAS;es;FDFT5;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/747.jpg
rtp://@239.0.0.84:8208
#EXTINF:-1,21 - Neox
#EXTTV:ENTRETENIMIENTO;es;NEOX;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/934.jpg
rtp://@239.0.0.107:8208
#EXTINF:-1,22 - Energy
#EXTTV:VARIEDADES;es;energ;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/884.jpg
rtp://@239.0.0.59:8208
#EXTINF:-1,24 - Divinity
#EXTTV:DRAMA;es;DIVIN;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/663.jpg
rtp://@239.0.0.48:8208
#EXTINF:-1,27 - Nova
#EXTTV:ENTRETENIMIENTO;es;NOVA;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/935.jpg
rtp://@239.0.0.106:8208
#EXTINF:-1,29 - Sundance HD
#EXTTV:ENTRETENIMIENTO;es;SunHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1615.jpg
rtp://@239.0.5.72:8208
#EXTINF:-1,31 - HWD HD
#EXTTV:POLICIACAS;es;HOLHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1612.jpg
rtp://@239.0.5.76:8208
#EXTINF:-1,32 - AMC HD
#EXTTV:ENTRETENIMIENTO;es;MGMHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1613.jpg
rtp://@239.0.9.132:8208
#EXTINF:-1,34 - TCM HD
#EXTTV:ENTRETENIMIENTO;es;TCMHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/2204.jpg
rtp://@239.0.5.89:8208
#EXTINF:-1,38 - Paramount C.
#EXTTV:AVENTURAS;es;PARCH;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1221.jpg
rtp://@239.0.0.90:8208
#EXTINF:-1,40 - EurosportHD
#EXTTV:POLICIACAS;es;EURHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1623.jpg
rtp://@239.0.9.135:8208
#EXTINF:-1,41 - Eurosport 2
#EXTTV:POLICIACAS;es;EUSP2;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/338.jpg
rtp://@239.0.0.37:8208
#EXTINF:-1,42 - Sportmania
#EXTTV:POLICIACAS;es;SPMA;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/16.jpg
rtp://@239.0.0.17:8208
#EXTINF:-1,43 - Teledeporte
#EXTTV:POLICIACAS;es;TDEP;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/744.jpg
rtp://@239.0.0.79:8208
#EXTINF:-1,44 - Iberalia
#EXTTV:ENTRETENIMIENTO;es;IBER;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/936.jpg
rtp://@239.0.5.6:8208
#EXTINF:-1,50 - C+LigaHD
#EXTTV:FÚTBOL;es;GOLHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1622.jpg
rtp://@239.0.9.129:8208
#EXTINF:-1,51 - C+Liga Multi
#EXTTV:FÚTBOL;es;FUT3;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1063.jpg
rtp://@239.0.0.119:8208
#EXTINF:-1,54 - Movistar Fútbol HD
#EXTTV:ENTRETENIMIENTO;es;QU1HD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/2268.jpg
rtp://@239.0.5.185:8208
#EXTINF:-1,55 - C+L.CampHD
#EXTTV:ENTRETENIMIENTO;es;CP3D;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1621.jpg
rtp://@239.0.9.138:8208
#EXTINF:-1,56 - Gol 2 IntHD
#EXTTV:ENTRETENIMIENTO;es;G2INT;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1667.jpg
rtp://@239.0.9.146:8208
#EXTINF:-1,64 - Futbol R.
#EXTTV:FÚTBOL;es;fut;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/12.jpg
rtp://@239.0.0.97:8208
#EXTINF:-1,70 - NAT GEO HD
#EXTTV:POLICIACAS;es;NATHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1643.jpg
rtp://@239.0.5.78:8208
#EXTINF:-1,71 - NG Wild HD
#EXTTV:ENTRETENIMIENTO;es;NGEHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1619.jpg
rtp://@239.0.9.136:8208
#EXTINF:-1,72 - Viajar HD
#EXTTV:POLICIACAS;es;ViaHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1617.jpg
rtp://@239.0.5.73:8208
#EXTINF:-1,73 - DSC HD
#EXTTV:POLICIACAS;es;DSCHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/2205.jpg
rtp://@239.0.5.77:8208
#EXTINF:-1,74 - ODISEA HD
#EXTTV:POLICIACAS;es;FHD2;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1618.jpg
rtp://@239.0.5.82:8208
#EXTINF:-1,75 - Historia
#EXTTV:POLICIACAS;es;HIST;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/17.jpg
rtp://@239.0.0.19:8208
#EXTINF:-1,76 - A&E
#EXTTV:POLICIACAS;es;A&E;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/340.jpg
rtp://@239.0.0.38:8208
#EXTINF:-1,77 - Cocina
#EXTTV:POLICIACAS;es;COCI;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/22.jpg
rtp://@239.0.0.27:8208
#EXTINF:-1,78 - Decasa
#EXTTV:POLICIACAS;es;DCASA;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/850.jpg
rtp://@239.0.0.71:8208
#EXTINF:-1,79 - Discov.Max
#EXTTV:POLICIACAS;es;TVCi;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/657.jpg
rtp://@239.0.0.32:8208
#EXTINF:-1,80 - Baby TV
#EXTTV:POLICIACAS;es;BABTV;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/778.jpg
rtp://@239.0.0.113:8208
#EXTINF:-1,81 - Disney Junior
#EXTTV:POLICIACAS;es;PLAY;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/10.jpg
rtp://@239.0.0.10:8208
#EXTINF:-1,82 - Canal Panda
#EXTTV:ENTRETENIMIENTO;es;PANDA;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1019.jpg
rtp://@239.0.0.117:8208
#EXTINF:-1,84 - Nickelodeon
#EXTTV:POLICIACAS;es;NICKE;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/579.jpg
rtp://@239.0.0.69:8208
#EXTINF:-1,85 - Disney XD
#EXTTV:POLICIACAS;es;DISXD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/11.jpg
rtp://@239.0.0.11:8208
#EXTINF:-1,86 - Disney HD
#EXTTV:POLICIACAS;es;DISHD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1616.jpg
rtp://@239.0.0.173:8208
#EXTINF:-1,87 - Boing
#EXTTV:POLICIACAS;es;ARSAT;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/578.jpg
rtp://@239.0.0.66:8208
#EXTINF:-1,88 - Clan TVE
#EXTTV:POLICIACAS;es;CLAN;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/745.jpg
rtp://@239.0.0.80:8208
#EXTINF:-1,90 - Sol Música
#EXTTV:POLICIACAS;es;SOLM;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/341.jpg
rtp://@239.0.0.39:8208
#EXTINF:-1,91 - 40 TV
#EXTTV:POLICIACAS;es;40TV;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/741.jpg
rtp://@239.0.0.12:8208
#EXTINF:-1,92 - VH1
#EXTTV:POLICIACAS;es;VH1;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/581.jpg
rtp://@239.0.0.75:8208
#EXTINF:-1,100 - Fox News
#EXTTV:POLICIACAS;es;FOXNW;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/845.jpg
rtp://@239.0.7.65:8208
#EXTINF:-1,101 - BBC World
#EXTTV:POLICIACAS;es;BBCW;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/197.jpg
rtp://@239.0.0.30:8208
#EXTINF:-1,102 - CNN Int.
#EXTTV:POLICIACAS;es;CNNI;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/342.jpg
rtp://@239.0.0.40:8208
#EXTINF:-1,103 - Euronews
#EXTTV:POLICIACAS;es;Eurnw;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/119.jpg
rtp://@239.0.0.28:8208
#EXTINF:-1,104 - Canal 24 H.
#EXTTV:POLICIACAS;es;C24H;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/743.jpg
rtp://@239.0.0.78:8208
#EXTINF:-1,105 - Al Jazeera
#EXTTV:POLICIACAS;es;ALJAZ;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/846.jpg
rtp://@239.0.7.66:8208
#EXTINF:-1,106 - France 24
#EXTTV:POLICIACAS;es;FRA24;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/847.jpg
rtp://@239.0.7.67:8208
#EXTINF:-1,107 - Russia T.
#EXTTV:POLICIACAS;es;RUSSI;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/848.jpg
rtp://@239.0.7.68:8208
#EXTINF:-1,108 - CNBC Eur.
#EXTTV:POLICIACAS;es;CNBC;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/849.jpg
rtp://@239.0.7.69:8208
#EXTINF:-1,109 - CCTV E
#EXTTV:CULTURA,ESPECTÁCULOS;es;CCTVE;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/752.jpg
rtp://@239.0.0.65:8208
#EXTINF:-1,110 - TV5 Monde
#EXTTV:POLICIACAS;es;TV5eu;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/198.jpg
rtp://@239.0.0.31:8208
#EXTINF:-1,111 - Bloomberg
#EXTTV:POLICIACAS;es;Bloom;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/120.jpg
rtp://@239.0.0.29:8208
#EXTINF:-1,112 - Intereconomía
#EXTTV:POLICIACAS;es;INTTV;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/582.jpg
rtp://@239.0.0.63:8208
#EXTINF:-1,114 - 13 TV
#EXTTV:POLICIACAS;es;13TV;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/844.jpg
rtp://@239.0.0.91:8208
#EXTINF:-1,116 - I 24 News
#EXTTV:ENTRETENIMIENTO;es;I24NW;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1807.jpg
rtp://@239.0.0.220:8208
#EXTINF:-1,117 - CNC World
#EXTTV:ENTRETENIMIENTO;es;CNCWD;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1805.jpg
rtp://@239.0.0.221:8208
#EXTINF:-1,118 - Canal Orbe 21
#EXTTV:ENTRETENIMIENTO;es;COR21;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/2463.jpg
rtp://@239.0.0.45:8208
#EXTINF:-1,150 - Andalucía TV
#EXTTV:ENTRETENIMIENTO;es;ANDSA;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/2275.jpg
rtp://@239.0.0.1:8208
#EXTINF:-1,151 - Galicia TV Europa
#EXTTV:ENTRETENIMIENTO;es;TVGEU;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/2273.jpg
rtp://@239.0.3.37:8208
#EXTINF:-1,152 - TV3CAT
#EXTTV:ENTRETENIMIENTO;es;TV3SA;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/2271.jpg
rtp://@239.0.3.36:8208
#EXTINF:-1,153 - ETB Sat.
#EXTTV:ENTRETENIMIENTO;es;ETBSA;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/2269.jpg
rtp://@239.0.0.60:8208
#EXTINF:-1,200 - LTC
#EXTTV:POLICIACAS;es;TIEND;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/886.jpg
rtp://@239.0.0.98:8208
#EXTINF:-1,504 - Cuatro
#EXTTV:VARIEDADES;es;CUATR;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1843.jpg
rtp://@239.0.0.4:8208
#EXTINF:-1,505 - Tele 5
#EXTTV:CULTURA,ESPECTÁCULOS;es;TELE5;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1844.jpg
rtp://@239.0.0.5:8208
#EXTINF:-1,523 - Calle 13
#EXTTV:POLICIACAS;es;CA13;http://172.26.22.23:2001/appclient/incoming/epg/MAY_1/imSer/1706.jpg
rtp://@239.0.0.13:8208

TVHeadEnd no entiende esta lista en formato .m3u, así que vamos a convertirla a su formato. Una vez más, otro genial script disponible en ![GitHub m3u2hts](/assets/img/original/m3u2hts){: width="730px" padding:10px } se encarga de la tarea.

[code language="bash" light="true"] totobo movistartv2xmltv $ mkdir tvheadend totobo movistartv2xmltv $ cd tvheadend/

totobo tvheadend $ curl -Ok https://raw.githubusercontent.com/grudolf/m3u2hts/master/m3u2hts.py totobo tvheadend $ chmod 755 m3u2hts.py [/code]  

Ejecuto el programa **m3u2hts** (nota que mi interfaz es el vlan100), dependiendo de la versión de TVHeadEnd (3.4 o 3.9+) usando argumentos diferentes:

**M3U2HTS con TVHeadEnd 3.4**

Ejecuto el script y vemos cómo se generan cuatro directorios:

[code language="bash" light="true"] totobo tvheadend $ EPYTHON=python2.7 python m3u2hts.py -c utf-8 --iface vlan100 -r ../movistartv-canales.m3u OK totobo tvheadend $ ls -al total 36 drwxr-xr-x 6 luis luis 4096 ene 31 18:59 . drwxr-xr-x 3 luis luis 4096 ene 31 18:55 .. drwxr-xr-x 2 luis luis 4096 ene 31 18:59 channels drwxr-xr-x 2 luis luis 4096 ene 31 18:59 channeltags drwxr-xr-x 3 luis luis 4096 ene 31 18:59 epggrab drwxr-xr-x 2 luis luis 4096 ene 31 18:59 iptvservices -rwxr-xr-x 1 luis luis 11535 ene 31 18:54 m3u2hts.py [/code]

Copio los cuatro directorios al directorio de trabajo de TVHeadEnd (en mi caso en /etc), notar que esto solo hay que hacerlo la primera vez. Ah!, no olvides cambiar los permisos (mira el comando chown).

[code language="bash" light="true"] totobo tvheadend # /etc/init.d/tvheadend stop

totobo tvheadend # cd /etc/tvheadend/ totobo tvheadend # cp -R /home/luis/movistartv2xmltv/tvheadend/channels . totobo tvheadend # cp -R /home/luis/movistartv2xmltv/tvheadend/channeltags . totobo tvheadend # cp -R /home/luis/movistartv2xmltv/tvheadend/epggrab . totobo tvheadend # cp -R /home/luis/movistartv2xmltv/tvheadend/iptvservices .

totobo tvheadend # chown -R tvheadend:video /etc/tvheadend/ [/code]   **M3U2HTS con TVHeadEnd 3.9**

En mi caso tengo instalada la versión 3.9+. Una vez que realicé la instalación ejecuté "tvheadend start" una única vez para que se creara la estructura de directorios, después lo paré con "tvheadend stop". A continuación ejecuto m3u2hts para importar los canales de Movistar TV.

No dejar de leer la nota respecto a la conversión para la versión 3.9+ en el sitio de GitHub porque todavia es experimental. Ejecuto el script y vemos cómo se generan tres directorios:

[code language="bash" light="true"] ___IMPORTANTE: Elimino la '@' en las URL's de los canales multicast: totobo movistartv2xmltv $ sed -i "s/\/@/\//" movistartv-canales.m3u

___CONVIERTO .m3u A FORMATO TVHEADEND 3.9+ totobo movistartv2xmltv $ cd tvheadend/ totobo tvheadend $ EPYTHON=python2.7 python m3u2hts.py --newformat -c utf-8 --iface vlan100 -r ../movistartv-canales.m3u -o channel OK totobo tvheadend $ ls -al total 32 drwxr-xr-x 5 luis luis 4096 feb 8 12:32 . drwxr-xr-x 3 luis luis 4096 feb 1 20:25 .. drwxr-xr-x 4 luis luis 4096 feb 8 12:32 channel drwxr-xr-x 3 luis luis 4096 feb 8 12:32 epggrab drwxr-xr-x 3 luis luis 4096 feb 8 12:32 input

totobo tvheadend $ sudo cp -R channel/ epggrab/ input/ /etc/tvheadend totobo tvheadend $ sudo chown -R tvheadend:video /etc/tvheadend/ totobo tvheadend $ sudo chmod go-rwx -R /etc/tvheadend/input/ /etc/tvheadend/epggrab/ /etc/tvheadend/channel/ [/code]

Una vez que tengo los canales pasados a los directorios de TVHeadEnd ya puedo arrancarlo e irme a XBMC a ver cómo los muestra ya disponibles.

[code language="bash" light="true"] totobo tvheadend # /etc/init.d/tvheadend start [/code]

![tvheadlist](/assets/img/original/tvheadlist-1024x578.png){: width="730px" padding:10px }

Lo iconos los entrega TVHeadEnd porque él se los baja desde el servidor de Movistar TV, si te fijas en la lista de canales también obtuvo el lugar desde el cual bajarse el icono.

![tvheadendchannels](/assets/img/original/tvheadendchannels-1024x527.png){: width="730px" padding:10px }

 

Nota: he creado un contenedor Docker para ejecutar Tvheadend, ya está 100% operativo, échale un ojo, estos son los proyectos donde tienes todo lo necesario:

- Registry Hub de Docker ![luispa/base-tvheadend](/assets/img/original/){: width="730px" padding:10px }
- Conectado (Automatizado) con el proyecto en ![GitHub base-tvheadend](/assets/img/original/base-tvheadend){: width="730px" padding:10px }
- Relacionado con este otro proyecto en GitHub para ejecutarlo a través de FIG: ![GitHub servicio-tvheadend](/assets/img/original/servicio-tvheadend){: width="730px" padding:10px }

Si no conoces Docker, te dejo estos enlaces: [¿qué es Docker?](https://www.luispa.com/?p=874) y ![otros casos de uso de Docker](/assets/img/original/?p=172){: width="730px" padding:10px }

 

#### Segundo paso: descargar y activar el EPG

El siguiente paso es ejecutar el programa (sin argumentos) para descargar el EPG. **Nota:** en el fichero de configuración indicamos el nombre del fichero de salida y al llamarlo sin argumentos por defecto se dedica a bajarse el EPG. La primera vez lo ejecuto manualmente para verificar su funcionamiento e ir viendo el Log en paralelo.

[code language="bash" light="true"] totobo movistartv2xmltv $ export EPYTHON=python2.7 totobo movistartv2xmltv $ nohup ./tv_grab_es_movistar.py &amp; [/code]   Observo en paralelo el log

totobo movistartv2xmltv $ tail -f movistartv.log
2015-01-30 22:01:26,051 - movistarxmltv - INFO - Init. DEM=19 TVPACKS=[u'UTX6C', u'UTX8F'] ENTRY_MCAST=239.0.2.129:3937
2015-01-30 22:01:28,018 - movistarxmltv - INFO - Getting channels source for DEM: 19
2015-01-30 22:01:28,019 - movistarxmltv - INFO - Getting channels list from: 239.0.2.154
2015-01-30 22:13:40,107 - movistarxmltv - INFO - Init. DEM=19 TVPACKS=[u'UTX6C', u'UTX8F'] ENTRY_MCAST=239.0.2.129:3937
2015-01-30 22:13:41,569 - movistarxmltv - INFO - Getting channels source for DEM: 19
2015-01-30 22:13:41,570 - movistarxmltv - INFO - Getting channels list from: 239.0.2.154
2015-01-30 22:14:17,955 - movistarxmltv - INFO - Reading day 0
2015-01-30 22:14:17,955 - movistarxmltv - INFO - Reading day 1
2015-01-30 22:14:17,956 - movistarxmltv - INFO - Reading day 2
2015-01-30 22:14:17,956 - movistarxmltv - INFO - Reading day 3
2015-01-30 22:14:17,956 - movistarxmltv - INFO - Reading day 4
2015-01-30 22:14:17,957 - movistarxmltv - INFO - Reading day 5
2015-01-30 22:19:11,569 - movistarxmltv - INFO - Parsing 241_1643
2015-01-30 22:19:11,570 - movistarxmltv - INFO - Parsing 241_1040
2015-01-30 22:19:11,656 - movistarxmltv - INFO - Parsing 241_870
2015-01-30 22:19:16,302 - movistarxmltv - INFO - Parsing 241_1826
2015-01-30 22:19:16,302 - movistarxmltv - INFO - Parsing 241_1825
2015-01-30 22:19:16,302 - movistarxmltv - INFO - Parsing 241_1824
2015-01-30 22:19:16,363 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Gran Hermano Vip 2015: La casa en directo: Gran Hermano Vip 2015: La casa en directo
2015-01-30 22:19:18,257 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Gran Hermano Vip 2015: Última hora: Gran Hermano Vip 2015: Última hora
2015-01-30 22:19:18,310 - movistarxmltv - INFO - Parsing 241_1823
2015-01-30 22:19:20,094 - movistarxmltv - INFO - Parsing 241_875
2015-01-30 22:19:21,019 - movistarxmltv - INFO - Parsing 241_1643
2015-01-30 22:19:21,020 - movistarxmltv - INFO - Parsing 241_2287
2015-01-30 22:19:21,020 - movistarxmltv - INFO - Parsing 241_870
2015-01-30 22:19:22,699 - movistarxmltv - INFO - Parsing 241_871
2015-01-30 22:19:23,489 - movistarxmltv - INFO - Parsing 241_877
2015-01-30 22:19:23,519 - movistarxmltv - INFO - Parsing 241_1643
2015-01-30 22:19:23,520 - movistarxmltv - INFO - Parsing 241_1040
2015-01-30 22:19:23,534 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Ley y Orden: Unidad de Víctimas Especiales
2015-01-30 22:19:23,617 - movistarxmltv - INFO - Parsing 241_870
2015-01-30 22:19:24,015 - movistarxmltv - INFO - Parsing 241_1825
2015-01-30 22:19:24,015 - movistarxmltv - INFO - Parsing 241_1824
2015-01-30 22:19:24,638 - movistarxmltv - INFO - Parsing 241_1284
2015-01-30 22:19:24,766 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Óxido Nitroso: Comedia Negra
2015-01-30 22:19:24,852 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Piezas: Splintertime
2015-01-30 22:19:24,950 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Saturday Night Live: Tina Fey / Arcade Fire
2015-01-30 22:19:24,999 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Gran Hermano VIP: El debate: Gran Hermano VIP: El debate
2015-01-30 22:19:25,000 - movistarxmltv - INFO - Parsing 241_1823
2015-01-30 22:19:25,154 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Pioneros de la televisión: Ciencia ficción
2015-01-30 22:19:25,283 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Bob Esponja: La supervivencia de los idiotas / Plantado
2015-01-30 22:19:25,321 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: The Amazing Spider-Man 2: El poder de Electro
2015-01-30 22:19:25,335 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Bob Esponja: En la vida no hay nada gratis / Soy tu mayor fan
2015-01-30 22:19:25,445 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Tierras del monzón: Inundación
2015-01-30 22:19:25,529 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Togetherness: Día de familia
2015-01-30 22:19:25,553 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: El encantador de perros: Chicas playboy
2015-01-30 22:19:25,554 - movistarxmltv - INFO - Parsing 241_871
2015-01-30 22:19:25,587 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Togetherness: Dentro del episodio
2015-01-30 22:19:25,603 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: El encantador de perros: Los perros malos de la comedia
2015-01-30 22:19:25,663 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Informe Robinson: Carlos Sainz en Fórmula 1 / Cuerpos al límite
2015-01-30 22:19:25,720 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Cine estreno: Nueva vida en Nueva York
2015-01-30 22:19:25,720 - movistarxmltv - INFO - Parsing 241_2282
2015-01-30 22:19:25,720 - movistarxmltv - INFO - Parsing 241_577
2015-01-30 22:19:26,163 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Planeta Calleja: David Bisbal
2015-01-30 22:19:26,216 - movistarxmltv - INFO - Parsing 241_875
2015-01-30 22:19:27,789 - movistarxmltv - INFO - Parsing 241_2280
2015-01-30 22:19:27,790 - movistarxmltv - INFO - Parsing 241_844
2015-01-30 22:19:28,503 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: J.A.G.: Alerta Roja
2015-01-30 22:19:28,563 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: J.A.G.: Alerta Roja
2015-01-30 22:19:28,635 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Futbola: Puebla-Cruz Azul

:

2015-01-30 22:29:47,378 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Reportaje Sol Música: Miguel Campello
2015-01-30 22:29:47,490 - movistarxmltv.tva.TvaParser - INFO - Grabbing episode in: Reportaje Sol Música: Miguel Campello
2015-01-30 22:29:47,659 - movistarxmltv - INFO - Parsing 241_717
2015-01-30 22:29:51,507 - movistarxmltv - INFO - Grabbed 192 channels and 24411 programmes

Que no te extrañe, tarda unos 30 minutos en un ![servidor (Intel Core i5)](/assets/img/original/?p=725) (también probé a hacerlo en el linux del receptor VU+ ultimo pero tardaba unos 60 minutos){: width="730px" padding:10px }, así que he decidido usar mi servidor casero.

El fichero resultante: /home/luis/movistartv2xmltv/movistartv-guia.xml ocupa unos 15MB:

![Captura de pantalla 2015-01-30 a las 22.58.26](/assets/img/original/Captura-de-pantalla-2015-01-30-a-las-22.58.26-1024x416.png){: width="730px" padding:10px }

Ahora que tenemos el EPG en /home/luis/movistartv2xmltv/movistartv-guia.xml se lo enviamos al daemon TVHeadEnd a través de un **socket**, pero antes debo instalar el programa socat y configurar TVHeadEnd para que acepte la información EPG a través de un interfaz externo (socket xmltv.sock), conectamos con el programa a través del interfaz Web y modificamos Configuración-> Channel/EPG-> EPG Grabber-> Interfaz Externo

[code language="bash" light="true"] totobo epggrab # emerge -v socat [/code]

![xmltv-sock](/assets/img/original/xmltv-sock.png){: width="730px" padding:10px }

Por fin podemos mandar el fichero EPG a TVHeadEnd on el comando siguiente:

[code language="bash" light="true"] # cat /home/luis/movistartv2xmltv/movistartv-guia.xml | socat - UNIX-CONNECT:/etc/tvheadend/epggrab/xmltv.sock [/code]   Al cabo de un minuto empezaremos a ver cómo aparece el EPG en los canales en XBMC.

![movistarepg](/assets/img/original/movistarepg-1024x578.png){: width="730px" padding:10px }  

#### Automatizar todo el proceso

Hemos visto todo el proceso paso por paso, ahora podemos automatizar la parte final, releer el EPG y enviárselo a TVHeadEnd, en mi caso lo hago a través del cron, creo un pequeño script y lo instalo en el directorio de ejecución diaria (/etc/cron.daily).

[code language="bash" light="true"] #!/bin/bash #

# Preparo el PATH export PATH=/usr/sbin:/usr/bin:/sbin:/bin:.

# CWD al directorio donde he instalado movistartv2xmltv cd /home/luis/movistartv2xmltv

# Ejecuto movistartv2xmltv (tarda aprox. 30 min) # # Crea el fichero: /home/luis/movistartv2xmltv/movistartv-guia.xml # EPYTHON=python2.7 ./tv_grab_es_movistar.py

# # Mando a TVHeadEnd el fichero generado # sync &amp;&amp; sleep 5 cat /home/luis/movistartv2xmltv/movistartv-guia.xml | socat - UNIX-CONNECT:/etc/tvheadend/epggrab/xmltv.sock [/code]  

## Nota sobre Routing y resolución DNS

El tráfico hacia los servidores de Movistar TV que se origina desde el daemon TVHeadEnd o desde los programas recolectores (ej: movistartv2xmltv, m3u2hts.py) debe ser enrutado correctamente hacia la VLAN2 de Movistar. Además, las consultas "DNS" que realice el programa movistartv2xmltv.py deben ir al DNS Server de Movistar TV (172.26.23.3).

Fácil decirlo pero puede ser complicado hacerlo, de hecho si no lo tienes bien configurado puede darte problemas como los scripts dando timeout o algunas cosas funcionen y otras no (por ejemplo, que sí descargues el EPG pero los iconos no puedan ser descargados por TVHeadEnd).

En mi caso lo tengo resuelto porque he ![sustituido el router de Telefónica por un equipo linux](/assets/img/original/?p=266){: width="730px" padding:10px } que se encarga de todo, en ese apunte encontrarás documentación relacionada con el routing, y además he añadido lo siguiente en la configuración de BIND del equipo:

   zone "svc.imagenio.telefonica.net" in {
        type forward;
        forwarders { 172.26.23.3; };
        forward only;
   };
   zone "tv.movistar.es" in {
        type forward;
        forwarders { 172.26.23.3; };
        forward first;
   };
