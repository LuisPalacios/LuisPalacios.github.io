---
title: "Virtualización: Guest (VM) Linux en host ESXi"
date: "2015-03-15"
categories: apuntes gentoo virtualizacion
tags: esxi gentoo-2 guest linux vm vmware
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/?p=29"
    caption="apunte sobre VMWare ESXi 5.5"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/D54250WYK-ESX-Gentoo.png"
    caption="D54250WYK-ESX-Gentoo"
    width="600px"
    %}

## Crear la VM

{% include showImagen.html
    src="/assets/img/original/?p=29"
    caption="Host"
    width="600px"
    %}

Como datastore uso un NAS casero vía NFS, donde he reservado un directorio especial para las máquinas virtuales (y los ISO's de arranque).

{% include showImagen.html
    src="/assets/img/original/ESXi-Create.png"
    caption="ESXi-Create"
    width="600px"
    %}

Recorro todas las opciones para configurar una nueva máquina virtual con estos parámetros que muestro a continuación, 2GB de RAM y 10GB de disco, una tarjeta de red E1000 y LSI Logic:

{% include showImagen.html
    src="/assets/img/original/ESXi-Create2.png"
    caption="ESXi-Create2"
    width="600px"
    %}

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**NOTA**: Asigno 4 virtual cpu's para acortar los tiempos de compilación, una vez que tenga la máquina lista reduciré este número en los clones que genere en el futuro.

[/dropshadowbox]  

{% include showImagen.html
    src="/assets/img/original/iso (un directorio que está en mi NAS a la que accedo vía NFS"
    caption="mirrors"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/)"
    caption="ejemplo en un mirror de España"
    width="600px"
    %}
    
    - /mirror/gentoo/releases/amd64/autobuilds/current-install-amd64-minimal

Entro en "Edit Settings" y conecto el ISO que acabo de bajarme y dejé en el directorio del NAS. Dicho ISO debe conectarse al DVD de esta máquina virtual para hacer boot desde él. Aunque es opcional a mi me gusta hacerlo, entro en Network adapter y me apunto la dirección MAC (o le asigno una manual). Pongo dicha MAC en mi DHCP Server para que al arrancar reciba una IP concreta estática.

{% include showImagen.html
    src="/assets/img/original/ESXi-Create3.png"
    caption="ESXi-Create3"
    width="600px"
    %}

Selecciono la VM, su lengüeta "Console" y hago el "Power On". Al hacer click en la Consola podremos controlar el proceso de arranque (Ctrl+Alt o Fn+Ctrl+Alt para salir). Pulso Intro para que arranque, "13" para el teclado Español, Intro para continuar hasta el prompt de Gentoo. A partir de aquí iniciamos el proceso de instalación estándar (bueno, con la particularidad de que estamos instalando en un Host ESXi).

{% include showImagen.html
    src="/assets/img/original/ESXi-Create4-1024x684.png"
    caption="ESXi-Create4"
    width="600px"
    %}

## Instalación de Gentoo

### Continuamos vía SSHD

Ya estamos listos para continuar, deberíamos tener "red" (ifconfig) y así poder arrancar "SSHD", cambiar la contraseña de root y a partir de ahora serguir desde otro terminal (vía ssh). Es mucho más cómodo que usar la consola del cliente vSphere:

{% include showImagen.html
    src="/assets/img/original/ESXi-GentooInstall-1.png"
    caption="ESXi-GentooInstall-1"
    width="600px"
    %}

### Disco, stage3, portage

Desde un Terminal (vía ssh) configuro el disco duro, creo una partición única con /boot de 50M, partición 2 Swap de 512M y el resto del disco para la Partición 3 (root)

livecd ~ #
livecd ~ # fdisk -l

Disk /dev/sda: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 * 512 = 512 bytes
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
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x107d525e

Device    Boot     Start       End  Blocks  Id System
/dev/sda1 *         2048    104447   51200  83 Linux
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

{% include showImagen.html
    src="/assets/img/original/mirrors2.xml), apunta la URL de tu mirror preferido (busca por Spain"
    caption="Mirrors"
    width="600px"
    %}

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
# tar xvjpf stage3-*.tar.bz2
:
# cd /mnt/gentoo/usr
# tar xvjpf ../portage-*.tar.bz2 
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
EMERGE_DEFAULT_OPTS="--nospinner --keep-going --jobs=5 --load-average=5"

