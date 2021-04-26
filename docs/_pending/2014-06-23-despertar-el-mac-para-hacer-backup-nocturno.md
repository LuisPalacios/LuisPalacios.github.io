---
title: "Despertar el Mac para hacer backup nocturno"
date: "2014-06-23"
categories: 
  - "apuntes"
tags: 
  - "backup"
  - "macosx"
---

"Hacer copias de seguridad es obligatorio". Por desgracia la mayoría hemos aprendido a lo largo de los años que la frase va en serio. El problema es que hacerlo es un verdadero rollo, así que cualquier programa o método que lo automatice es bienvenido.

[![backup](https://www.luispa.com/wp-content/uploads/2014/12/backup.jpg)](https://www.luispa.com/wp-content/uploads/2014/12/backup.jpg)

En este artículo describo uno más de varios métodos que se usan para hacer copias de seguridad, lo dejo aquí documentado porque es bastante simple y a mi me viene genial, básicamente el Mac se despierta todos los días para hacer la copia. ¿Porqué no uso TimeCapsule?, prefiero hacer copias a un disco compartido NAS vía SMB, donde escribe también otro equipo que no es un MAC, sino un Linux.

Mi método consiste en asegurarme que el Mac se despierte por la noche a las 02:00am, para que GoodSync pueda hacer copia de seguridad de todos mis directorios. Me aseguro de que no se vuelva a dormir antes de tiempo, en mi caso con 45 min tengo tiempo de sobra para que terminen mis copias.

- Creo una Aplicación con "Automator". La llamo AppCaffeinate.app, es muy sencilla, solo ejecuta un script que llama a "caffeinate", pequeño programa de OSX que permite pedirle que se mantenga despierto 45 minutos.
- Programo una cita diaria usando "iCal" a las 2:00am, que simplemente llama a "AppCaffeinate.app".
- "GoodSync" ejecuta las copias de seguridad programadas precisamente a las 02:00am. Varias tareas que copian las modificaciones del día al NAS externo.

## AppCaffeinate.app

Ejecuto Automator, creo un nuevo "Flujo de Trabajo". Arrastro la acción “Ejecutar el script Shell” y configuro como Shell /bin/bash y como comando /usr/bin/caffeinate -t 2700 &

[![back1](https://www.luispa.com/wp-content/uploads/2014/12/back1.png)](https://www.luispa.com/wp-content/uploads/2014/12/back1.png) [![back2](https://www.luispa.com/wp-content/uploads/2014/12/back2.png)](https://www.luispa.com/wp-content/uploads/2014/12/back2.png) [![back3](https://www.luispa.com/wp-content/uploads/2014/12/back3.png)](https://www.luispa.com/wp-content/uploads/2014/12/back3.png) [![back4](https://www.luispa.com/wp-content/uploads/2014/12/back4.png)](https://www.luispa.com/wp-content/uploads/2014/12/back4.png)

Lo salvo como Aplicación en un directorio de mi propio usuario: /Users/luis/priv/bin/AppCaffeinate.app

[![back5](https://www.luispa.com/wp-content/uploads/2014/12/back5.png)](https://www.luispa.com/wp-content/uploads/2014/12/back5.png)

## Configuración de iCal

Para diferenciarlo del resto de citas creo un calendario nuevo que he llamado "Wake up", añado en él una única cita a las 02:00 que se repite todos días. La duración de dicha cita no es importante, en mi caso 30 min, pero solo para que en pantalla se vea bien. Lo importante es la horar de inicio.

[![back6](https://www.luispa.com/wp-content/uploads/2014/12/back6-1024x368.png)](https://www.luispa.com/wp-content/uploads/2014/12/back6.png)

Modifico el "Aviso" de la cita, pulso en "Personalizar", "Abrir Archivo" (ejecutar un programa), "Otra" y selecciono mi aplicación creada con Automator: /Users/luis/priv/bin/AppCaffeinate.app

[![back7](https://www.luispa.com/wp-content/uploads/2014/12/back7.png)](https://www.luispa.com/wp-content/uploads/2014/12/back7.png)

[![back8](https://www.luispa.com/wp-content/uploads/2014/12/back8.png)](https://www.luispa.com/wp-content/uploads/2014/12/back8.png) [![back9](https://www.luispa.com/wp-content/uploads/2014/12/back9.png)](https://www.luispa.com/wp-content/uploads/2014/12/back9.png)

El equipo se despertará todos los días a las 02:00 am para ejecutar el comando /usr/bin/caffeinate -t 2700 &. De este modo se mantiene despierto durante 45min que es lo que necesito en mi caso para que GoodSync, que tiene programado empezar a las 02:00am, haga su backup incremental.

## Configuración de GoodSync y alternativa FreeFileSync

No voy a documentar aquí GoodSync dado que no es el objetivo de este artículo, pero es bastante sencillo, el programa permite crear múltiples tareas y que se ejecuten de forma diaria a una hora concreta. En mi caso he creado varias tareas, una para cada directorio raiz principal (por ejemplo Fotos, Documentos, etc...) y las programo para que hagan copia incremental (solo las modificaciones) hacia un NAS que tengo en la red de casa.

Existe una alternativa de software libre, FreeFileSync. Lo estuve usando una temporada pero la verdad es que me gusta mucho más la estabilidad y seguridad de GoodSync, así que un buen día decidir adquirir una licencia del programa.
