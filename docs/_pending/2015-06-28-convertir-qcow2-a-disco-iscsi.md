---
title: "Conversión  qcow2 <--> iSCSI"
date: "2015-06-28"
categories: apuntes gentoo virtualizacion
tags: convertir iscsi qcow2
excerpt_separator: <!--more-->
---

En este apunte describo cómo mover una VM (KVM) desde almacenamiento basado en fichero hacia almacenamiento basado en bloque (iSCSI). Dicho de otra forma, vamos a ver cómo mover el "contenido" del fichero .qcow2 a un disco RAW (entregado desde una NAS vía iSCSI). En este ejemplo el host KVM se llama marte y la VM se llama aplicacionix.

![conv-iSCSI-0](/assets/img/original/conv-iSCSI-0-1024x864.png){: width="730px" padding:10px }

En este ejemplo la VM original ocupa 20GB (se averigua arrancándola y ejecutando el comando df), aprovecho y creo algo más de espacio (30GB) en mi nuevo disco iSCSI dede el GUI del NAS, por lo tanto el objetivo es copiar el fichero fuente al disco destino:

- Fuente: Archivo aplicacionix.qcow2
    
- Destino: iqn.2004-04.com.qnap:ts-569pro:iscsi.vmaplicacionix.d70ea1
    

![convert-iSCSI-1](/assets/img/original/convert-iSCSI-1.png){: width="730px" padding:10px }

### Acciones en el Host KVM (marte)

- Paro la VM (aplicacionix)

marte ~ # virsh shutdown aplicacionix

- Convierto el fichero .qcow2 a RAW

luis@marte ~ $ qemu-img convert aplicacionix.qcow2 -O raw aplicacionix.raw

- Discovery del NAS para comprobar que veo el disco destino (iSCSI)

marte ~ # iscsiadm -m discovery --portal=192.168.1.2:3260 -t sendtargets
:
192.168.1.2:3260,1 iqn.2004-04.com.qnap:ts-569pro:iscsi.vmaplicacionix.d70ea1

- Login al disco destino (se activa como /dev/sde en mi caso)

marte ~ # iscsiadm -m node -T iqn.2004-04.com.qnap:ts-569pro:iscsi.vmaplicacionix.d70ea1 -p 192.168.1.2 --login
marte ~ # dmesg
:
[ 8951.352110] scsi host4: iSCSI Initiator over TCP/IP
[ 8951.606632] scsi 4:0:0:0: Direct-Access     QNAP     iSCSI Storage    4.0  PQ: 0 ANSI: 5
[ 8951.607761] sd 4:0:0:0: Attached scsi generic sg4 type 0
[ 8951.608262] sd 4:0:0:0: [sde] 62914560 512-byte logical blocks: (32.2 GB/30.0 GiB)
[ 8951.610556] sd 4:0:0:0: [sde] Write Protect is off
[ 8951.610576] sd 4:0:0:0: [sde] Mode Sense: 2f 00 10 00
[ 8951.611052] sd 4:0:0:0: [sde] Write cache: enabled, read cache: enabled, supports DPO and FUA
[ 8951.634983] sd 4:0:0:0: [sde] Attached SCSI disk
[ 8968.825116] sd 4:0:0:0: [sde] Synchronizing SCSI cache
[10143.628578] scsi host5: iSCSI Initiator over TCP/IP
[10143.882808] scsi 5:0:0:0: Direct-Access     QNAP     iSCSI Storage    4.0  PQ: 0 ANSI: 5
[10143.883926] sd 5:0:0:0: Attached scsi generic sg4 type 0
[10143.884628] sd 5:0:0:0: [sde] 62914560 512-byte logical blocks: (32.2 GB/30.0 GiB)
[10143.886088] sd 5:0:0:0: [sde] Write Protect is off
[10143.886094] sd 5:0:0:0: [sde] Mode Sense: 2f 00 10 00
[10143.886583] sd 5:0:0:0: [sde] Write cache: enabled, read cache: enabled, supports DPO and FUA
[10143.891977] sd 5:0:0:0: [sde] Attached SCSI disk

- Copio a nivel físico el fichero RAW al disco iSCSI (21GB tarda unos 35min al copiarse a una NAS con puertos de 1GbE)

marte ~ # cd /home/luis
marte luis # dd if=aplicacionix.raw of=/dev/sde
41943040+0 registros leídos
41943040+0 registros escritos
21474836480 bytes (21 GB) copiados, 1834,16 s, 11,7 MB/s

- Borro el disco RAW

marte luis # rm /home/luis/aplicacionix.raw

- Logout del disco iSCSI

marte ~ # iscsiadm -m node -T iqn.2004-04.com.qnap:ts-569pro:iscsi.vmaplicacionix.d70ea1 -p 192.168.1.2 --logout
Logging out of session [sid: 5, target: iqn.2004-04.com.qnap:ts-569pro:iscsi.vmaplicacionix.d70ea1, portal: 192.168.1.2,3260]

- Desde virt-manager, conecto con el disco iSCSI y configuro la VM para que lo utilice

![conv-iSCSI-2](/assets/img/original/conv-iSCSI-2-1024x719.png){: width="730px" padding:10px }

![conv-iSCSI-3](/assets/img/original/conv-iSCSI-3-1024x689.png){: width="730px" padding:10px }

![conv-iSCSI-4](/assets/img/original/conv-iSCSI-4-1024x694.png){: width="730px" padding:10px }

- Arranco la nueva VM

marte ~ # virsh start aplicacionix

![conv-iSCSI-5](/assets/img/original/conv-iSCSI-5.png){: width="730px" padding:10px }

### Acciones en la VM (aplicacionix)

- Amplío el file system principal para consumir el resto de GBs extra, recordar que el disco original tenía aprox. 20GB pero el nuevo es de 30GB. Es fácil, ejecutao gparted desde la propia VM (aplicacionix) y le asigno el espacio restante al filesystem principal.

![conv-iSCSI-6](/assets/img/original/conv-iSCSI-6.png){: width="730px" padding:10px }

 

aplicacionix ~ # df -h
S.ficheros                  Tamaño Usados  Disp Uso% Montado en
/dev/vda3                      29G    12G   17G  42% /
devtmpfs                      2,0G      0  2,0G   0% /dev
tmpfs                         2,0G      0  2,0G   0% /dev/shm
tmpfs                         2,0G   1,1M  2,0G   1% /run
tmpfs                         2,0G      0  2,0G   0% /sys/fs/cgroup
tmpfs                         2,0G      0  2,0G   0% /tmp
tmpfs                         396M      0  396M   0% /run/user/1500
