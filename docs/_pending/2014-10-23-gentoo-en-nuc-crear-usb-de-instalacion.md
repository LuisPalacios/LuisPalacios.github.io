---
title: "Gentoo en NUC: Crear USB de instalación"
date: "2014-10-23"
categories: 
  - "gentoo"
tags: 
  - "d54250wyk"
  - "linux"
  - "nuc"
  - "usb"
---

Nota: Este post pertenece a una "colección", así que te recomiendo que empieces por la [instalación Gentoo GNU/Linux en un Intel® NUC D54250WYK](https://www.luispa.com/?p=7). En este artículo en concreto describo cómo preparar una USB para hacer la instalación

# Crear USB "bootable" para instalar

Lo primero que tienes que hacer es descargarte la última versión del ISO de instalación de Gentoo: install-amd64-minimal-AAAAMMDD.iso desde los [mirrors de gentoo,](https://www.gentoo.org/main/en/mirrors2.xml) que encontrarás en el directorio **releases/amd64/current-iso**

El siguiente paso es preparar un USB (te recomiendo mínimo 2.0 de 1GB) para instalar este ISO. El procedimiento que utilices tiene que asegurarte que finalmente hace boot. Hay decenas de métodos, algunos desde Linux, otros desde Windows, MacOSX, manuales, usando herramientas como unetbootin [http://unetbootin.sourceforge.net/](http://unetbootin.sourceforge.net/), etc.

En mi caso he optado por un disco externo USB3.0 de 1TB, donde formatearé una pequeña partición para instalar gentoo en el NUC, me servirá de emergencia para hacer boot desde él en caso de problemas y además usaré el resto del disco para crear una partición de datos ([lo haré una vez termine de instalar el NUC, usando gparted](http://blog.luispa.com/index.php?controller=post&action=view&id_post=41)).

[![usbgentoo](https://www.luispa.com/wp-content/uploads/2014/12/usbgentoo.png)](https://www.luispa.com/wp-content/uploads/2014/12/usbgentoo.png)

### Instalación manual desde linux

En mi caso he preferido documentar el proceso "largo y tedioso" porque se deduce bien qué hace falta para que una USB pueda hacer boot, así que ahí va:

**Nota**: Ojo que este proceso elimina por completo todo el contenido del USB

Con mi USB externa insertada (en mi caso un disco enorme de 1TB), identifico el nombre del "device" USB tal como lo reconoce el kernel

 
# dmesg
:
\[425170.630067\] sd 3:0:0:0: \[sdb\] Attached SCSI removable disk
 

Nota: Si el disco es reconocible por el comando fdisk también puedes usar "fdisk -l" para identificar la USB, en cualquier caso lo más seguro es usar dmesg. **En mi caso el dispositivo es el /dev/sdb**.

Vacío por completo el USB, incluso elimino el MBR

 
# dd if=/dev/zero of=/dev/sdb bs=512 count=1
 

Creo una única partición FAT32

 
# fdisk /dev/sdb
 

En mi caso creo una partición única que ocupa solo 4GB del USB. Donde pongo Intro,Intro me refiero a aceptar los valores de primer y último sector que me ofrece por defecto (usar todo el disco)

- Orden : o ==> Crea una nueva tabla de particiones msdos
- Orden : n p 1 (Intro, +4G) ==> Acepto el sector de inicio e indico 4GB de tamaño
- Orden : t b (W95 FAT32) ==> Cambiamos el tipo de la partición a W95 FAT32
- Orden : a 1 ==> Convierte la partición en Bootable
- Orden : w ==> Escribe todo lo anterior en el disco

 
# fdisk -l
Disk /dev/sdb:  931,5 GiB, 1000170586112 bytes, 1953458176 sectors
Units: sectors of 1 \* 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xe4e671ce

Disposit.  Inicio   Start    Final  Blocks   Id  System
/dev/sdb1       \*    2048  8390655  4194304   b  W95 FAT32  
 

 
# emerge -v dosfstools
# mkdosfs -F 32 /dev/sdb1
mkfs.fat 3.0.22 (2013-07-19)
 

Instalo un MBR

 
# emerge -v sys-boot/syslinux
# dd if=/usr/share/syslinux/mbr.bin of=/dev/sdb
# sync
 

Montar la partición recien creada y el fichero ISO de instalación

 
# mkdir /mnt/usb/
# mkdir /mnt/iso
:
# mount -t vfat /dev/sdb1 /mnt/usb
:
# mount -t iso9660 -o loop,ro /root/install-amd64-minimal-20141023.iso /mnt/iso/
:
 

Copiar todo el contenido del ISO a la USB

 
# cp -r /mnt/iso/\* /mnt/usb
# sync
# mv /mnt/usb/isolinux/\* /mnt/usb
# mv /mnt/usb/isolinux.cfg /mnt/usb/syslinux.cfg
# rm -rf /mnt/usb/isolinux\*
# mv /mnt/usb/memtest86 /mnt/usb/memtest
 

Podemos ya desmontar el ISO, no lo vamos a necesitar

 
# umount /mnt/iso
 

Corregimos el fichero syslinux.cfg

 
sed -i -e "s:cdroot:cdroot slowusb:" -e "s:kernel memtest86:kernel memtest:" /mnt/usb/syslinux.cfg
 

Instalo el syslinux bootloader en el USB

 
# umount /mnt/usb
# syslinux /dev/sdb1
# sync
 

Extraer el USB, ya está listo para ser utilizado

 

Volver al paso anterior: [Preparar la BIOS](https://www.luispa.com/?p=740) o ir al siguiente: [Iniciar la instalación](https://www.luispa.com/?p=759)
