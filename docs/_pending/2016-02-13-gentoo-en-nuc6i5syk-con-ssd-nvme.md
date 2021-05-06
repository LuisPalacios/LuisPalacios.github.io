---
title: "Gentoo en NUC6i5SYK con SSD NVMe"
date: "2016-02-13"
categories: apuntes gentoo linux
tags: d54250wyk linux nuc servidor
excerpt_separator: <!--more-->
---

Instalar Linux Gentoo en NUC6i5SYK con un disco SSD Samsung SM951-NVMe no es tarea fácil. Algún día lo será, pero hoy (Feb'2016) estamos hablando de tecnología muy puntera (NVMe). La buena noticia es que al final lo he conseguido y puedo disfrutar de su rendimiento, sirva como ejemplo que tarda solo **5 segundos en hacer boot (desde BIOS al prompt de Login)**.

{% include showImagen.html
    src="/assets/img/original/mem16-300x129.jpg"
    caption="NUC6i5SYK](https://www.luispa.com/wp-content/uploads/2016/06/NUC6i5SYK-300x169.jpg)](https://www.luispa.com/wp-content/uploads/2016/06/NUC6i5SYK.jpg)[![mem16"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/ssd256-300x79.jpg"
    caption="ssd256"
    width="600px"
    %}

 

## Hardware

Antes de describir el problema y la solución, aquí tienes el hardware utilizado

{% include showImagen.html
    src="/assets/img/original/BIOS-Update-SYSKLi35-86A"
    caption="SYSKLi35.86A"
    width="600px"
    %}
- Disco /www.samsung.com/semiconductor/products/flash-storage/client-ssd/MZVPV256HDGL?ia=831">SM951-NVMe M.2 SSD 256GB - MZVPV256HDGL-00000
{% include showImagen.html
    src="/assets/img/original/f4-2133c15s-16grs"
    caption="G.Skill Ripjaws SO-DIMM DDR4 2133 PC4-17000 16GB CL15"
    width="600px"
    %}

 

Configuración de la BIOS "durante la instalación". Más adelante podrás ver la configuración FINAL.

BIOS NUC BIOS Devices SATA:
        Chipset SATA (checked)
        Chipset SATA Mode: AHCI
        SMART (checked)
        SATA Port (checked)
        SATA Port [not installed]
        M.2 NVMe     SSD:  SAMSUNG MZVPV256HDGL-00000 (256.3GB-PCIe x4, 8.0GT/s)
        SATA Port Hot Plug Capability: (not checked)
        Hard Disk Pre-Delay: 0
        HDD Activity Led: (checked)
        M.2 PCIe SSD Led: (not checked)

 

## Problemas

{% include showImagen.html
    src="/assets/img/original/?p=3221) para los NUC's, en ambas empleo el **LiveCD de Gentoo**, particiono en modo GPT, creo 4 particiones (grub_bios, boot, swap y rootfs"
    caption="para Hypervisor KVM (con systemd)"
    width="600px"
    %}

- El **LiveCD** de Gentoo **NO** incluye soporte para discos NVMe, por lo tanto no los detecta.
{% include showImagen.html
    src="/assets/img/original/?41883"
    caption="bug #41883"
    width="600px"
    %}

 

## Solución

Esto es lo que tienes que cambiar, dejo las pistas necesarias para que no pierdas horas navegando por internet:

{% include showImagen.html
    src="/assets/img/original/Sysresccd-manual-en_Booting_the_CD-ROM"
    caption="SystemRescueCD"
    width="600px"
    %}
- Durante la instalación de Gento, a la hora de particionar, hazlo con MBR para la tabla de particiones en vez de GPT
- Crea solo 2 particiones, una para root (/) y otra para Swap (512MB)
- Utiliza GRUB2 de forma normal. Al no tener GPT ni partición separada de Boot dejará de hacerse un lio.

 

### DISCO

nuc ~ # blkid
/dev/nvme0n1: PTUUID="e3c78928" PTTYPE="dos"
/dev/nvme0n1p1: LABEL="rootfs" UUID="9b3f52de-2d26-4722-8f5d-f1cba3cb33b5" TYPE="ext4" PARTUUID="e3c78928-01"
/dev/nvme0n1p2: LABEL="swap" UUID="46cb9f3c-bf23-4cb9-a5f5-210f1542d995" TYPE="swap" PARTUUID="e3c78928-02"

nuc ~ # fdisk --list /dev/nvme0n1
Disco /dev/nvme0n1: 238,5 GiB, 256060514304 bytes, 500118192 sectores
Unidades: sectores de 1 * 512 = 512 bytes
Tamaño de sector (lógico/físico): 512 bytes / 512 bytes
Tamaño de E/S (mínimo/óptimo): 512 bytes / 512 bytes
Tipo de etiqueta de disco: dos
Identificador del disco: 0xe3c78928

Disposit.      Inicio  Comienzo     Final  Sectores Tamaño Id Tipo
/dev/nvme0n1p1 *           2048 499068927 499066880   238G 83 Linux
/dev/nvme0n1p2        499068928 500117503   1048576   512M 82 Linux swap / Solaris

 

#### GRUB

Configuración final del fichero grub (utiilzado por el comando grub2-mkconfig -o /boot/grub/grub.cfg).

nuc ~ # confcat /etc/default/grub
GRUB_DISTRIBUTOR="Gentoo"
GRUB_TIMEOUT=0
GRUB_CMDLINE_LINUX="init=/usr/lib/systemd/systemd quiet rootfstype=ext4"
GRUB_TERMINAL=console
GRUB_DISABLE_LINUX_UUID=true

nuc ~ # cat /boot/grub/grub.cfg
:
menuentry 'Gentoo GNU/Linux' --class gentoo --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-simple-9b3f52de-2d26-4722-8f5d-f1cba3cb33b5' {
    load_video
    insmod gzio
    insmod ext2
    if [ x$feature_platform_search_hint = xy ]; then
      search --no-floppy --fs-uuid --set=root  9b3f52de-2d26-4722-8f5d-f1cba3cb33b5
    else
      search --no-floppy --fs-uuid --set=root 9b3f52de-2d26-4722-8f5d-f1cba3cb33b5
    fi
    echo    'Cargando Linux 4.4.1-gentoo...'
    linux   /boot/kernel-4.4.1-gentoo root=/dev/nvme0n1p1 ro init=/usr/lib/systemd/systemd quiet rootfstype=ext4
}
:

 

