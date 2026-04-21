---
title: "WireShark remoto"
date: "2016-06-05"
categories: ["linux"]
tags: ["networking","tráfico","captura"]
draft: false
cover:
  image: "/img/posts/logo-wireshark.svg"
  hidden: true
---

<img src="/img/posts/logo-wireshark.svg" alt="Logo wireshark" width="150px" style="float:left; padding-right:25px"  />

En este apunto explico cómo lanzo una captura tráfico de la red (`tcpdump`) en un equipo Linux remoto ([Pi2 con Gentoo]({{< relref "2015-05-17-gentoo-pi2.md" >}})) y pido que se reenvíe a **Wireshark** ejecutándose en mi ordenado (Mac). Conseguiremos que la salida de tcpdump sea la entrada de Wireshark. Parece magia pero verás que es extremadamente sencillo. Vas a necesitar conocer `ssh` y `sudo`, un par de requisitos para que esto sea tan fácil.

<br clear="left"/>
<!--more-->

<div class="image-box">
  <img src="/img/posts/2016-06-05-wireshark-remoto-01.jpg" alt="wireshark-remote" width="600px" />
  <div class="image-caption">wireshark-remote</div>
</div>

<br/>

- Opción con mkfifo

Primero empiezo por una opción un poco más complicada (la siguiente es más sencilla), pero nos va a ayudar a entender mejor cual es la idea...

Ejecutamos dos sesiones en un terminal (`Terminal.app`, `iTerm2`, etc..). En mi caso las ejecuto en mi iMac. En una sesión ejecuto WireShark en mi ordenado. En la otra pido la ejecución remota de tcpdump mediante SSH a un equipo Linux. Conecto ambos procesos a través de un fichero intermedio de tipo FIFO.

Sesión 1:

```shell
mkfifo /tmp/remote
wireshark -k -i /tmp/remote
```

Sesión 2:

```shell
ssh luis@gentoopi.tudominio.com "sudo tcpdump -s 0 -U -n -w - -i eth0 not port 22" > /tmp/remote
```

<br/>

- Opción directa sin mkfifo (Preferida)

Lo anterior se puede reducir a una línea en una única sesión de Terminal:

Sesión única, en este caso ejecuto el Wireshark en mi MacOS:

```shell
ssh luis@gentoopi.tudominio.com "sudo tcpdump -s 0 -U -n -w - -i eth0 not port 22" | /Applications/Wireshark.app/Contents/MacOS/Wireshark -k -i -
```
