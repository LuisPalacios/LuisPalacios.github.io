---
title: "Capturar tráfico con WireShark de forma remota"
date: "2016-06-05"
categories: 
  - "apuntes"
---

Un apunte rápido. Necesitaba capturar tráfico en un linux remoto, pero no quería pasar por la aro de hacer una instalación completa de Wireshark, es demasiado 'pesado' para equipos poco potentes (por ejemplo, [Pi2 con linux Gentoo](https://www.luispa.com/?p=3128)).

Solución: Ejecutar **`tcpdump`** en la **Pi con Linux** y ejecutar **Wireshark** **en iMac con OSX** y conseguir que la salida de tcpdump sea la entrada de Wireshark. Parece magia pero verás que es extremadamente sencillo. Asumo que conoces **SSH** y **sudo**, no lo describo aquí y son los únicos requisitos para que esto acabe siendo tan fácil.

[![wireshark-remote](https://www.luispa.com/wp-content/uploads/2016/06/wireshark-remote.jpg)](https://www.luispa.com/wp-content/uploads/2016/06/wireshark-remote.jpg)

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
