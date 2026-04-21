---
title: "Media Center Pi+KODI/XBMC"
date: "2015-01-31"
categories: ["tv"]
tags: ["media","center","movistar","raspberry","xbmc","pi","linux","kodi"]
draft: false
cover:
  image: "/img/posts/logo-kodi-pi.png"
  hidden: true
---

<img src="/img/posts/logo-kodi-pi.png" alt="logo Pi Kodi" width="150px" height="150px" style="float:left; padding-right:25px"  />

Por el 2015 andaba yo buscando un Media Center casero de siguiente generación conectado a mi TV, un “pata negra” que no sea demasiado caro, que pueda conectarse por cable ethernet a un “mundo” de múltiples fuentes que incluya música, fotos, videos familiares o películas o series (tanto SD o HD) y que sea capaz de reproducir TV en tiempo real (SD o HD), que soporte bitrates altos (~40Mbps) independiente de cual sea la fuente (antena, satélite, internet).

<br clear="left"/>
<!--more-->

The winner was (and still is) the Raspberry Pi with OpenELEC software. Han pasado por mi mano la Pi1, Pi2 y Pi3, mismos precios y a cada cual más moderna y potente, así que a pesar de que dejo documentadas cosas sobre las antiguas te I recommend irte por supuesto a la última. Para la Pi1 probé hasta la versión [“OpenElec](http://openelec.tv/) 4.0.5”, con la Pi2 y Pi3 las versiones «OpenElec 6.0.3 -> Kodi v15 Isengard» y «OpenElec 7.0B2 -> Kodi v16 Jarvis». También proble «[OSMC](https://osmc.tv/)» aunque me he quedé con OpenElec (principalmente por el Skin, no me convence el de OSMC).

In April 2017, [LibreElec](https://libreelec.tv/), a fork of OpenElec, was born and since then I have stuck with it (LibreElec).

| Why don't I talk about WiFi?: Pues porque busco el mejor rendimiento y eliminar posibles puntos de fallo o empeoramiento de las condiciones de ancho de banda. Una vez que pruebes y re-pruebes todo y estés convencido de que va perfecto, entonces es cuando deberías añadir la "variable" Wifi y por supuesto probar de nuevo. |

At home I still do not use WiFi but he probado recientemente con la Wifi embebida en la Pi3 y funciona bien con streams HD, eso sí, siempre que esté cerca del punto de acceso y no haya ni muros, ni ladrillos por medio ni interferencias cercanas.

<br/>

### **The Hardware**

Depende de cual compres, Pi1,2,3; here you have la lista de sus especificaciones:

- Raspberry Pi Model B+ 1.2 (versión 1)
  - Broadcom BCM2835 System on a Chip (SoC)
  - CPU: ARM1176JZF-S 700 MHz
  - GPU: VideoCore IV
  - Memoria: 512 MB
- Raspberry Pi 2 Model B v1.1 (versión 2)
  - Broadcom BCM2836 System on a Chip (SoC)
  - CPU: ARM Cortex-A7 quad-core 900MHz (~6x versión 1)
  - GPU: VideoCore IV (no cambia)
  - Memoria: 1GB LPDDR2 SDRAM (2x versión 1)
  - Compatibilidad total con la Raspberry Pi 1
- Raspberry Pi 3 Model B v1.1 (versión 2)
  - SoC: Broadcom BCM2837
  - CPU: 4× ARM Cortex-A53, 1.2GHz
  - GPU: Broadcom VideoCore IV
  - RAM: 1GB LPDDR2 (900 MHz)
  - Red: 10/100 Ethernet, 2.4GHz 802.11n wireless
  - Bluetooth: Bluetooth 4.1 Classic, Bluetooth Low Energy

**Comunes:**

"Cosas" que tienes que comprar adicionales

- Transformador de 5.25V y 2.5A
- Cable USB para el transformador
- Caja VESA transparente con ventilación
- Juego de disipadores. Solo hacen falta 2 disipadores:
- 1 Disipador para el SoC (CPU) de 13x13x5mm
- 1 Disipador para la LAN de 10x10x5mm
- Tarjeta Micro-SD (mínimo 8GB Clase 10)

Pensé en usar un microventilador pero me ha ido muy bien con solo los disipadores, así que al final no los he instalado. Incluso con la Pi3 no instalo ni los disipadores, porque para Kodi y el uso que le doy va sobrada... En cualquier caso, si necesitas ventilador, ve a por uno de estos: 15x15x4,5mm, Voltaje: 3.3v-5v, Potencia (Amps): 0.06A, Velocidad: 1300 rpm, Airflow (CFM): 0.42, Max presión del aire: 15.7Pa. He leído por ahí que es posible instalar un sensor de temperatura y bajo demanda activar el ventilador desde un script en phyton.

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-11.jpg" alt="Raspberry PiB+ 1.2" width="600px" />
  <div class="image-caption">Raspberry PiB+ 1.2</div>
</div>

<br/>

### **The Software**

Todos los paquetes de software que se ejecutan en la Raspberry son de software libre y hay múltiples distribuciones. En el área de Media Center tenemos dos: raspbmc (ahora OSMC), openelec y ahora LibreElec. Tras múltiples pruebas y pasar por OpenElec, ahora utilizo **LibreElec**.

- Proyecto [LibreElec](https://libreelec.tv/)
- Proyecto [OpenELEC](http://openelec.tv/) y enlace a la raíz del proyecto [OpenELEC en GitHub](https://github.com/OpenELEC) y en particular a [OpenElec.tv](https://github.com/OpenELEC/OpenELEC.tv)
- [Wiki](http://wiki.openelec.tv/index.php/Main_Page) de OpenELEC y [documentación](http://wiki.openelec.tv/index.php/Development_workflow) para compilar desde los fuentes (por si quieres trastear y cross-compilar directamente desde GitHub, interesante aprendizaje :-)).

<br/>

**IMPORTANT**

| A continuación vas a leer la documentación original sobre cómo grabar las imágenes, pero más adelante descubrí un método mucho mejor, así que no dejes de leer la sección donde I recommend encarecidamente **grabar las imágenes con [balenaEtcher](https://www.balena.io/etcher/)**. |

<br/>

#### Format the SD card

Necesitas una tarjeta SD, I recommend que sea al menos de 8GB y Clase 10 o superior. Puedes formatearla con el programa [SDFormatter](https://www.sdcard.org/downloads/formatter_4/). (que es el que yo uso para Mac)

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-12.png" alt="sdformatter" width="600px" />
  <div class="image-caption">sdformatter</div>
</div>

**Raspberry Pi Versión 1: "OpenElec 4.0.5" desde NOOBS**

Esta opción usa la instalación desde NOOBS, un paquete preparado por la gente de Raspberry directamente y dejará instalada la versión 4.0.5 de "openelec" que incluye XBMC 13.1 "Ghotam". Es la versión que mejor me ha funcionado en la Raspberry Pi Model B+ 1.2 (Versión 1). Estos son los pasos realizados en mi Mac:

- Descargar el ZIP de la versión [1.3.12 de NOOBs](http://www.raspberrypi.org/downloads/). Note: para la nueva Raspberry Pi versión 2 necesitas que sea versión 1.3.12 o superior. Por otro lado, te I recommend descargar y usar el torrent.

- Descomprimir el archivo NOOBS_v1_3_12.zip

- Arrastrar y copiar todo el contenido dentro del directorio hacia la raíz de la tarjeta SD

- Desmonta el volumen de la Micro SD, ya está lista para usarse en la Raspberry

- Insertar la Micro SD en la Raspberry Pi B+, I recommend que conectes un "teclado y ratón USBs" para ejecutar NOOBS. Conectar el cable de potencia, HDMI, etc.. y arránca el equipo (**Primer boot NOOBS**)

Aparecerá una ventana con un listado de los sistemas operativos que puedes instalar, seleccionar "openelec" y clic en "install". Automáticamente se reformatea/instala en la misma SD la versión de Openelec.

**Raspberry Pi Versión 2 o 3: Ejemplo con "OpenElec 5.0.8" desde OpenELEC**

Para esta opción vamos a descargar la imagen directamente desde OpenElec, describo cómo instalé esta versión concreta, pero el proceso es el mismo para futuras versiones:

Note: Con Pi 2 o 3 se soportan bitrates >40Mbps con muchísimo menor consumo de CPU, ahora bien, de ahí (40-45Mbps) no pasa sin sufrir microcortes y es debido a que el chip ethernet LAN9154 emplea el bus USB. En mi caso 99.99% de mi contenido va sobrado con dicho rendimiento (TV 1080 y videos en 1080).

- Descargar la imagen [OpenELEC 5.0.8 (arm) Diskimage](http://releases.openelec.tv/OpenELEC-RPi2.arm-5.0.8.img.gz) desde la sección RaspberryPi-2 Builds en el sitio de [OpenELEC](http://openelec.tv/get-openelec).

- Descomprimir: gunzip OpenELEC-RPi2.arm-5.0.8.img.gz

- Insertar la tarjeta que se montará como “NO NAME”.

- Averiguar device (resultó ser /dev/disk5): df -h

- Desmontar el volumen: sudo diskutil unmount /dev/disk5s1

- Grabar: sudo dd if=OpenELEC-RPi2.arm-5.0.8.img of=/dev/rdisk5 bs=4194304

**Raspberry Pi Versión 3: Ejemplo con "LibreElec"**

- Descargo el [LibreElec SD USB Creator](https://libreelec.tv/downloads/)
- Ejecutar el programa y seguir cuatro sencillos pasos

<img src="/img/posts/2015-01-31-media-center-09.png" alt="" width="600px" style="display: block; margin: 0 auto;" />

<br/>

### Recommendation (updated 2021)

I recommend encarecidamente **grabar las imágenes con [balenaEtcher](https://www.balena.io/etcher/)**, es un programa que funciona genial y no he tenido ningún problema con él.

<img src="/img/posts/2015-01-31-media-center-01.png" alt="" width="600px" style="display: block; margin: 0 auto;" />

<br/>

### Booting the "homemade" Media Center

Una vez que hemos "quemado" la memoria la colocamos en la Raspberry Pi y hacemos Boot. Al arrancar realiza un proceso automático (que incluye un reboot) donde se redimensiona la partición de la Micro-SD y se ejecuta un asistente para la configuración básica de XBMC/KODI. En la Raspberry versión 1 notarás que el interfaz es lento, es normal, tendrás que activar el overclocking más adelante.

Parámetros mínimos que configuro en mi caso. Debido a los diferentes Skins indico el lugar donde puedes encontrarlo...

```conf
:
 Parámetros regionales: Spanish
 Nombre del equipo: TV-Dormitorio
 Dirección IP: En mi caso la recibe vía DHCP
 Servicios: En mi caso activo ambos: SAMBA y SSH
:

Sistema
 Openelec/LibreElec
  Sistema: Teclado, Disposición de teclas: es
  Red: Servidor de hora (NTP): 192.168.1.1
 Ajustes
  Apariencia:
   Skin:
    Activar noticias RSS: ( )
   Internacional:
    Región: España 24h
    País del uso horario: Spain, Europe/Madrid
 Sistema
  Hardware de video
    Resolución: Máxima soportada por mi monitor
    Calibración de video: Uso Overscan para calibrar perfectamente la pantalla
 Servicios
  General
   Nombre del dispositivo: TV-Dormitorio (lo hago coincidir con el nombre del equipo)
  Control remoto:
   Permitir que los programas de este equipo controlen XBMC: (x)
   Permitir que los programas de otro equipo controlen XBMC: (x)
:
```

<br/>

#### MPEG-2 and VC1 license installation

La Raspberry cuenta con soporte para codecs MPEG2 y VC1, pero están deshabilitados por defecto, si los necesitas (como en mi caso para ver los streams SD de la TV, o para reproducir .vob’s extraídos de DVD’s o videos familiares en ese formato) puedes [adquirir las licencias a través de su tienda](http://www.raspberrypi.com/). Note: Si no lo haces e intentas reproducir esas fuentes entonces solo tendrás el audio.

Para adquirir la licencia, conecta vía SSH con tu raspberry como root, averigua el número de serie de la cpu, adquire la licencia para luego instalarla en el fichero config.txt

```shell
bolica ~ $ ssh -l root rasp-dormitorio.tudominio.com
 :
TV-Dormitorio:~ # cat /proc/cpuinfo
:
Serial      : 000000005771f8a3
```

Cuando pases por la tienda para comprar la licencia y tengas el número podrás instalarla dentro del fichero config.txt, mira un ejemplo donde indico el número de licencia para Mpeg-2

```shell
 bolica ~ $ ssh -l root rasp-dormitorio.tudominio.com
 :
 TV-Dormitorio:~ #
 TV-Dormitorio:~ # mount -o remount,rw /flash
 TV-Dormitorio:~ # cd /flash
 TV-Dormitorio:/flash #  nano config.txt
 :
 # decode_MPG2=0x00000000
 decode_MPG2=0x12345678
 # decode_WVC1=0x00000000
 # decode_DTS=0x00000000
 # decode_DDP=0x00000000
 ---------------------------<<< Salvamos con CTRL-O, CTRL-X y rearrancamos
 TV-Dormitorio:~ # reboot
```

<br/>

### Configuring XBMC/KODI and its sources

Este paso es muy personal, porque cada uno tendrá distintas fuentes con distintos protocolos de acceso. Describo a continuación las que utilizo en mi caso:

<br/>

#### NAS with videos, photos and music

En mi caso tengo una NAS QNAP en la dirección 192.168.1.2 y comparto la raiz de mi contenido multimedia usando el protocolo NFS. Aunque se configura vía web, ésta es la línea en el /etc/exports:

```conf
"/share/MD0_DATA/Multimedia" *(ro,async,no_root_squash,insecure)
```

La razón de usar NFS es que consume menos en la raspberry y es más rápido. Desde XBMC/KODI y las áreas de video, música e imágenes añadir los directorios con el recurso "Network Filesystem (NFS)"

- Note: Cuando seleccionas el recurso "Network Filesystem (NFS)" lo normal es que aparezca la dirección IP de tu servidor NFS dado que XBMC/KODI envía un broadcast en UDP intentando "descubrir" los servidores NFS activos en tu red. Si no aparece el tuyo la razón está en la configuración de tú servidor NFS. Si te ocurre, puedes configurar la URL a mano.

- Cambios en la configuración del sistema

```conf
:
  Configuración: Sistema, Videos
   Colección
     Obtener automáticamente las miniaturas de actor: ( )
```

Después desde Videos, Archivos:

```conf
:
   Archivos
    Añadir Videos (uso NFS hasta mi NAS y configuro)
    :
    Repito para cada directorio fuente con videos, series, videos familiares.
  :
  Música
   Archivos
    Añado mi colección de música vía NFS
    :
  Imágenes
   Añadir imágenes
    Añado raiz de mis colecciones de Fotografía (Positivos) principales
```

Una de mis aficiones es comprar (o que me regalen) series de TV completas, las ripeo en Inglés con subtítulos en Inglés para seguir "estudiando" el idioma, la integración dentro del Media Center es perfecta:

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-13.png" alt="series" width="600px" />
  <div class="image-caption">series</div>
</div>

<br/>

#### External tuner VU+ Ultimo

Si te has hecho con un receptor con sintonizadores de TDT o Satélite, como los VU+ Ultimo o Enigma, puedes activar el Add-On «VU+ / Enigma Client» ([fuentes en GitHub](https://github.com/kodi-pvr/pvr.vuplus)) que viene incluido y se activa con:

```conf
  Add-ons:
   Add-Ons Desactivados
    VU+/Enigma2 Client
     Configurar: IP, usuario, contraseña
     Activar

  TV en directo
   Activado
:
```

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-14.png" alt="VU+ - 1" width="600px" />
  <div class="image-caption">VU+ - 1</div>
</div>

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-15.png" alt="VU+ - 2" width="600px" />
  <div class="image-caption">VU+ - 2</div>
</div>

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-16.png" alt="VU+ - 3" width="600px" />
  <div class="image-caption">VU+ - 3</div>
</div>

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-17.png" alt="VU+ - 4" width="600px" />
  <div class="image-caption">VU+ - 4</div>
</div>

<br/>

#### Tune Movistar TV with a plugin

He descubierto un plugin que tiene muy buena pinta, no he tenido tiempo de probarlo, pero si lo único que quieres es ver los canales de Movistar TV en múltiples TV’s here you have una solución que promete llamada CodePlex xbmcimagenio, que finalmente migró al proyecto : [Kodi Movistar+ TV - ADDON para XBMC/ Kodi](https://sourceforge.net/projects/movistartv/)

<br/>

#### Tune Movistar TV with Tvheadend

Si te has hecho con un equipo externo (como el MOI+ o MOI Pro que incluye el programa Tvheadend) o tienes **un servidor dedicado con Tvheadend** y quieres ver los canales de Movistar TV, puedes echar un vistazo a diferentes apuntes que he realizado al respecto. Fuí investigando poco a poco y los tienes a continuación, en orden de más antiguo a más moderno:

- Soluciones con un servidor dedicado o semidedicado:
  - Movistar Fusión TV. Conseguirlo no es tan directo como configurar un Add-on. Opciones:
    - [Tvheadend y Movistar TV (2015)]({{< relref "2015-01-31-tvh-movistar-2015.md" >}})
    - Integración de Movistar TV en mi media center (WP 1225)
    - [WebGrab+Plus con Tvheadend]({{< relref "2015-02-03-webgrabplus.md" >}})
  - [Tvheadend y Movistar TV (2016)]({{< relref "2016-02-28-tvh-movistar-2016.md" >}})
  - Ojo porque en mi caso he cambiado el router que te entregan por un Linux + un Switch, documentado aquí: [Router Linux para Movistar]({{< relref "2014-10-05-router-linux.md" >}}).
- Solución con un equipo externo
  - Podrías montarte un servidor de streaming IPTV casero por ejemplo con un `MOI Pro` con Tvheadend, para agregar todo tipo de fuentes.

<br/>

### Remote control - CEC

Una vez que lo tengas todo configurado y funcionando te I recommend que utilices el «mando de la TV» activando CEC (Consumer Electronics Control), una funcionalidad que permite a la TV reenviar las órdenes del mando por el cable HDMI a tu raspberry y por lo tanto a XBMC/KODI. Así podrás reducir el número de mandos. Tienes muchas más alternativas como usar un teclado (usb y/o bluetooth) o bien mandos remotos específicos, o mejor todavía, una aplicación para tu smartphone (here you have un ejempo, la [oficial de XBMC/KODI](http://kodi.wiki/view/Official_XBMC_Remote/iOS))

<br/>

### USB Remote

Otra opción es hacerte con un mando remoto que funciona por el puerto USB, tienes muchas opciones en el mercado. Una que a mi me ha gustado mucho y funciona nada más sacarlo de la caja es el HP MCE remote. [Aquí](http://www.dxsdata.com/2015/02/currently-available-and-recommended-openelec-kodi-remote-controls-hardware/) tienes una buena comparativa.

<br/>

### Improve your Kodi installation

En esta sección explico cómo conseguir algunas "mejoras" a tu instalación de Kodi:

- Que el Servicio de TV se apague de forma automática a la hora y media sin interactuar con el mando remoto.
  - Se consigue con dos plugins (**Kodi Callbaks, Sleep Timer**) y dos scripts (`screen_off.sh, screen_on.sh`)
- Que Kodi detecte cuando se ha añadido algo nuevo (Pelis, Series, Audio, ...) y auto-reconstruya sus Librerías.
  - Se consigue con un plugin (`Watchdog`)
- Que el botón ON/OFF del mando remoto ponga en standby a Kodi (Off) o lo despierte (On), en vez de "Apagarlo".
  - Se consigue con el script "`powerButton.py`" y tocando la configuración.

<br/>

#### Support scripts

Antes de nada crea tres scripts de apoyo en tu equipo Openelec/LIbreelec. Conecta vía SSH, cambia al directorio /storage y crea tres scripts (a continuación tienes un ejemplo). Haz que los tres sean ejecutables (chmod):

- Conecta vía SSH

```shell
$ ssh -l root -p 22 tv-despacho.tudominio.com
password: openelec   <=== Por defecto
```

- Crea el fichero **`.kodi/userdata/keymaps/keyPower.xml`**

```xml
<keymap>
  <global>
    <remote>
      <power>XBMC.RunScript(/storage/powerButton.py)</power>
    </remote>
 </global>
</keymap>
```

- Crea el fichero **`/storage/powerButton.py`**

```python
#!/usr/bin/python
#
# Change remote's power button behaviour, by LuisPa, 2016
#
# Imports
#
import os
import xbmc
#import xbmcgui
import sys
import subprocess

# Check HDMI Status
#
ret = subprocess.call(["/usr/bin/tvservice -s | grep -v off > /dev/null 2>&1"], shell=True)
if ret == 0:

    # HDMI is On, so I assume user wants to power it off
    # xbmcgui.Dialog().ok("HDMI Status","HDMI is On, I'll switch it Off")

    # Stop anything that is being played
    xbmc.executebuiltin('PlayerControl(Stop)')

     # Activate Screen Saver
    xbmc.executebuiltin('ActivateScreensaver')
    print("powerButton.py: Screen Saver has been activated")

    # Power off HDMI
    #subprocess.call(["/usr/bin/tvservice -o"], shell=True)

    # In case someone is looking at the log files
    #print("powerButton.py: HDMI has been powered off")

else:

    # HDMI is Off, so I assume user wants mi to power it On

    # Power on HDMI
    subprocess.call(["/usr/bin/tvservice -p"], shell=True)
    subprocess.call(["/bin/killall -9 kodi.bin"], shell=True)

    # In case someone is looking at the log files
    print("powerButton.py: HDMI has been powered on")
```

- Crea el fichero **`/storage/screen_off.sh`**

```shell
#!/bin/sh
tvservice -o
```

- Crea el fichero **`/storage/screen_on.sh`**

```shell
#!/bin/sh
tvservice -p
killall -9 kodi.bin
```

- Cambia el permiso de los tres scripts a "ejecutable".

```shell
TV-Despacho:~ # chmod 755 screen_off.sh screen_on.sh powerButton.py
```

<br/>

### Plugin Installation

En mi caso siempre instalo las Network Tools (para poder cotillear qué está pasando con la red). Las tienes en `Ajustes > Add-ons > Instalar` desde `Repositorio > Todos los Repositorios > Add-ons de Programas`

- Network Tools

Continuamos con los tres recomendados. Instálalos a través de `Ajustes > Add-ons >Instalar desde Repositorio > Todos los repositorios > **Servicios**`

- Kodi Callbacks
- Sleep Timer
- Watchdog

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-04.png" alt="Plugins importantes" width="600px" />
  <div class="image-caption">Plugins importantes</div>
</div>

<br/>

- Una vez instalados entramos a configurarlos:

<br/>

#### Kodi Callbacks

Entramos en la configuración de Kodi Callbacks, definimos como **`TASK #1`** el script `/storage/screen_off.sh` y como **`TASK #2`** el script `/storage/screen_on.sh`

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-02.jpg" alt="kodi_cb2" width="600px" />
  <div class="image-caption">kodi_cb2</div>
</div>

Definimos dos eventos, el **EVENTO #1** "`on Screensaver Activated`" que ejecute el **TASK #1** (script `/storage/screen_off.sh`) y el **EVENTO #2** "`on Screensaver Deactivated`" que ejecute el **TASK #2** (script `/storage/screen_on.sh`)

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-03.jpg" alt="Kodi Callbacks" width="600px" />
  <div class="image-caption">Kodi Callbacks</div>
</div>

<br/>

#### Sleep Timer

Entramos en la configuración,

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-07.jpg" alt="Plugin Sleep Timer - Configuración" width="600px" />
  <div class="image-caption">Plugin Sleep Timer - Configuración</div>
</div>

Configuramos primero GENERAL, cómo iniciar el Sleep Timer

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-05.jpg" alt="Plugin Sleep Timer - General" width="600px" />
  <div class="image-caption">Plugin Sleep Timer - General</div>
</div>

Después configuramos AUDIO/VIDEO SUPERVISIÓN, donde indicamos "cuando" queremos que se active el Timer.

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-06.jpg" alt="Plugin Sleep Timer - Supervisión" width="600px" />
  <div class="image-caption">Plugin Sleep Timer - Supervisión</div>
</div>

En este ejemplo vemos que a los 90 minutos de inactividad (no iteración con Kodi) se hará un trigger del Timer y cuando venza el timeout del diálogo (nos da 45seg para abortar) se activará el "Screensaver", y ya vimos qué pasa cuando se activa el screensaver en el otro plugin (Kodi Callbacks), te lo recuerdo: el **EVENTO #1** "`on Screensaver Activated`" ejecuta el **TASK #1** (script `/storage/screen_off.sh`). Traducido significa que a la hora y media de no tocar el mando remoto muestra una caja de diálogo para abortar y si no lo hacemos en 45 segundos pues se apaga Kodi (se pone a dormir, NO apaga la raspberry).

<br/>

#### Watchdog

El objetivo es que cada vez que se añada algo nuevo a la librería se reconstruya. Activamos el plugin y entramos en su configuración para dejarla como ves a continuación.

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-08.jpg" alt="Activamos Watchdog" width="600px" />
  <div class="image-caption">Activamos Watchdog</div>
</div>

<br/>

### Reprogram the remote ON/OFF button

Por último, veamos cómo reprogramar el botón de apagado/encendido del mando para despertar/dormir a Kodi, cerrando el círculo. Entra en tu equipo vía SSH y edita el siguiente fichero.

- **`keyPower.xml`** bajo **`.kodi/userdata/keymaps`**

```
$ ssh -l root -p 22 tv-despacho.tudominio.com
password: openelec   <=== Por defecto

TV-Despacho:~/.kodi/userdata/keymaps # cat keyPower.xml
<keymap>
  <global>
    <remote>
      <power>XBMC.RunScript(/storage/powerButton.py)</power>
    </remote>
 </global>
</keymap>
```

- Rearranca el equipo y cuando pulses el botón de Power (Apagado/Encendido) del mando remoto que a su vez ejecutará el script `powerButton.py`, que "dormirá" o "despertará" a Kodi, en vez de apagar el sistema operativo.

Note: El consumo de energía (eléctrica) de una Raspberry con KODI durmiendo es mínimo.

<br/>

## OpenVPN Client

Si necesitas acceder desde un sitio remoto a tu instalación casera te I recommend utilizar OpenVPN. Si es tu caso y tienes un servidor OpenVPN en un linux o similar puedes instalar un gestor de cliente OpenVPN que funciona muy bien en KODI, se trata de [VPN Manager for OpenVPN](https://github.com/Zomboided/service.vpn.manager)

- Proyecto [VPN Manager for OpenVPN en GitHub](https://github.com/Zomboided/service.vpn.manager)
- [Wiki con instrucciones](https://github.com/Zomboided/service.vpn.manager/wiki) para realizar una instalación «personalizada»

Si conoces OpenVPN resumo el proceso:

- Descarga el fichero service.vpn.manager-X.X.X.zip del link anterior y prepara tu fichero micliente-openvpn.**ovpn**
- Envía ambos a la raspberry.
- Instala  service.vpn.manager-X.X.X.zip desde Add-Ons->Instalar desde un archivo .zip
- Copia miclient-openvpn.ovpn a /storage/.kodi/userdata/addon_data/service.vpn.manager/UserDefined
  - Nota. En mi caso uso un único fichero .ovpn que tiene dentro todo lo necesario (Si conoces OpenVPN sabes de qué hablo)
- Configura el AddOn:
  - VPN Povider: User Defined
  - El resto de parámetros los debes poner tú que conoces bin tu instalación de OpenVPN.

<br/>

### Monitor OpenElec

Durante la instalación y puesta en marcha me han venido bien una serie de herramientas, empiezo por la de monitorización. Para poder monitorizar la Raspberry I recommend descargar el script `bcmstat.sh` desde [aquí](https://github.com/MilhouseVH/bcmstat).

- Lanzar la monitorización: `./bcmstat.sh cgxd10`

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-10.png" alt="Monitorizar la Pi" width="600px" />
  <div class="image-caption">Monitorizar la Pi</div>
</div>

<br/>

### Improve performance

Lo que describo a continuación NO lo hago en la Raspberry PI 3.

- Overclocking en Raspberry Pi Model B+ 1.2 (versión 1)

Para modificar el overclocking conecta con tu raspberry (usa SSH, usuario root, password "openelec"). La configuración siguiente pone a "tope" la CPU cuando lo necesita, irá conmutando entre 700-1000 Mhz bajo demada. Una vez más, es MUY importante instalar al menos disipadores (y quizá necesites micro ventilador si la temperatura ambiente es alta).

```shell
 bolica ~ $ ssh -l root rasp-dormitorio.tudominio.com
 :
 TV-Dormitorio:~ #
 TV-Dormitorio:~ # mount -o remount,rw /flash
 TV-Dormitorio:~ # cd /flash
 TV-Dormitorio:/flash #  nano config.txt
 :
 arm_freq=1000
 core_freq=500
 sdram_freq=500
 over_voltage=6
 force_turbo=0
 ---------------------------<<< Salvamos con CTRL-O, CTRL-X y rearrancamos
 TV-Dormitorio:~ # reboot
```

- Overclocking en Raspberry Pi 2 Model B v1.1 (versión 2)

En el caso de la Pi2 he decidido usar la opción "High" y sin turbo, de hecho el monitor "High" demuestra que pocas veces necesita subir los MHz.

```shell
~ $ ssh -l root rasp-dormitorio.tudominio.com
 :
 TV-Dormitorio:~ #
 TV-Dormitorio:~ # mount -o remount,rw /flash
 TV-Dormitorio:~ # cd /flash
 TV-Dormitorio:/flash #  nano config.txt
 :
 arm_freq=950
 core_freq=450
 sdram_freq=450
 over_voltage=6
 force_turbo=0
 ---------------------------<<< Salvamos con CTRL-O, CTRL-X y rearrancamos
 TV-Dormitorio:~ # reboot
```

**NOTA**: I recommend tener una fuente de alimentación de 5.25V y 2.5A o podrías ver un cuadrado de colores en la parte superior derecha avisando de bajo voltaje. Si estás seguro que tu fuente es la correcta siempre puedes quitarlo con `avoid_warnings=(1 o 2)` en `/flash/config.txt`.

El significado de esta opción es el siguiente: `avoid_warnings=1` elimina el recuadro de colores que avisa de voltaje bajo. Por otro lado, `avoid_warnings=2` además permite activar el turbo incluso en condiciones de bajo voltaje.

- Cambiar el swapping

Un script que cambia el swapping y alguna cosa más, lo bajo de internet y lo ejecuto. Dejo una copia de todas formas aquí:

```shell
# wget http://www.nmacleod.com/public/oebuild/configrpi256.sh -P /storage && chmod +x /storage/configrpi256.sh
```

```shell
:
#!/bin/bash

#Enable swap
[ -f /storage/.config/swap.conf ] || cp /etc/swap.conf /storage/.config
sed -i 's/SWAP_ENABLED="no"/SWAP_ENABLED="yes"/' /storage/.config/swap.conf

#Increase swappiness
[ -f /storage/.config/autostart.sh ] || echo "#!/bin/sh" > /storage/.config/autostart.sh
if ! grep vm.swappiness /storage/.config/autostart.sh >/dev/null; then
  echo "sysctl -qw vm.swappiness=20" >>/storage/.config/autostart.sh
fi

#Set correct gpu_mem_256
mount -o remount,rw /flash
[ -f /flash/config.txt ] || touch /flash/config.txt
if ! grep "^[ ]*gpu_mem_256" /flash/config.txt >/dev/null; then
   echo "gpu_mem_256=112" >> /flash/config.txt
else
  sed -i 's/gpu_mem_256.*/gpu_mem_256=112/' /flash/config.txt
fi
mount -o remount,ro /flash

sync

echo "Please reboot for changes to take effect"
```

- Opciones avanzadas

Puedes parametrizar las opciones avanzadas en el fichero advancesettings.xml.

- Buffering

Si quieres «jugar» con el buffering puedes activar la opción que más te apetezca. Here you have la [documentación con ejempos](http://kodi.wiki/view/HOW-TO:Modify_the_video_cache).

- Otras opciones

Si buscas en internet encontrarás un montón de documentación para "mejorar" el rendimieto de tu raspberry, te I recommend que eches un ojo porque puede beneficiarte. En mi caso no he tenido que hacer nada más diferente a lo anterior.

<br/>

## Backup and Clone

Por último veamos cómo resuelvo el hacer un bakcup o clonado de la Raspberry. El caso de uso es simple: para evitar pérdidas de datos o simplemente para ahorrarte a configurar todo de nuevo cuando quieras instalar tu segunda Raspberry.

#### Clone (backup) the Micro-SD to an "image file"

El siguiente proceso clona la Micro-SD, es deicr, hace una copia exacta y lo guarda en un fichero (que llamamos "imagen") en el disco duro de mi iMac. Uso la versión raw del device (notar la "r") en el nombre del dispositivo para que vaya más rápido (acceso a disco en modo raw en vez de en modo bloque), aún así hablamos de "minutos" para copiar una SD de 8GB (es un proceso lento).

- No te olvides: asegurate de comprobar cual es el nombre del disco identificado para tu Micro-SD, equivocarte aquí podría ser fatal, dado que el comando "dd" no pide permiso, simplemente ejecuta. En el ejemplos siguiente se detecta que se ha asignado disk3 a la Micro-SD al conectarla.

```shell
:
obelix:Desktop luis$ sudo df -h
:
/dev/disk3s1                             803Mi  728Mi   75Mi    91%         0          0  100%   /Volumes/RECOVERY
/dev/disk3s5                             158Mi  110Mi   48Mi    70%         0          0  100%   /Volumes/SYSTEM

obelix:Desktop luis$ sudo diskutil unmount /Volumes/RECOVERY/
Volume RECOVERY on disk3s1 unmounted
obelix:Desktop luis$ sudo diskutil unmount /Volumes/SYSTEM/
Volume SYSTEM on disk3s5 unmounted
obelix:Desktop luis$ sudo dd if=/dev/rdisk3 bs=1m | gzip > rasp-openelec-luispa.img.gz
:
    (ESTE PROCESO PUEDE TARDAR VARIOS MINUTOS)
:
7580+0 records in
7580+0 records out
7948206080 bytes transferred in 222.251993 secs (35762136 bytes/sec)
:
```

 <br/>

#### Clone (restore) the image to a Micro-SD

El proceso contrario, cuando quieras crear una nueva Micro-SD con una copia exacta de la fuente (la original), simplemente clonas la imagen anterior hacia la Micro-SD.

No es necesario pero te I recommend formatearla antes la Micro-SD destino con SDFormatter, usando formato rápido, así te aseguras que se reconoce bien en el sistema operativo. Una vez formateada el Mac la montará, por lo que podemos de nuevo comprobar qué nombre de «device» le ha sido asignado, a continuación ejecutamos el comando «dd» pero al revés. RECUERDA: FIJATE MUY BIEN porque «dd» no avisa y podrías cargarte tu disco principal si te equivocas.

- Clonamos desde la imagen a la Micro-SD

```shell
:
obelix:Desktop luis$ sudo df -h
:
/dev/disk3s1                             7.2Gi  2.3Mi  7.2Gi     1%         0          0  100%   /Volumes/NO NAME
:
obelix:Desktop luis$ gzip -dc rasp-openelec-luispa.img.gz | sudo dd of=/dev/rdisk3 bs=1m
:
    (ESTE PROCESO PUEDE TARDAR VARIOS MINUTOS)
:
0+121280 records in
0+121280 records out
7948206080 bytes transferred in 652.344831 secs (12184056 bytes/sec)
:
```

Durante el proceso de copia verás simplemente un cursor parpadeando durante varios minutos, una vez que termina mostrará el número de bytes escritos. A partir de aquí hacemos boot con la nueva tarjeta. I recommend cambiarle el nombre a este segundo sistema y además borrar la configuración de SSH para que no use los mismos certificados que el antiguo (el fuente desde el cual partimos)

- Cambia el nombre de tu nuevo media center, hay que hacerlo en dos sitios, puedes usar el mismo para ambos o que sean diferentes, mira un ejemplo

El primero "**Nombre del Dispositivo**" (en SISTEMA -> Ajustes -> Servicios ->General) es el que se usa para anunciar servicios como UPnP, web, control remoto, zeroconf o AirPlay.

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-18.png" alt="xbmc-nombre-dispositivo" width="600px" />
  <div class="image-caption">xbmc-nombre-dispositivo</div>
</div>

<div class="image-box">
  <img src="/img/posts/2015-01-31-media-center-19.png" alt="xbmc-nombre-sistema" width="600px" />
  <div class="image-caption">xbmc-nombre-sistema</div>
</div>

- Limpiamos la configuración SSH borrando los certificados y rearrancamos el equipo.

```shell
:
$ ssh -l root nuevo-sistema-raspberry
:
# rm -f /storage/.cache/ssh/ssh_host*
# reboot
:
```

Al arrancar el daemon de ssh se regenerarán los certificados y la próxima vez que conectes observarás que ha cambiado el nombre del Host.

- No olvides de poner la licencia específica de MPEG-2 y/o VC1 para tu raspberry.

<br/>

### Capture screenshots

Si quieres hacer una captura de lo que estás viendo en pantalla (screenshot, screencapture) puedes usar el comando siguiente desde tu Raspberry. Dejará el resultado en el directorio /storage/screenshots y podrás enviarlo a tu ordenador vía scp por ejemplo.

```shell
:
# kodi-send --host=localhost --port=9777 --action="TakeScreenshot"
```
