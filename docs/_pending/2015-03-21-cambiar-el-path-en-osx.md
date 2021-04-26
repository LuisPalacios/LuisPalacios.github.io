---
title: "Cambiar el PATH en OSX"
date: "2015-03-21"
categories: 
  - "apuntes"
---

Varias veces me han preguntado **cómo cambiar el PATH de manera permanente en OSX**. Lo siguiente funciona en varias versiones de OSX: El Capitan, Yosemite, Mavericks y Lion.

[![bashosx](https://www.luispa.com/wp-content/uploads/2015/10/bashosx.png)](https://www.luispa.com/wp-content/uploads/2015/10/bashosx.png)

Para mocificarlo de manera permanente tienes que crear (o editar) el fichero .bash\_profile en tu directorio $HOME.

- Lanza Terminal.app desde Finder (/Aplicaciones/Utilidades/Terminal.app) o pulsa CMD-Espacio, escribe Terminal y pulsa Intro.   [![path-spotlight](https://www.luispa.com/wp-content/uploads/2015/10/path-spotlight.png)](https://www.luispa.com/wp-content/uploads/2015/10/path-spotlight.png)  
    
- Cambia al directorio HOME. Por defecto "caes" en él, asegúrate de todas formas con el comando cd:
    

obelix:~ luis$ cd
obelix:~ luis$ pwd
/Users/luis

- Edita .bash\_profile. En mi ejemplo estoy añadiendo un directorio privado: export PATH=${HOME}/priv/bin

obelix:~ luis$ nano .bash\_profile

[![path-bash_profile](https://www.luispa.com/wp-content/uploads/2015/10/path-bash_profile.png)](https://www.luispa.com/wp-content/uploads/2015/10/path-bash_profile.png)  

- Sal salvando mediante CTRL-X, Y
    
- Sal de Terminal.app con CMD-Q y vuelve a lanzarlo. Mediante el siguiente comando podrás comprobar cómo cambia tu PATH de forma permanente.
    

obelix:~ luis$ echo $PATH
/usr/bin:/bin:/usr/sbin:/sbin:/Users/luis/priv/bin
