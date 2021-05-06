---
title: "Movistar TV: Video bajo demanda con router Linux"
date: "2014-10-18"
categories: apuntes
tags: linux movistar router television
excerpt_separator: <!--more-->
---

![Movistar Fusión Fibra + TV + VoIP con router Linux](/assets/img/original/?p=266)". Aquí me ocupo en detalle de la configuración de los "Videos bajo demanda". Desde el Decodificador es posible seleccionar y ver videos bajo demanda en dos situaciones: 1) reproducir una grabación o 2){: width="730px" padding:10px } reproducir un video, serie, etc. desde la parrilla de Movistar TV, pero para que esto funcione tu Router debe soportar una cosa que se llama "Full Cone NAT" y como Linux no lo implementa en el kernel entonces no es sencillo hacerlo funcionar, así que he dedicado un artículo entero a este concepto.

## Full Cone NAT vs "netfilter rtsp"

Hay varios tipos de NAT y no es el objeto describirlos aquí, lo que sí que tienes que tener en cuenta es que necesitas usar Full Cone NAT (o algo parecido) para poder ver los videos bajo demanda (si mirás la configuración del router que te deja Movistar verás que lo trae activo en el interfaz IPTV, vlan2). ¿Porqué hace falta? pues porque los Decos solicitan los videos mediante el protocolo RTSP a un servidor X pero el que realmente entrega el stream MPEG2(TS) es otro servidor Y completamente distinto, enviando tráfico desde una IP distinta y desconocida para el router, tráfico que se descartará si no tenemos algo "especial" configurado.

![pequeño pero potente paquete de software libre](/assets/img/original/) desarrollado para resolver precisamente este problema, identifica las peticiones de video bajo demanda (flujos RTSP){: width="730px" padding:10px } e instala lo necesario en el kernel para aceptar el tráfico cuando empiece a llegar.

![vod](/assets/img/original/vod-978x1024.png){: width="730px" padding:10px }

## ¿Cómo funciona?

Sigamos el gráfico anterior. Cuando pulsas el botón "Movistar TV" en tu mando, el Deco busca al servidor que gestiona la parrilla, lo primero que hace es enviar una consulta al DNS Server (1) para preguntar quién es el servidor que gestiona la parrilla y los menús. Una vez que consigue su dirección establece un diálogo con él (2) y es ahí donde recibes y ves los menús en tu tele. Navegando por los menús y una vez seleccionas una grabación, serie o película y pulsas en "Ver", el deco solicita el video a otro servidor distinto que llamo gestor de videos bajo demanda (3) mediante el protocolo RTSP. En esta última petición se envía un paquete SETUP que contiene el número del puerto por el que el Deco se quedará escuchando para recibir el futuro video. Mientras el deco espera, el gestor de videos bajo demanda solicita (4) que uno de los servidores que llamo MPEG Servers envíe de vuelta el stream de video MPEG (5) al puerto que se solicitó en el paquete SETUP.

![captura_vod](/assets/img/original/captura_vod1-1024x578.png){: width="730px" padding:10px }

En el gráfico de captura anterior vemos como el Deco solicita que se envíe el video al puerto 27171. El servidor que hará de emisor del stream MPEG será distinto y empezará a enviar tráfico MPEG-2 TS (Transport Stream) en modo Unicast a la IP visible del router (Linux) al puerto solicitado (27171 en este ejemplo). El router (Linux) deberá instalar una regla dinámica para que todo tráfico recibido en su IP exterior y ese puerto se conmute hacia el Deco solicitante y mismo puerto.

## ¿Cómo lo implemento?

