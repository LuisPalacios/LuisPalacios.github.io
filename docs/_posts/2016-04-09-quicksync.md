---
title: "Intel Quick Sync Video"
date: "2016-04-09"
categories: apuntes gentoo linux media-center qsv vaapi
tags: aceleracion qsv quicksync-video transcodificacion tvheadend
excerpt_separator: <!--more-->
---

![logo Tvheadend](/assets/img/posts/logo-intel-quicksync.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

En este apunte explico cómo intento que Tvheadend use las capacidades de transcodificación (encode y decode) por Hardware ofrecidas por Intel Quick Sync Video (por ejemplo en sus NUC’s). El objetivo es que los streams de video utilicen mucho menos ancho de banda. Pensaba que NO me iba a hacer falta debido a mi caso de uso (Tvheadend para ver canales iptv en un entorno sin problemas de ancho de banda, router Linux + Fibra y clientes raspberry con Kodi por cable Ethernet)...


<br clear="left"/>
<!--more-->

### Tvheadend y aceleración HW

Pero la realidad fue que **sí que necesito transcodificar**, tengo dos casos: el primero es cuando uso un **cliente Móvil** (teléfono, tableta) por la WiFi casera y el segundo si quiero **acceder por internet** para ver la TV de mi casa (ejemplo: en vacaciones).  Si intento enviar un canal HD (+10Mbps) vía WiFi o Internet a un móvil o una tableta funciona pero con microcortes o retrasos o pérdidas de tráfico, en definitiva inestabilidad.

{% include showImagen.html
    src="/assets/img/posts/Transcoding.jpg"
    caption="Transcoding"
    width="600px"
    %}

Tvheadend soporta transcodificación, tanto software como hardware. La primera es fácil de activar y funciona, pero si le exiges que tenga buena calidad te va a **fundir la CPU** (100% de consumo) y tendrás microcortes, retrasos, pérdidas de tráfico, inestabilidad. Hay dos opciones 1) transcodificación software sin demasiadas exigencias o 2) transcodificación HW exigiendo buena calidad y mínimo consumo de CPU.

Nota: En mi caso estoy haciendo las pruebas con un NUC D54250WYK, cuenta con CPU Intel Core i5-4250U y GPU (reportada por `lspci`) `Intel Corporation Haswell-ULT Integrated Graphics Controller (rev 09)`, pero este apunte aplica a cualquier ordenador que use los chips de intel de diferentes generaciones (ojo, algunas pueden no soportar lo que aquí se describe, consulta los enlaces al final de este apunte).

<br/>

## Intel QSV en Linux y en Tvheadend

 
**Que Linux use aceleración por HW (QSV): objetivo cumplido**

El primer objetivo que me planteé fue que el Linux (gentoo) fuese capaz de acceder al Hardware gráfico (QSV) del Intel NUC. Hay que instalar paquetes estándar (Gentoo en mi caso) y preparar el Kernel. Opcional recomiendo instalar X11 para verificar que se consume QSV en entorno gráfico cuando ves por ejemplo una peli. En cualquier caso también funciona en modo Headless (sin X11), es decir, puedes usar ffmpeg para codificar o de-codificar (transcodificar).

