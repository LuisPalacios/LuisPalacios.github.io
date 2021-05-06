---
title: "Media Center: Raspberry Pi + KODI/XBMC"
date: "2015-01-31"
categories: apuntes linux media-center raspberry-pi
tags: media-center movistar raspberry xbmc
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/?p=1025) de siguiente generación conectado a mi TV, un “pata negra” que no sea demasiado caro, que pueda conectarse por cable ethernet a un “mundo” de múltiples fuentes que incluya música, fotos, videos familiares o películas o series (tanto SD o HD) y que sea capaz de reproducir TV en tiempo real (SD o HD), que soporte bitrates altos (~40Mbps) independiente de cual sea la fuente (antena, satélite, internet"
    caption="Media Center casero"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/)" aunque me he quedé con OpenElec (principalmente por el Skin, no me convence el de OSMC"
    caption="OpenElec](http://openelec.tv/) 4.0.5”, con la Pi2 y Pi3 las versiones "OpenElec 6.0.3 -> Kodi v15 Isengard" y "OpenElec 7.0B2 -> Kodi v16 Jarvis". También proble "[OSMC"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/), una bifurcación (fork) de OpenElec y desde entonces me he mantenido en ella (LibreElec"
    caption="LibreElec"
    width="600px"
    %}

Nota1: ¿porqué no hablo de Wifi?: Pues porque busco el mejor rendimiento y eliminar posibles puntos de fallo o empeoramiento de las condiciones de ancho de banda. Una vez que pruebes y re-pruebes todo y estés convencido de que va "PERFECTO", entonces es cuando deberías añadir la "variable" Wifi y por supuesto probar de nuevo.

Nota2: En casa sigo sin usar WiFi pero he probado recientemente con la Wifi embebida en la Pi3 y funciona bien con streams HD, eso sí, siempre que esté cerca del punto de acceso y no haya muros ni interferencias cercanas...

 

### La lista de la compra:

#### **El Hardware**

Depende de cual compres, Pi1,2,3; aquí tienes la lista de sus especificaciones:

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

 

{% include showImagen.html
    src="/assets/img/original/RaspberryPiB-1.2.jpg"
    caption="RaspberryPiB+1.2"
    width="600px"
    %}

 

#### **El Software**

Todos los paquetes de software que se ejecutan en la Raspberry son de software libre y hay múltiples distribuciones. En el área de Media Center tenemos dos: raspbmc (ahora OSMC), openelec y ahora LibreElec. Tras múltiples pruebas y pasar por OpenElec, ahora utilizo **LibreElec**.

{% include showImagen.html
    src="/assets/img/original/"
    caption="LibreElec"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/OpenELEC.tv"
    caption="OpenElec.tv"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/Development_workflow) para compilar desde los fuentes (por si quieres trastear y cross-compilar directamente desde GitHub, interesante aprendizaje :-)"
    caption="documentación"
    width="600px"
    %}

 

#### Formatear la tarjeta SD

{% include showImagen.html
    src="/assets/img/original/) (que es el que yo uso para Mac"
    caption="SDFormatter."
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/sdformatter-300x196.png"
    caption="sdformatter"
    width="600px"
    %}

**Raspberry Pi Versión 1: "OpenElec 4.0.5" desde NOOBS**

Esta opción usa la instalación desde NOOBS, un paquete preparado por la gente de Raspberry directamente y dejará instalada la versión 4.0.5 de "openelec" que incluye XBMC 13.1 "Ghotam". Es la versión que mejor me ha funcionado en la Raspberry Pi Model B+ 1.2 (Versión 1). Estos son los pasos realizados en mi Mac:

{% include showImagen.html
    src="/assets/img/original/"
    caption="1.3.12 de NOOBs"
    width="600px"
    %}
    
- Descomprimir el archivo NOOBS_v1_3_12.zip
    
- Arrastrar y copiar todo el contenido dentro del directorio hacia la raíz de la tarjeta SD
    
- Desmonta el volumen de la Micro SD, ya está lista para usarse en la Raspberry
    
- Insertar la Micro SD en la Raspberry Pi B+, recomiendo que conectes un "teclado y ratón USBs" para ejecutar NOOBS. Conectar el cable de potencia, HDMI, etc.. y arránca el equipo. **Primer boot NOOBS**
    

