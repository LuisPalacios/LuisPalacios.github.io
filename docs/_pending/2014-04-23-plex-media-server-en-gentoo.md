---
title: "Plex Media Server en Gentoo"
date: "2014-04-23"
categories: gentoo
tags: linux plex
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/Plex-Logo.png"
    caption="Plex-Logo"
    width="600px"
    %}

## Instalación

{% include showImagen.html
    src="/assets/img/original/fouxlay"
    caption="gracias al ebuild que ha creado François-Xavier Payet disponible en GitHub"
    width="600px"
    %}

 
# layman -a fouxlay
# emerge -v plex-media-server
:
[ebuild N ~] media-tv/plex-media-server-0.9.9.7::fouxlay 68,137 kB

## Mensajes importantes

 
* Plex Media Server is now fully installed. Please check the configuration file in /etc/plex if the defaults please your needs.
{% include showImagen.html
    src="/assets/img/original/"
    caption="http://<ip>:32400/web/"
    width="600px"
    %}
* If the new management interface forces you to log into myPlex and afterwards gives you an error that you need to be a plex-pass subscriber please delete the folder WebClient.bundle inside the Plug-Ins folder found in your library!
 

El proceso de instalación crea el usuario "plex" y su directorio HOME está en /var/lib/plexmediaserver.

## Configuración

En mi caso he dejado la configuración por defecto

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

Configuro el equipo para que PMS arranque siempre al hacer boot

 
# rd-update add pled-media-server default
 

## Arranque El proceso es sencillo, ejecutamos el script que ha dejado en init.d:

 
# /etc/init.d/plex-media-server start
:
___ PROCESOS ___
plex 15833 1 0 13:02 ? 00:00:00 /bin/sh /usr/sbin/start_pms
plex 15839 15833 0 13:02 ? 00:00:00 /bin/sh /usr/sbin/start_pms
plex 15840 15839 49 13:02 ? 00:00:07 ./Plex Media Server
plex 15856 15840 85 13:02 ? 00:00:00 Plex Plug-in [com.plexapp.system] /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/Framework.bundle/Contents/Resources/Versions/2/Python/bootstrap.py --server-version 0.9.9.7.429-f80a8d6 /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/System.bundle
 

## Configuración Web

A partir de aquí la gestión de tu PMS se realiza a través de un interfaz Web. A continuación solo tienes que preparar tu librería.
