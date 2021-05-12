---
title: "Plex Media Server"
date: "2014-04-23"
categories: tv
tags: linux gentoo plex
excerpt_separator: <!--more-->
---


![logo plex](/assets/img/posts/logo-pms.png){: width="150px" style="float:left; padding-right:25px" } 

Plex Media Server te permite transformar el ordenador en un centro multimedia. Va a utilizar los contenidos y fuentes digitales que disponga, por ejemplo los archivos u otras fuentes multimedia. Organiza los contenidos en diferentes secciones para servirlos hacia los clientes.


<br clear="left"/>
<!--more-->


## Instalación

A continuación muestro el proceso de instalación

``` 
# layman -a fouxlay
# emerge -v plex-media-server
:
[ebuild N ~] media-tv/plex-media-server-0.9.9.7::fouxlay 68,137 kB
```

Una vez que termina muestra el mensaje `Plex Media Server is now fully installed...` y ya podremos conectar con él a través de un navegador:`http://<ip>:32400/web/`

El proceso de instalación crea el usuario "plex" y su directorio HOME está en `/var/lib/plexmediaserver`

## Configuración

En mi caso he dejado la configuración por defecto

```bash
# default script for Plex Media Server
# the number of plugins that can run at the same time
PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
# ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE
PLEX_MEDIA_SERVER_MAX_STACK_SIZE=3000
# where the mediaserver should store the transcodes
PLEX_MEDIA_SERVER_TMPDIR=/tmp
# uncomment to set it to something else
# PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="${HOME}/Library/Application\ Support"
# the user that PMS should run as, defaults to 'plex'
# note that if you change this you might need to move
# the Application Support directory to not lose your
# media library
PLEX_MEDIA_SERVER_USER=plex
```

Configuro el equipo para que el servicio arranque siempre al hacer boot

```console 
# rd-update add pled-media-server default
```

El proceso de arranque es sencillo, ejecutamos el script que ha dejado en init.d:

```bash
# /etc/init.d/plex-media-server start
:
___ PROCESOS ___
plex 15833 1 0 13:02 ? 00:00:00 /bin/sh /usr/sbin/start_pms
plex 15839 15833 0 13:02 ? 00:00:00 /bin/sh /usr/sbin/start_pms
plex 15840 15839 49 13:02 ? 00:00:07 ./Plex Media Server
plex 15856 15840 85 13:02 ? 00:00:00 Plex Plug-in [com.plexapp.system] /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/Framework.bundle/Contents/Resources/Versions/2/Python/bootstrap.py --server-version 0.9.9.7.429-f80a8d6 /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/System.bundle
```


A partir de aquí la gestión de tu PMS se realiza a través de un interfaz Web. A continuación solo tienes que preparar tu librería.