Aparecerá una ventana con un listado de los sistemas operativos que puedes instalar, seleccionar "openelec" y clic en "install". Automáticamente se reformatea/instala en la misma SD la versión de Openelec.

**Raspberry Pi Versión 2 o 3: Ejemplo con "OpenElec 5.0.8" desde OpenELEC**

Para esta opción vamos a descargar la imagen directamente desde OpenElec, describo cómo instalé esta versión concreta, pero el proceso es el mismo para futuras versiones:

Nota: Con Pi 2 o 3 se soportan bitrates >40Mbps con muchísimo menor consumo de CPU, ahora bien, de ahí (40-45Mbps) no pasa sin sufrir microcortes y es debido a que el chip ethernet LAN9154 emplea el bus USB. En mi caso 99.99% de mi contenido va sobrado con dicho rendimiento (TV 1080 y videos en 1080).

{% include showImagen.html
    src="/assets/img/original/get-openelec"
    caption="OpenELEC"
    width="600px"
    %}
    
- Descomprimir: gunzip OpenELEC-RPi2.arm-5.0.8.img.gz
    
- Insertar la tarjeta que se montará como “NO NAME”.
    
- Averiguar device (resultó ser /dev/disk5): df -h
    
- Desmontar el volumen: sudo diskutil unmount /dev/disk5s1
    
- Grabar: sudo dd if=OpenELEC-RPi2.arm-5.0.8.img of=/dev/rdisk5 bs=4194304
    

**Raspberry Pi Versión 3: Ejemplo con "LibreElec"**

{% include showImagen.html
    src="/assets/img/original/"
    caption="LibreElec SD USB Creator"
    width="600px"
    %}
- Ejecutar el programa y seguir cuatro sencillos pasos

{% include showImagen.html
    src="/assets/img/original/libreelec.png"
    caption=""
    width="600px"
    %}

 

### Boot del Media Center "casero"

Una vez que hemos "quemado" la memoria la colocamos en la Raspberry Pi y hacemos Boot. Al arrancar realiza un proceso automático (que incluye un reboot) donde se redimensiona la partición de la Micro-SD y se ejecuta un asistente para la configuración básica de XBMC/KODI. En la Raspberry versión 1 notarás que el interfaz es lento, es normal, tendrás que activar el overclocking más adelante.

Parámetros mínimos que configuro en mi caso. Debido a los diferentes Skins indico el lugar donde puedes encontrarlo...

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

 

#### Instalación de licencias MPEG-2 y VC1

{% include showImagen.html
    src="/assets/img/original/"
    caption="licencias a través de su tienda"
    width="600px"
    %}

Para adquirir la licencia, conecta vía SSH con tu raspberry como root, averigua el número de serie de la cpu, adquire la licencia para luego instalarla en el fichero config.txt

bolica ~ $ ssh -l root rasp-dormitorio.parchis.org
 :
TV-Dormitorio:~ # cat /proc/cpuinfo
:
Serial      : 000000005771f8a3

Cuando pases por la tienda para comprar la licencia y tengas el número podrás instalarla dentro del fichero config.txt, mira un ejemplo donde indico el número de licencia para Mpeg-2

 bolica ~ $ ssh -l root rasp-dormitorio.parchis.org
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

 

### Configuración de XBMC/KODI y sus fuentes

Este paso es muy personal, porque cada uno tendrá distintas fuentes con distintos protocolos de acceso. Describo a continuación las que utilizo en mi caso:

#### NAS con videos, fotos y música

En mi caso tengo una NAS QNAP en la dirección 192.168.1.2 y comparto la raiz de mi contenido multimedia usando el protocolo NFS. Aunque se configura vía web, ésta es la línea en el /etc/exports:

"/share/MD0_DATA/Multimedia" *(ro,async,no_root_squash,insecure)

La razón de usar NFS es que consume menos en la raspberry y es más rápido. Desde XBMC/KODI y las áreas de video, música e imágenes añadir los directorios con el recurso "Network Filesystem (NFS)"