Para conseguir que nuestro Linux haga todo esto necesitamos activar "conntrack" en el Kernel e instalar [el programa "Netfilter RTSP"](http://mike.it-loops.com/rtsp/), que a fecha 18/Oct/2014 estaba en la versión 3.7-v2. Muy importante: verás que hay que aplicarle un ![**pequeño parche**](/assets/img/original/4QZ2r7eV){: width="730px" padding:10px } para que funcione con Movistar TV.

![Movistar Fusión Fibra + TV + VoIP con router Linux](/assets/img/original/?p=266){: width="730px" padding:10px }"

**Nota 2**: Estas pruebas están hechas con el kernel 3.17.0 y en Gentoo **"NO"** he usado el paquete net-firewall/rtsp-conntrack-3.7, dado que instala unav ersión más antigua. Descargué los fuentes originales y los compilé de forma manual.

1.- **Descarga, parchea, compila e instala el programa Netfilter RTSP**:

 
___DESCARGA___
# mkdir /tmp/rtsp
# cd /tmp/rtsp
# wget http://mike.it-loops.com/rtsp/rtsp-module-3.7-v2.tar.gz
:
# tar xvfz rtsp-module-3.7-v2.tar.gz
# rm rtsp-module-3.7-v2.tar.gz

___PATCH___
Copia/Pega desde pastebin el parche: http://pastebin.com/4QZ2r7eV 
Crea un fichero por ejempo en: /tmp/rtsp-3.7-v2.patch

# patch < /tmp/rtsp-3.7-v2.patch

___COMPILA___
# make debug
:

___INSTALA MODULOS KERNEL___
# make modules_install
:
# ls -al /lib/modules/3.17.0-gentoo/extra/
total 36
drwxr-xr-x 2 root root 4096 oct 18 16:37 .
drwxr-xr-x 5 root root 4096 oct 18 16:41 ..
-rw-r--r-- 1 root root 13305 oct 18 16:41 nf_conntrack_rtsp.ko
-rw-r--r-- 1 root root 11369 oct 18 16:41 nf_nat_rtsp.ko
 

Empleo la opción "debug" al hacer el make. Te recomiendo que lo uses para poder enterarte de lo que está pasando en el log del kernel.

2.- **Cargamos el nuevo módulo en el Kernel**

Una vez terminada la compilación e instalación anterior ya puedes cargar los módulos en el Kernel:

 
# modprobe nf_conntrack_rtsp  (Este módulo se encarga de "detectar" el SETUP RTSP)
# modprobe nf_nat_rtsp        (Este módulo se encarga de establecer la asociación (nat))
 
# sysctl -w net.netfilter.nf_conntrack_helper=1

Te vuelves a tu Deco, entras en el menú Movistar TV, busca una grabación y pula en "ver", debería funcionar. Puedes comprobar con el comando dmesg que la asociación es correcta, algo parecido a lo siguiente:

 
# dmesg
[358463.389458] nf_conntrack_rtsp v0.7.2 loading
[358463.389462] port #0: 554
[359189.716507] nf_nat_rtsp v0.7.2 loading
:
[359263.569596] conntrackinfo = 2
[359263.576080] IP_CT_DIR_REPLY
[359263.583559] IP_CT_DIR_REPLY
[359263.585568] found a setup message
[359263.585577] tran='Transport: MP2T/H2221/UDP;unicast;client_port=27336'
[359263.585596] lo port found : 27336
[359263.585597] udp transport found, ports=(0,27336,27336)
[359263.585600] expect_related 0.0.0.0:0-10.214.XX.YY:27336
[359263.585601] NAT rtsp help_out
[359263.585603] hdr: len=9, CSeq: 3
[359263.585604] hdr: len=25, User-Agent: MICA-IP-STB
[359263.585605] hdr: len=53, Transport: MP2T/H2221/UDP;unicast;client_port=27336
[359263.585606] hdr: Transport
[359263.585608] stunaddr=10.214.XX.YY (auto)
[359263.585610] using port 27336
[359263.585613] rep: len=53, Transport: MP2T/H2221/UDP;unicast;client_port=27336
[359263.585614] hdr: len=14, x-mayNotify:
[359263.624565] IP_CT_DIR_REPLY
[359263.718991] IP_CT_DIR_REPLY
[359263.992779] IP_CT_DIR_REPLY
[359264.285029] IP_CT_DIR_REPLY
 

## Instalación final

Una vez lo tengas todo funcionando te recomiendo que recompiles sin "debug", vuelvas a instalar los módulos y programes su carga durante el arranque del equipo

Recompila e instala

 
# cd /tmp/rtsp
# make clean
# make
# make modules_install   (quedan copiados en /lib/modules/3.17.0-gentoo/extra/)
:
 

**Nota**: Recuerda que si compilas e instalas un nuevo Kernel, tendrás que recompilar e instalar de nuevo estos dos módulos.

Programa su carga durante el boot, añade lo siguiente final del fichero /etc/conf.d/modules

:
modules="nf_conntrack_rtsp"
modules="nf_nat_rtsp"

Acuérdate de ejecutar lo siguiente en algún momento durante el arranque

sysctl -w net.netfilter.nf_conntrack_helper=1

## Monitorizar

Dejo aquí algunos comandos útiles que te pueden servir para monitorizar qué está pasando:

Ver qué ocurre (debes compilar con opción debug)

 
# dmesg 
 

Ver qué flujos UDP tienes contra tu IP fija en la vlan 2. Recuerda cambiar 10.214.XX.YY por tu ip), en Gentoo instala las conntrack tools con "# emerge -v conntrack-tools"

 
# /usr/sbin/conntrack -L | grep 10.214.XX.YY | grep udp;
 

Comprobar si se creo NAT hacia IP de un Deco concreto (.200 en el ejemplo)

 
# netstat -nat -n | grep 192.168.1.200
Se vería algo así:
:
udp 17 29 src=172.26.83.137 dst=10.214.XX.YY sport=48440 dport=27645 [UNREPLIED] src=192.168.1.203 \
         dst=172.26.83.137 sport=27645 dport=48440 mark=0 use=1
:
