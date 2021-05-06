---
title: "Gentoo en NUC: Particionar el disco SSD"
date: "2014-10-27"
categories: apuntes
tags: linux nuc
excerpt_separator: <!--more-->
---

Nota: Este post pertenece a una "colección", así que te recomiendo que empieces por la instalación ![Gentoo GNU/Linux en un Intel® NUC D54250WYK](/assets/img/original/?p=7){: width="730px" padding:10px }. En este artículo en concreto describo cómo crear las particiones del disco SSD y los file systems

## Crear las particiones del disco

Recuerda que recomiendo continuar la instalación desde un puesto de trabajo más cómodo, así que si no lo has hecho ya... conecta con la IP de tu equipo mediante SSH. En mi caso el DHCP server me dio la dirección que ves a continuación:

 
obelix:~ luis$ ssh -l root 192.168.1.245
 

Antes de crear las particiones hay que identificar el nombre del dispositivo del disco SSD (y no confundirlo con el USB de arranque). Hay un par de maneras de averiguarlo: con dmesg o con fdisk

 
livecd ~ # dmesg | grep "SCSI"
[ 0.327492] SCSI subsystem initialized
[ 0.870016] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[ 0.958660] Loading iSCSI transport class v2.0-870.
[ 0.959277] SCSI Media Changer driver v0.25
[ 3.152007] sd 3:0:0:0: [**sda] Attached SCSI disk <== Este es el disco interno SSD**
[ 5.101341] sd 4:0:0:0: [sdb] Attached SCSI removable disk <== Este es el USB 
:
 
livecd ~ # fdisk -l
Disk /dev/sda: 223.6 GiB, 240057409536 bytes, 468862128 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes

Disk /dev/sdb: 3.8 GiB, 4009754624 bytes, 7831552 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00000000

 

### Parted

Está claro que mi disco SSD es el /dev/sda, así que empezamos a preparar las particiones. Notar que UTILIZO UEFI y GPT (en vez de MBR) en el disco SSD del equipo.

 
livecd ~ # parted -a optimal /dev/sda
:
GNU Parted 3.1
Using /dev/sda
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mklabel gpt
(parted) unit mib
(parted) mkpart primary 1 3
(parted) name 1 grub
(parted) set 1 bios_grub on
(parted) mkpart primary 3 131
(parted) name 2 boot
(parted) mkpart primary 131 643
(parted) name 3 swap
(parted) mkpart primary 643 -1
(parted) name 4 rootfs
(parted) print
Model: ATA Crucial_CT240M50 (scsi)
Disk /dev/sda: 228937MiB
Sector size (logical/physical): 512B/4096B
Partition Table: gpt
Disk Flags:
Number Start End Size File system Name Flags
 1 1.00MiB 3.00MiB 2.00MiB grub bios_grub
 2 3.00MiB 131MiB 128MiB boot
 3 131MiB 643MiB 512MiB swap
 4 643MiB 228936MiB 228293MiB rootfs

(parted) quit

### File Systems

A continuación creo los file systems

 
livecd ~ # mkfs.ext2 /dev/sda2
livecd ~ # mkfs.ext4 /dev/sda4
livecd ~ # mkswap /dev/sda3
livecd ~ # swapon /dev/sda3
 

 

Aunque todavía no podemos usar la versión gráfica "gparted", una vez que terminé la instalación así es como se ve desde dicho programa:

![particionar](/assets/img/original/particionar.png){: width="730px" padding:10px }

Volver al paso anterior: [Iniciar la instalación](https://www.luispa.com/?p=759) o ir al siguiente: ![Stage 3, Portage y chroot](/assets/img/original/?p=800){: width="730px" padding:10px }