- Soporte nativo en el Kernel, Sistema Operativo, FFMPEG accediendo a QSV vía VAAPI
  - Ventaja: Funciona.
  - Está documentado más abajo en *Soporte nativo de Intel QSV+VAAPI en Linux*
  - Nota1: Quick Sync está soportado por el [VA API](https://en.wikipedia.org/wiki/VA_API), tanto para encoding como decoding, así ques VAAPI es el método preferido para poder «consumir» dicho Hardware (QSV).
  - Nota2: FFMPEG, uso la nueva 3.1 que ha empezado a soportar VAAPI hace poco tiempo.
 

**Que Tvheadend use aceleración por HW (QSV): Work In Progress**

Esto es otra historia,  el segundo objetivo consiste en compilar Tvheadend para que acceda al Hardware del Intel NUC (QSV) y sea capaz de usar la aceleración HW. Por desgracia a fecha de Julio de 2016 todavía no es fácil pero se supone que llegará.

Por lo que he podido investigar tenemos dos opciones:

- Soporte nativo de vaapi en Tvheadend (Solución ideal)
  - Ventaja: Mucho más sencillo, estándar y compatible con cualquier distro/kernel.
  - Desventaja: Todavía no existe (aunque ya hay petición oficial [#3831](https://tvheadend.org/issues/3831) en Tvheadend, no te cortes y pídelo tú también) — Actualización (Feb 2018: [issue 4443](https://tvheadend.org/issues/4443) es más moderno
  - Lo iré documentando más abajo en la sección *Tvheadend con soporte nativo VAAPI*. Mira también [este issue](https://tvheadend.org/issues/4443)
- Soporte meditante el SDK de Quick Sync de Intel y un Kernel concreto parcheado (no me gusta)
  - Ventaja: Funciona, aunque por lo que he visto no me convence…
  - Desventaja: obliga a usar una Distro+Kernel concretos,
  - Desventaja: Por lo que he visto en los foros es complicado de montar.
  - Desventaja: Condena al NUC a este role específico (tvheadend).
  - Documentado más abajo en la sección *Tvheadend con SDK Quick Sync*

<br/>

### Soporte nativo de Intel QSV+VAAPI en Linux (Gentoo)

Lo primero que voy a hacer es preparar el sistema para que funcione Xorg y  la aceleración de video. Te recomiendo que empieces por aquí, aunque no necesites X11 para Tvheadend más tarde, es una forma de quitarme muchas dudas si luego las cosas NO funcionan, es decir prefiero conseguir llegar a la primera «base», dejar X11 funcionando, comprobar que mi tarjeta i965 funciona correctamente y que se consume por Hardware de forma correcta. Nota: [he usado esta fuente](https://wiki.gentoo.org/wiki/VAAPI). Mi segunda base será confirmar que incluso sin X11 me funcionan los comandos que comprueban que el hardware GPU es accesible.


- Configuro VIDEO_CARDS y USE (Habilito el HW decoding H264 y VAAPI)

```console
# grep VIDEO_CARDS /etc/portage/make.conf
VIDEO_CARDS="intel i965"

# grep USE /etc/portage/make.conf
USE="X -bindist -gnome -kde  aes avx avx2 fma3 mmx mmxext popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3 g45-h264 vaapi"
```

- Accept Keywords

```console
tv ~ # cat /etc/portage/package.accept_keywords
:
~media-tv/tvheadend-9999 **
media-video/ffmpeg ~amd64

~x11-libs/libva-9999 **
~x11-libs/libva-intel-driver-9999 **

media-video/mpv ~amd64
```

- Licencia fdk-aac

```console
tv ~ # cat /etc/portage/package.license
=media-libs/fdk-aac-0.1.3 FraunhoferFDK
```

- USE flags para FFMPEG y para Tvheadend

```console
tv ~ # cat /etc/portage/package.use/ffmpeg
media-plugins/alsa-plugins pulseaudio
x11-libs/libva drm X -egl opengl -vdpau -wayland
media-video/ffmpeg X alsa bzip2 encode gpl hardcoded-tables iconv mp3 network openal opengl postproc pulseaudio sdl threads truetype vaapi -vdpau vorbis x264 x265 xcb xvid zlib static-libs amr amrenc cpudetection faac fdk

tv ~ # cat /etc/portage/package.use/tvheadend
# Tvheadend
media-tv/tvheadend cwc dbus dvb dvbscan timeshift zlib -avahi -capmt -constcw ffmpeg -hdhomerun -imagecache -inotify iptv -libav -satip uriparser xmltv
# X
x11-libs/libxcb xkb
# VLC
sys-libs/zlib minizip
```

- Unmask FFMPEG (para que compile la 3.x)

```console
tv ~# cat /etc/portage/package.unmask/ffmpeg
media-video/ffmpeg
```

- Me aseguro de tener preparado el Kernel según comenta en este enlace https://wiki.gentoo.org/wiki/Intel (yo uso Kernel 4.x)

```config
Processor type and features  --->
    [*] MTRR (Memory Type Range Register) support

 Device Drivers  --->
            Graphics support  --->
                <*> /dev/agpgart (AGP Support)  --->
                    --- /dev/agpgart (AGP Support)
                    < >   AMD Opteron/Athlon64 on-CPU GART support
                    -*- Intel 440LX/BX/GX, I8xx and E7x05 chipset support
                    < >   SiS chipset support
                    < >   VIA chipset support
                [ ] VGA Arbitration
                [ ] Laptop Hybrid Graphics - GPU switching support
                <*> Direct Rendering Manager (XFree86 4.1.0 and higher DRI support)  --->
                    --- Direct Rendering Manager (XFree86 4.1.0 and higher DRI support)
                    [*]   Enable legacy fbdev support for your modesetting driver
                [ ] Allow to specify an EDID data set instead of probing for it
                    I2C encoder or helper chips  --->
                < > 3dfx Banshee/Voodoo3+
                < > ATI Rage 128
                < > ATI Radeon
                < > AMD GPU
                < > Nouveau (NVIDIA) cards
                < > Intel I810
                <*> Intel 8xx/9xx/G3x/G4x/HD Graphics
                [ ]   Enable preliminary support for prerelease Intel hardware by default
                < > Matrox g200/g400
                < > SiS video cards
                < > Via unichrome video cards
                < > Savage video cards
                < > Virtual GEM provider
                < > DRM driver for VMware Virtual GPU
                < > Intel GMA5/600 KMS Framebuffer
                < > DisplayLink
                < > AST server chips
                < > Kernel modesetting driver for MGA G200 server engines
                < > Cirrus driver for QEMU emulated device
                < > QXL virtual GPU
                < > DRM Support for bochs dispi vga interface (qemu stdvga)
                    Display Panels  -- 
                    Display Interface Bridges  --
                    Frame buffer Devices  --->
                -*- Backlight & LCD device support  --->
                    Console display driver support  --->
                [*] Bootup logo  --->
```

Rearranco el equipo y continúo.

- Fuerzo que se recompile todo, con los **nuevos flags de USE**, las librerías de **libva y ffmpeg**

```console
tv ~ # emerge -DuvN system world ffmpeg
```

- Compilo Xorg-server

```console
tv ~ # emerge -v xorg-server
```

- Arranco Xorg

```console
tv ~ # startx
```

- Desde la CONSOLA X11 ejecuto 'vainfo'

```console
(( No hace falta, pero podrías necesitar hacer: export LIBVA_DRIVER_NAME=i965 ))
# vainfo
libva info: VA-API version 0.39.2
libva info: va_getDriverName() returns 0
libva info: Trying to open /usr/lib64/va/drivers/i965_drv_video.so
libva info: Found init function __vaDriverInit_0_39
libva info: va_openDriver() returns 0
vainfo: VA-API version: 0.39 (libva 1.7.2.pre1)
vainfo: Driver version: Intel i965 driver for Intel(R) Broadwell - 1.7.2.pre1 (1.7.0-53-gbcde10d)
vainfo: Supported profile and entrypoints
      VAProfileMPEG2Simple            :    VAEntrypointVLD
      VAProfileMPEG2Simple            :    VAEntrypointEncSlice
      VAProfileMPEG2Main              :    VAEntrypointVLD
      VAProfileMPEG2Main              :    VAEntrypointEncSlice
      VAProfileH264ConstrainedBaseline:    VAEntrypointVLD
      VAProfileH264ConstrainedBaseline:    VAEntrypointEncSlice
      VAProfileH264Main               :    VAEntrypointVLD
      VAProfileH264Main               :    VAEntrypointEncSlice
      VAProfileH264High               :    VAEntrypointVLD
      VAProfileH264High               :    VAEntrypointEncSlice
      VAProfileH264MultiviewHigh      :    VAEntrypointVLD
      VAProfileH264MultiviewHigh      :    VAEntrypointEncSlice
      VAProfileH264StereoHigh         :    VAEntrypointVLD
      VAProfileH264StereoHigh         :    VAEntrypointEncSlice
      VAProfileVC1Simple              :    VAEntrypointVLD
      VAProfileVC1Main                :    VAEntrypointVLD
      VAProfileVC1Advanced            :    VAEntrypointVLD
      VAProfileNone                   :    VAEntrypointVideoProc
      VAProfileJPEGBaseline           :    VAEntrypointVLD
      VAProfileVP8Version0_3          :    VAEntrypointVLD
```

- Para probar la aceleración instalo MPV

```console
marte ~ # emerge -v mpv
```

- Ejecuto MPV e intento abrir un stream de video. Todo esto en la consola GUI del servidor.

```console
marte ~ # gpasswd -a luis video
marte ~$ mpv
```

**Comprobar que FFMPEG consume la GPU con VAAPI**

- Vamos a por la segunda *base*, comprobar que `ffmpeg` es capaz de realizar una transcodificación delegándoselo a la GPU. Para comprobarlo necesitas instalar una herramienta de intel llamada `intel_gpu_tool`

```console
marte ~ # emerge -v intel-gpu-tools
```

-  A partir de aquí NO necesitamos X11, es decir, trabajamos en modo headless. En mi ejemplo he usado una película ripeada a 1080FullHD con H264 y audio AC3. El objetivo es transcodificarla pero sobre todo que lo haga la GPU. El soporte de VAAPI en FFMPEG se incluyo hace muy poco tiempo.

```console
marte ~ # ffmpeg -vaapi_device /dev/dri/renderD128 -i CA.mpeg -vf 'format=nv12,hwupload' -c:v h264_vaapi output.mkv
```

{% include showImagen.html
    src="/assets/img/posts/ffmpegGPUuse.png"
    caption="Ejecución de ffmpeg"
    width="600px"
    %}

- Aquí viene la verdadera comprobación, ejecuto `intel_gpu_tool` en otra sesión de terminal para comprobar que **efectivamente se está consumiendo la GPU (Hardware gráfico de Intel QSV)**

```console
marte ~ # intel_gpu_top
```

{% include showImagen.html
    src="/assets/img/posts/intel_gpu_tool.png"
    caption="Salida de la herramienta intel_gpu_tool"
    width="600px"
    %}

<br/>

### Soporte nativo de Intel QSV+VAAPI en Linux (Ubuntu 16.04 LTS)

En esta sección describo cómo he instalado FFMPEG + VAAPI para un Servidor (headless).

Instalación de ffmpeg ([fuente](https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu)). Otros enlaces de interes son [este](https://gist.github.com/Brainiarc7/95c9338a737aa36d9bb2931bed379219) y [este](https://tvheadend.org/boards/5/topics/22670). 


Por desgracia nunca conseguí evolucionar y por tanto documentar esta opción.

<br/>

### Tvheadend con soporte nativo VAAPI

**Esta es la sección buena**, aunque se quedó como un *work in progress* indefinido, era la opción que queremos que funcione, aunque todavía no lo hace :-(

El objetivo aquí es sencillo, que Tvheadend incorpore el soporte de forma nativa para acceder a QSV mediante VAAPI directamente, recuerda que QSV – Intel QuickSync Video – permite usar las capacidades Hardware de procesamiento multimedia de la tarjeta fráfica de los procesadores Intel y la clave aquí es cómo acceder a dicho Hardware, en concreto cómo acceder al device driver. El método limpio y sencillo que no requiere tocar el kernel ni usar entornos cerrados de desarrollo es mediante [VA API](https://en.wikipedia.org/wiki/Video_Acceleration_API) y eso es precisamente lo que necesitamos en Tvheadend, soporte del VA API directo (Video Acceleration API). En FFMPEG ya está hecho, soporta usar VA API, pero… nos falta que Tvheadend lo soporte.

Para conseguirlo es necesario que los desarrolladores de Tvheadend modifiquen el código. Parece que no es demasiado complicado pero obviamente tienen muchas peticiones y tendrán que priorizar. Si tienes un procesador Intel con una tarjeta gráfica embebida de las soportadas te invito a registrarte en Tvheadend y pidas en este hilo [#3831](https://tvheadend.org/issues/3831) que lo implementen, como todo, cuantos más lo pidan mejor 🙂

Nota: A paritr de aquí y hasta el final de esta sección sobre Tvheadend y VAAPI está "**Work in Progress (Julio 2016)**", es decir que iré añadiendo pruebas y documentación...

Nota: FFmpeg puede [usar QSV](https://www.ffmpeg.org/general.html#Intel-QuickSync-Video) para realizar codificación y decodificación de múltiples códex en hardware. Para poder usar QSV Tvheadend debe linkarse contra el libmfx dispatcher y este a su vez  se encarga de cargar las librerías de de-codificación (creo que son las libva*). Este dispatcher es un proyecto open source disponible en [mfx_dispatch.git](https://github.com/lu-zero/mfx_dispatch.git).

El soporte de VAAPI en Tvheadend no está completo de momento, usas el pix_fmt incorrecto (esto es sencillo de arreglar) y no configura el dispositivo DRM. Lo dicho, necesita que un desarrollador lo arregle.

Para entender cómo hacer pruebas con esta versión en desarrollo te recomiendo leer la sección siguiente "Compilación manual de Tvheadend" y luego hasta llegar las "Pruebas Agosto 2016" donde describo lo último que estoy probando (una branch especial de 'lekma')

<br/>

## Compilación manual de Tvheadend

En esta sección documento cómo estoy compilando [Tvheadend «a pelo» desde GitHub](https://github.com/tvheadend/tvheadend), en vez de usar emerge porque me permite ir haciendo pruebas con las distintas liberías (elegir usar las del sistema o las de SDK) y además estar seguro de usar el último código de Tvheadend.



Notar que utilizo  **`configure`** con la opción **`--enable-qsv`** que provoca que se instalen ffmpeg con las opciones que necesitamos (`--enable-libx264 --enable-libx265 **--enable-vaapi** **--enable-libmfx**`), entre otras.

```console
# mkdir /root/github_tvh
# cd github_tvh
# git clone https://github.com/tvheadend/tvheadend.git
# cd tvheadend
# pwd
/root/github_tvh/tvheadend
# ./configure --prefix=/usr --build=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu --mandir=/usr/share/man --infodir=/usr/share/info \
  --datadir=/usr/share --sysconfdir=/etc --localstatedir=/var/lib --libdir=/usr/lib64 --prefix=/usr --datadir=/usr/share --enable-qsv
Checking support/features
```

- La salida del comando completa la tienes [aquí](https://gist.github.com/LuisPalacios/357bf48a56cc43b030b66ad3e04909cf).

Se baja y compila `hdhomerun`. Cuando termina deja el ejecutable en `./build.linux/`

El siguiente paso es instalarlo en tu sistema:

```console
# make install
```

En mi caso (ver los argumentos de `./configure`) dejo el ejecutable en `/usr/bin`, es decir en el mismo sitio donde lo deja `emerge` en Gentoo. Si quieres mantener ambos deberías renombrar uno de los dos o configurar que la versión manual se instale en otro sitio.

**Librerías FFMPEG que se Linkan estáticamente al ejecutable**

En la compilación **manual de Tvheadend** estamos creando un **ejecutable con muchas librerías linkadas estáticamente dentro del mismo**, es decir **no utiliza esas librerias de tu sistema operativo sino que compila su propia copia de FFMPEG y sus librerías para linkarlas al ejecutable.** No me gusta demasiado, pero la ventaja es que evita conflictos y que podrías tener varias versiones de Tvheadend para hacer pruebas. Estas son las dependencias de FFMpeg que linka estáticamente (fecha Julio 2016):

```console
marte tvheadend # cd build.linux/ffmpeg/
marte ffmpeg # ls -al
total 20400
drwxr-xr-x 13 root root    4096 jul  5 20:51 .
drwxr-xr-x  5 root root    4096 jul  5 20:56 ..
-rw-r--r--  1 root root  112281 jul  5 20:51 9f4a84d73fb73d430f07a80cea3688c424439f6a.tar.gz
drwxr-xr-x  3 root root    4096 jul  5 20:46 build
drwxr-xr-x 15 1000 1000    4096 jul  5 20:51 fdk-aac-0.1.4
-rw-r--r--  1 root root 1986515 mar 11  2015 fdk-aac-0.1.4.tar.gz
drwx------ 16 1000 1000    4096 jul  5 20:55 ffmpeg-3.1
-rw-r--r--  1 root root 9329359 jun 27 02:26 ffmpeg-3.1.tar.bz2
drwxrwxr-x  7  500  500    4096 jul  5 20:50 libogg-1.3.2
-rw-r--r--  1 root root  550250 may 27  2014 libogg-1.3.2.tar.gz
drwxrwxrwx 11  500  500    4096 jul  5 20:50 libtheora-1.1.1
-rw-r--r--  1 root root 2111877 ene 25  2010 libtheora-1.1.1.tar.gz
drwxr-xr-x 13  501   20    4096 jul  5 20:50 libvorbis-1.3.5
-rw-r--r--  1 root root 1638779 mar  3  2015 libvorbis-1.3.5.tar.gz
drwxr-xr-x 15 root root    4096 jul  5 20:50 libvpx-1.5.0
-rw-r--r--  1 root root 1906571 nov 10  2015 libvpx-1.5.0.tar.bz2
drwxrwxr-x  7 root root    4096 jul  5 20:51 mfx_dispatch-9f4a84d73fb73d430f07a80cea3688c424439f6a
drwxr-xr-x 10 1000 1000    4096 jul  5 20:47 x264-snapshot-20160502-2245
-rw-r--r--  1 root root  730104 may  2 22:45 x264-snapshot-20160502-2245.tar.bz2
drwxr-xr-x  5 root root    4096 jul  5 20:49 x265_1.9
-rw-r--r--  1 root root  956101 feb  5 05:20 x265_1.9.tar.gz
drwxrwxr-x 13 1000 1000    4096 jul  5 20:46 yasm-1.3.0
-rw-r--r--  1 root root 1492156 ago 11  2014 yasm-1.3.0.tar.gz
```

<br/> 

#### Liberías o paquetes que espera encontrar en el Sistema Operativo

Por otro lado hay una serie de apquetes que espera encontrar en el Sistema Operativo (lo indica durante la ejecución de `./configure`)

```config
Packages:
  openssl                                  1.0.2h
  zlib                                     1.2.8
  liburiparser                             0.8.0
  avahi-client                             0.6.32
  libva                                    0.39.2
  libva-x11                                0.39.2
  libva-drm                                0.39.2
  dbus-1                                   1.10.8
```

Y de ellos el más importante es `libva`

```config
  libva                                    0.39.2
  libva-x11                                0.39.2
  libva-drm                                0.39.2
```
 
<br/>

#### Transcodificar por HW

Como comenté al principio de este apunte Tvheadend puede usar libva (vaapi) pero por desgracia luego no funciona. Tras la compilación manual verás múltiples opciones muy interesantes.

{% include showImagen.html
    src="/assets/img/posts/TransOptions-300x185.png"
    caption="Trans Options"
    width="300px"
    %}

Puedo poner la de h264_vaapi, pero ...

{% include showImagen.html
    src="/assets/img/posts/TransVAAPI-1024x694.png"
    caption="Trans VA API"
    width="600px"
    %}


...pero **de momento nos da este ERROR**

```console
**jul 05 21:22:13 marte tvheadend[15699]: libav: mmco: unref short failure
jul 05 21:22:13 marte tvheadend[15699]: transcode: 0003: Using preset faster
jul 05 21:22:13 marte tvheadend[15699]: libav: Error initializing an internal MFX session
jul 05 21:22:13 marte tvheadend[15699]: transcode: 0003: Unable to open h264_qsv encoder**
```
 
<br/>

#### Transcodificar por Software (solución temporal)

Tras varias pruebas he conseguido configurar un perfil de transcodificación (**software**) que funciona **bastante bien** cuando sólo se usa para un único usuario, un único stream y sobre todo "en casos especiales", por ejemplo ver la TV desde una tablet cuando no queda más remedio o para verlo conectado por internet. OJo!, es **sub-óptimo** y como lo fuerces mucho (varios usuarios) te empezará a fallar.

Desde mi punto de vista es una solución **TEMPORAL hasta que Tvheadend soporte FFMPEG con VAAPI**.

{% include showImagen.html
    src="/assets/img/posts/TransSW-300x283.png"
    caption="Transcodificación por SW"
    width="300px"
    %}

A continuación podemos ver un gráfico con el consumo de CPU utilizando la **transcodificación Software "veryfast", 720 bps video y 64bps audio**:. Como se puede ver en la parte superior izquierda, la herramienta intel_gpu_tool indica que NO ESTÁ haciendo nada, es decir, funciona todo por Software, como demuestra **htop**, donde aproximadamente el 25% de los vCores están dedicados a transcodificar.

{% include showImagen.html
    src="/assets/img/posts/transSW-1024x576.jpg"
    caption="Gráfico de consumo"
    width="600px"
    %}

El ancho de banda medio consumido es de 750-800Kbps, con ráfaga que llegan a los 2Mbps. En el siguiente gráfico puedes observar en Verde el stream de entrada (un Canal HD) y en Morado el stream de Salida transcodificado.

{% include showImagen.html
    src="/assets/img/posts/transbw.png"
    caption="Ancho de banda consumido"
    width="600px"
    %}

<br/>

#### Pruebas Agosto 2016

He descargado el Fork de [lekma](https://github.com/lekma/tvheadend) que según el hilo «[Feature #3831: VAAPI Encoding via FFmpeg](https://tvheadend.org/issues/3831#change-19620)» tiene una branch (codecs) que podría ser la primera versión que funciona, comentan que ha hecho un trabajo impresionante en la reimplementación del sistema de codecs. Estos son los pasos que he seguido en mi prueba:


Me salvo el antiguo tvheadend añadiendole la versión que tenía compilada:

```console
marte ~ # cd /usr/bin
marte bin # cp tvheadend tvheadend-4.1-2130~g55fec0f-dirty
```

En un nuevo directorio clono el fork y lo compilo, el proceso es idéntico a lo que describí más arriba.

```console
marte ~ # mkdir /root/github_tvh_lekma
marte ~ # cd /root/github_tvh_lekma/
marte github_tvh_lekma # git clone https://github.com/lekma/tvheadend.git

marte github_tvh_lekma # cd tvheadend/
```

**Importante: cambio al branch "codecs"**

```console
marte github_tvh_lekma # git checkout codecs
```

Compilo (importante usar --enable-vaapi), y luego instalo.

```console
marte tvheadend # ./configure --prefix=/usr --build=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu --mandir=/usr/share/man --infodir=/usr/share/info \
  --datadir=/usr/share --sysconfdir=/etc --localstatedir=/var/lib --libdir=/usr/lib64 --prefix=/usr --datadir=/usr/share --enable-vaapi
:
marte tvheadend # make
```

Me hago una copia del ejecutable antiguo e instalo el nuevo

```console
# make install
:
marte tvheadend # ls -al /usr/bin/tvheadend*
-rwxr-xr-x 1 root root 51212936 sep 31 21:58 /usr/bin/tvheadend  <== nuevo 
-rwxr-xr-x 1 root root 49980584 ago 31 21:17 /usr/bin/tvheadend-4.1-2140~gf34fac1
-rwxr-xr-x 1 root root 51212936 ago 31 21:00 /usr/bin/tvheadend-4.1-2202~gf3e5bfb  <== nuevo
```

Hago un backup de la configuración (aunque al arrancar la nueva versión automáticamente haga su propio backup en /etc/tvheadend/backup).

```console
# cd /etc
# tar cfz /root/tvheadend-backup.tgz tvheadend/
```

Arranco el log desde otra sesión:

```console
# journalctl -f
```

y rearranco tvheadend

```console
# systemctl restart tvheadend
```

Creo 2 nuevos **Codec Profiles** (nuevo en esta branch, 1xVideo y 1xAudio), creo un nuevo **Stream Profile** al que asigno los dos Codec Profiles anteriores. He creado un usuario nuevo al que le asigno el Stream Profile y desde un cliente conecto usando este usuario.

Arranco **intel_gpu_top y htop** en dos terminales y conecto desde el cliente. 

Actualizar la versión: Si más adelante van actualizando esta branch, para sincronizar con ella simplemente haz un pull con git y vuelve a compilar

```console
marte tvheadend # git fetch
remote: Counting objects: 68, done.
remote: Total 68 (delta 47), reused 47 (delta 47), pack-reused 21
Unpacking objects: 100% (68/68), done.
From https://github.com/lekma/tvheadend
   f3e5bfb..dbdd70f  codecs     -> origin/codecs
marte tvheadend # git pull
Updating f3e5bfb..dbdd70f
Fast-forward
 src/profile.c                               | 25 
 src/transcoding/codec/codecs/libs/libx26x.c |  2 ++
 src/transcoding/codec/codecs/libs/vaapi.c   |  3 +++
 src/transcoding/codec/internals.h           |  1 -
 src/transcoding/codec/profile_video_class.c | 20 ++++++++++++++++++++
 src/transcoding/transcode/context.c         |  6 
 src/transcoding/transcode/helpers.c         | 32 
 src/transcoding/transcode/internals.h       |  2 +-
 src/transcoding/transcode/video.c           | 52 
 9 files changed, 64 insertions(+), 79 deletions(-)
marte tvheadend #
```
 
<br/> 

### Tvheadend con SDK Quick Sync

He dejado para el final la opción que no me termina de convencer, consiste en usar una distro concreta, con un kernel concreto, instalar el SDK de Intel, parchear el kernel, compilar Tvheadend a mano y **en funciona, aunque puede que no en todos los chips de Intel (parece que Skylake es un ejemplo donde NO funciona)**. Ojo, aunque he conseguido que funcione (la transcodificación por Hardware) veo que sigue consumiendo demasiada CPU y además no consigo que más de un cliente funcionen bien, así que lo dicho, aunque no me convence pero tendré que probarlo más en profundidad algún día.

{% include showImagen.html
    src="/assets/img/posts/nuc-d54250wyk-mss.jpg"
    caption="NUC as a Media Server Studio"
    width="400px"
    %}

- Distro. CentOS 7.1.1503 (sí, es la versión concreta que Intel llama Gold)
- Entorno de desarrollo. Regístrate como desarrollador al [Intel® Media Server Studio – Community Edition](https://registrationcenter.intel.com/en/forms/?productid=2411%29), descarga la versión Intel® Media Server Studio for Linux (199 MB) y copiala a tu Distro (se instala en `/opt/intel/mediasdk/lib64/*`).
- Parches del Kernel. Los instalará el SDK de Intel
- Tvheadend, compilarlo manulamente.

Para probar esta opción voy a crear un Disco con CentOS 7.1.1503 en una USB para no tocar mi instalación en el NUC. Forzaré que haga boot desde dicha USB mientras realizo las pruebas. Nota: Uso USB's 3.0 o esto sería inmanejable :)

#### Instalo CentOS

- Requisitos - 2xUSB's 3.0,
    - USB1: ISO de Instalación de CentOS
    - USB2: Disco destino donde instalaré CentOS
- Preparo la USB1: ISO de Instalación de CentOS
    - Descargo CentOS 7.1.1503 desde http://mirror.nsc.liu.se/centos-store/7.1.1503/isos/x86_64/
    - Creo una USB Bootable, la inserto en mi iMac.
    - Averiguo el device con 'df -h' (resultó ser /dev/disk2)
    - Desmonto el volumen: sudo diskutil unmount /dev/disk2s1
    - Grabo el ISO (notar la 'r'): dd if=CentOS-7-x86_64-DVD-1503-01.iso of=/dev/rdisk2 bs=4194304
- Instalación de CentOS
    - Inserto la USB1 en el NUC (CentOS Install Boot)
    - Inserto la USB2 en el NUC (futuro disco destino)
    - Rearranco el NUC y pulso F10 para elegir desde dónde hacer boot (USB1)
    - Arranco con el ISO de instalación de CentOS
        - Selecciono Install CentOS 7
        - Selecciono como Disco Destino la segunda USB2 (reclamo todo su espacio, particiona automático)
        - Hará una instalación mínima
        - Configuro la Red con IP fija
        - Configuro la contraseña de root y creo un usuario luis
        - Cuando termina, pulso Reiniciar, saco la USB1
- Arranque con USB2 (Donde he instalado CentOS)
    - Al reiniciar pulso F10 para seleccionar la USB2

#### Instalo SDK Intel Media Server Studio

- Uso este [PDF](https://software.intel.com/sites/default/files/media_server_studio_getting_started_guide.pdf) como guía.
- Instalo dependencias

```console
# yum install -y lshw
# yum install -y pciutils
# yum install -y mesa-dri-drivers
# yum install -y net-tools
```

- Verifico que mi HW es compatible

```console
# lshw
 NUC5i5RYB, con Intel(R) Core(TM) i5-5250U CPU @ 1.60GHz
# lspci -nn -s 00:02.0
 00:02.0 VGA compatible controller [0300]: Intel Corporation Broadwell-U Integrated Graphics [8086:1626] (rev 09)
```

- Descargo el SDK Media Server Studio
    - Intel® Media Server Studio – Community Edition Version 2016 (Latest Release)     10 Feb 2016
    - https://registrationcenter.intel.com/en/products/
- NOTA: La IP de mi NUC es 192.168.100.244
    - `$ scp MediaServerStudioEssentials2016.tar.gz luis@192.168.100.244:.`
- Vuelvo al NUC como usuario normal (luis)

```console
$ tar -xvzf MediaServerStudioEssentials2016.tar.gz
$ cd MediaServerStudioEssentials2016
$ tar xzf SDK2016Production16.4.4.tar.gz
$ cd SDK2016Production16.4.4
$ cd CentOS/
$ tar -xzf install_scripts_centos_16.4.4-47109.tar.gz
``

- Como "root"

```console
# cd /home/luis/.../CentOS/
# ./install_sdk_UMD_CentOS.sh
# mkdir /MSS
# chown luis:luis /MSS
```

- Como usuario normal (luis)

```console
# su - luis
$ cd MediaServerStudioEssentials2016/SDK2016Production16.4.4/CentOS/
$ cp build_kernel_rpm_CentOS.sh /MSS
$ cd /MSS
$ ./build_kernel_rpm_CentOS.sh
```

- COMO "root", compruebo que se han generado los RPM's del kernel y los instalo:

```console
# cd /MSS/rpmbuild/RPMS/x86_64/
# ls -al
 total 44052
 drwxr-xr-x. 2 luis luis     4096 jul 12 15:00 .
 drwxrwxr-x. 3 luis luis       19 jul 12 14:59 ..
 -rw-rw-r--. 1 luis luis 32273040 jul 12 15:00 kernel-3.10.0-229.1.2.47109.MSSr1.el7.centos.x86_64.rpm
 -rw-rw-r--. 1 luis luis 10437600 jul 12 15:00 kernel-devel-3.10.0-229.1.2.47109.MSSr1.el7.centos.x86_64.rpm
 -rw-rw-r--. 1 luis luis  2385132 jul 12 15:00 kernel-headers-3.10.0-229.1.2.47109.MSSr1.el7.centos.x86_64.rpm

# rpm -Uvh kernel-3.10.0-229.1.2.47109.MSSr1.el7.centos.x86_64.rpm
```

#### Rearrancar y comprobar que lo hace con el nuevo kernel

Antes de nada miro en ek Kernel estaba,

```console
# uname -a
 Linux marte.parchis.org 3.10.0-229.el7.x86_64 #1 SMP Fri Mar 6 11:36:42 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux

# reboot

# uname -a
 Linux marte.parchis.org 3.10.0-229.1.2.47109.MSSr1.el7.centos.x86_64 #1 SMP Tue Jul 11 23:24:57 CEST 2016 x86_64 x86_64 x86_64 GNU/Linux
                                    ^^^^^^^^^^^^^^^                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

COMPRUEBO QUE CARGA i915
 [root@marte ~]# lsmod | grep 'i915'
 i915                  938476  4
 i2c_algo_bit           13413  1 i915
 drm_kms_helper         98274  1 i915
 drm                   311336  3 i915,drm_kms_helper
 i2c_core               40325  6 drm,i915,i2c_i801,i2c_hid,drm_kms_helper,i2c_algo_bit
 video                  19263  1 i915

[root@marte CentOS]# ls -al /usr/lib64/libva*
 lrwxrwxrwx. 1 root root     21 jul 12 14:04 /usr/lib64/libva-drm.so -> libva-drm.so.1.9900.0
 lrwxrwxrwx. 1 root root     21 jul 12 14:04 /usr/lib64/libva-drm.so.1 -> libva-drm.so.1.9900.0
 -rwxr-xr-x. 1 root root  11344 dic  7  2015 /usr/lib64/libva-drm.so.1.9900.0
 lrwxrwxrwx. 1 root root     21 jul 12 14:04 /usr/lib64/libva-glx.so -> libva-glx.so.1.9900.0
 lrwxrwxrwx. 1 root root     21 jul 12 14:04 /usr/lib64/libva-glx.so.1 -> libva-glx.so.1.9900.0
 -rwxr-xr-x. 1 root root  20120 dic  7  2015 /usr/lib64/libva-glx.so.1.9900.0
 lrwxrwxrwx. 1 root root     17 jul 12 14:04 /usr/lib64/libva.so -> libva.so.1.9900.0
 lrwxrwxrwx. 1 root root     17 jul 12 14:04 /usr/lib64/libva.so.1 -> libva.so.1.9900.0
 -rwxr-xr-x. 1 root root 119248 dic  7  2015 /usr/lib64/libva.so.1.9900.0
 lrwxrwxrwx. 1 root root     21 jul 12 14:04 /usr/lib64/libva-tpi.so -> libva-tpi.so.1.9900.0
 lrwxrwxrwx. 1 root root     21 jul 12 14:04 /usr/lib64/libva-tpi.so.1 -> libva-tpi.so.1.9900.0
 -rwxr-xr-x. 1 root root   6840 dic  7  2015 /usr/lib64/libva-tpi.so.1.9900.0
 lrwxrwxrwx. 1 root root     21 jul 12 14:04 /usr/lib64/libva-x11.so -> libva-x11.so.1.9900.0
 lrwxrwxrwx. 1 root root     21 jul 12 14:04 /usr/lib64/libva-x11.so.1 -> libva-x11.so.1.9900.0
 -rwxr-xr-x. 1 root root  32984 dic  7  2015 /usr/lib64/libva-x11.so.1.9900.0
```

<br/>

#### Ejemplos del SDK

Nota: Esta sección debería conseguir que puedas instalar los ejemplos para comprobar que la transcodificación por HW funciona. Por desgracia no he conseguido que me funcione, dejo la documentación de todas formas. En mi caso lo ignoré y salté a instalar Tvheadend.

```console
# yum install -y gcc g++ make cmake perl libX11-devel mesa-libGL-devel

COMO LUIS
 $ mkdir /MSS
 $ cd /MSS
 $ git clone https://github.com/Intel-Media-SDK/samples.git
 $ cd /MSS/samples/samples
 $ export MFX_HOME=/opt/intel/mediasdk/
 $ perl build.pl --cmake=intel64.make.release --build --clean

$ ls -al __cmake/intel64.make.release/__bin/release/
 total 2024
 drwxrwxr-x. 2 luis luis   4096 jul 12 15:32 .
 drwxrwxr-x. 3 luis luis     20 jul 12 15:32 ..
 -rwxrwxr-x. 1 luis luis 202597 jul 12 15:32 libsample_plugin_opencl.so
 -rwxrwxr-x. 1 luis luis 140752 jul 12 15:32 libsample_rotate_plugin.so
 -rw-rw-r--. 1 luis luis   3976 jul 12 15:32 ocl_rotate.cl
 -rwxrwxr-x. 1 luis luis 409959 jul 12 15:32 sample_decode
 -rwxrwxr-x. 1 luis luis 417292 jul 12 15:32 sample_encode
 -rwxrwxr-x. 1 luis luis 526198 jul 12 15:32 sample_multi_transcode
 -rwxrwxr-x. 1 luis luis 355758 jul 12 15:32 sample_vpp

PROBAR
 [root@marte ~]# cd /MSS/samples/samples/__cmake/intel64.make.release/__bin/release/
 [root@marte release]# wget http://download.openbricks.org/sample/H264/big_buck_bunny_1080p_H264_AAC_25fps_7200K.MP4
 [root@marte release]# mv big_buck_bunny_1080p_H264_AAC_25fps_7200K.MP4 test.mp4
 [root@marte release]# ./sample_multi_transcode -i::h264 test.mp4 -o::h264 test_out.mp4 -hw
```

DA ERROR y NO CONSIGO AVANZAR... !!!!! IGNORO LOS SAMPLES Y PASO A tvheadend...

<br/>

#### Instalo Tvheadend

Preparo dependencias

```console

# yum install -y openssl openssl-devel uriparser-devel dbus dbus-devel
 # yum -y install epel-release
 # yum -y install htop
 # yum install -y intel-gpu-tools

# cd
 # git clone https://github.com/tvheadend/tvheadend.git
 # cd tvheadend

# ./configure --prefix=/usr --build=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu --mandir=/usr/share/man --infodir=/usr/share/info --datadir=/usr/share --sysconfdir=/etc --localstatedir=/var/lib --libdir=/usr/lib64 --prefix=/usr --datadir=/usr/share --enable-qsv
 Checking support/features
 :
```

- La salida del comando completa la tienes [aquí](https://gist.github.com/LuisPalacios/531b9ec5f99a3139517d4fe2095f65a3).

- Añado el usuario "tvheadend"

```console
# useradd -d /home/tvheadend -g video -m -s /usr/bin/bash tvheadend
```

- Copio el directorio de configuración.En otro sistema tenía instalado Tvheadend y configurado en `/etc/tvheadend`, lo que hago es copiarme el directorio de configuración para evitar configurarlo desde cero.

```console
FUENTE:
 cd /etc
 tar czf /tmp/tvheadend.tgz tvheadend

DESTINO
 scp luis@fuente:/tmp/tvheadend.tgz /tmp
 cd /etc
 tar xzf /tmp/tvheadend.tgz
 chown -R tvheadend:video tvheadend
```

- DESACTIVO EL FIREWALL DE CENTOS, viene activo por defecto

```console
# systemctl disable firewalld
 rm '/etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service'
 rm '/etc/systemd/system/basic.target.wants/firewalld.service'
# systemctl stop firewalld
```

- ARRANCO TVHEADEND en un termimal

```console
# /usr/bin/tvheadend -C -u tvheadend -g video -c /etc/tvheadend
```

- ARRANCO intel_gpu_top en otro terminal

```console
# intel_gpu_top
```

- ARRANCO htop en otro terminal

```console
# htop
```

{% include showImagen.html
    src="/assets/img/posts/centosqsv-1024x563.jpg"
    caption="QSV en Centos"
    width="800px"
    %}

- Pendientes de investigar
  - Nota1: No he aplicado ningún parche tal como se menciona [aquí](https://tvheadend.org/issues/3080): 
  - Nota2: No he aplicado el [Fork TheTroll](https://github.com/TheTroll/tvheadend): 
 
<br/>

## Enlaces

Enlaces relacionados con este apunte:

- [Subsistema de aceleración](https://trac.ffmpeg.org/wiki/HWAccelIntro) HW de FFMPEG
- [VA API](https://en.wikipedia.org/wiki/VA_API) (Video Acceleration API) ofrece acceso al hardware gráfico (GPU) para procesamiento de video
- INTEL: Página de descarga del «[Intel® Media Server Studio – Community Edition](https://registrationcenter.intel.com/download.aspx?productid=2813&pass=yes)»
  - Es necesario que estes registrado, podrása bajarte el Intel® Media Server Studio for Linux,
- INTEL: [Open Source](https://github.com/lu-zero/mfx_dispatch) – Intel Media SDK Dispatcher (lu-zero/mfx_dispatch)
- INTEL: [Información](https://01.org/linuxgraphics) – Intel Graphic Stack para diferentes plataformas
- INTEL: [Driver Intel para VAAPI](https://cgit.freedesktop.org/vaapi/intel-driver/)
- Gentoo: [Driver «Intel» open source](https://wiki.gentoo.org/wiki/Intel) para tener acceso a la tarjeta gráfica de los NUC
  - Necesario para montar un entorno X11 acelerado.
  - Incluye una lista interesante de generaciones de tarjetas gráficas que Intel incluye en sus procesadores.
  - Describe modificaciones en el Kernel para acceder a la tarjeta gráfica Intel y usar su driver
- [Gentoo: VAAPI](https://wiki.gentoo.org/wiki/VAAPI)
  - Describe cómo activar VAAPI (Video Acceleration API) en un equipo con Gentoo.
- [Gentoo: Enable hardware H264 decoding on Intel G/GM45](https://wiki.gentoo.org/wiki/Enable_hardware_H264_decoding_on_Intel_G/GM45)
  - Al usar VAAPI solo se pueden decodificar en hardware streams de video MPEG-2 en los chipsets intel G/GM45. En este enlace se habilita la decodificación (experimental) de H.264/AVC en hardware.


Discusiones relevantes en el foro de Tvheadend

- [Primera](https://tvheadend.org/issues/3080) (aunque algo desactualizada). Aquí se habla de los parches para Kernels 3 y 4.1.
  - Versión de prueba de LuisPa de los [parches](https://github.com/LuisPalacios/tvh_qsv) para Kernel 4.6 (ojo todavía no me funcionan)
- [Segunda](https://tvheadend.org/issues/3831) (más interesante y actualizada)

Herramientas

- [mpv](https://wiki.archlinux.org/index.php/mpv), un media player ligero basado en MPlayer. Por si montas el Linux con X11 y necesitas uno reproductor de video ligero.