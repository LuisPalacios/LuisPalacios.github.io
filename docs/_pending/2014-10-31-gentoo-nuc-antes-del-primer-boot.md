---
title: "Gentoo en NUC: Antes del primer boot"
date: "2014-10-31"
categories: gentoo
tags: linux nuc
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/?p=7"
    caption="instalar Gentoo GNU/Linux en un Intel® NUC D54250WYK"
    width="600px"
    %}

Crea el script "confcat": recomiendo que crees un script en tu sistema,  muy útil para poder ver el contenido "no comentado" de los ficheros de configuración.

#!/bin/bash
#
# confcat: quita las lineas con comentarios, muy util como sustituto
# al programa "cat" cuando queremos ver solo las lineas efectivas,
# no las lineas que tienen comentarios.
grep -vh '^[[:space:]]*#' "$@" | grep -v '^//' | grep -v '^;' | grep -v '^$' | grep -v '^!' | grep -v '^--'

 
 
(chroot) livecd ~ # chmod 755 /usr/bin/confcat
 

A partir de ahora puedes usar "confcat" en vez de "cat" para ver las líneas que se usan en los ficheros de configuración

**Últimos componentes**

Los siguientes pasos son muy importantes antes de arrancar el equipo, no te olvides y hazlos en este orden

Hostname y Resolución de nombres

Preparo los ficheros /etc/hostname, /etc/hosts, /etc/resolv.conf y /etc/host.conf. Notar que en mi ejemplo mi equipo se llama "totobo", el dominio es "tudominio.com" (servidor por un DNS Server en la 192.168.1.1)

hostname="totobo"        <== Poner aquí el nombre de tu equipo

127.0.0.1  localhost
::1        localhost

domain tudominio.com
nameserver 192.168.1.1

order bind, hosts        <== Primero DNS Server (hará que funcione "hostname --fqdn")

Más tarde, cuando arranque el equipo, y asumiendo que el DNS server funciona, debería ver estos resultados

 
 
# hostname
totobo
 
# hostname --fqdn
totobo.tudominio.com
 

Contraseña de root

 
 
(chroot) livecd init.d # passwd
:
 

Ficheros rc.conf, keymaps, hwclock, metalog,

rc_shell=/sbin/sulogin
rc_depend_strict="NO"
unicode="YES"
rc_tty_number=12

keymap="-u es"
windowkeys="YES"
extended_keymaps="backspace keypad euro2"
dumpkeys_charset=""
fix_euro="NO"

clock="local"
clock_systohc="YES"
clock_args=""

Instalo metalog,

 
 
(chroot) livecd ~ # emerge -v metalog
 
(chroot) livecd ~ # rc-update add metalog default
 

METALOG_OPTS=""
CONSOLE="/dev/tty10"
FORMAT='$1 [$2] $3'

Instalo vixie-cron, mlocate, añado ssh a default, instalo dhcp, eix, etc...

 
 
(chroot) livecd etc # emerge -v vixie-cron
(chroot) livecd init.d # rc-update add vixie-cron default
 
(chroot) livecd init.d # emerge mlocate
 
(chroot) livecd init.d # rc-update add sshd default
 
(chroot) livecd init.d # emerge -v dhcp
(chroot) livecd portage # emerge eix
(chroot) livecd portage # eix-update
 

Evitar que se limpie la consola al hacer boot

Cuando el sistema arranque (en breve) verás que tras mostrar todos los mensajes durante la inicialización de los procesos se limpiará la pantalla y nos ofrecerá el prompt de login. Bien, pues a mi no me gusta que "limpie" la pantalla porque evita ver posibles errores durante el arranque, así que añado "--noclear" en el inittab

c1:12345:respawn:/sbin/agetty --noclear 38400 tty1 linux

Update de System y World

Este paso es muy importante antes de poder hacer un re-boot del sistema. No olvides que en la "Configuración mínima" vimos que he decidido bloquear "systemd" y “udev” en favor del (fork) Gentoo "eudev"

sys-apps/systemd
sys-fs/udev

La actualización de system y world debería recompilar muchísimos paquetes y ponerlo todo a la última versión, a la vez que sustituirá udev con eudev.

Si has seguido las instrucciones hasta aquí y estás usando los mismos parámetros USE que en mi caso entonces no debería darte ningún problema. Recuerda que tienes una copia de los ficheros principales de configuración de Gentoo para instalación en NUC D54250WYK

 
 
(chroot) livecd ~ # emerge --sync
(chroot) livecd ~ # emerge -DuvN system world
 

Boot Loader (Grub2)

El paso final antes de poder arrancar desde el SSD es instalar un boot loader.

 
 
(chroot) livecd ~ # emerge -v grub
 
(chroot) livecd ~ # grub2-install /dev/sda
Installing for i386-pc platform.
Installation finished. No error reported.
 
(chroot) livecd ~ # grub2-mkconfig -o /boot/grub/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/kernel-3.17.1-gentoo-r1
done
 

Boot desde SSD

Desconectar de la sesión SSH, desmontar y reboot

 
 
(chroot) livecd ~ # exit
livecd ~# cd
livecd ~# umount -l /mnt/gentoo/dev{/shm,/pts,}
livecd ~# umount /mnt/gentoo{/boot,/sys,/proc,}
livecd ~# reboot
 

{% include showImagen.html
    src="/assets/img/original/?p=861"
    caption="Finalizar la instalación"
    width="600px"
    %}
