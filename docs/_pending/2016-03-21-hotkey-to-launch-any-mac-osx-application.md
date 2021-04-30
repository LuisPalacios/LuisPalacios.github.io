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

El que me interesa es [Path Finder](http://www.cocoatech.com/pathfinder/), como alternativa a Finder. Se trata de una aplicación muy prometedora, tiene funcionalidades que he echado de menos en Finder durante años, entre ellas que **no crea ficheros “.DS_Store”**, mantiene toda la información en una base de datos propia (una bendición :-) ). ![pathfinder](/assets/img/original/pathfinder-150x150.png){: width="730px" padding:10px }

Path Finder

 

Para configurar una HotKey para arrancar una aplicación simplemente tenemos que usar el Automator y las Preferencias del teclado del sistema. Arranca Automator

![automator1](/assets/img/original/automator1.png){: width="730px" padding:10px }
- Crea un Servicio nuevo,

![automator2](/assets/img/original/automator2-1024x824.png){: width="730px" padding:10px } Asóciale una única acción: **abrir aplicación** y con condiciones: **El servicio recibe: sin datos de entrada" en "cualquier aplicación"**.

- Automator: Documento nuevo
- Seleccionar las condiciones: sin datos de entrada, en cualquier aplicación
- Arrastrar *Abrir Aplicación* y seleccionar la aplicación a abrir
- Salvar el Servicio coo "Arrancar Path Finder"

[![automator3](https://www.luispa.com/wp-content/uploads/2016/03/automator3.png)](https://www.luispa.com/wp-content/uploads/2016/03/automator3.png) Salir de Automator e ir al panel de Preferencias del Sistema, Teclado, Funciones rápidas, Servicios, "Arrancar Path Finder", asignarle una combinación de teclas (Hotkey). ![automator4](/assets/img/original/automator4.png){: width="730px" padding:10px }, se arrancará Path Finder.

* * *
