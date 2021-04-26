---
title: "Plex Media Server en Gentoo"
date: "2014-04-23"
categories: 
  - "gentoo"
tags: 
  - "linux"
  - "plex"
---

[![Plex-Logo](https://www.luispa.com/wp-content/uploads/2014/12/Plex-Logo.png)](https://www.luispa.com/wp-content/uploads/2014/12/Plex-Logo.png) No es muy habitual, pero si tienes un servidor Linux con Gentoo siempre encendido y además quieres ofrecer un fantástico gestor multimedia en tu casa, te recomiendo Plex Media Server.

## Instalación

Necesitas tener instalado Layman. El proceso es sencillo, [gracias al ebuild que ha creado François-Xavier Payet disponible en GitHub](https://github.com/foux/fouxlay) puedes realizarlo sin apenas trabajo:

 
# layman -a fouxlay
# emerge -v plex-media-server
:
\[ebuild N ~\] media-tv/plex-media-server-0.9.9.7::fouxlay 68,137 kB

## Mensajes importantes

 
\* Plex Media Server is now fully installed. Please check the configuration file in /etc/plex if the defaults please your needs.
\* To start please call '/etc/init.d/plex-media-server start'. You can manage your library afterwards by navigating to [http://<ip>:32400/web/](http://%3Cip%3E:32400/web/) \* Please note, that the URL to the library management has changed from http://<ip>:32400/manage to http://<ip>:32400/web!
\* If the new management interface forces you to log into myPlex and afterwards gives you an error that you need to be a plex-pass subscriber please delete the folder WebClient.bundle inside the Plug-Ins folder found in your library!
 

El proceso de instalación crea el usuario "plex" y su directorio HOME está en /var/lib/plexmediaserver.

## Configuración

En mi caso he dejado la configuración por defecto

\# default script for Plex Media Server
# the number of plugins that can run at the same time
PLEX\_MEDIA\_SERVER\_MAX\_PLUGIN\_PROCS=6
# ulimit -s $PLEX\_MEDIA\_SERVER\_MAX\_STACK\_SIZE
PLEX\_MEDIA\_SERVER\_MAX\_STACK\_SIZE=3000
# where the mediaserver should store the transcodes
PLEX\_MEDIA\_SERVER\_TMPDIR=/tmp
# uncomment to set it to something else
# PLEX\_MEDIA\_SERVER\_APPLICATION\_SUPPORT\_DIR="${HOME}/Library/Application\\ Support"
# the user that PMS should run as, defaults to 'plex'
# note that if you change this you might need to move
# the Application Support directory to not lose your
# media library
PLEX\_MEDIA\_SERVER\_USER=plex

Configuro el equipo para que PMS arranque siempre al hacer boot

 
# rd-update add pled-media-server default
 

## Arranque El proceso es sencillo, ejecutamos el script que ha dejado en init.d:

 
# /etc/init.d/plex-media-server start
:
\_\_\_ PROCESOS \_\_\_
plex 15833 1 0 13:02 ? 00:00:00 /bin/sh /usr/sbin/start\_pms
plex 15839 15833 0 13:02 ? 00:00:00 /bin/sh /usr/sbin/start\_pms
plex 15840 15839 49 13:02 ? 00:00:07 ./Plex Media Server
plex 15856 15840 85 13:02 ? 00:00:00 Plex Plug-in \[com.plexapp.system\] /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/Framework.bundle/Contents/Resources/Versions/2/Python/bootstrap.py --server-version 0.9.9.7.429-f80a8d6 /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/System.bundle
 

## Configuración Web

A partir de aquí la gestión de tu PMS se realiza a través de un interfaz Web. A continuación solo tienes que preparar tu librería.