# CHOST
CHOST="x86_64-pc-linux-gnu"

# USE Flags
USE="-bindist aes avx fma3 mmx mmxext popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3 -gnome -kde"

# Nuevo CPU Flags
#  $ emerge -1v app-portage/cpuinfo2cpuflags
#  $ cpuinfo2cpuflags-x86
#
CPU_FLAGS_X86="aes avx fma3 mmx mmxext popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3"

# Ubicaciones de portage
PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"

# Lenguaje
LINGUAS="es en"

# Mirrors
GENTOO_MIRRORS="http://gentoo-euetib.upc.es/mirror/gentoo/"

# Teclado y graficos
INPUT_DEVICES="keyboard mouse vmmouse evdev"
VIDEO_CARDS="fbdev nv vesa vmware intel"

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

# emerge -v v86d
# eselect python set --python3 python3.3
 

**Instalo DHCP Cliente**

Para el futuro arranque tras el primer boot, mejor instalar ahora el paquete cliente de DHCP

# emerge -v dhcpcd

**Descargo y compilo el último Kernel**

Primero nos bajamos los fuentes del Kernel con el comando siguiente:

(chroot) livecd / # emerge -v gentoo-sources

Los fuentes quedan instalados en /usr/src/linux (realmente es un link simbólico), a continuación tendrías que parametrizarlo con "make menuconfig" y luego compilarlo.

{% include showImagen.html
    src="/assets/img/original/2015-03-19-config-3.18.7-Gentoo_VM_ESXi.txt"
    caption="2015-03-19-config-3.18.7-Gentoo_VM_ESXi.txt"
    width="600px"
    %}

 cd /usr/src/linux

 wget https://raw.githubusercontent.com/LuisPalacios/Linux-Kernel-configs/master/configs/2015-03-19-config-3.18.7-Gentoo_VM_ESXi.txt -O .config 

 make && make modules_install
 cp arch/x86_64/boot/bzImage /boot/kernel-3.18.7-gentoo
 cp System.map /boot/System.map-3.18.7-gentoo

 

## Instalación de "systemd"

**Selecciono el Perfil systemd**

Voy a configurar esta VM con systemd, así que selecciono el perfil adecuado:

(chroot) livecd / # eselect profile list
:
[5] default/linux/amd64/13.0/desktop/gnome/systemd
:
(chroot) livecd / # eselect profile set 5
 

**Adapto Portage**

Antes de actualizar el sistema (tras el cambio de profile) hay que preparar los diferentes ficheros de Portage:

# iproute
dev-haskell/appa ~amd64
dev-haskell/iproute ~amd64
dev-haskell/byteorder ~amd64

net-misc/iputils -caps -filecaps

**Recompilo con el nuevo Profile systemd**

Una vez que se selecciona un Profile distinto lo que ocurre es que cambias los valores USE de por defecto del sistema y esto significa que tenemos que "recompilarlo" por completo, así que lo siguiente que vamos a hacer es un emerge que actualice "world" :

# emerge -avDN @world

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**NOTA**: El proceso re-compila más de 150 paquetes y es normal que tarde varias horas (2 en mi caso), por eso asigné 4 virtual cpu's a esta VM, para acortar este tiempo al máximo.

[/dropshadowbox]   **Hostname** Con systemd se deja de usar /etc/conf.d/hostname, así que voy a editar a mano directamente los dos ficheros que emplea systemd:

gentoo

PRETTY_NAME="VM Gentoo Linux"
ICON_NAME="gentoo"

**Contraseña de root**

Antes de hacer boot, es fundamental cambiar la contraseña de root

(chroot) livecd init.d # passwd
New password:
Retype new password:
passwd: password updated successfully
 

**Herramientas indispensables al trabajar con Gentoo**

# emerge -v eix genlop
# eix-update 

**Preparo el mtab**

Es necesario realizar un link simbólico especial:

# rm /etc/mtab
# ln -sf /proc/self/mounts /etc/mtab

**Grub 2**

Necesitamos un "boot loader" y nada mejor que Grub2.

# emerge -v grub:2

Instalamos el boot loader en el disco

# grub2-install /dev/sda

Modifico el fichero de configuración de Grub /etc/default/grub, la siguientes son las líneas importantes:

GRUB_CMDLINE_LINUX="init=/usr/lib/systemd/systemd quiet rootfstype=ext4" GRUB_TERMINAL=console GRUB_DISABLE_LINUX_UUID=true

