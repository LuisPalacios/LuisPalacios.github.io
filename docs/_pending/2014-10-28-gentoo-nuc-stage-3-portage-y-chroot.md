---
title: "Gentoo en NUC: Stage 3, Portage y chroot"
date: "2014-10-28"
categories: gentoo
tags: linux nuc
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/?p=7"
    caption="instalación de Gentoo GNU/Linux en un Intel® NUC D54250WYK"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/spc.png"
    caption="spc"
    width="600px"
    %}

## Stage 3

{% include showImagen.html
    src="/assets/img/original/handbook-x86.xml)"
    caption="HandBook de Gentoo"
    width="600px"
    %}

Antes de bajar el Stage 3, montamos root y boot

 
livecd ~ # mount /dev/sda4 /mnt/gentoo
livecd ~ # mkdir /mnt/gentoo/boot
livecd ~ # mount /dev/sda2 /mnt/gentoo/boot
 

Ajustar la hora y fecha

 
livecd ~ # date 102822082014   <== MMDDHHMMAAAA
 

Descarga de Stage 3

 
livecd ~ # cd /mnt/gentoo
:
livecd gentoo # links http://www.gentoo.org/main/en/mirrors.xml
:
 

Descargo el último paquete "stage3", el último "portage" y los descomprimo:

 
/mirror/gentoo/releases/amd64/current-iso --> stage3-amd64-<último>.tar.bz2
/mirror/gentoo/snapshots --> portage-latest.tar.bz2
:
livecd gentoo # ls -al
total 270849
drwxr-xr-x 4 root root 4096 Oct 28 22:15 .
drwxr-xr-x 6 root root 120 Oct 28 21:54 ..
drwxr-xr-x 3 root root 1024 Oct 28 22:05 boot
drwx------ 2 root root 16384 Oct 28 22:05 lost+found
-rw-r--r-- 1 root root 71285570 Oct 28 22:15 portage-latest.tar.bz2
-rw-r--r-- 1 root root 57 Oct 28 22:15 portage-latest.tar.bz2.md5sum.bz2
-rw-r--r-- 1 root root 206032351 Oct 28 22:13 stage3-amd64-20141023.tar.bz2
-rw-r--r-- 1 root root 720 Oct 28 22:13 stage3-amd64-20141023.tar.bz2.DIGESTS.bz2
:
livecd ~ # cd /mnt/gentoo/
livecd ~ # tar xvjpf stage3-*.tar.bz2
livecd ~ # cd /mnt/gentoo/usr
livecd ~ # tar xvjpf ../portage-*.tar.bz2
 

 

### chroot al nuevo entorno

A partir de ahora entro ya directamente en el nuevo entorno con chroot, por lo tanto "/" (root) apuntará al disco SSD que hemos formateado y donde hemos descomprimido Stage 3 y Portage.

Antes de hacer el chroot debes copiar el /etc/resolv.conf para que la red siga funcionando (sobre todo la resolución de nombres :-))

 
livecd usr # cp /etc/resolv.conf /mnt/gentoo/etc
 
livecd usr # mount -t proc none /mnt/gentoo/proc
livecd usr # mount --rbind /sys /mnt/gentoo/sys
livecd usr # mount --rbind /dev /mnt/gentoo/dev
livecd usr # chroot /mnt/gentoo /bin/bash
livecd / # source /etc/profile
livecd / # export PS1="(chroot) $PS1"
(chroot) livecd / #
 

{% include showImagen.html
    src="/assets/img/original/?p=807"
    caption="Configuración mínima del nuevo sistema"
    width="600px"
    %}
