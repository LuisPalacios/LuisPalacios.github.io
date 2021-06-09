---
title: "WireShark remoto"
date: "2016-06-05"
categories: apuntes
tags: linux nuc
excerpt_separator: <!--more-->
---

![Logo Mover](/assets/img/posts/logo-wireshark.svg){: width="150px" style="float:left; padding-right:25px" } 

En este apunto explico cómo lanzo una captura tráfico de la red (`tcpdump`) en un equipo Linux remoto ([Pi2 con Gentoo]({% post_url 2015-05-17-gentoo-pi2 %})) y pido que se reenvíe a **Wireshark** ejecutándose en mi ordenado (Mac). Conseguiremos que la salida de tcpdump sea la entrada de Wireshark. Parece magia pero verás que es extremadamente sencillo. Vas a necesitar conocer `ssh` y `sudo`, un par de requisitos para que esto sea tan fácil. 

<br clear="left"/>
<!--more-->

{% include showImagen.html
    src="/assets/img/original/wireshark-remote.jpg"
    caption="wireshark-remote"
    width="600px"
    %}

* Opción con mkfifo

Primero empiezo por una opción un poco más complicada (la siguiente es más sencilla), pero nos va a ayudar a entender mejor cual es la idea... 

Ejecutamos dos sesiones en un terminal (`Terminal.app`, `iTerm2`, etc..). En mi caso las ejecuto en mi iMac. En una sesión ejecuto WireShark en mi ordenado. En la otra pido la ejecución remota de tcpdump mediante SSH a un equipo Linux. Conecto ambos procesos a través de un fichero intermedio de tipo FIFO.

Sesión 1: 

```console
$ mkfifo /tmp/remote
$ wireshark -k -i /tmp/remote
```

Sesión 2:

```console
$ ssh luis@gentoopi.parchis.org "sudo tcpdump -s 0 -U -n -w - -i eth0 not port 22" > /tmp/remote
```

* Opción sin mkfifo

Lo anterior se puede reducir a una línea en una única sesión de Terminal:

Sesión única:

```console
$ ssh luis@gentoopi.parchis.org "sudo tcpdump -s 0 -U -n -w - -i eth0 not port 22" | wireshark -k -i -
```