### FSTAB

nuc ~ # cat /etc/fstab
/dev/nvme0n1p1      /       ext4        noatime     0 1
/dev/nvme0n1p2      none        swap        sw      0 0

 

## KERNEL

{% include showImagen.html
    src="/assets/img/original/2016-02-13-config-4.4.1-NUC-NUC6i5SYK-SSD-NVMe-KVM.txt"
    caption="Kernel 4.4.1"
    width="600px"
    %}

 

## BIOS (final)

Configuración final de la BIOS.

{% include showImagen.html
    src="/assets/img/original/BIOS-FastBoot-300x130.png"
    caption="BIOS-FastBoot"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/BIOS-NVMe-300x217.png"
    caption="BIOS-NVMe"
    width="600px"
    %}

BIOS QUICK BOOT: SI  (IMPORTANTE para conseguir los 5 segundos)

BIOS NUC BIOS Devices -- Sata:
        Chipset SATA (NO) --- QUITA EL CHECK, NO HACE FALTA !!!!!!!!!
        M.2 NVMe     SSD:  SAMSUNG MZVPV256HDGL-00000 (256.3GB-PCIe x4, 8.0GT/s)
        Hard Disk Pre-Delay: 0
        HDD Activity Led: (NO)
        M.2 PCIe SSD Led: (SI)