- Nota: Cuando seleccionas el recurso "Network Filesystem (NFS)" lo normal es que aparezca la dirección IP de tu servidor NFS dado que XBMC/KODI envía un broadcast en UDP intentando "descubrir" los servidores NFS activos en tu red. Si no aparece el tuyo la razón está en la configuración de tú servidor NFS. Si te ocurre, puedes configurar la URL a mano.

:
  Configuración: Sistema, Videos
   Colección
     Obtener automáticamente las miniaturas de actor: ( )

Después desde Videos, Archivos:

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

 

Una de mis aficiones es comprar (o que me regalen) series de TV completas, las ripeo en Inglés con subtítulos en Inglés para seguir "estudiando" el idioma, la integración dentro del Media Center es perfecta:

{% include showImagen.html
    src="/assets/img/original/series-1024x578.png"
    caption="series"
    width="600px"
    %}

 

#### Sintonizador externo VU+ Ultimo

{% include showImagen.html
    src="/assets/img/original/pvr.vuplus)"
    caption="fuentes en GitHub"
    width="600px"
    %}

:

  Add-ons:
   Add-Ons Desactivados
    VU+/Enigma2 Client
     Configurar: IP, usuario, contraseña
     Activar

  TV en directo
   Activado
:

{% include showImagen.html
    src="/assets/img/original/vuplus1-1024x578.png"
    caption="vuplus1"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/vuplus2-1024x578.png"
    caption="vuplus2"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/vuplus3-1024x578.png"
    caption="vuplus3"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/vuplus4-1024x578.png"
    caption="vuplus4"
    width="600px"
    %}

#### Sintonizar Movistar TV con un plugin

{% include showImagen.html
    src="/assets/img/original/"
    caption="https://xbmcimagenio.codeplex.com/"
    width="600px"
    %}

 

#### Sintonizar Movistar TV con Tvheadend

Si te has hecho con un equipo externo (como el MOI+ o MOI Pro que incluye el programa Tvheadend) o tienes **un servidor dedicado con Tvheadend** y quieres ver los canales de Movistar TV, puedes echar un vistazo a diferentes apuntes que he realizado al respecto. Fuí investigando poco a poco y los tienes a continuación, en orden de más antiguo a más moderno:

- Soluciones con un servidor dedicado o semidedicado:
{% include showImagen.html
    src="/assets/img/original/?p=1587"
    caption="WebGrab+Plus con TVHeadEnd en Linux"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/4571"
    caption="TVheadend y Movistar TV (2016)"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/?p=266"
    caption="Movistar Fusión con router Linux"
    width="600px"
    %}
- Solución con un equipo externo
{% include showImagen.html
    src="/assets/img/original/2647"
    caption="Servidor de streaming IPTV casero"
    width="600px"
    %}

 

## Control remoto

### CEC

{% include showImagen.html
    src="/assets/img/original/iOS)"
    caption="aquí tienes un ejempo, la oficial de XBMC/KODI"
    width="600px"
    %}

### Remoto vía USB

{% include showImagen.html
    src="/assets/img/original/"
    caption="Aquí"
    width="600px"
    %}

* * *

* * *

## Mejorar tu instalación de Kodi

En esta sección explico cómo conseguir algunas "mejoras" a tu instalación de Kodi:

- Que el Servicio de TV se apague de forma automática a la hora y media sin interactuar con el mando remoto.
    - Se consigue con dos plugins (**Kodi Callbaks, Sleep Timer**) y dos scripts (**`screen_off.sh, screen_on.sh`**)
- Que Kodi detecte cuando se ha añadido algo nuevo (Pelis, Series, Audio, ...) y auto-reconstruya sus Librerías.
    - Se consigue con un plugin (**Watchdog**)
- Que el botón ON/OFF del mando remoto ponga en standby a Kodi (Off) o lo despierte (On), en vez de "Apagarlo".
    - Se consigue con el script "**`powerButton.py`**" y tocando la configuración.

 

#### Scripts de apoyo

Antes de nada crea tres scripts de apoyo en tu equipo Openelec/LIbreelec. Conecta vía SSH, cambia al directorio /storage y crea tres scripts (a continuación tienes un ejemplo). Haz que los tres sean ejecutables (chmod):

- Conecta vía SSH

$ ssh -l root -p 22 tv-despacho.parchis.org
password: openelec   <=== Por defecto

 

