---
title: "Gentoo Linux en Raspberry Pi2 (ARMv7)"
date: "2015-05-17"
categories: apuntes gentoo media-center raspberry-pi
tags: arm boot gentoo-2 linux rpi2 tvheadend
excerpt_separator: <!--more-->
---

En este apunte describo cómo instalar Gentoo Linux en una Raspberry Pi 2. Necesito poder "Compilar el programa Tvheadend para ARMv7 y copiarlo a un MOIPro" y se supone que es más rápido hacerlo desde una RPi2 que emular el chip ARM en un x86, así que he optado por usar Gentoo como un equipo de desarrollo para ARM. Independientemente del caso de uso, si sigues estos pasos tendrás un Gentoo Linux en una RPi2.

![RPi2Gentoo](/assets/img/original/RPi2Gentoo.png){: width="730px" padding:10px }

Los **requisitos** son los siguientes:

- Una Micro-SD (he usado una de 16GB clase 10)
- PC o VM con Gentoo LInux (con acceso a la Micro-SD)
- Una fuente de alimentación de 2A
- Una RPi2 + teclado USB

## Formatear la Micro-SD

Formatea la Micro-SD, usa el método que quieras, en mi caso uso un MacOSX y el programa ![SDFormatter.](/assets/img/original/) (opción Quick Format){: width="730px" padding:10px }

- Insertar la tarjeta que se montará como “NO NAME”.
- Averiguar device (resultó ser /dev/disk3): df -h
- Ejecutar SDFormatter

![Captura de pantalla 2015-05-17 a las 9.05.15](/assets/img/original/Captura-de-pantalla-2015-05-17-a-las-9.05.15.png){: width="730px" padding:10px }

- Desmontar el volumen: sudo diskutil unmount /dev/disk3s1

## Preparar los File Systems

Para preparar los File Systems de la Micro-SD usaré un **PC (o Máquina Virtual)** donde ya tenga instalado **Linux** y que además pueda acceder a la Micro-SD.

Para mi lo más sencillo ha sido usar una VM con Gentoo Linux (x86_64) corriendo en Parallels para MacOX. Tras arrancarla, conecto la Micro-SD a la máquina virtual, que la reconoce como /dev/sdb.

