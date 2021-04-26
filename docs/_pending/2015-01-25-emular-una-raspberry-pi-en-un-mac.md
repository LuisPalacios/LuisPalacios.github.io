---
title: "Emular una Raspberry Pi en un Mac"
date: "2015-01-25"
categories: 
  - "apuntes"
---

Dejo aquí unos apuntes sobre cómo emular una Raspberry Pi en un MacOSX. Ojo que la Raspberry Pi tiene una GPU y eso no creo que se puede emular, así que distros como openelec no creo que funcionen...

[![emurasp](https://www.luispa.com/wp-content/uploads/2015/01/emurasp.png)](https://www.luispa.com/wp-content/uploads/2015/01/emurasp.png)

- Instala Xcode y las command line tools desde el sitio de desarrollo de Apple (el registro es gratuito). Si ya tienes Xcode y solo te faltan las command line tools, se instalan con el comando xcode-select --install.
- Instala [MacPorts](https://www.macports.org/). Si ya lo tenías, actualizalo a la última versión con sudo port selfupdate y de paso haz un upgrade a los paquetes que ya tenías instalados sudo port upgrade outdated
- Instala QEMU con el compilador apropiado para el hardware de Raspberry Pi ([ARM1176JZF-S](http://infocenter.arm.com/help/topic/com.arm.doc.ddi0301h/DDI0301H_arm1176jzfs_r0p7_trm.pdf)) usando el comando siguiente: sudo port install qemu +target\_arm. Aunque no hace falta, aprovecho para poner python27 como la versión por defecto con sudo port select --set python python27
- Creo una carpeta en mi Mac para poder depositar los ficheros de trabajo, básicamente dos: una [imagen para Raspberry](http://www.raspberrypi.org/downloads/) (raspbian funciona) y un [kernel que funcione](http://xecdesign.com/downloads/linux-qemu/kernel-qemu) (fuente: [aquí](http://xecdesign.com/qemu-emulating-raspberry-pi-the-easy-way/)). En mi caso puse todo bajo el directorio /Users/luis/priv/raspberry

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

#/usr/lib/arm-linux-gnueabihf/libcofi\_rpi.so

- Salvar con ‘ctrl+x’ y en el prompt salir con exit, cerrar la ventana de QEMU
- A partir de ahora ya se puede hacer boot normal, con el comando siguiente que puedes salvar en un script si lo deseas

 

qemu-system-arm -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" -hda 2014-12-24-wheezy-raspbian.img.img

- Una vez que arranca, ejecutar el comando "login" y el usuario pi/xxxx para poder arrancar "startx"
