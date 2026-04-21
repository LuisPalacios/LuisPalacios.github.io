---
title: "Despertar el Mac para backup"
date: "2014-06-23"
categories: ["herramientas"]
tags: ["backup","macosx","copia"]
draft: false
cover:
  image: "/img/posts/2014-06-23-despierta-para-backup-06.jpg"
  hidden: true
---


<img src="/img/posts/2014-06-23-despierta-para-backup-06.jpg" alt="logo backup" width="150px" style="float:left; padding-right:25px"  />

**Hacer copias de seguridad debería ser obligatorio**. Por desgracia la mayoría hemos aprendido a lo largo de los años que la frase va en serio. El problema es que hacerlo es un verdadero rollo, así que cualquier programa o método que lo automatice es bienvenido.

<br clear="left"/>
<!--more-->

En este artículo describo un método para hacer copias de seguridad, lo documenté porque es bastante simple y a mi me viene genial. Consiste en despertar el Mac todos los días para que haga su copia. ¿Porqué no uso TimeCapsule/TimeMachine?, pues porque prefiero hacer copias a un disco compartido NAS vía SMB, donde escribe también otro equipo que no es un MAC, sino un Linux.

Mi método consiste en asegurarme que el Mac se despierte por la noche a las 02:00am, uso `GoodSync` para hacer la copia de todos mis directorios. Me aseguro de que no se vuelva a dormir antes de tiempo, en mi caso con 45 min tengo tiempo de sobra para que terminen mis copias.

- Creo una Aplicación con `Automator` que llamo `AppCaffeinate.app``
  - Ejecuta un script que llama a `caffeinate`, pequeño programa de OSX que mantiene despierto el equipo 45 minutos.
- Programo una cita diaria usando "iCal" a las 2:00am, que simplemente llama a `AppCaffeinate.app`.
- "GoodSync" ejecuta las copias de seguridad programadas precisamente a las 02:00am. Varias tareas que copian las modificaciones del día al NAS externo.

<br/>

## AppCaffeinate.app

Ejecuto Automator, creo un nuevo "Flujo de Trabajo". Arrastro la acción “Ejecutar el script Shell” y configuro como Shell `/bin/bash` y como comando `/usr/bin/caffeinate -t 2700 &`

<div class="image-box">
  <img src="/img/posts/2014-06-23-despierta-para-backup-01.png" alt="Nuevo flujo de trabajo" width="600px" />
  <div class="image-caption">Nuevo flujo de trabajo</div>
</div>

Lo salvo como Aplicación en un directorio de mi propio usuario: `/Users/luis/priv/bin/AppCaffeinate.app`

<div class="image-box">
  <img src="/img/posts/2014-06-23-despierta-para-backup-02.png" alt="Salvo como Aplicación" width="300px" />
  <div class="image-caption">Salvo como Aplicación</div>
</div>

<br/>

## Configuración de iCal

Para diferenciarlo del resto de citas creo un calendario nuevo que he llamado "Wake up", añado en él una única cita a las 02:00 que se repite todos días. La duración de dicha cita no es importante, en mi caso 30 min, pero solo para que en pantalla se vea bien. Lo importante es la horar de inicio.

<div class="image-box">
  <img src="/img/posts/2014-06-23-despierta-para-backup-03.png" alt="Configuro iCal" width="600px" />
  <div class="image-caption">Configuro iCal</div>
</div>

Modifico el "Aviso" de la cita, pulso en "Personalizar", "Abrir Archivo" (ejecutar un programa), "Otra" y selecciono mi aplicación creada con Automator: /Users/luis/priv/bin/AppCaffeinate.app

<div class="image-box">
  <img src="/img/posts/2014-06-23-despierta-para-backup-04.png" alt="Parámetros del aviso" width="400px" />
  <div class="image-caption">Parámetros del aviso</div>
</div>

<div class="image-box">
  <img src="/img/posts/2014-06-23-despierta-para-backup-05.png" alt="Aplicación a ejecutar" width="400px" />
  <div class="image-caption">Aplicación a ejecutar</div>
</div>

El equipo se despertará todos los días a las 02:00 am para ejecutar el comando `/usr/bin/caffeinate -t 2700 &`. De este modo se mantiene despierto durante 45min que es lo que necesito en mi caso para que GoodSync, que tiene programado empezar a las 02:00am, haga su backup incremental.

<br/>

## Configuración Goodsync

No voy a documentar aquí GoodSync dado que no es el objetivo de este artículo, pero es bastante sencillo, el programa permite crear múltiples tareas y que se ejecuten de forma diaria a una hora concreta. En mi caso he creado varias tareas, una para cada directorio raiz principal (por ejemplo Fotos, Documentos, etc...) y las programo para que hagan copia incremental (solo las modificaciones) hacia un NAS que tengo en la red de casa.

Existe una alternativa de software libre, FreeFileSync. Lo estuve usando una temporada pero la verdad es que me gusta mucho más la estabilidad y seguridad de GoodSync, así que un buen día decidí adquirir una licencia del programa.
