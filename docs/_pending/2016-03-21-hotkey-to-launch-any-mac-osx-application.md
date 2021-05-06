---
title: "Hotkey para arrancar un App en OSX"
date: "2016-03-21"
categories: apuntes
tags: finder hotkey osx pathfinder
excerpt_separator: <!--more-->
---

# Introducción

Necesito poder, independientemente de qué aplicación tenga el foco, abrir un programa presionando una HotKey. Como es lógico las aplicaciones no suelen traer dicha opción pero hay casos donde podría venir bien.

### Caso de uso

{% include showImagen.html
    src="/assets/img/original/pathfinder-150x150.png"
    caption="pathfinder"
    width="600px"
    %}

Path Finder

 

Para configurar una HotKey para arrancar una aplicación simplemente tenemos que usar el Automator y las Preferencias del teclado del sistema. Arranca Automator

{% include showImagen.html
    src="/assets/img/original/automator1.png"
    caption="automator1"
    width="600px"
    %}
- Crea un Servicio nuevo,

{% include showImagen.html
    src="/assets/img/original/automator2-1024x824.png"
    caption="automator2"
    width="600px"
    %}

- Automator: Documento nuevo
- Seleccionar las condiciones: sin datos de entrada, en cualquier aplicación
- Arrastrar *Abrir Aplicación* y seleccionar la aplicación a abrir
- Salvar el Servicio coo "Arrancar Path Finder"

{% include showImagen.html
    src="/assets/img/original/automator4.png"
    caption="automator4"
    width="600px"
    %}

* * *
