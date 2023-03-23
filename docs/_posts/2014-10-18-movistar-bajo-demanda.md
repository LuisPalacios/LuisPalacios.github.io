---
title: "Video bajo demanda para Movistar"
date: "2014-10-18"
categories: linux
tags: movistar router cone nat iptables television
excerpt_separator: <!--more-->
---

![logo linux router](/assets/img/posts/logo-linux-rtsp.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

Los streams de video IPTV que utiliza Movistar son de dos tipos: los canales normales (Multicast/UDP) y los videos bajo demanda (Unicast/UDP). En este apunte describo qué hay que hacer en el [router Linux para Movistar]({% post_url 2014-10-05-router-linux %}) para que funcionen los "Videos bajo demanda". Utilizan el protocolo `RTSP` que necesita que nuestro router soporte **Full Cone NAT**. 

Los Decos solicitan los videos mediante RTSP a su servidor de control pero el video se enviá desde otro servidor distinto, con una IP desconocida, por lo que si no hacemos nada se descartará el tráfico del video. Veamos cómo resolverlo.


<br clear="left"/>
<!--more-->

## Full Cone NAT vs "netfilter rtsp"

Hay varios tipos de NAT y no es el objeto describirlos aquí, lo que sí que tienes que tener en cuenta es que necesitas usar **Full Cone NAT** para poder ver los videos bajo demanda. En los routers originales que nos deja Movistar podemos ver que tiene Full cone nat activo en el interfaz IPTV (vlan2).

Como decía al principio, los Decos solicitan los videos mediante el protocolo RTSP a su servidor de control pero el que entrega el stream MPEG2(TS) es otro servidor distinto, desde una IP distinta y desconocida para tu router, por lo que se descartará. Ahí es donde entra el Full Cone NAT. Fue desarrollado para resolver precisamente este problema, identificar las peticiones de video bajo demanda (flujos RTSP).

{% include showImagen.html
    src="/assets/img/original/vod-978x1024.png"
    caption="vod"
    width="600px"
    %}

<br/> 

### ¿Cómo funciona?

Sigamos el gráfico anterior, por ejemplo seleccionando una Peli. Cuando pulsas el botón "Movistar TV" en tu mando, el Deco busca al servidor que gestiona la parrilla, lo primero que hace es enviar una consulta al DNS Server (1) para preguntar quién es el servidor que gestiona la parrilla y los menús.

Una vez que consigue su dirección establece un diálogo con él (2) y es ahí donde recibes y ves los menús en tu tele. Navegando por los menús y una vez seleccionas una grabación, serie o película y pulsas en "Ver", el deco solicita el video a otro servidor distinto que llamo gestor de videos bajo demanda (3) mediante el protocolo RTSP.

Se origina con un paquete SETUP que contiene el número del puerto por el que el Deco se quedará escuchando para recibir el futuro video. Mientras el deco espera, el gestor de videos solicita (4) que uno de los servidores (que llamo MPEG Servers) envíe el stream de video MPEG (5) al puerto que se solicitó en el paquete SETUP.

{% include showImagen.html
    src="/assets/img/original/captura_vod1-1024x578.png"
    caption="Captura de una sesión de video bajo demanda"
    width="600px"
    %}

En el gráfico de captura anterior vemos como el Deco solicita que se envíe el video al puerto 27171. El servidor que hará de emisor del stream MPEG será distinto y empezará a enviar tráfico MPEG-2 TS (Transport Stream) en modo Unicast/UDP a la IP visible del router (Linux), al puerto solicitado (27171).

Para que el router (Linux) no tire el tráfico hay que instalar una regla de tipo DNAT para que se conmute hacia el Deco solicitante.

<br/>

### ¿Cómo lo implemento?

En el caso de linux vamos a utilizar **netfilter rtsp** y lo vamos a hacer instalando un pequeño código de software libre que se llama **rtsp-conntrack**, añadiendo un pequeño parche necesario para que funcione correctamente. Estas pruebas las hice con el kernel 3.17.0 en Gentoo, descargué los fuentes originales, los parcheé, compilé e instalé. He dejado todo en [mi repositorio rtsp-linux en github](https://github.com/LuisPalacios/rtsp-linux).

- Instalación del módulo, fíjate que uso "debug" al hacer el make. Durante la fase de pruebas es importante para enterarte de lo que está pasando (log del kernel). Más adelante recompilo sin dicha opción.

```console
 
___DESCARGA___
# cd ~/
# wget https://github.com/LuisPalacios/rtsp-linux/archive/refs/heads/master.zip
# unzip master.zip
# rm master.zip
# cd ~/rtsp-linux-master

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
```

- Cargo el nuevo módulo en el Kernel

Una vez terminada la compilación e instalación anterior ya puedes cargar los módulos en el Kernel:

```console 
# modprobe nf_conntrack_rtsp  (Este módulo se ejecuta al "detectar" el SETUP RTSP)
# modprobe nf_nat_rtsp        (Este módulo se encarga de establecer la asociación (dnat))
 
````

- A continuación tenemos que configurar `conntrack` para que llame a los módulos del kernel. Hay dos formas de hacerlo, dependiendo de qué versíon del kernel tengas: 

- Automático: `sysctl -w net.netfilter.nf_conntrack_helper=1`
- Manual: `iptables -t raw -A PREROUTING -p tcp --dport 554 -j CT --helper rtsp`

El método automático solo se puede usar hasta el kernel 5, mientras que el manual puede usarse con cualquier kernel. El método que recomiendo es el manual, de hecho la recomendación completa es: 

```console
iptables -t raw -A PREROUTING -p tcp --dport 554 -j CT --helper rtsp
iptables -A FORWARD -p tcp --dport 554 -m state --state RELATED,ESTABLISHED
```

Estas reglas asumen que la conexión RTSP usa TCP y que el servidor está escuchando en el puerto 554 (que es el caso). El primer comando utiliza el target `CT` para asignar el helper `rtsp` a las conexiones RTSP entrantes. El segundo comando hace posible que estas conexiones que ya estuviesen establecidas y relacionadas funcionen a través del firewall.

- Te vuelves a tu Deco, entras en el menú Movistar TV, busca una grabación y pula en "ver", debería funcionar. Puedes comprobar con el comando dmesg que la asociación es correcta, algo parecido a lo siguiente:

```console
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
```

<br/>

### Instalación final

Una vez lo tengas todo funcionando te recomiendo que recompiles sin "debug", vuelvas a instalar los módulos y programes su carga durante el arranque del equipo. 

Recompila e instala

```console
# cd /tmp/rtsp
# make clean
# make
# make modules_install   (quedan copiados en /lib/modules/3.17.0-gentoo/extra/)
:
```

**Nota**: Recuerda que si compilas e instalas un nuevo Kernel, tendrás que recompilar e instalar de nuevo estos dos módulos.

Carga durante el boot, en gentoo hay que añadir lo siguiente al fichero `/etc/conf.d/modules` (en Gentoo)

```console
:
modules="nf_conntrack_rtsp"
modules="nf_nat_rtsp"
```

En Ubuntu, añade al fichero `/etc/modules`

```console
nf_nat_rtsp
```

No olvides configurar `conntrack` para que llame a los módulos del kernel, tienes dos formas distintas de hacerlo como veíamos arriba, acuérdate de ejecutarlo en algún momento durante el arranque de tu equipo:

- Kernel <= 5 : `sysctl -w net.netfilter.nf_conntrack_helper=1`
- Kernel >= 6 : `iptables -t raw -A PREROUTING -p tcp --dport 554 -j CT --helper rtsp`

<br/>

### Monitorizar

Dejo aquí algunos comandos útiles que te pueden servir para monitorizar qué está pasando:

- Ver qué ocurre (compilar con opción debug)

```console
# dmesg 
```

- Ver qué flujos UDP tienes contra tu IP fija en la vlan 2. Recuerda cambiar 10.214.XX.YY por tu ip), en Gentoo instala las conntrack tools con "# emerge -v conntrack-tools"

```console
# /usr/sbin/conntrack -L | grep 10.214.XX.YY | grep udp;
```

- Comprobar si se creo NAT hacia IP de un Deco concreto (.200 en el ejemplo)

```console
# netstat -nat -n | grep 192.168.1.200
:
udp 17 29 src=172.26.83.137 dst=10.214.XX.YY sport=48440 dport=27645 [UNREPLIED] src=192.168.1.203 \
         dst=172.26.83.137 sport=27645 dport=48440 mark=0 use=1
:
```

<br/>

### Referencias

- Mi repositorio [rtsp-linux](https://github.com/LuisPalacios/rtsp-linux).