Ah!, en el futuro, cuando te sientas confortable, cambia el timeout del menu que muestra Grub a "0", de modo que ganarás 5 segundos en cada rearranque de tu servidor Gentoo desde vSphere Client :-)

GRUB_TIMEOUT=0

Cada vez que se modifica el fichero /etc/default/grub hay que ejecutar el programa grub2-mkconfig -o /boot/grub/grub.cfg porque es él el que crea la versión correcta del fichero de configuración de Grub: /boot/grub/grub.cfg.

# mount /boot (por si acaso se te había olvidado :-))
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
make && make modules_install

#!/bin/bash
#
# Script de apoyo para instalar el último kernel. Se apoya en el enlace simbólico
# By LuisPa, 2015

# Compruebo si existe /usr/src/linux
if [ ! -L "/usr/src/linux" ]; then
    echo "ERROR, no encuentro el link simbólico /usr/src/linux"
    exit
fi

# Obtengo el numero de la versión a la que está enalazado
cd /usr/src
ls -al linux | sed '/.*-\(.*\)-gentoo.*/{s/.*-\(.*\)-gentoo.*/\1/;q}; /.*-\(.*\)-gentoo.*/!{q100}' > /dev/null
if [ "$?" = "0" ]; then
    export version=\`ls -al linux | sed 's/.*-\(.*\)-gentoo.*/\1/'\`
else
    echo "ERROR, /usr/src/linux no está enlazado a un directorio del tipo xxxx-X.Y.Z-xxxxx"
fi

# Monto boot y si todo fue bien instalo el kernel
mount /boot > /dev/null 2>&1
if grep -qs '/boot' /proc/mounts; then
    cd /usr/src/linux
    cp arch/x86_64/boot/bzImage /boot/kernel-${version}-gentoo
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

 localectl set-locale LANG=es_ES.UTF-8 

El ultimo simplemente para comprobar

# localectl
System Locale: LANG=es_ES.UTF-8
VC Keymap: es
X11 Layout: es

**Preparo el fichero locale.gen**

en_US ISO-8859-1
en_US.UTF-8 UTF-8
es_ES ISO-8859-1
es_ES@euro ISO-8859-15
es_ES.UTF-8 UTF-8
en_US.UTF-8@euro UTF-8
es_ES.UTF-8@euro UTF-8

Compilo los "locales"

# locale-gen
 

**La red**

Vamos a "contectar", instalo, habilito y arranco DHCP. Los servicios en "systemd" se programan para futuros arranques con "systemctl enable" y se pueden arrancar o parar con "systemctl start/stop".

# systemctl enable dhcpcd.service
# systemctl start dhcpcd.service
 

{% include showImagen.html
    src="/assets/img/original/?p=581) de cómo hacer una configuración de dirección IP fija (manual"
    caption="Aquí tienes un ejemplo"
    width="600px"
    %}

Si todo falla siempre puedes asignar una IP fija mientras solucionas el problema. Averigua cómo se llama el interfaz, un ejemplo:

# dmesg | grep -i e1000
[    3.563105] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    3.563111] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    3.917422] e1000 0000:02:00.0 eth0: (PCI:66MHz:32-bit) 00:0c:29:c2:79:ea
[    3.917429] e1000 0000:02:00.0 eth0: Intel(R) PRO/1000 Network Connection
[    4.038847] e1000 0000:02:00.0 enp2s0: renamed from eth0
[    5.288029] e1000: enp2s0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None

# ifconfig enp2s0 192.168.1.242 netmask 255.255.255.0
# ip route add default via 192.168.1.1

**Activo SSHD**

Otro indispensable, habilito y arranco el daemon de SSH para poder conectar con esta VM vía ssh. Si en el futuro quieres poder hacer forward de X11 recuerda poner X11Forwarding yes en el fichero /etc/ssh/sshd_config

# systemctl enable sshd.service
# systemctl start sshd.service

Nota: Si sshd no te funciona, prueba:
# systemctl disable sshd.service
# systemctl enable sshd.socket

**Vixie-cron**

Instalo, habilito y arranco el cron

# emerge -v vixie-cron
# systemctl enable vixie-cron.service
# systemctl start vixie-cron.service

**Fecha y hora**

{% include showImagen.html
    src="/assets/img/original/?p=881"
    caption="servicio NTP"
    width="600px"
    %}

# timedatectl set-local-rtc 0
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

# groupadd -g 1400 luis
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

Instalo las tools de VMWare, la versión open source, para ello editamos el fichero package.use y package.accept_keywords. Es muy importante que no olvides la opción "-modules" para que se pueda instalar sin problemas.

app-emulation/open-vm-tools -X -modules fuse

# Open Source VMWare tools
=app-emulation/open-vm-tools-2013.09.16.1328054-r3 ~amd64

___PRIMERO VEMOS QUE SE INSTALARÍA___

gentoo ~ # emerge -pv open-vm-tools
These are the packages that would be merged, in order:
Calculating dependencies  ... done!
[ebuild  N     ] virtual/linux-sources-1  USE="-firmware" 0 KiB
[ebuild  N     ] sys-apps/ethtool-3.12.1  183 KiB
[ebuild  N     ] dev-libs/libdnet-1.12  USE="ipv6 -python -static-libs {-test}" PYTHON_TARGETS="python2_7" 953 KiB
[ebuild  N     ] sys-fs/fuse-2.9.3  USE="-examples -static-libs" 559 KiB
[ebuild  N    ~] app-emulation/open-vm-tools-2013.09.16.1328054-r3  USE="modules pam pic -X -doc -icu -xinerama" 0 KiB

Total: 6 packages (6 new), Size of downloads: 5.399 KiB

___EJECUTAMOS LA INSTALACIÓN___

gentoo ~# emerge -v open-vm-tools

A continuación programamos que el servicio de VMWare tools arranque durante el boot y de paso lo activamos:

gentoo ~ # systemctl enable vmtoolsd.service
Created symlink from /etc/systemd/system/multi-user.target.wants/vmtoolsd.service to /usr/lib64/systemd/system/vmtoolsd.service.
gentoo ~ # systemctl start vmtoolsd.service

Ya deberías poder ven cómo el cliente vSphere detecta que las vmware tools se han activado en tu VM

{% include showImagen.html
    src="/assets/img/original/Gentoo-VMWare-Tools.png"
    caption="Gentoo-VMWare-Tools"
    width="600px"
    %}

## Aplicaciones extra y acabamos...

Antes de apagar y clonar, voy a personalizar esta máquina virtual con ciertas aplicaciones que a mi me gusta tener siempre por defecto, digamos que es un Linux "base" con preferencias personales:

emerge -v sudo gentoolkit emacs mono              \
          pciutils tcpdump traceroute telnetd     \
          mlocate xclock gparted bmon procmail    \
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

# Recursos en la NAS via NFS
nas.parchis.org:/Recordings  /mnt/Recordings  nfs auto,user,exec,rsize=8192,wsize=8192,hard,intr,timeo=5   0 0
nas.parchis.org:/Apps        /Apps            nfs auto,user,exec,rsize=8192,wsize=8192,hard,intr,timeo=5   0 0

continúo con Docker,

# Virtualizador Docker
=app-emulation/docker-1.5.0 ~amd64

# emerge -v app-emulation/docker
:
# systemctl enable docker.service
:
# usermod -aG docker luis
:

Ya hemos terminado, te recomiendo que apagues la VM y guardes una copia (a contiuación explico cómo se hace).

{% include showImagen.html
    src="/assets/img/original/barra_separadora.png"
    caption="barra_separadora"
    width="600px"
    %}

# Unos cuantos trucos

A continuación dejo algunos trucos que pueden servirte de ayuda.

 

### Clonar VM: mediante plantilla OVF/OVA

La primera opción es crear una plantilla en formato OVF (varios ficheros) o bien OVA (un único fichero)

- IMPORTANTE: Para la máquina virtual desde vSphere Client.
    
{% include showImagen.html
    src="/assets/img/original/esxi-cloneOVA1.png"
    caption="esxi-cloneOVA1"
    width="600px"
    %}
    
- A partir de ahora puedes usar dicha plantilla para crear VM's nuevas
    

{% include showImagen.html
    src="/assets/img/original/newVM.jpg"
    caption="newVM"
    width="600px"
    %}

 

### Clonar VM: copia manual

{% include showImagen.html
    src="/assets/img/original/search.do?language=en_US&cmd=displayKC&externalId=1027876)"
    caption="fuente"
    width="600px"
    %}

- IMPORTANTE: Para la máquina virtual desde vSphere Client.
    
- Clonamos el disco contectando con el ESXi vía SSH
    

___ CONECTAR VIA SSH CON EL ESXi ___
obelix:~ luis$ ssh -l root esxi.parchis.org
Password:
~ #

___ CREAR EL DIRECTORIO DE LA NUEVA VM ___
~ # mkdir /vmfs/volumes/Panoramix-NFS-Apps/Totobo
~ #

___ CLONAR EL DISCO (en mi caso es Thin)___
~ # mkdir /vmfs/volumes/Panoramix-NFS-Apps/Totobo
~ # vmkfstools -i /vmfs/volumes/Panoramix-NFS-Apps/Gentoo/Gentoo.vmdk /vmfs/volumes/Panoramix-NFS-Apps/Totobo/Totobo.v
mdk -d thin
Destination disk format: Thin
Cloning disk '/vmfs/volumes/Panoramix-NFS-Apps/Gentoo/Gentoo.vmdk'...
:

- Desde el vSphere Client crear una nueva máquina virtual tal como describo en este artículo pero esta vez al llegar a la parte del disco duro utiliza "Use an existing virtual disk"

{% include showImagen.html
    src="/assets/img/original/esxi-cloneVM2.png"
    caption="esxi-cloneVM2"
    width="600px"
    %}

**Boot desde el ISO de Instalación**

Una vez que terminas la instalación la VM siempre hará boot desde el disco duro, por lo tanto si necesitas hacer boot desde el ISO de instalación (por ejemplo para resolver algún problema), es tan sencillo como meterse en la BIOS de la maquina virtual y alterar el orden de arranque. Selecciono la VM, botón derecho: "edit virtual machine settings" -> "options" -> "settings" -> "Boot Options" y activo "Force BIOS Setup". En el próximo boot entramos en la BIOS y podremos cambiar el orden de arranque.

**Montar un disco VMDK desde Linux**

{% include showImagen.html
    src="/assets/img/original/vddk). A continuación muestro un ejemplo donde monto un VMDK desde un Linux (no usar Nombre-flat.vmdk, sino Nombre.vmdk"
    caption="vSphere Disk Development Kit"
    width="600px"
    %}

bolica ~ # vmware-mount /Apps/datastore/Totobo/Totobo.vmdk 3 /mnt/totobo

___ Para desmontarla ___
bolica ~ # vmware-mount -k /Apps/datastore/Totobo/Totobo.vmdk
:

**Recompilar el Kernel de Gentoo**

Si necesitas modificar alguno de los parámetros del fichero .config que dejé arriba tendrás que seguir los pasos siguietnes para cambiarlo y recompilar e instalar de nuevo el kernel:

___ MODIFICO EL KERNEL ___
 mount /boot (por si acaso se te había olvidado :-))
 cd /usr/src/linux
 make menuconfig
:

___ COMPILAMOS EL KERNEL ___
 make && make modules_install
:

___ COPIAMOS EL KERNEL A /boot ___
 cp arch/x86_64/boot/bzImage /boot/kernel-3.18.7-gentoo
 cp System.map /boot/System.map-3.18.7-gentoo
 cp .config /boot/config-3.18.7-gentoo

___ EJECUTAMOS GRUB ___
 grub2-mkconfig -o /boot/grub/grub.cfg
:

___ REARRANCAMOS ___
 reboot
:

**Systemd: Enlace simbólico - Boot en modo Consola**

En este apunte uso el modo consola, pero si lo has cambiado y quieres volver a boot en modo consola (en vez de gráfico) te dejo cómo hacerlo con Systemd

# ln -sf /usr/lib/systemd/system/multi-user.target /etc/systemd/system/default.target

**Systemd: Mensaje "WRITE SAME failed"**

Este tema me costó encontralo en el pasado y solo porque probe a activar X11 (que no es el caso de este apunte). Si ves dicho error durante el boot, justo antes de arrancar X11, la forma de resolverlo es:

# find /sys | grep max_write_same_blocks
/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/scsi_disk/2:0:0:0/max_write_same_block
Añado este dispositivo a un nuevo fichero de configuración, debe terminar en .conf y residir en /etc/tmpfiles.d/:

# cat > /etc/tmpfiles.d/write_same.conf <<EOD
# Type Path Mode UID GID Age Argument
w /sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/scsi_disk/2:0:0:0/max_write_same_blocks - - - - 0
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

{% include showImagen.html
    src="/assets/img/original/lists.xml"
    caption="suscrito a la lista"
    width="600px"
    %}

**Actualizar tu Gentoo**

{% include showImagen.html
    src="/assets/img/original/"
    caption="Foro de Gentoo"
    width="600px"
    %}

Estos son los pasos:

- Sincronizamos "portage": # emerge --sync
- Comprobamos qué se va a actualizar: # emerge -DuvNp system world
- Actualizamos: # emerge -DuvN system world
- Actualizamos EIX: # eix-update
- Actualizamos los ficheros en /etc: # etc-update

A continuación tienes un ejemplo donde compruebo qué tengo que actualizar, fíjate en cuantos paquetes y solo han pasado 10 días desde que hice la primera instalación.

{% include showImagen.html
    src="/assets/img/original/emergeUpdate-901x1024.png"
    caption="emergeUpdate"
    width="600px"
    %}

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**AVISO**: Cuidado con el comando etc-update, te recomiendo que entiendas bien qué es Portage y qué hace este comando en concreto.

[/dropshadowbox]   **Portage**

Portage es la herramienta que gestiona el software en Gentoo y lo hace a través del comando emerge

{% include showImagen.html
    src="/assets/img/original/handbook-x86.xml?part=2&chap=1"
    caption="Portage"
    width="600px"
    %}
- El manual de Portage: # man portage
{% include showImagen.html
    src="/assets/img/original/Portage"
    caption="cómo trabajar con Portage"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/Project:Portage"
    caption="Proyecto Portage"
    width="600px"
    %}

**Actualizar el Kernel**

Al actualizar Gentoo resulta que uno de los paquetes es el "Kernel", ¿qué hago?. Puedes hacer dos cosas, la primera es ignorarlo y seguir con tu Kernel actual y la segunda es actualizar también el Kernel. Mi consejo es que si tienes tu sistema estable y no necesitas nada del Kernel nuevo (un hardware nuevo o un update de seguridad), ni lo toques, deja el que tenías.

{% include showImagen.html
    src="/assets/img/original/kernel-upgrade.xml"
    caption="actualización del Kernel"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/emergeKernel.png"
    caption="emergeKernel"
    width="600px"
    %}

Si miro en el directorio /usr/src veo que ahora hay dos kernels, el que está activo (3.18.7) y el nuevo (3.18.9).

{% include showImagen.html
    src="/assets/img/original/nuevoKernel.png"
    caption="nuevoKernel"
    width="600px"
    %}

Para actualizarlo ejecuto lo siguiente:

gentoo ~ # cd /usr/src/

___ BORRO Y RECREO EL LINK SIMBÓLICO AL NUEVO KERNEL ___
gentoo src # rm linux      
gentoo src # ln -s linux-3.18.9-gentoo linux

___ COPIO EL FICHERO .config ANTERIOR ___
gentoo src # cd linux
gentoo linux # cp ../linux-3.18.7-gentoo/.config .  

___ IMPORTO EL .config ANTERIOR ___
gentoo linux # make oldconfig 
:
 (normalmente puedes ir pulsando Intro y aceptando todo lo que te ofrece por defecto)
:
 
___ COMPILO E INSTALO EL NUEVO KERNEL ___
gentoo linux # make && make modules_install
gentoo linux # mount /boot
gentoo linux # cp arch/x86_64/boot/bzImage /boot/kernel-3.18.9-gentoo
gentoo linux # cp System.map /boot/System.map-3.18.9-gentoo
gentoo linux # cp .config /boot/config-3.18.9-gentoo
gentoo linux # grub2-mkconfig -o /boot/grub/grub.cfg

___ REBOOT ___
gentoo linux # reboot

 

**Ahorrar espacio en disco**

Si vas a utilizar esta imagen como fuente para clonar, te recomiendo que limpies al menos el directorio donde se bajan los paquetes de software durante su instalación # rm -fr /usr/portage/distfiles/*

 

### Enlaces

{% include showImagen.html
    src="/assets/img/original/viewtopic-p-6949882.html"
    caption="Post sobre vmware-tools y open-vm-tools"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/viewtopic-t-961502.html"
    caption="Post sobre la optimización del kernel"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/HOWTO_Install_Gentoo_on_VMware_ESX_server"
    caption="Post muy antiguo (archivo) sobre Gentoo en ESX"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/Systemd"
    caption="Apunte sobre systemd en Gentoo"
    width="600px"
    %}
