---
title: "Virtualización: Guest (VM) Linux en host ESXi"
date: "2015-03-15"
categories: 
  - "apuntes"
  - "gentoo"
  - "virtualizacion"
tags: 
  - "esxi"
  - "gentoo-2"
  - "guest"
  - "linux"
  - "vm"
  - "vmware"
---

Este apunte está dedicado a la instalación de **Gentoo Linux (3.18.7 - 64 bits - systemd)** sobre **ESXi**. Se trata de mi primera VM y la voy a ejecutar en mi ESXi casero. Echa un ojo a este [apunte sobre VMWare ESXi 5.5](https://www.luispa.com/?p=29) en un servidor casero.

[![D54250WYK-ESX-Gentoo](https://www.luispa.com/wp-content/uploads/2015/03/D54250WYK-ESX-Gentoo.png)](https://www.luispa.com/wp-content/uploads/2015/03/D54250WYK-ESX-Gentoo.png)  

## Crear la VM

Inicio la creación de la nueva VM, desde el vSphere Client (en Windows) selecciono el [Host](https://www.luispa.com/?p=29) y la opción "Create a new virtual machine".

Como datastore uso un NAS casero vía NFS, donde he reservado un directorio especial para las máquinas virtuales (y los ISO's de arranque).

[![ESXi-Create](https://www.luispa.com/wp-content/uploads/2015/03/ESXi-Create.png)](https://www.luispa.com/wp-content/uploads/2015/03/ESXi-Create.png)

Recorro todas las opciones para configurar una nueva máquina virtual con estos parámetros que muestro a continuación, 2GB de RAM y 10GB de disco, una tarjeta de red E1000 y LSI Logic:

[![ESXi-Create2](https://www.luispa.com/wp-content/uploads/2015/03/ESXi-Create2.png)](https://www.luispa.com/wp-content/uploads/2015/03/ESXi-Create2.png)

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**NOTA**: Asigno 4 virtual cpu's para acortar los tiempos de compilación, una vez que tenga la máquina lista reduciré este número en los clones que genere en el futuro.

\[/dropshadowbox\]  

Antes de arrancar, descargo desde los [mirrors](http://www.gentoo.org/main/en/mirrors2.xml) de Gentoo el ISO install-amd64-minimal-<fecha del último>.iso y lo coloco en /Apps/iso (un directorio que está en mi NAS a la que accedo vía NFS):

- Directorio donde está el stage3-amd64-minimal-<fecha-último>.tar.bz2 en los Mirrors ([ejemplo en un mirror de España](http://gentoo-euetib.upc.es/mirror/gentoo/releases/amd64/autobuilds/current-install-amd64-minimal/)):
    
    - /mirror/gentoo/releases/amd64/autobuilds/current-install-amd64-minimal

Entro en "Edit Settings" y conecto el ISO que acabo de bajarme y dejé en el directorio del NAS. Dicho ISO debe conectarse al DVD de esta máquina virtual para hacer boot desde él. Aunque es opcional a mi me gusta hacerlo, entro en Network adapter y me apunto la dirección MAC (o le asigno una manual). Pongo dicha MAC en mi DHCP Server para que al arrancar reciba una IP concreta estática.

[![ESXi-Create3](https://www.luispa.com/wp-content/uploads/2015/03/ESXi-Create3.png)](https://www.luispa.com/wp-content/uploads/2015/03/ESXi-Create3.png)

Selecciono la VM, su lengüeta "Console" y hago el "Power On". Al hacer click en la Consola podremos controlar el proceso de arranque (Ctrl+Alt o Fn+Ctrl+Alt para salir). Pulso Intro para que arranque, "13" para el teclado Español, Intro para continuar hasta el prompt de Gentoo. A partir de aquí iniciamos el proceso de instalación estándar (bueno, con la particularidad de que estamos instalando en un Host ESXi).

[![ESXi-Create4](https://www.luispa.com/wp-content/uploads/2015/03/ESXi-Create4-1024x684.png)](https://www.luispa.com/wp-content/uploads/2015/03/ESXi-Create4.png)  

## Instalación de Gentoo

### Continuamos vía SSHD

Ya estamos listos para continuar, deberíamos tener "red" (ifconfig) y así poder arrancar "SSHD", cambiar la contraseña de root y a partir de ahora serguir desde otro terminal (vía ssh). Es mucho más cómodo que usar la consola del cliente vSphere:

[![ESXi-GentooInstall-1](https://www.luispa.com/wp-content/uploads/2015/03/ESXi-GentooInstall-1.png)](https://www.luispa.com/wp-content/uploads/2015/03/ESXi-GentooInstall-1.png)  

### Disco, stage3, portage

Desde un Terminal (vía ssh) configuro el disco duro, creo una partición única con /boot de 50M, partición 2 Swap de 512M y el resto del disco para la Partición 3 (root)

livecd ~ #
livecd ~ # fdisk -l

Disk /dev/sda: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 \* 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

livecd ~ # fdisk /dev/sda
:
Command (m for help): o
Created a new DOS disklabel with disk identifier 0x107d525e.

Command (m for help): n

Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-20971519, default 2048):
Last sector, +sectors or +size{K,M,G,T,P} (2048-20971519, default 20971519): +50M

Created a new partition 1 of type 'Linux' and of size 50 MiB.

Command (m for help): n

Partition type:
   p   primary (1 primary, 0 extended, 3 free)
   e   extended
Select (default p): p
Partition number (2-4, default 2):
First sector (104448-20971519, default 104448):
Last sector, +sectors or +size{K,M,G,T,P} (104448-20971519, default 20971519): +512M

Created a new partition 2 of type 'Linux' and of size 512 MiB.

Command (m for help): n

Partition type:
   p   primary (2 primary, 0 extended, 2 free)
   e   extended
Select (default p): p
Partition number (3,4, default 3):
First sector (1153024-20971519, default 1153024):
Last sector, +sectors or +size{K,M,G,T,P} (1153024-20971519, default 20971519):

Created a new partition 3 of type 'Linux' and of size 9.5 GiB.

Command (m for help): t
Partition number (1-3, default 3): 2
Hex code (type L to list all codes): 82

Changed type of partition 'Linux' to 'Linux swap / Solaris'.

Command (m for help): a
Partition number (1-3, default 3): 1

The bootable flag on partition 1 is enabled now.

Command (m for help): p
Disk /dev/sda: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 \* 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x107d525e

Device    Boot     Start       End  Blocks  Id System
/dev/sda1 \*         2048    104447   51200  83 Linux
/dev/sda2         104448   1153023  524288  82 Linux swap / Solaris
/dev/sda3        1153024  20971519 9909248  83 Linux

Command (m for help): w

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

 mkfs.ext2 /dev/sda1
 mkfs.ext4 /dev/sda3
 mkswap /dev/sda2
 swapon /dev/sda2
 mount /dev/sda3 /mnt/gentoo
 mkdir /mnt/gentoo/boot
 mount /dev/sda1 /mnt/gentoo/boot 

**Cambiar la Fecha**

Este paso es importante, cambia la fecha al equipo y asegúrate de poner la actual (no la del ejemplo :-))

 date 031511052015 

**Descargar y descomprimir Stage3 y Portage**

Descargo en /mnt/gentoo desde uno de los mirrors de gentoo el fichero "stage3" y el fichero "portage", los últimos disponibles para x86\_64. Utilizo "links" para descargar desde los mirrors de Gentoo. Conecta desde tu navegador con www.gentoo.org, click en [Mirrors](http://www.gentoo.org/main/en/mirrors2.xml), apunta la URL de tu mirror preferido (busca por Spain) que vas a usar a continuación.

:
# cd /mnt/gentoo/
:
# links :   USA EL TECLADO PARA NAVEGAR y descarga el stage3 y el portage...
:
:    /mirror/gentoo/releases/amd64/autobuilds/ :     --> stage3-amd64-20150312.tar.bz2
: 
:    /mirror/gentoo/snapshots 
:     --> portage-latest.tar.bz2
:
:
:
# tar xvjpf stage3-\*.tar.bz2
:
# cd /mnt/gentoo/usr
# tar xvjpf ../portage-\*.tar.bz2 
:
# cd ..
# rm portage-latest.tar.bz2 stage3-amd64-20150312.tar.bz2
rm: remove regular file 'portage-latest.tar.bz2'? y
rm: remove regular file 'stage3-amd64-20150312.tar.bz2'? y 

### Entrar en el nuevo entorno

A partir de ahora entro ya directamente en el nuevo entorno con chroot, por lo tanto "/" (root) apuntará al nuevo disco que acabamos de formatear y donde hemos descomprimido todo el software. Importante copiar el resolv.conf :-)

 

 cp /etc/resolv.conf /mnt/gentoo/etc
 
 mount -t proc none /mnt/gentoo/proc
 mount --rbind /sys /mnt/gentoo/sys
 mount --rbind /dev /mnt/gentoo/dev
 chroot /mnt/gentoo /bin/bash
 source /etc/profile
 export PS1="(chroot) $PS1"
 

**Modificamos el fichero make.conf:**

#
# Opciones de compilacion, by LuisPa. -l'n' n=+1 CPUs
CFLAGS="-O2 -march=native -pipe"
CXXFLAGS="${CFLAGS}"
MAKEOPTS="-j3 -l3"
EMERGE\_DEFAULT\_OPTS="--nospinner --keep-going --jobs=5 --load-average=5"

# CHOST
CHOST="x86\_64-pc-linux-gnu"

# USE Flags
USE="-bindist aes avx fma3 mmx mmxext popcnt sse sse2 sse3 sse4\_1 sse4\_2 ssse3 -gnome -kde"

# Nuevo CPU Flags
#  $ emerge -1v app-portage/cpuinfo2cpuflags
#  $ cpuinfo2cpuflags-x86
#
CPU\_FLAGS\_X86="aes avx fma3 mmx mmxext popcnt sse sse2 sse3 sse4\_1 sse4\_2 ssse3"

# Ubicaciones de portage
PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"

# Lenguaje
LINGUAS="es en"

# Mirrors
GENTOO\_MIRRORS="http://gentoo-euetib.upc.es/mirror/gentoo/"

# Teclado y graficos
INPUT\_DEVICES="keyboard mouse vmmouse evdev"
VIDEO\_CARDS="fbdev nv vesa vmware intel"

**Leemos todas las "News"**

(chroot) livecd ~ # eselect news list
(chroot) livecd ~ # eselect news read ’n’

**Establecemos la Zona horaria**

(chroot) livecd ~ # cd /
(chroot) livecd / # cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime
(chroot) livecd / # echo "Europe/Madrid" > /etc/timezone

**Preparo el /etc/fstab**

/dev/sda1 /boot ext2 noauto,noatime 1 2
/dev/sda2 none swap sw 0 0
/dev/sda3 / ext4 noatime 0 1

**Instalo v86d**

\# emerge -v v86d
# eselect python set --python3 python3.3
 

**Instalo DHCP Cliente**

Para el futuro arranque tras el primer boot, mejor instalar ahora el paquete cliente de DHCP

\# emerge -v dhcpcd

**Descargo y compilo el último Kernel**

Primero nos bajamos los fuentes del Kernel con el comando siguiente:

(chroot) livecd / # emerge -v gentoo-sources

Los fuentes quedan instalados en /usr/src/linux (realmente es un link simbólico), a continuación tendrías que parametrizarlo con "make menuconfig" y luego compilarlo.

Si tienes experiencia en parametrizar el kernel, adelante con ello. Si lo prefieres, para facilitarte el trabajo, empieza por un kernel ya parametrizado. Puedes usar un ".config ya probado" para esta versión concreta de kernel. Este que comparto a continuación tiene soporte para ejecutarse en ESXi, para iptables (por si quieres hacerte un firewall) y para Docker (por si quieres dockerizar aplicaciones). Lo dejo en mi repositorio de [GitHub](https://github.com/LuisPalacios/Linux-Kernel-configs), en concreto tienes que bajarte el fichero [2015-03-19-config-3.18.7-Gentoo\_VM\_ESXi.txt](https://raw.githubusercontent.com/LuisPalacios/Linux-Kernel-configs/master/configs/2015-03-19-config-3.18.7-Gentoo_VM_ESXi.txt) y copiarlo como /usr/src/linux/.config. Luego compilas e instalas el kernel.

 cd /usr/src/linux

 wget https://raw.githubusercontent.com/LuisPalacios/Linux-Kernel-configs/master/configs/2015-03-19-config-3.18.7-Gentoo\_VM\_ESXi.txt -O .config 

 make && make modules\_install
 cp arch/x86\_64/boot/bzImage /boot/kernel-3.18.7-gentoo
 cp System.map /boot/System.map-3.18.7-gentoo

 

## Instalación de "systemd"

**Selecciono el Perfil systemd**

Voy a configurar esta VM con systemd, así que selecciono el perfil adecuado:

(chroot) livecd / # eselect profile list
:
\[5\] default/linux/amd64/13.0/desktop/gnome/systemd
:
(chroot) livecd / # eselect profile set 5
 

**Adapto Portage**

Antes de actualizar el sistema (tras el cambio de profile) hay que preparar los diferentes ficheros de Portage:

\# iproute
dev-haskell/appa ~amd64
dev-haskell/iproute ~amd64
dev-haskell/byteorder ~amd64

net-misc/iputils -caps -filecaps

**Recompilo con el nuevo Profile systemd**

Una vez que se selecciona un Profile distinto lo que ocurre es que cambias los valores USE de por defecto del sistema y esto significa que tenemos que "recompilarlo" por completo, así que lo siguiente que vamos a hacer es un emerge que actualice "world" :

# emerge -avDN @world

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**NOTA**: El proceso re-compila más de 150 paquetes y es normal que tarde varias horas (2 en mi caso), por eso asigné 4 virtual cpu's a esta VM, para acortar este tiempo al máximo.

\[/dropshadowbox\]   **Hostname** Con systemd se deja de usar /etc/conf.d/hostname, así que voy a editar a mano directamente los dos ficheros que emplea systemd:

gentoo

PRETTY\_NAME="VM Gentoo Linux"
ICON\_NAME="gentoo"

**Contraseña de root**

Antes de hacer boot, es fundamental cambiar la contraseña de root

(chroot) livecd init.d # passwd
New password:
Retype new password:
passwd: password updated successfully
 

**Herramientas indispensables al trabajar con Gentoo**

\# emerge -v eix genlop
# eix-update 

**Preparo el mtab**

Es necesario realizar un link simbólico especial:

\# rm /etc/mtab
# ln -sf /proc/self/mounts /etc/mtab

**Grub 2**

Necesitamos un "boot loader" y nada mejor que Grub2.

\# emerge -v grub:2

Instalamos el boot loader en el disco

\# grub2-install /dev/sda

Modifico el fichero de configuración de Grub /etc/default/grub, la siguientes son las líneas importantes:

GRUB\_CMDLINE\_LINUX="init=/usr/lib/systemd/systemd quiet rootfstype=ext4" GRUB\_TERMINAL=console GRUB\_DISABLE\_LINUX\_UUID=true

Ah!, en el futuro, cuando te sientas confortable, cambia el timeout del menu que muestra Grub a "0", de modo que ganarás 5 segundos en cada rearranque de tu servidor Gentoo desde vSphere Client :-)

GRUB\_TIMEOUT=0

Cada vez que se modifica el fichero /etc/default/grub hay que ejecutar el programa grub2-mkconfig -o /boot/grub/grub.cfg porque es él el que crea la versión correcta del fichero de configuración de Grub: /boot/grub/grub.cfg.

\# mount /boot (por si acaso se te había olvidado :-))
# grub2-mkconfig -o /boot/grub/grub.cfg

Nota, si en el futuro tienes que modificar el Kernel, no olvides ejecutar grub2-mkconfig tras la compilación (y posterior copiado a /boot) del kernel, tampoco te olvides de haber montado /boot (mount /boot) previamente.

 

### Reboot

Salgo del chroot, desmonto y rearranco el equipo...

 
# exit
# cd
# umount -l /mnt/gentoo/dev{/shm,/pts,}
# umount -l /mnt/gentoo{/boot,/proc,}
:
# reboot
 

**Un par de scripts**

Dejo aquí un par de scripts que te pueden servir de ayuda, se llaman "compila.sh" e "instala.sh"

#!/bin/bash
#
# Script de apoyo para recompilar el Kernel
# By LuisPa, 2015

cd /usr/src/linux
make && make modules\_install

#!/bin/bash
#
# Script de apoyo para instalar el último kernel. Se apoya en el enlace simbólico
# By LuisPa, 2015

# Compruebo si existe /usr/src/linux
if \[ ! -L "/usr/src/linux" \]; then
    echo "ERROR, no encuentro el link simbólico /usr/src/linux"
    exit
fi

# Obtengo el numero de la versión a la que está enalazado
cd /usr/src
ls -al linux | sed '/.\*-\\(.\*\\)-gentoo.\*/{s/.\*-\\(.\*\\)-gentoo.\*/\\1/;q}; /.\*-\\(.\*\\)-gentoo.\*/!{q100}' > /dev/null
if \[ "$?" = "0" \]; then
    export version=\`ls -al linux | sed 's/.\*-\\(.\*\\)-gentoo.\*/\\1/'\`
else
    echo "ERROR, /usr/src/linux no está enlazado a un directorio del tipo xxxx-X.Y.Z-xxxxx"
fi

# Monto boot y si todo fue bien instalo el kernel
mount /boot > /dev/null 2>&1
if grep -qs '/boot' /proc/mounts; then
    cd /usr/src/linux
    cp arch/x86\_64/boot/bzImage /boot/kernel-${version}-gentoo
    cp System.map /boot/System.map-${version}-gentoo
    cp .config /boot/config-${version}-gentoo
    grub2-mkconfig -o /boot/grub/grub.cfg
    umount /boot
    echo
    echo "Se instaló el kernel versión ${version}"
else
    echo "ERROR, no se instala el kernel porque no se puede montar /boot"
fi

 

## Configuración importante

Una vez que el equipo rearranca tenemos que volver a la consola del ESXi, tras el primer boot nos faltan piezas muy importantes, de hecho estás con el teclado en inglés, no te funciona la red, no tienes locales, etc. Vamos a arreglarlo empezando por lo básico.. el teclado :-)

**Teclado y Locale**

Parametrizo con systemd el teclado y los locales ejecutando los tres comandos siguientes:

El primer comando modifica /etc/vconsole.conf

 localectl set-keymap es

El siguiente modifica /etc/X11/xorg.conf.d/00-keyboard.conf

 localectl set-x11-keymap es 

El siguiente modifica /etc/locale.conf

 localectl set-locale LANG=es\_ES.UTF-8 

El ultimo simplemente para comprobar

\# localectl
System Locale: LANG=es\_ES.UTF-8
VC Keymap: es
X11 Layout: es

**Preparo el fichero locale.gen**

en\_US ISO-8859-1
en\_US.UTF-8 UTF-8
es\_ES ISO-8859-1
es\_ES@euro ISO-8859-15
es\_ES.UTF-8 UTF-8
en\_US.UTF-8@euro UTF-8
es\_ES.UTF-8@euro UTF-8

Compilo los "locales"

\# locale-gen
 

**La red**

Vamos a "contectar", instalo, habilito y arranco DHCP. Los servicios en "systemd" se programan para futuros arranques con "systemctl enable" y se pueden arrancar o parar con "systemctl start/stop".

\# systemctl enable dhcpcd.service
# systemctl start dhcpcd.service
 

[Aquí tienes un ejemplo](https://www.luispa.com/?p=581) de cómo hacer una configuración de dirección IP fija (manual).

Si todo falla siempre puedes asignar una IP fija mientras solucionas el problema. Averigua cómo se llama el interfaz, un ejemplo:

\# dmesg | grep -i e1000
\[    3.563105\] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
\[    3.563111\] e1000: Copyright (c) 1999-2006 Intel Corporation.
\[    3.917422\] e1000 0000:02:00.0 eth0: (PCI:66MHz:32-bit) 00:0c:29:c2:79:ea
\[    3.917429\] e1000 0000:02:00.0 eth0: Intel(R) PRO/1000 Network Connection
\[    4.038847\] e1000 0000:02:00.0 enp2s0: renamed from eth0
\[    5.288029\] e1000: enp2s0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None

# ifconfig enp2s0 192.168.1.242 netmask 255.255.255.0
# ip route add default via 192.168.1.1

**Activo SSHD**

Otro indispensable, habilito y arranco el daemon de SSH para poder conectar con esta VM vía ssh. Si en el futuro quieres poder hacer forward de X11 recuerda poner X11Forwarding yes en el fichero /etc/ssh/sshd\_config

\# systemctl enable sshd.service
# systemctl start sshd.service

Nota: Si sshd no te funciona, prueba:
# systemctl disable sshd.service
# systemctl enable sshd.socket

**Vixie-cron**

Instalo, habilito y arranco el cron

\# emerge -v vixie-cron
# systemctl enable vixie-cron.service
# systemctl start vixie-cron.service

**Fecha y hora**

Para configurar fecha/hora debe utilizarse "timedatectl". No te pierdas este apunte sobre cómo montar además el [servicio NTP](https://www.luispa.com/?p=881).

\# timedatectl set-local-rtc 0
# timedatectl set-timezone Europe/Madrid
# timedatectl set-time 2012-10-30 18:17:16 <= Ponerlo primero en hora.
# timedatectl set-ntp true <= Activar NTP

 

**Actualizo portage**

Lo primero es hacer un "perl-cleaner" y luego un update completo.

:
# perl-cleaner --reallyall
:
# emerge -DuvN system world

**Usuario y rearranque**

Desde una shell añado un usuario normal y por último rearranco el equipo. Mira un ejemplo:

\# groupadd -g 1400 luis
# useradd -u 1400 -g luis -m -G cron,audio,cdrom,cdrw,users,wheel -d /home/luis -s /bin/bash luis
:
# passwd luis
Nueva contraseña:
Vuelva a escribir la nueva contraseña:
:

Rearranco de nuevo...

# reboot.  (O bien "halt" para pararla)

 

## VMWare Tools

Nos falta un último paso,

**Open-VM**

Instalo las tools de VMWare, la versión open source, para ello editamos el fichero package.use y package.accept\_keywords. Es muy importante que no olvides la opción "-modules" para que se pueda instalar sin problemas.

app-emulation/open-vm-tools -X -modules fuse

\# Open Source VMWare tools
=app-emulation/open-vm-tools-2013.09.16.1328054-r3 ~amd64

\_\_\_PRIMERO VEMOS QUE SE INSTALARÍA\_\_\_

gentoo ~ # emerge -pv open-vm-tools
These are the packages that would be merged, in order:
Calculating dependencies  ... done!
\[ebuild  N     \] virtual/linux-sources-1  USE="-firmware" 0 KiB
\[ebuild  N     \] sys-apps/ethtool-3.12.1  183 KiB
\[ebuild  N     \] dev-libs/libdnet-1.12  USE="ipv6 -python -static-libs {-test}" PYTHON\_TARGETS="python2\_7" 953 KiB
\[ebuild  N     \] sys-fs/fuse-2.9.3  USE="-examples -static-libs" 559 KiB
\[ebuild  N    ~\] app-emulation/open-vm-tools-2013.09.16.1328054-r3  USE="modules pam pic -X -doc -icu -xinerama" 0 KiB

Total: 6 packages (6 new), Size of downloads: 5.399 KiB

\_\_\_EJECUTAMOS LA INSTALACIÓN\_\_\_

gentoo ~# emerge -v open-vm-tools

A continuación programamos que el servicio de VMWare tools arranque durante el boot y de paso lo activamos:

gentoo ~ # systemctl enable vmtoolsd.service
Created symlink from /etc/systemd/system/multi-user.target.wants/vmtoolsd.service to /usr/lib64/systemd/system/vmtoolsd.service.
gentoo ~ # systemctl start vmtoolsd.service

Ya deberías poder ven cómo el cliente vSphere detecta que las vmware tools se han activado en tu VM

[![Gentoo-VMWare-Tools](https://www.luispa.com/wp-content/uploads/2015/03/Gentoo-VMWare-Tools.png)](https://www.luispa.com/wp-content/uploads/2015/03/Gentoo-VMWare-Tools.png)  

## Aplicaciones extra y acabamos...

Antes de apagar y clonar, voy a personalizar esta máquina virtual con ciertas aplicaciones que a mi me gusta tener siempre por defecto, digamos que es un Linux "base" con preferencias personales:

emerge -v sudo gentoolkit emacs mono              \\
          pciutils tcpdump traceroute telnetd     \\
          mlocate xclock gparted bmon procmail    \\
          mlocate traceroute telnetd net-snmp

Instalo LVM2, lo necesito para docker...

# emerge -v lvm2
:
# systemctl enable lvm2-monitor.service

sigo con nfs-utils para montar volúmenes remotos desde mi NAS,

# emerge -v nfs-utils
:
# systemctl enable rpcbind.service
:

Ejemplo de fichero fstab para acceder a recursos remotos NFS

\# Recursos en la NAS via NFS
nas.parchis.org:/Recordings  /mnt/Recordings  nfs auto,user,exec,rsize=8192,wsize=8192,hard,intr,timeo=5   0 0
nas.parchis.org:/Apps        /Apps            nfs auto,user,exec,rsize=8192,wsize=8192,hard,intr,timeo=5   0 0

continúo con Docker,

\# Virtualizador Docker
=app-emulation/docker-1.5.0 ~amd64

\# emerge -v app-emulation/docker
:
# systemctl enable docker.service
:
# usermod -aG docker luis
:

Ya hemos terminado, te recomiendo que apagues la VM y guardes una copia (a contiuación explico cómo se hace).

  [![barra_separadora](https://www.luispa.com/wp-content/uploads/2015/03/barra_separadora.png)](https://www.luispa.com/wp-content/uploads/2015/03/barra_separadora.png)  

# Unos cuantos trucos

A continuación dejo algunos trucos que pueden servirte de ayuda.

 

### Clonar VM: mediante plantilla OVF/OVA

La primera opción es crear una plantilla en formato OVF (varios ficheros) o bien OVA (un único fichero)

- IMPORTANTE: Para la máquina virtual desde vSphere Client.
    
- Creo la plantilla [![esxi-cloneOVA1](https://www.luispa.com/wp-content/uploads/2015/03/esxi-cloneOVA1.png)](https://www.luispa.com/wp-content/uploads/2015/03/esxi-cloneOVA1.png)
    
- A partir de ahora puedes usar dicha plantilla para crear VM's nuevas
    

[![newVM](https://www.luispa.com/wp-content/uploads/2015/05/newVM.jpg)](https://www.luispa.com/wp-content/uploads/2015/05/newVM.jpg)

 

### Clonar VM: copia manual

Otra opción es clonar manualmente ([fuente](http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1027876)):

- IMPORTANTE: Para la máquina virtual desde vSphere Client.
    
- Clonamos el disco contectando con el ESXi vía SSH
    

\_\_\_ CONECTAR VIA SSH CON EL ESXi \_\_\_
obelix:~ luis$ ssh -l root esxi.parchis.org
Password:
~ #

\_\_\_ CREAR EL DIRECTORIO DE LA NUEVA VM \_\_\_
~ # mkdir /vmfs/volumes/Panoramix-NFS-Apps/Totobo
~ #

\_\_\_ CLONAR EL DISCO (en mi caso es Thin)\_\_\_
~ # mkdir /vmfs/volumes/Panoramix-NFS-Apps/Totobo
~ # vmkfstools -i /vmfs/volumes/Panoramix-NFS-Apps/Gentoo/Gentoo.vmdk /vmfs/volumes/Panoramix-NFS-Apps/Totobo/Totobo.v
mdk -d thin
Destination disk format: Thin
Cloning disk '/vmfs/volumes/Panoramix-NFS-Apps/Gentoo/Gentoo.vmdk'...
:

- Desde el vSphere Client crear una nueva máquina virtual tal como describo en este artículo pero esta vez al llegar a la parte del disco duro utiliza "Use an existing virtual disk"

[![esxi-cloneVM1](https://www.luispa.com/wp-content/uploads/2015/03/esxi-cloneVM1.png)](https://www.luispa.com/wp-content/uploads/2015/03/esxi-cloneVM1.png) [![esxi-cloneVM3](https://www.luispa.com/wp-content/uploads/2015/03/esxi-cloneVM3.png)](https://www.luispa.com/wp-content/uploads/2015/03/esxi-cloneVM3.png) [![esxi-cloneVM2](https://www.luispa.com/wp-content/uploads/2015/03/esxi-cloneVM2.png)](https://www.luispa.com/wp-content/uploads/2015/03/esxi-cloneVM2.png)

**Boot desde el ISO de Instalación**

Una vez que terminas la instalación la VM siempre hará boot desde el disco duro, por lo tanto si necesitas hacer boot desde el ISO de instalación (por ejemplo para resolver algún problema), es tan sencillo como meterse en la BIOS de la maquina virtual y alterar el orden de arranque. Selecciono la VM, botón derecho: "edit virtual machine settings" -> "options" -> "settings" -> "Boot Options" y activo "Force BIOS Setup". En el próximo boot entramos en la BIOS y podremos cambiar el orden de arranque.

**Montar un disco VMDK desde Linux**

Si necesitas montar un disco VMDK desde un equipo externo (windows o linux) tienes que instalar una herramienta llamada vmware-mount que es parte del (vSphere 5 Disk Development Kit). En mi caso he desacargado la versión para LINUX y encontré dicho programa en la versión 5.1 (no en la 5.5) de dicho Kit VDDK, disponible en el sitio de desarrolladores de VMWare en la sección [vSphere Disk Development Kit](http://www.vmware.com/support/developer/vddk). A continuación muestro un ejemplo donde monto un VMDK desde un Linux (no usar Nombre-flat.vmdk, sino Nombre.vmdk)

bolica ~ # vmware-mount /Apps/datastore/Totobo/Totobo.vmdk 3 /mnt/totobo

\_\_\_ Para desmontarla \_\_\_
bolica ~ # vmware-mount -k /Apps/datastore/Totobo/Totobo.vmdk
:

**Recompilar el Kernel de Gentoo**

Si necesitas modificar alguno de los parámetros del fichero .config que dejé arriba tendrás que seguir los pasos siguietnes para cambiarlo y recompilar e instalar de nuevo el kernel:

\_\_\_ MODIFICO EL KERNEL \_\_\_
 mount /boot (por si acaso se te había olvidado :-))
 cd /usr/src/linux
 make menuconfig
:

\_\_\_ COMPILAMOS EL KERNEL \_\_\_
 make && make modules\_install
:

\_\_\_ COPIAMOS EL KERNEL A /boot \_\_\_
 cp arch/x86\_64/boot/bzImage /boot/kernel-3.18.7-gentoo
 cp System.map /boot/System.map-3.18.7-gentoo
 cp .config /boot/config-3.18.7-gentoo

\_\_\_ EJECUTAMOS GRUB \_\_\_
 grub2-mkconfig -o /boot/grub/grub.cfg
:

\_\_\_ REARRANCAMOS \_\_\_
 reboot
:

**Systemd: Enlace simbólico - Boot en modo Consola**

En este apunte uso el modo consola, pero si lo has cambiado y quieres volver a boot en modo consola (en vez de gráfico) te dejo cómo hacerlo con Systemd

\# ln -sf /usr/lib/systemd/system/multi-user.target /etc/systemd/system/default.target

**Systemd: Mensaje "WRITE SAME failed"**

Este tema me costó encontralo en el pasado y solo porque probe a activar X11 (que no es el caso de este apunte). Si ves dicho error durante el boot, justo antes de arrancar X11, la forma de resolverlo es:

\# find /sys | grep max\_write\_same\_blocks
/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/scsi\_disk/2:0:0:0/max\_write\_same\_block
Añado este dispositivo a un nuevo fichero de configuración, debe terminar en .conf y residir en /etc/tmpfiles.d/:

# cat > /etc/tmpfiles.d/write\_same.conf <<EOD
# Type Path Mode UID GID Age Argument
w /sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/scsi\_disk/2:0:0:0/max\_write\_same\_blocks - - - - 0
EOD

**Trabajar con Systemd**

Ubicación de los servicios: /usr/lib64/systemd/system

Arrancar en boot: systemctl enable nombre.service Quitar del boot: systemctl disable nombre.service Arrancar ahora: systemctl start nombre.service Re-arrancar ahora: systemctl restart nombre.service Parar ahora: systemctl stop nombre.service Ver el estado actual: systemctl status nombre.service

Mostrar las "units" cargadas en el sistema: systemctl list-units

**Logging con Systemd**

Dejo aquí algunos comandos útiles:

Ver el log: journalctl Ver el log de forma contínua: journalctl -f Ver el log del último boot: journalctl -b Log de boot, solo ERROR o superior: journalctl -b -p err Log disco sda: journalctl /dev/sda Log entre fechas: journalctl --since=2014-01-15 --until="2014-01-20 23:59:59 Desde ayer: journalctl --since=yesterday Log de "ábaco": journalctl /bin/abaco Log de "ábaco" y además "curl": journalctl /bin/abaco /bin/curl Log de Apache: journalctl -u httpd --since=07:30 --until=08:30 Log de sshd de forma contínua: journalctl -f /usr/sbin/sshd

 

# Mantenimiento

Gentoo es una "distro" que está en actualización continua, todos los días suele haber algún "paquete" upstream que ha sido actualizado a una versión más moderna. Por lo tanto es muy conveniente que de vez en cuando (cada semana o cada mes) compruebes si deberías actualizar tu Gentoo y dejarlo a la última.

¿qué hago yo?, cuando tengo el sistema estable y funcionando al 100% no necesito actualizarlo cada dos por tres sino que lo actualizo una vez al año o cuando hay algún fallo de [seguridad](https://www.gentoo.org/security/en/) grave. Estoy [suscrito a la lista](https://www.gentoo.org/main/en/lists.xml) **gentoo-announce**@gentoo.org y cuando veo que el tema es preocupante pues hago una Actualización.

**Actualizar tu Gentoo**

La teoría es que es muy sencillo, la práctica es que a veces, sobre todo si llevas mucho tiempo sin actualizar, se puede complicar bastante. Si estás empezando con Gentoo te recomiendo que actualices una vez por semana durante un par de meses, luego una vez al mes durante un año y luego pases a una vez al año. ¿Porqué?, pues porque a veces hay "conflictos" entre los paquetes a instalar y si eres nuevo puede ser un dolor de cabeza, así que empieza a actualizar de forma frecuente para perder el miedo y sobre todo ganar en práctica. Si alguna vez tienes problemas encontrarás la solución casi seguro en el [Foro de Gentoo](https://forums.gentoo.org/), no dejes de visitarlo.

Estos son los pasos:

- Sincronizamos "portage": \# emerge --sync
- Comprobamos qué se va a actualizar: \# emerge -DuvNp system world
- Actualizamos: \# emerge -DuvN system world
- Actualizamos EIX: \# eix-update
- Actualizamos los ficheros en /etc: \# etc-update

A continuación tienes un ejemplo donde compruebo qué tengo que actualizar, fíjate en cuantos paquetes y solo han pasado 10 días desde que hice la primera instalación.

[![emergeUpdate](https://www.luispa.com/wp-content/uploads/2015/03/emergeUpdate-901x1024.png)](https://www.luispa.com/wp-content/uploads/2015/03/emergeUpdate.png)

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**AVISO**: Cuidado con el comando etc-update, te recomiendo que entiendas bien qué es Portage y qué hace este comando en concreto.

\[/dropshadowbox\]   **Portage**

Portage es la herramienta que gestiona el software en Gentoo y lo hace a través del comando emerge

- Documento en castellano sobre [Portage](https://www.gentoo.org/doc/es/handbook/handbook-x86.xml?part=2&chap=1)
- El manual de Portage: \# man portage
- Documento en inglés sobre [cómo trabajar con Portage](https://wiki.gentoo.org/wiki/Handbook:Alpha/Full/Portage)
- [Proyecto Portage](https://wiki.gentoo.org/wiki/Project:Portage)

**Actualizar el Kernel**

Al actualizar Gentoo resulta que uno de los paquetes es el "Kernel", ¿qué hago?. Puedes hacer dos cosas, la primera es ignorarlo y seguir con tu Kernel actual y la segunda es actualizar también el Kernel. Mi consejo es que si tienes tu sistema estable y no necesitas nada del Kernel nuevo (un hardware nuevo o un update de seguridad), ni lo toques, deja el que tenías.

Enseño a continuación cómo suelo hacerlo por si insistes :-) . Te recomiendo que leas el artículo de Gentoo sobre [actualización del Kernel](http://www.gentoo.org/doc/en/kernel-upgrade.xml). Veamos este caso concreto, notarás en la captura anterior que en mi caso se ha bajado un kernel nuevo.

[![emergeKernel](https://www.luispa.com/wp-content/uploads/2015/03/emergeKernel.png)](https://www.luispa.com/wp-content/uploads/2015/03/emergeKernel.png)

Si miro en el directorio /usr/src veo que ahora hay dos kernels, el que está activo (3.18.7) y el nuevo (3.18.9).

[![nuevoKernel](https://www.luispa.com/wp-content/uploads/2015/03/nuevoKernel.png)](https://www.luispa.com/wp-content/uploads/2015/03/nuevoKernel.png)

Para actualizarlo ejecuto lo siguiente:

gentoo ~ # cd /usr/src/

\_\_\_ BORRO Y RECREO EL LINK SIMBÓLICO AL NUEVO KERNEL \_\_\_
gentoo src # rm linux      
gentoo src # ln -s linux-3.18.9-gentoo linux

\_\_\_ COPIO EL FICHERO .config ANTERIOR \_\_\_
gentoo src # cd linux
gentoo linux # cp ../linux-3.18.7-gentoo/.config .  

\_\_\_ IMPORTO EL .config ANTERIOR \_\_\_
gentoo linux # make oldconfig 
:
 (normalmente puedes ir pulsando Intro y aceptando todo lo que te ofrece por defecto)
:
 
\_\_\_ COMPILO E INSTALO EL NUEVO KERNEL \_\_\_
gentoo linux # make && make modules\_install
gentoo linux # mount /boot
gentoo linux # cp arch/x86\_64/boot/bzImage /boot/kernel-3.18.9-gentoo
gentoo linux # cp System.map /boot/System.map-3.18.9-gentoo
gentoo linux # cp .config /boot/config-3.18.9-gentoo
gentoo linux # grub2-mkconfig -o /boot/grub/grub.cfg

\_\_\_ REBOOT \_\_\_
gentoo linux # reboot

 

**Ahorrar espacio en disco**

Si vas a utilizar esta imagen como fuente para clonar, te recomiendo que limpies al menos el directorio donde se bajan los paquetes de software durante su instalación \# rm -fr /usr/portage/distfiles/\*

 

### Enlaces

- [Post sobre vmware-tools y open-vm-tools](http://forums.gentoo.org/viewtopic-p-6949882.html).
- [Post sobre la optimización del kernel](https://forums.gentoo.org/viewtopic-t-961502.html)
- [Post muy antiguo (archivo) sobre Gentoo en ESX](http://www.gentoo-wiki.info/HOWTO_Install_Gentoo_on_VMware_ESX_server).
- [Apunte sobre systemd en Gentoo](http://wiki.gentoo.org/wiki/Systemd)
