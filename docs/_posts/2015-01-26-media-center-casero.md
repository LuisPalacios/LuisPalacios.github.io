---
title: "Media Center Casero"
date: "2015-01-26"
categories: tv
tags: media center movistar raspberry xbmc pi linux kodi
excerpt_separator: <!--more-->
---

![logo Kodi](/assets/img/posts/logo-kodi-0.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

Lo de tener un DVD es muy de los 90’s, hoy en día es posible aunar todo en un único Media Center casero con un solo mando para ver canales en streaming por internet, canales TDT o Satélite, Movistar TV, películas de tus DVDs o Series, videos caseros, oir tu música o ver tu colección de fotografías.

<br clear="left"/>
<!--more-->

Suena fácil pero en realidad tiene su truco, hay demasiadas soluciones comerciales o gratuitas con sus ventajas y también sus reparos. Hasta hace poco lo tenía medio resuelto, o eso creía yo, con un [Plex Server](https://plex.tv/) + un [«Chromecast](https://www.google.es/chrome/devices/chromecast/) (+[Plex Cliente](https://support.plex.tv/hc/en-us/sections/200286998-Chromecast))» conectado a cada TV de casa. Es una buena solución, necesita un equipo 24h encendido y ejecutando el «[Plex Media Server (PMS)](https://plex.tv/)» (puede ser en Linux, Mac, Windows o NAS), cada Chromecast cuesta 35€ y funciona muy bien.

#### Los reparos

Acabas con varios mandos (el de la tele, el deco de movistar, el móvil para controlar el plex del chromecast) y cambiando de puertos HDMI cada dos por tres. Otro pero es que **Chromecast usa Wifi** b/n/g y no aguanta bitrates superiores a 4Mbps, obliga al servidor a transcodificar e incluso con ciertas pelis (de muy alto bitrate) a veces sufre paradas intermitentes en el audio o en el video. El último reparo es que encima no puedo integrar fuentes de Televisión por Satélite desde un sintonizador externo.

Aún así, si tienes un linux o una NAS dedicado, la solución de Plex es muy buena, su interfaz y la experiencia del usuario son simplemente "excepcionales".

## Raspberry Pi con XBMC

Decidí probar algo distinto y empecé con la Raspberry Pi 1.2 B+ junto con la distribución OpenElec (XBMC) capaz de soportar todas mis necesidades multimedia caseras (si quieres algo más potente échale un ojo a «[Vero](https://getvero.tv/)» (~220€)). Importante: A principios de Febrero de 2015 los de Raspberry sacaron la [versión 2 del equipo: Raspberry Pi 2 Model B v1.1](http://www.raspberrypi.org/raspberry-pi-2-on-sale/) que de momento está en oferta al mismo precio que la versión anterior (Raspberry Pi 1.2 B+ aprox. 35€)

{% include showImagen.html
    src="/assets/img/original/mediacenter1-1024x520.png"
    caption="mediacenter"
    width="600px"
    %}

La **Raspberry Pi** es un "ordenador generico" muy barato (empieza en ~35€ y puedes llegar a 80-90€ sumando fuente de alimentación, cable hdmi, usb, disipadores, caja, etc..). La idea es conectar una por cada TV y conseguir un gestor multimedia "multiusos" muy extensible, puede conectarse por ethernet (recomendado), también soporta wifi y sus fuentes son múltiples: música, fotos, videos familiares (SD o HD), películas (SD o HD), receptores de Televisión (SD o HD) con sintonización por TDT, Satélite o IPTV.

La Raspberry Pi 1.2 B+ (la llamaré versión 1) soporta videos de aprox. ~40Mbps, un bitrate más alto le cuesta. Recomiendo usar "openelec" versión 4.0.2 que puede descargarse vía NOOBs en la web de Raspberry (versiones más modernas no me han dado tan buen resultado).

La Raspberry Pi 2 Model B v1.1 (versión 2) soporta videos con los mismos bitrates dado que la tarjeta LAN es la misma que en la versión anterior (~40Mbps). Si quieres más información te recomiendo que pases al apunte, ([Media Center Pi+KODI/XBMC]({% post_url 2015-01-31-media-center %})), donde entro en detalle con ejemplos de uso.


