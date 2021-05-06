---
title: "Capturar tráfico con WireShark de forma remota"
date: "2016-06-05"
categories: apuntes
tags: linux nuc
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/?p=3128)"
    caption="Pi2 con linux Gentoo"
    width="600px"
    %}

Solución: Ejecutar **`tcpdump`** en la **Pi con Linux** y ejecutar **Wireshark** **en iMac con OSX** y conseguir que la salida de tcpdump sea la entrada de Wireshark. Parece magia pero verás que es extremadamente sencillo. Asumo que conoces **SSH** y **sudo**, no lo describo aquí y son los únicos requisitos para que esto acabe siendo tan fácil.

{% include showImagen.html
    src="/assets/img/original/wireshark-remote.jpg"
    caption="wireshark-remote"
    width="600px"
    %}

### OPCIÓN 1 con mkfifo

Las dos sesiones de Terminal.app las ejecuto ambas en mi iMac: Es el equipo donde veremos WireShark y pedimos la ejecución remota de tcpdump mediante SSH. Abre dos sesiones de Terminal.app. Se usa un fichero intermedio de tipo FIFO.

- Sesión 1

```
$ mkfifo /tmp/remote
$ wireshark -k -i /tmp/remote
```

- Sesión 2

$ ssh luis@gentoopi.parchis.org "sudo tcpdump -s 0 -U -n -w - -i eth0 not port 22" > /tmp/remote

### OPCIÓN 2 sin mkfifo

Más sencillo todavía (gracias Joan), desde mi Mac ejecuto un único comando:

- Sesión 1

```
$ ssh luis@gentoopi.parchis.org "sudo tcpdump -s 0 -U -n -w - -i eth0 not port 22" | wireshark -k -i -
```