- Crea el fichero **`.kodi/userdata/keymaps/keyPower.xml`** 

<keymap>
  <global>
    <remote>
      <power>XBMC.RunScript(/storage/powerButton.py)</power>
    </remote>
 </global>
</keymap>

 

- Crea el fichero **`/storage/powerButton.py`**

#!/usr/bin/python
#
# Change remote's power button behaviour, by LuisPa, 2016
#
# Python script called from KODI in order to have an alterntive
# to the power button. I want remote's power button to trigger
# the following: If HDMI is On, then stop playing and power off
# the HDMI. If HDMI is OFF, then power it on and restart Kodi
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
#ret = subprocess.call(["/storage/screen_status.sh"], shell=True)
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

 

- Crea el fichero **`/storage/screen_off.sh`**

#!/bin/sh
tvservice -o

 

- Crea el fichero **`/storage/screen_on.sh`** 

#!/bin/sh
tvservice -p
killall -9 kodi.bin

 

- Cambia el permiso de los tres scripts a "ejecutable".

TV-Despacho:~ # chmod 755 screen_off.sh screen_on.sh powerButton.py

 

 

### Instalación de Plugins

En mi caso siempre me instalo también las Network Tools (para poder cotillear qué está pasando con la red). Las tienes en Ajustes->Add-ons->Instalar desde Repositorio->Todos los Repositorios->Add-ons de Programas

- Network Tools

Continuamos con los tres recomendados. Instálalos a través de Ajustes->Add-ons->Instalar desde Repositorio->Todos los repositorios->**Servicios**

- Kodi Callbacks
- Sleep Timer
- Watchdog

 

{% include showImagen.html
    src="/assets/img/original/kodiOnOff_9-1024x576.png"
    caption="kodiOnOff_9"
    width="600px"
    %}

### Configuración de los Plugins

Una vez instalados entramos a configurarlos:

#### Kodi Callbacks

Entramos en la configuración de Kodi Callbacks, definimos como **`TASK #1`** el script `/storage/screen_off.sh` y como **`TASK #2`** el script `/storage/screen_on.sh`

{% include showImagen.html
    src="/assets/img/original/kodi_cb2-1024x576.jpg"
    caption="kodi_cb2"
    width="600px"
    %}

Definimos dos eventos, el **EVENTO #1** "`on Screensaver Activated`" que ejecute el **TASK #1** (script `/storage/screen_off.sh`) y el **EVENTO #2** "`on Screensaver Deactivated`" que ejecute el **TASK #2** (script `/storage/screen_on.sh`)

{% include showImagen.html
    src="/assets/img/original/kodi_cb4-1024x576.jpg"
    caption="kodi_cb4"
    width="600px"
    %}

El resto lo dejamos por defecto

{% include showImagen.html
    src="/assets/img/original/kodi_cb6-1024x576.jpg"
    caption="kodi_cb6"
    width="600px"
    %}

 

#### Sleep Timer

Entramos en la configuración,

{% include showImagen.html
    src="/assets/img/original/kodi_st3-1024x576.jpg"
    caption="kodi_st3"
    width="600px"
    %}

Configuramos primero GENERAL, cómo iniciar el Sleep Timer

{% include showImagen.html
    src="/assets/img/original/kodi_st0-1024x576.jpg"
    caption="kodi_st0"
    width="600px"
    %}

Después configuramos AUDIO/VIDEO SUPERVISIÓN, donde indicamos "cuando" queremos que se active el Timer.

{% include showImagen.html
    src="/assets/img/original/kodi_st2-1024x576.jpg"
    caption="kodi_st2"
    width="600px"
    %}

En este ejemplo vemos que a los 90 minutos de inactividad (no iteración con Kodi) se hará un trigger del Timer y cuando venza el timeout del diálogo (nos da 45seg para abortar) se activará el "Screensaver", y ya vimos qué pasa cuando se activa el screensaver en el otro plugin (Kodi Callbacks), te lo recuerdo: el **EVENTO #1** "`on Screensaver Activated`" ejecuta el **TASK #1** (script `/storage/screen_off.sh`). Traducido significa que a la hora y media de no tocar el mando remoto muestra una caja de diálogo para abortar y si no lo hacemos en 45 segundos pues se apaga Kodi (se pone a dormir, NO apaga la raspberry).

 

