---
title: "Media Center casero"
date: "2015-01-26"
categories: apuntes media-center raspberry-pi
tags: kodi media-center raspberry xbmc
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/?p=1225"
    caption="Movistar TV"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/)" (puede ser en Linux, Mac, Windows o NAS"
    caption="Plex Server](https://plex.tv/) + un "[Chromecast](https://www.google.es/chrome/devices/chromecast/) (+[Plex Cliente](https://support.plex.tv/hc/en-us/sections/200286998-Chromecast))" conectado a cada TV de casa. Es una buena solución, necesita un equipo 24h encendido y ejecutando el "[Plex Media Server (PMS)"
    width="600px"
    %}

#### Los reparos

Acabas con varios mandos (el de la tele, el deco de movistar, el móvil para controlar el plex del chromecast) y cambiando de puertos HDMI cada dos por tres. Otro pero es que **Chromecast usa Wifi** b/n/g y no aguanta bitrates superiores a 4Mbps, obliga al servidor a transcodificar e incluso con ciertas pelis (de muy alto bitrate) a veces sufre paradas intermitentes en el audio o en el video. El último reparo es que encima no puedo integrar fuentes de Televisión por Satélite desde un sintonizador externo.

Aún así, si tienes un linux o una NAS dedicado, la solución de Plex es muy buena, su interfaz y la experiencia del usuario son simplemente "excepcionales".

## Raspberry Pi con XBMC

{% include showImagen.html
    src="/assets/img/original/) que de momento está en oferta al mismo precio que la versión anterior (Raspberry Pi 1.2 B+ aprox. 35€"
    caption="Vero](https://getvero.tv/)" (~220€)). **Importante:** A principios de Febrero de 2015 los de Raspberry sacaron la [versión 2 del equipo: Raspberry Pi 2 Model B v1.1"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/mediacenter1-1024x520.png"
    caption="mediacenter"
    width="600px"
    %}

La **Raspberry Pi** es un "ordenador generico" muy barato (empieza en ~35€ y puedes llegar a 80-90€ sumando fuente de alimentación, cable hdmi, usb, disipadores, caja, etc..). La idea es conectar una por cada TV y conseguir un gestor multimedia "multiusos" muy extensible, puede conectarse por ethernet (recomendado), también soporta wifi y sus fuentes son múltiples: música, fotos, videos familiares (SD o HD), películas (SD o HD), receptores de Televisión (SD o HD) con sintonización por TDT, Satélite o IPTV.

La Raspberry Pi 1.2 B+ (la llamaré versión 1) soporta videos de aprox. ~40Mbps, un bitrate más alto le cuesta. Recomiendo usar "openelec" versión 4.0.2 que puede descargarse vía NOOBs en la web de Raspberry (versiones más modernas no me han dado tan buen resultado).

{% include showImagen.html
    src="/assets/img/original/?p=1284"
    caption="Media Center: Raspberry Pi + XBMC"
    width="600px"
    %}
