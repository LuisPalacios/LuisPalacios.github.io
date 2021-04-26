---
title: "Disco FireWire en Gentoo en Mac Mini"
date: "2012-11-15"
categories: 
  - "gentoo"
tags: 
  - "firewire"
  - "linux"
---

[![firewire](https://www.luispa.com/wp-content/uploads/2014/12/firewire.jpg)](https://www.luispa.com/wp-content/uploads/2014/12/firewire.jpg)Este artículo describe cómo conectar un disco externo FireWire (IEEE 1394, i.Link) a mi Mac Mini que está ejecutando Gentoo Linux.

Primero hay que preparar el Kernel de Linux para que de soporte al driver de FireWire.

 
 Device Drivers --->
   IEEE 1394 (FireWire) support --->
      <\*> FireWire driver stack
      <\*> OHCI-1394 controllers
      <\*> Storage devices (SBP-2 protocol)
 
 Device Drivers --->
   SCSI device support --->
      <\*> SCSI device support
      <\*> SCSI disk support
 

Compila e instala el nuevo kernel, arranca el equipo y a continuación prepara el fichero /etc/make.conf. Portage tiene un flag USE global "ieee1394" que habilita el que se soporte FireWire en otros paquetes de software. Por el hecho de activarlo se va a provocar que se instale la librería sys-libs/libraw1394

USE="... ieee1394 ..."

Con el nuevo USE activo, recopilamos el sistema: emerge -DuvNp system world

A partir de este momento ya puedes conectar el disco FireWire al Mac, debería reconocerlo como un disco más, durante el arranque esto es lo que se ve en "dmesg":

 
\[ 8.967388\] firewire\_core 0000:05:00.0: created device fw1: GUID 00d0b802e0009568, S800
\[ 9.199443\] firewire\_sbp2 fw1.0: logged in to LUN 0000 (0 retries)
\[ 9.205079\] scsi 3:0:0:0: Direct-Access External RAID 0 PQ: 0 ANSI: 4
\[ 9.205249\] sd 3:0:0:0: Attached scsi generic sg2 type 0
\[ 9.209223\] sd 3:0:0:0: \[sdc\] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
\[ 9.212173\] sd 3:0:0:0: \[sdc\] Write Protect is off
\[ 9.212180\] sd 3:0:0:0: \[sdc\] Mode Sense: 10 00 00 00
\[ 9.214408\] sd 3:0:0:0: \[sdc\] Cache data unavailable
\[ 9.214414\] sd 3:0:0:0: \[sdc\] Assuming drive cache: write through
\[ 9.224797\] sd 3:0:0:0: \[sdc\] Cache data unavailable
\[ 9.224806\] sd 3:0:0:0: \[sdc\] Assuming drive cache: write through
\[ 9.227352\] sdc: \[mac\] sdc1 sdc2 sdc3 sdc4
\[ 9.237568\] sd 3:0:0:0: \[sdc\] Cache data unavailable
\[ 9.237578\] sd 3:0:0:0: \[sdc\] Assuming drive cache: write through
\[ 9.239442\] sd 3:0:0:0: \[sdc\] Attached SCSI disk
 

En mi caso voy a usar este disco conectado a mi Mac Mini para poder acceder a una partición HFS+, dado que la creé hace tiempo en un iMac. He descrito dicho proceso en el [post Filesystem HFS+ en Gentoo Linux](http://blog.luispa.com/index.php?controller=post&action=view&id_post=6)   **Artículo relacionado:** [Filesystem HFS+ en Gentoo Linux](https://www.luispa.com/?p=498)
