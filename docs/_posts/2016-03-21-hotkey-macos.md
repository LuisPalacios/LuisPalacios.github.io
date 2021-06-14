---
title: "Hotkey para Apps de MacOS"
date: "2016-03-21"
categories: herramientas
tags: finder hotkey macos osx pathfinder
excerpt_separator: <!--more-->
---



![logo hotkey](/assets/img/posts/logo-hotkey.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

Necesito poder, independientemente de qué aplicación tenga el foco, abrir un programa presionando una HotKey. Como es lógico las aplicaciones no suelen traer dicha opción pero hay casos donde podría venir bien.

<br clear="left"/>
<!--more-->

Voy a usar como ejemplo la aplicación PathFinder. Mi objetivo es que se abra esta aplicación en cuanto pulse una combinación concreta de teclas. Para configurar una HotKey para arrancar una aplicación simplemente tenemos que usar el Automator y las Preferencias del teclado del sistema. Arranca el programa `Automator`

{% include showImagen.html
    src="/assets/img/posts/automator1.png"
    caption="Programa Automator"
    width="800px"
    %}

- Crea un Servicio nuevo,

{% include showImagen.html
    src="/assets/img/posts/automator2.png"
    caption="Crea un servicio nuevo "
    width="800px"
    %}

Asociamos la pulsación de una tecla con una App.

- Automator: Documento nuevo
- Seleccionar las condiciones: sin datos de entrada, en cualquier aplicación
- Arrastrar *Abrir Aplicación* y seleccionar la aplicación a abrir
- Salvar el Servicio coo "Arrancar Path Finder"

{% include showImagen.html
    src="/assets/img/posts/automator3.png"
    caption="Asociamos la tecla"
    width="600px"
    %}