[![MicroSD_Parallels1](https://www.luispa.com/wp-content/uploads/2015/05/MicroSD_Parallels1.png)](https://www.luispa.com/wp-content/uploads/2015/05/MicroSD_Parallels1.png) ![MicroSD_Parallels2](/assets/img/original/MicroSD_Parallels2-1024x836.png){: width="730px" padding:10px }

Desde esta máquina virtual y usando fdisk creo tres particiones en la Micro-SD:

- Partición 1: Tipo "c" (W95 FAT32 (LBA)), 50MB. Será la partición desde la cual haremos boot.
- Partición 2: Tipo "82" (Linux SWAP), 256MB. Partición para el área de SWAP
- Partición 3: Tipo "83" (Linux), resto del espacio del disco para root

 

obelix:~ luis$ ssh -l root menhir.parchis.org
:
menhir ~ # fdisk -l
Device     Boot  Start      End  Sectors  Size Id Type
/dev/sdb1  *      2048   100351    98304   48M  c W95 FAT32 (LBA)
/dev/sdb2       100352   600063   499712  244M 82 Linux swap / Solaris
/dev/sdb3       600064 31116287 30516224 14,6G 83 Linux

- Creo los filesystems y los monto

 
menhir ~ # mkfs.vfat -F 16 /dev/sdb1
menhir ~ # mkfs.ext4 /dev/sdb3
menhir ~ # mkswap /dev/sdb2

menhir ~ # mkdir /mnt/sd_boot
menhir ~ # mkdir /mnt/sd_root

menhir ~ # mount /dev/sdb1 /mnt/sd_boot/
menhir ~ # mount /dev/sdb3 /mnt/sd_root/

## Preparar la partición "/boot"

Como has visto antes, la partición de boot es de tipo VFAT (el formato nativo de MSDOS y Windows), y se utiliza para hacer boot del Linux que vamos a instalar en la Raspberry. Lo que haremos es aprovechar un proyecto que tienen los de Raspberry disponible en GitHub para facilitar todo este proceso de boot.

![Fuente Github](/assets/img/original/boot)). Podrías hacer un clone completo del proyecto (ojo! es enorme) o mejor... usa svn para bajarte solo el directorio "boot" (GIT no permite bajarse directorios de un proyecto, pero tenemos la suerte de que GitHub soporta subversion){: width="730px" padding:10px }.

 

menhir ~ # mkdir rpi2
menhir ~ # cd rpi2/

___OPCIÓN 1___
menhir rpi2 # git clone https://github.com/raspberrypi/firmware.git

___OPCIÓN 2___  <== RECOMENDADA
menhir rpi2 # svn export https://github.com/raspberrypi/firmware/trunk/boot

- Copio el contenido del directorio boot al filesystem de arranque /mnt/sd_boot/:

 

___OPCIÓN 1___
menhir rpi2 # cp -r firmware/boot/* /mnt/sd_boot

___OPCIÓN 2___
menhir rpi2 # cp -r boot/* /mnt/sd_boot

- Creo un fichero /mnt/sd_boot/cmdline.txt

root=/dev/mmcblk0p3 rw rootwait console=ttyAMA0,115200 console=tty1 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=ttyAMA0,115200 elevator=noop

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**AVISO**: A continuación vamos a compilar nuestro propio Kernel y sobreescribiremos el que acabamos de copiar.

[/dropshadowbox]

## Compilar el Kernel ARM

El siguiente paso es crear mi propio Kernel compilando para ARM para la RPi2. Lo voy a hacer desde mi Máquina Virtual con Linux x86_64, a esto se le llama "cross-compilar" y por lo tanto voy a instalar el paquete crossdev !!!.

- Instalo **GIT** y **CROSSDEV**:

 
menhir ~ # emerge -pv dev-vcs/git crossdev

- Creo un "output overlay" local (más información ![aquí](/assets/img/original/Local_overlay)){: width="730px" padding:10px }

Los Overlays contienen ebuilds adicionales que no son parte del árbol principal de portage. El overlay que necesito crear es local a este Gentoo donde voy a hacer el "crossdev"

 
menhir ~ #
menhir ~ # mkdir -p /usr/local/portage/{metadata,profiles}
menhir ~ # echo 'OverLayLuisPa' > /usr/local/portage/profiles/repo_luis
menhir ~ # echo 'masters = gentoo' > /usr/local/portage/metadata/layout.conf
menhir ~ # chown -R portage:portage /usr/local/portage
menhir ~ #
menhir ~ # mkdir -p /etc/portage/repos.conf
menhir ~ # cat > /etc/portage/repos.conf/local.conf
[OverlayLuisPa]
location = /usr/local/portage
masters = gentoo
auto-sync = no
^D

- Creo el "toolchain" para poder compilar y generar código para ARM.

 
menhir ~ #
menhir ~ # crossdev -S -v -t armv7a-hardfloat-linux-gnueabi
------------------------------------------------------------------
 * crossdev version:      20140917
 * Host Portage ARCH:     amd64
 * Target Portage ARCH:   arm
 * Target System:         armv7a-hardfloat-linux-gnueabi
 * Stage:                 4 (C/C++ compiler)
 * ABIs:                  default

 * binutils:              binutils-[stable]
 * gcc:                   gcc-[stable]
 * headers:               linux-headers-[stable]
 * libc:                  glibc-[stable]

 * CROSSDEV_OVERLAY:      /usr/local/portage
 * PORT_LOGDIR:           /var/log/portage
 * PORTAGE_CONFIGROOT:
:

A continuación necesito **conseguir el fichero .config del Kernel**. Este paso es importante, hacerlo manualmente puede llevarte a error. Lo mejor es aprovechar el trabajo que ya han hecho los de Raspberry o descargarte una copia de mi fichero .config.

- Opción 1: Descarga esta versión del fichero .config.
    
- Opción 2: Aprovechar el trabajo que ha hecho el equipo de Raspberry. Accedo a un RASPBIAN instalado en una RPi2, por ejemplo ![Raspbian 2015-05-05](/assets/img/original/){: width="730px" padding:10px }, extraigo el Kernel y lo copio al Linux que voy a usar para compilar el Kernel.
    

 

___ EN UNA RPi2 CON RASPBIAN ___
:
pi@raspberrypi ~ $ sudo su -
root@raspberrypi:~# dd if=/proc/config.gz of=originalRPi2Config.gz
root@raspberrypi:~# mv originalRPi2Config.gz /home/pi/
root@raspberrypi:~# exit

___ EN EL LINUX x86 DONDE VOY A COMPILAR EL KERNEL ___
menhir rpi2 # scp pi@192.168.1.53:originalRPi2Config.gz .
:
menhir ~ # cd rpi2/
menhir rpi2 # gunzip originalRPi2Config.gz
menhir rpi2 # 

- Descargo los fuentes de Linux

 
menhir ~ # cd rpi2
menhir rpi2 # git clone --depth 1 git://github.com/raspberrypi/linux.git
:
menhir rpi2 # cp originalRPi2Config linux/.config

- Prepara el kernel (make oldconfig)

 

menhir rpi2 # git clone --depth 1 git://github.com/raspberrypi/linux.git
menhir rpi2 # cd linux
menhir linux # ARCH=arm CROSS_COMPILE=/usr/bin/armv7a-hardfloat-linux-gnueabi- make oldconfig

- Opcionalmente puedes modificarlo (make menuconfig)

 
menhir linux # ARCH=arm CROSS_COMPILE=/usr/bin/armv7a-hardfloat-linux-gnueabi- make menuconfig

- Compila el kernel (make)

 
menhir linux # ARCH=arm CROSS_COMPILE=/usr/bin/armv7a-hardfloat-linux-gnueabi- make -j9
(NOTA: -j'n', siendo 'n' el número de CPU's+1)

- Copio la imagen del kernel (linux/arch/arm/boot/Image) a la Micro-SD (/mnt/sd_boot/kernel7.img).

 
menhir linux # mv /mnt/sd_boot/kernel7.img /mnt/sd_boot/kernel7.img.old
menhir linux # cp arch/arm/boot/Image /mnt/sd_boot/kernel7.img

## Instalar Stage3

- Descargo el último Stage3 (consultar ![aquí](/assets/img/original/) cual es el último){: width="730px" padding:10px }

 
menhir ~ # wget http://distfiles.gentoo.org/releases/arm/autobuilds/current-stage3-armv7a_hardfp/stage3-armv7a_hardfp-20150508.tar.bz2
menhir ~ # tar xpjf stage3-armv7a_hardfp-20150508.tar.bz2 -C /mnt/sd_root/

- Copio los fuentes de linux

menhir rpi2 # cp -R /root/rpi2/linux /mnt/sd_root/usr/src/linux

- Edito la línea CFLAGS en el fichero make.conf

CFLAGS="-O2 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard"

- Edito el fstab

/dev/mmcblk0p1          /boot           vfat            defaults        0 2
/dev/mmcblk0p2          none            swap            sw              0 0
/dev/mmcblk0p3          /               ext4            defaults        0 1

- Cambio la contraseña a root. Hay que crear la contraseña y modificar el fichero /mnt/sd_root/etc/shadow.

 
menhir etc # openssl passwd -1
Password:
Verifying - Password:
$1$9M1234sS$W/9C51234gxyxO2xE8Fnl0
menhir etc # nano /mnt/sd_root/etc/shadow
__CAMBIAR EL '*' después de root por el HASH que te haya salido

- En el fichero /mnt/sd_root/etc/initttab comentar la línea s0:12345:respawn:/sbin/agetty -L 9600 ttyS0 vt100.

## Instalar Portage

- Descargar y desempaquetar la última versión de portage

 
menhir ~ # wget http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2
menhir ~ # tar xpjf portage-latest.tar.bz2 -C /mnt/sd_root/usr

## Boot

- Desmontar los filesystems

 
menhir ~ # sync
menhir ~ # umount /mnt/sd_boot
menhir ~ # umount /mnt/sd_root

Haz **Boot** con tu nueva Pi2 con Gentoo Linux. Insertar la Micro-SD en la Pi y encenderla. Ya está, deberías tener una RPi2 con Gentoo Linux lista para hacer boot...

## Migrar a systemd y parametrizar

Una vez que el equipo rearranca tenemos que completar la instalación. Recomiendo migrar a systemd para acelerar el boot. Además hay que parametrizar muchas cosas todavía.

![Systemd-204-Released-with-Two-Fixes](/assets/img/original/Systemd-204-Released-with-Two-Fixes.jpg){: width="730px" padding:10px }

- Pon en hora el equipo (MUY IMPORTANTE)

 
localhost ~ # date MMDDHHMMYYYY

- Sobreescribe /etc/portage/profile para añadir systemd

 
menhir ~ # mkdir /etc/portage/profile
menhir ~ # cp /usr/portage/profile/targets/systemd/* /etc/portage/profile
menhir ~ # rm /etc/portage/profile/eapi
menhir ~ # emerge -avDN @world

**Hostname** Con systemd se deja de usar /etc/conf.d/hostname, así que voy a editar a mano directamente los dos ficheros que emplea systemd:

gentoopi

PRETTY_NAME="Gentoo Pi"
ICON_NAME="gentoo"

- Ajustes recomendados al trabajar con Gentoo

localhost ~ # emerge -v eix genlop
localhost ~ # eix-update 

- Preparo el mtab, realizar un link simbólico especial

localhost ~ # rm /etc/mtab
localhost ~ # ln -sf /proc/self/mounts /etc/mtab

- Activo **systemd**. Añado init=/usr/lib/systemd/systemd al fichero /boot/cmdline.txt para que en el próximo boot utilice systemd.

root=/dev/mmcblk0p3 rw rootwait console=ttyAMA0,115200 console=tty1 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=ttyAMA0,115200 elevator=noop

- Reboot

 
localhost ~ # reboot

## Teclado y Locale

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
 

![Aquí tienes un ejemplo](/assets/img/original/?p=581) de cómo hacer una configuración de dirección IP fija (manual){: width="730px" padding:10px }.

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

Para configurar fecha/hora debe utilizarse "timedatectl". No te pierdas este apunte sobre cómo montar además el ![servicio NTP](/assets/img/original/?p=881){: width="730px" padding:10px }.

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

## Compilar Tvheadend 4.1 para MOI Pro

Ya lo comentaba al principio de este apunte, he construido un Linux (Gentoo) en una Raspberry Pi2 para tener una plataforma de desarrollo para ARM y conseguir ejecutables para esta plataforma. El caso de uso principal es poder compilar mi propia versión de Tvheadend para ![mi MOI Pro](/assets/img/original/?p=2647){: width="730px" padding:10px }. En mayo de 2015 la versión disponible en GitHub fue **HTS Tvheadend 4.1-49**.

![Captura de pantalla 2015-05-24 a las 13.54.29](/assets/img/original/Captura-de-pantalla-2015-05-24-a-las-13.54.29.png){: width="730px" padding:10px }

### Compilación

- Preparar un directorio de trabajo en la "Gentoo Pi2"

Con un usuario normal (no hace falta ser root), descargo los fuentes de GitHub.

luis@gentoopi ~ $ mkdir -p $HOME/src/tvheadend
luis@gentoopi ~ $ cd src/tvheadend
luis@gentoopi ~/src/tvheadend $ git clone https://github.com/tvheadend/tvheadend.git /home/luis/src/tvheadend

- Actualizar Tvheadend a la última versión

Cambia a la versión master:

luis@gentoopi ~/src/tvheadend $ git checkout master 

Solo si se trata de una re-compilación, porque ha pasado tiempo, quieres sincronizar a la última versión y recompilar:

luis@gentoopi ~/src/tvheadend $ git pull 
luis@gentoopi ~/src/tvheadend $ make clean
luis@gentoopi ~/src/tvheadend $ rm -fr build.linux 

- Configurar antes de compilar

La configuración se realiza con el siguiente comando:

luis@gentoopi ~/src/tvheadend $ ./configure --disable-libav --disable-libffmpeg_static --disable-avahi --cpu=armv7a --release  --enable-kqueue --enable-bundle

- Compilación

luis@gentoopi ~/src/tvheadend $ make

### Instalación en MOI Pro

- Transferir el ejecutable

Transfiero el nuevo ejecutable al equipo MOI Pro, al directorio /usr/local/bin. Dado que he compilado con la opcion --enable-bundle, el ejecutable lleva embebidos todos los ficheros necesarios.

luis@gentoopi ~/src/tvheadend $ scp build.linux/tvheadend root@moipro.parchis.org:.
:
[root@MOIPro ~]# mv tvheadend /usr/local/bin/tvheadend
:

- Hacer un backup de la versión original

Aunque voy a instalar una versión en paralelo a la existente, sin borrarla ni modificarla, siempre hago una Backup del Tvheadend que viene de "fábrica".

[root@MOIPro ~]# systemctl stop tvheadend
:
[root@MOIPro ~]# systemctl disable tvheadend
:
[root@MOIPro ~]# cp /usr/bin/tvheadend /usr/bin/tvheadend.original
:
[root@MOIPro ~]# cd /media/mmcblk0p1/usr/share/
[root@MOIPro /media/mmcblk0p1/usr/share]# tar cvfz 2015-05-24-backup-share_tvheadend.tgz tvheadend/
:
[root@MOIPro ~]# cd /\(null\)/.hts/
[root@MOIPro /(null)/.hts]# tar cvfz 2015-05-24-tvheadend-backup.tgz tvheadend/
:

- Crear un nuevo fichero de servicio tv.service

Creo un nuevo fichero /etc/systemd/system/tv.service para poder activar el daemon desde /usr/local/bin y que no entre en conflicto con el existente (tvheadend.service).

[Unit]
Description=TV streaming server
After=syslog.target

[Service]
Type=forking
PIDFile=/run/tvheadend.pid
ExecStart=/usr/local/bin/tvheadend -f -p /run/tvheadend.pid -C -u root -g root
ExecStop=/usr/bin/rm /run/tvheadend.pid
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target

- Transfiero la configuración

Tenía ya una configuración del Tvheadend original en /\(null\)/.hts/tvheadend, así que la copio al directorio que utilizará el nuevo ejecutable /root/.hts/tvheadend.

[root@MOIPro ~]# cp -R /\(null\)/.hts/tvheadend /root/.hts/

- Deshabilito el antiguo y habilito el nuevo

Desabilito el tvheadend que viene con el MOI Pro y habilito el nuevo.

[root@MOIPro ~]# systemctl disable tvheadend
rm '/etc/systemd/system/tvheadend.target.wants/tvheadend.service'
[root@MOIPro ~]# systemctl enable tv
ln -s '/etc/systemd/system/tv.service' '/etc/systemd/system/multi-user.target.wants/tv.service'

- Arranco el nuevo Tvheadend

Arranco el nuevo Tvheadend, detectará una configuración con formato antiguo (v16) y la convertirá a la versión v17 y luego v18.

[root@MOIPro ~]# systemctl start tv

![tvheadend41](/assets/img/original/tvheadend41-1024x631.png){: width="730px" padding:10px }

- Ver el Logging

Puedes ver el log en otro terminal en paralelo con el comando journalctl -f.

:
2015-05-24 10:12:25.426 [   INFO] config: backup: migrating config from 0.0.0~unknown (running 4.1-49~ge7b5e7f)
2015-05-24 10:12:25.426 [   INFO] config: backup: running, output file /root/.hts/tvheadend/backup/0.0.0~unknown.tar.bz2
2015-05-24 10:12:25.427 [   INFO] config: migrating config from v16 to v17
2015-05-24 10:12:25.428 [   INFO] spawn: Executing "/bin/tar"
2015-05-24 10:12:25.430 [   INFO] config: migrating config from v17 to v18
:
