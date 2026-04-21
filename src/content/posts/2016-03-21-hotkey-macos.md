---
title: "Hotkey para Apps de MacOS"
date: "2016-03-21"
categories: ["herramientas"]
tags: ["finder","hotkey","macos","osx","pathfinder"]
draft: false
cover:
  image: "/img/posts/logo-hotkey.svg"
  hidden: true
---



<img src="/img/posts/logo-hotkey.svg" alt="logo hotkey" width="150px" height="150px" style="float:left; padding-right:25px"  />

Necesito poder, independientemente de qué aplicación tenga el foco, abrir un programa presionando una HotKey. Como es lógico las aplicaciones no suelen traer dicha opción pero hay casos donde podría venir bien.

<br clear="left"/>
<!--more-->

Voy a usar como ejemplo la aplicación PathFinder. Mi objetivo es que se abra esta aplicación en cuanto pulse una combinación concreta de teclas. Para configurar una HotKey para arrancar una aplicación simplemente tenemos que usar el Automator y las Preferencias del teclado del sistema. Arranca el programa `Automator`

<div class="image-box">
  <img src="/img/posts/2016-03-21-hotkey-macos-01.png" alt="Programa Automator" width="800px" />
  <div class="image-caption">Programa Automator</div>
</div>

- Crea un Servicio nuevo,

<div class="image-box">
  <img src="/img/posts/2016-03-21-hotkey-macos-02.png" alt="Crea un servicio nuevo " width="800px" />
  <div class="image-caption">Crea un servicio nuevo </div>
</div>

Asociamos la pulsación de una tecla con una App.

- Automator: Documento nuevo
- Seleccionar las condiciones: sin datos de entrada, en cualquier aplicación
- Arrastrar *Abrir Aplicación* y seleccionar la aplicación a abrir
- Salvar el Servicio coo "Arrancar Path Finder"

<div class="image-box">
  <img src="/img/posts/2016-03-21-hotkey-macos-03.png" alt="Asociamos la tecla" width="600px" />
  <div class="image-caption">Asociamos la tecla</div>
</div>
