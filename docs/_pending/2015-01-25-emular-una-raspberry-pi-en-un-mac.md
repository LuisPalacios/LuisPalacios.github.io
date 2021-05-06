---
title: "Emular una Raspberry Pi en un Mac"
date: "2015-01-25"
categories: apuntes
tags: linux nuc
excerpt_separator: <!--more-->
---

Dejo aquí unos apuntes sobre cómo emular una Raspberry Pi en un MacOSX. Ojo que la Raspberry Pi tiene una GPU y eso no creo que se puede emular, así que distros como openelec no creo que funcionen...

{% include showImagen.html
    src="/assets/img/original/emurasp.png"
    caption="emurasp"
    width="600px"
    %}

- Instala Xcode y las command line tools desde el sitio de desarrollo de Apple (el registro es gratuito). Si ya tienes Xcode y solo te faltan las command line tools, se instalan con el comando xcode-select --install.
{% include showImagen.html
    src="/assets/img/original/"
    caption="MacPorts"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/DDI0301H_arm1176jzfs_r0p7_trm.pdf)"
    caption="ARM1176JZF-S"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/)"
    caption="aquí"
    width="600px"
    %}

obelix:~ luis$ cd /Users/luis/priv/raspberry
obelix:raspberry luis$ ls -al
total 340856
drwxr-xr-x+  4 luis  staff         136 25 ene 21:34 .
drwxr-xr-x+ 18 luis  staff         612 25 ene 21:13 ..
-rw-r--r--+  1 luis  staff  3276800000 25 ene 21:57 2014-12-24-wheezy-raspbian.img
-rw-r--r--@  1 luis  staff     2551416 25 ene 21:15 kernel-qemu

- El primer boot se realiza para hacer un pequeño cambio en el sistema. En el terminal escribimos lo siguiente:

 

obelix:raspberry luis$ qemu-system-arm -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw init=/bin/bash" -hda 2014-12-24-wheezy-raspbian.img

- Editar el fichero /etc/ld.so.preload y comentar la primera línea (añadir un #) para que quede así:

#/usr/lib/arm-linux-gnueabihf/libcofi_rpi.so

- Salvar con ‘ctrl+x’ y en el prompt salir con exit, cerrar la ventana de QEMU
- A partir de ahora ya se puede hacer boot normal, con el comando siguiente que puedes salvar en un script si lo deseas

 

qemu-system-arm -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" -hda 2014-12-24-wheezy-raspbian.img.img

- Una vez que arranca, ejecutar el comando "login" y el usuario pi/xxxx para poder arrancar "startx"
