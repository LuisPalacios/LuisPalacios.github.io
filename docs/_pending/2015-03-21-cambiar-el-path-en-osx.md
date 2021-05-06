---
title: "Cambiar el PATH en OSX"
date: "2015-03-21"
categories: apuntes
tags: linux ntopng
excerpt_separator: <!--more-->
---

Varias veces me han preguntado **cómo cambiar el PATH de manera permanente en OSX**. Lo siguiente funciona en varias versiones de OSX: El Capitan, Yosemite, Mavericks y Lion.

{% include showImagen.html
    src="/assets/img/original/bashosx.png"
    caption="bashosx"
    width="600px"
    %}

Para mocificarlo de manera permanente tienes que crear (o editar) el fichero .bash_profile en tu directorio $HOME.

{% include showImagen.html
    src="/assets/img/original/path-spotlight.png"
    caption="path-spotlight"
    width="600px"
    %}
    
- Cambia al directorio HOME. Por defecto "caes" en él, asegúrate de todas formas con el comando cd:
    

obelix:~ luis$ cd
obelix:~ luis$ pwd
/Users/luis

- Edita .bash_profile. En mi ejemplo estoy añadiendo un directorio privado: export PATH=${HOME}/priv/bin

obelix:~ luis$ nano .bash_profile

{% include showImagen.html
    src="/assets/img/original/path-bash_profile.png"
    caption="path-bash_profile"
    width="600px"
    %}

- Sal salvando mediante CTRL-X, Y
    
- Sal de Terminal.app con CMD-Q y vuelve a lanzarlo. Mediante el siguiente comando podrás comprobar cómo cambia tu PATH de forma permanente.
    

obelix:~ luis$ echo $PATH
/usr/bin:/bin:/usr/sbin:/sbin:/Users/luis/priv/bin