#### Watchdog

El objetivo es que cada vez que xxxxx relea la libería. Activamos el plugin y entramos en su configuración para dejarla como ves a continuación.

 

{% include showImagen.html
    src="/assets/img/original/kodi_wd3-1024x576.jpg"
    caption="kodi_wd3"
    width="600px"
    %}

 

### Reprogramar el boton ON/OFF del Remote

Por último, veamos cómo reprogramar el botón de apagado/encendido del mando para despertar/dormir a Kodi, cerrando el círculo. Entra en tu equipo vía SSH y edita el siguiente fichero.

- **`keyPower.xml`** bajo **`.kodi/userdata/keymaps`**

```
$ ssh -l root -p 22 tv-despacho.parchis.org
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

- Rearranca el equipo y cuando pulses el botón de Power (Apagado/Encendido) del mando remoto que a su vez ejecutará el script **powerButton.py**, que "dormirá" o "despertará" a Kodi, en vez de apagar el sistema operativo.

Nota: El consumo de energía (eléctrica) de una Raspberry donde KODI está durmiendo es mínimo.

 

## Cliente OpenVPN

{% include showImagen.html
    src="/assets/img/original/service.vpn.manager"
    caption="VPN Manager for OpenVPN"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/service.vpn.manager"
    caption="VPN Manager for OpenVPN en GitHub"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/wiki"
    caption="Wiki con instrucciones"
    width="600px"
    %}

Si conoces OpenVPN resumo el proceso:

- Descarga el fichero service.vpn.manager-X.X.X.zip del link anterior y prepara tu fichero micliente-openvpn.**ovpn**
- Envía ambos a la raspberry.
- Instala  service.vpn.manager-X.X.X.zip desde Add-Ons->Instalar desde un archivo .zip
- Copia miclient-openvpn.ovpn a /storage/.kodi/userdata/addon_data/service.vpn.manager/UserDefined
    - Nota. En mi caso uso un único fichero .ovpn que tiene dentro todo lo necesario (Si conoces OpenVPN sabes de qué hablo)
- Configura el AddOn:
    - VPN Povider: User Defined
    - El resto de parámetros los debes poner tú que conoces bin tu instalación de OpenVPN.

 

## Parametrizar Openelec

### Monitorizar

{% include showImagen.html
    src="/assets/img/original/bcmstat"
    caption="bcmstat.sh desde aquí"
    width="600px"
    %}

- Lanzar la monitorización: ./bcmstat.sh cgxd10

{% include showImagen.html
    src="/assets/img/original/monitorizarraspberry-copy-1024x631.png"
    caption="monitorizarraspberry copy"
    width="600px"
    %}

 

### Mejorar el rendimiento

Lo que describo a continuación NO lo hago en la Raspberry PI 3.

- Overclocking en Raspberry Pi Model B+ 1.2 (versión 1)

Para modificar el overclocking conecta con tu raspberry (usa SSH, usuario root, password "openelec"). La configuración siguiente pone a "tope" la CPU cuando lo necesita, irá conmutando entre 700-1000 Mhz bajo demada. Una vez más, es MUY importante instalar al menos disipadores (y quizá necesites micro ventilador si la temperatura ambiente es alta).

 bolica ~ $ ssh -l root rasp-dormitorio.parchis.org
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

 

- Overclocking en Raspberry Pi 2 Model B v1.1 (versión 2)

En el caso de la Pi2 he decidido usar la opción "High" y sin turbo, de hecho el monitor "High" demuestra que pocas veces necesita subir los MHz.

~ $ ssh -l root rasp-dormitorio.parchis.org
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

 

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**NOTA**: Recomiendo tener una fuente de alimentación de 5.25V y 2.5A o podrías ver un cuadrado de colores en la parte superior derecha avisando de bajo voltaje. Si estás seguro que tu fuente es la correcta siempre puedes quitarlo con avoid_warnings=(1 o 2) en /flash/config.txt.

[/dropshadowbox]

El significado de esta opción es el siguiente: avoid_warnings=1 elimina el recuadro de colores que avisa de voltaje bajo. Por otro lado, avoid_warnings=2 además permite activar el turbo incluso en condiciones de bajo voltaje.

- Cambiar el swapping

Un script que cambia el swapping y alguna cosa más, lo bajo de internet y lo ejecuto. Dejo una copia de todas formas aquí:

# wget http://www.nmacleod.com/public/oebuild/configrpi256.sh -P /storage && chmod +x /storage/configrpi256.sh

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

 

- Opciones avanzadas

Puedes parametrizar las opciones avanzadas en el fichero advancesettings.xml.

- Buffering

{% include showImagen.html
    src="/assets/img/original/HOW-TO:Modify_the_video_cache"
    caption="documentación con ejempos"
    width="600px"
    %}

- Otras opciones

Si buscas en internet encontrarás un montón de documentación para "mejorar" el rendimieto de tu raspberry, te recomiendo que eches un ojo porque puede beneficiarte. En mi caso no he tenido que hacer nada más diferente a lo anterior.

 

 

## Backup y Clonar

Por último veamos cómo resuelvo el hacer un bakcup o clonado de la Raspberry. El caso de uso es simple: para evitar pérdidas de datos o simplemente para ahorrarte a configurar todo de nuevo cuando quieras instalar tu segunda Raspberry.

#### Clonar (backup) la Micro-SD hacia un "fichero imagen"

El siguiente proceso clona la Micro-SD, es deicr, hace una copia exacta y lo guarda en un fichero (que llamamos "imagen") en el disco duro de mi iMac. Uso la versión raw del device (notar la "r") en el nombre del dispositivo para que vaya más rápido (acceso a disco en modo raw en vez de en modo bloque), aún así hablamos de "minutos" para copiar una SD de 8GB (es un proceso lento).

- No te olvides: asegurate de comprobar cual es el nombre del disco identificado para tu Micro-SD, equivocarte aquí podría ser fatal, dado que el comando "dd" no pide permiso, simplemente ejecuta. En el ejemplos siguiente se detecta que se ha asignado disk3 a la Micro-SD al conectarla.

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

 

#### Clonar (restaurar) la imagen hacia una Micro-SD

El proceso contrario, cuando quieras crear una nueva Micro-SD con una copia exacta de la fuente (la original), simplemente clonas la imagen anterior hacia la Micro-SD.

{% include showImagen.html
    src="/assets/img/original/"
    caption="SDFormatter"
    width="600px"
    %}

- Clonamos desde la imagen a la Micro-SD

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

Durante el proceso de copia verás simplemente un cursor parpadeando durante varios minutos, una vez que termina mostrará el número de bytes escritos. A partir de aquí hacemos boot con la nueva tarjeta. Recomiendo cambiarle el nombre a este segundo sistema y además borrar la configuración de SSH para que no use los mismos certificados que el antiguo (el fuente desde el cual partimos)

- Cambia el nombre de tu nuevo media center, hay que hacerlo en dos sitios, puedes usar el mismo para ambos o que sean diferentes, mira un ejemplo

El primero "**Nombre del Dispositivo**" (en SISTEMA -> Ajustes -> Servicios ->General) es el que se usa para anunciar servicios como UPnP, web, control remoto, zeroconf o AirPlay.

{% include showImagen.html
    src="/assets/img/original/xbmc-nombre-dispositivo-1024x578.png"
    caption="xbmc-nombre-dispositivo"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/xbmc-nombre-sistema-1024x578.png"
    caption="xbmc-nombre-sistema"
    width="600px"
    %}

- Limpiamos la configuración SSH borrando los certificados y rearrancamos el equipo.

:
$ ssh -l root nuevo-sistema-raspberry 
:
# rm -f /storage/.cache/ssh/ssh_host*
# reboot
:

Al arrancar el daemon de ssh se regenerarán los certificados y la próxima vez que conectes observarás que ha cambiado el nombre del Host.

- No olvides de poner la licencia específica de MPEG-2 y/o VC1 para tu raspberry.

 

## Capturar pantallazos

Si quieres hacer una captura de lo que estás viendo en pantalla (screenshot, screencapture) puedes usar el comando siguiente desde tu Raspberry. Dejará el resultado en el directorio /storage/screenshots y podrás enviarlo a tu ordenador vía scp por ejemplo.

 

:
# kodi-send --host=localhost --port=9777 --action="TakeScreenshot"
