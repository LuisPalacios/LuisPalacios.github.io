---
title: "Gentoo en NUC6i5SYK con SSD NVMe"
date: "2016-02-13"
categories: 
  - "apuntes"
  - "gentoo"
  - "linux"
---

Instalar Linux Gentoo en NUC6i5SYK con un disco SSD Samsung SM951-NVMe no es tarea fácil. Algún día lo será, pero hoy (Feb'2016) estamos hablando de tecnología muy puntera (NVMe). La buena noticia es que al final lo he conseguido y puedo disfrutar de su rendimiento, sirva como ejemplo que tarda solo **5 segundos en hacer boot (desde BIOS al prompt de Login)**.

[![NUC6i5SYK](https://www.luispa.com/wp-content/uploads/2016/06/NUC6i5SYK-300x169.jpg)](https://www.luispa.com/wp-content/uploads/2016/06/NUC6i5SYK.jpg)[![mem16](https://www.luispa.com/wp-content/uploads/2016/06/mem16-300x129.jpg)](https://www.luispa.com/wp-content/uploads/2016/06/mem16.jpg)

[![ssd256](https://www.luispa.com/wp-content/uploads/2016/02/ssd256-300x79.jpg)](https://www.luispa.com/wp-content/uploads/2016/02/ssd256.jpg)

 

## Hardware

Antes de describir el problema y la solución, aquí tienes el hardware utilizado

-  [NUC6i5SYK](http://ark.intel.com/products/89188/Intel-NUC-Kit-NUC6i5SYK) I5-6260U con BIOS [SYSKLi35.86A](https://downloadcenter.intel.com/download/25696/BIOS-Update-SYSKLi35-86A)
- Disco /www.samsung.com/semiconductor/products/flash-storage/client-ssd/MZVPV256HDGL?ia=831">SM951-NVMe M.2 SSD 256GB - MZVPV256HDGL-00000
- 32GB de memoria con 2 x  [G.Skill Ripjaws SO-DIMM DDR4 2133 PC4-17000 16GB CL15](http://www.gskill.com/en/product/f4-2133c15s-16grs)

 

Configuración de la BIOS "durante la instalación". Más adelante podrás ver la configuración FINAL.

BIOS NUC BIOS Devices SATA:
        Chipset SATA (checked)
        Chipset SATA Mode: AHCI
        SMART (checked)
        SATA Port (checked)
        SATA Port \[not installed\]
        M.2 NVMe     SSD:  SAMSUNG MZVPV256HDGL-00000 (256.3GB-PCIe x4, 8.0GT/s)
        SATA Port Hot Plug Capability: (not checked)
        Hard Disk Pre-Delay: 0
        HDD Activity Led: (checked)
        M.2 PCIe SSD Led: (not checked)

 

## Problemas

Normalmente sigo [esta guía (con openrc)](https://www.luispa.com/?p=7) o esta otra [para Hypervisor KVM (con systemd)](https://www.luispa.com/?p=3221) para los NUC's, en ambas empleo el **LiveCD de Gentoo**, particiono en modo GPT, creo 4 particiones (grub\_bios, boot, swap y rootfs). Por desgracia no es tan fácil.

- El **LiveCD** de Gentoo **NO** incluye soporte para discos NVMe, por lo tanto no los detecta.
- La combinación GTP + NVMe + GRUB2 tiene de momento el [bug #41883](http://savannah.gnu.org/bugs/?41883): Booting from NVMe Device Enters GRUB rescue.

 

## Solución

Esto es lo que tienes que cambiar, dejo las pistas necesarias para que no pierdas horas navegando por internet:

- Uitliza [SystemRescueCD](https://www.system-rescue-cd.org/Sysresccd-manual-en_Booting_the_CD-ROM) como LiveCD, que sí soporta NVMe y no olvides escoger la opción **altker64** al hacer boot, de modo que detecte la tarjeta de red correctamente.
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
Unidades: sectores de 1 \* 512 = 512 bytes
Tamaño de sector (lógico/físico): 512 bytes / 512 bytes
Tamaño de E/S (mínimo/óptimo): 512 bytes / 512 bytes
Tipo de etiqueta de disco: dos
Identificador del disco: 0xe3c78928

Disposit.      Inicio  Comienzo     Final  Sectores Tamaño Id Tipo
/dev/nvme0n1p1 \*           2048 499068927 499066880   238G 83 Linux
/dev/nvme0n1p2        499068928 500117503   1048576   512M 82 Linux swap / Solaris

 

#### GRUB

Configuración final del fichero grub (utiilzado por el comando grub2-mkconfig -o /boot/grub/grub.cfg).

nuc ~ # confcat /etc/default/grub
GRUB\_DISTRIBUTOR="Gentoo"
GRUB\_TIMEOUT=0
GRUB\_CMDLINE\_LINUX="init=/usr/lib/systemd/systemd quiet rootfstype=ext4"
GRUB\_TERMINAL=console
GRUB\_DISABLE\_LINUX\_UUID=true

nuc ~ # cat /boot/grub/grub.cfg
:
menuentry 'Gentoo GNU/Linux' --class gentoo --class gnu-linux --class gnu --class os $menuentry\_id\_option 'gnulinux-simple-9b3f52de-2d26-4722-8f5d-f1cba3cb33b5' {
    load\_video
    insmod gzio
    insmod ext2
    if \[ x$feature\_platform\_search\_hint = xy \]; then
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

Aquí encontrarás el [Kernel 4.4.1](https://raw.githubusercontent.com/LuisPalacios/Linux-Kernel-configs/master/configs/2016-02-13-config-4.4.1-NUC-NUC6i5SYK-SSD-NVMe-KVM.txt) utilizado para reconocer discos NVMe.

 

## BIOS (final)

Configuración final de la BIOS.

[![BIOS-FastBoot](https://www.luispa.com/wp-content/uploads/2016/02/BIOS-FastBoot-300x130.png)](https://www.luispa.com/wp-content/uploads/2016/02/BIOS-FastBoot.png)

[![BIOS-NVMe](https://www.luispa.com/wp-content/uploads/2016/02/BIOS-NVMe-300x217.png)](https://www.luispa.com/wp-content/uploads/2016/02/BIOS-NVMe.png)

BIOS QUICK BOOT: SI  (IMPORTANTE para conseguir los 5 segundos)

BIOS NUC BIOS Devices -- Sata:
        Chipset SATA (NO) --- QUITA EL CHECK, NO HACE FALTA !!!!!!!!!
        M.2 NVMe     SSD:  SAMSUNG MZVPV256HDGL-00000 (256.3GB-PCIe x4, 8.0GT/s)
        Hard Disk Pre-Delay: 0
        HDD Activity Led: (NO)
        M.2 PCIe SSD Led: (SI)
