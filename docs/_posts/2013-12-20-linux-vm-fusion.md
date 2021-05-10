---
title: "Linux en 'Fusion para Mac'"
date: "2013-12-20"
categories: virtualización
tags: fusion gentoo linux virtualizacion vmware
excerpt_separator: <!--more-->
---

En este artículo describo cómo instalar Gentoo Linux 3.10.17 (64 bits, con **systemd + Gnome 3**) en una máquina virtual (VM) ejecutándose en VMWare Fusion 6 para Mac OSX versión 10.9 (Mavericks). Esto mismo debería funcionar igual en un Host distinto, como Parallels o VMWare Workstation para Windows o Linux.

<br clear="left"/>
<!--more-->

Anticipo que el tiempo de boot con systemd me ha dejado boquiabierto. Desde que pulso "Play" hasta que hace boot a Consola (modo multi-user sin GUI) tarda 3,5 seg. En caso de ir a modo gráfico X11 hasta la ventana de login tarda 4,5 seg y si uso login automático en total 9 segundos. En hacer shutdown tarda 2 seg. Nota: el host es un iMac 27 late 2013 core i7 (Haswell).

El manual oficial para este tipo de instalación es el Gentoo Linux AMD64 Handbook, un manual perfecto con mucho detalle. Considera este artículo munición extra que te servirá como ejemplo. Además te recomiendo leer también este par de enlaces importantes relacionados con el nuevo systemd en Gentoo y Gnome 3.8 en Gentoo.

## Preparar la máquina virtual

Descarga el ISO install-amd64-minimal-<fecha del último>.iso desde los mirrors de gentoo. Para encontrarlo bucea hasta este directorio: `/mirror/gentoo/releases/amd64/autobuilds/current-iso`

Arranca VMWare Fusion, crea una nueva máquina virtual, indica que usarás el ISO como disco de arranque, asígnale por lo menos 1GB de memoria RAM, 20GB de espacio en disco y la red en modo NAT.

**Recuerda: Le doy mínimo 20GB al disco virtual, para no tener problemas con los "distfiles" de Gentoo.**

{% include showImagen.html
    src="/assets/img/original/fusiongentoo-1_3_o.jpg"
    caption="fusiongentoo-1_3_o"
    width="600px"
    %}

* Configuración del disco

Crea la Partición 1 /boot de 50M, partición 2 SWAP de 512M y partición 3 ROOT con el resto hasta 20GB

```console 
# fdisk /dev/sda
Device Boot Start End Blocks Id System
/dev/sda1 * 2048 104447 51200 83 Linux
/dev/sda2 104448 1153023 524288 82 Linux swap / Solaris
/dev/sda3 1153024 41943039 203395008 83 Linux
# mkfs.ext2 /dev/sda1
# mkfs.ext4 /dev/sda3
# mkswap /dev/sda2
# swapon /dev/sda2
# mount /dev/sda3 /mnt/gentoo
# mkdir /mnt/gentoo/boot
# mount /dev/sda1 /mnt/gentoo/boot
```

* Fecha
 
```console
# date 121508312013
```

**Seguir vía SSH** Puede que te interese seguir desde una sesión remota. En mi caso lo prefiero, abro un terminal (iTerm) en el Mac y conecto directamente contra la máquina virtual usando ssh, donde previamente he puesto una contraseña a root y arrancado el servicio. La razón: En VMWare Fusion todavía me captura el ratón y no tengo instaladas las tools así que prefiero la comodidad del entorno mac.
 
```console
# passwd
:
# /etc/init.d/sshd start
```

* Descargar y descomprimir Stage3 y Portage

Descargo en /mnt/gentoo desde uno de los mirrors de gentoo

* /mirror/gentoo/releases/amd64/autobuilds/current-iso --> stage3-amd64-<último>.tar.bz2
* /mirror/gentoo/snapshots --> portage-latest.tar.bz2

```console
# cd /mnt/gentoo/
# tar xvjpf stage3-*.tar.bz2
# cd /mnt/gentoo/usr
# tar xvjpf ../portage-*.tar.bz2
```

* Entrar en el nuevo entorno

A partir de ahora entro ya directamente en el nuevo entorno con chroot, por lo tanto "/" (root) apuntará al nuevo disco que acabamos de formatear y donde hemos descomprimido todo el software. Importante copiar el resolv.conf :-)
 
```console
# cp /etc/resolv.conf /mnt/gentoo/etc
```

Entramos en el entorno...

```console
# mount -t proc none /mnt/gentoo/proc
# mount --rbind /sys /mnt/gentoo/sys
# mount --rbind /dev /mnt/gentoo/dev
# chroot /mnt/gentoo /bin/bash
# source /etc/profile
# export PS1="(chroot) $PS1"
```

Fichero make.conf:

```console
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
CFLAGS="-O2 -march=native -pipe"
CXXFLAGS="${CFLAGS}"

# WARNING: Changing your CHOST is not something that should be done lightly.
# Please consult http://www.gentoo.org/doc/en/change-chost.xml before changing.
CHOST="x86_64-pc-linux-gnu"

# These are the USE flags that were used in addition to what is provided by the
# profile used for building.
USE="opengl alsa pulseaudio gtk gnome qt4 -gpm"
PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"

# By LuisPa. -l'n' n=+1 CPUs
MAKEOPTS="-j5 -l5"
EMERGE_DEFAULT_OPTS="--nospinner --keep-going --jobs=5 --load-average=5"

# USE
USE="opengl alsa pulseaudio gtk gnome qt4 -gpm"

# Lenguaje
LINGUAS="es en"

# Mirrors
GENTOO_MIRRORS="http://gentoo-euetib.upc.es/mirror/gentoo/"

# Teclado y graficos
INPUT_DEVICES="keyboard mouse vmmouse evdev"
VIDEO_CARDS="fbdev nv vesa vmware intel"
Leer las news

(chroot) livecd usr # eselect news list
(chroot) livecd usr # eselect news read ’n’
Zona horaria

(chroot) livecd usr # cd /
(chroot) livecd / # cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime
(chroot) livecd / # echo "Europe/Madrid" > /etc/timezone
Preparo el /etc/fstab

/dev/sda1 /boot ext2 noauto,noatime 1 2
/dev/sda2 none swap sw 0 0
/dev/sda3 / ext4 noatime 0 1
```

* Elegir el Perfil adecuado

Este paso es importante. En mi instalación voy a dejar el sistema configurado con el nuevo systemd, por lo tanto tenemos que elegir el perfil adecuado. Ahora es el momento.

```console 
(chroot) livecd / # eselect profile list
:
[5] default/linux/amd64/13.0/desktop/gnome/systemd
:
(chroot) livecd / # eselect profile set 5
```

* Portage - accept_keywords

```config
# Open Source VMWare tools
app-emulation/open-vm-tools-kmod ~amd64
app-emulation/open-vm-tools ~amd64

# Systemd
sys-apps/systemd-ui ~amd64

# iproute
dev-haskell/appa ~amd64
dev-haskell/iproute ~amd64
dev-haskell/byteorder ~amd64
```

* Preparo el fichero /etc/portage/package.use

```console
# Para splashutils
media-gfx/splashutils fbcondecor -gpm -mng png truetype -hardened
media-libs/lcms static-libs
media-libs/libjpeg-turbo static-libs
app-arch/bzip2 static-libs
media-libs/libpng static-libs
virtual/jpeg static-libs
media-libs/libmng static-libs
media-libs/freetype static-libs
sys-libs/zlib static-libs

# X11
media-libs/mesa xa
dev-libs/libxml2 python
x11-libs/libdrm libkms

# VMWare
app-emulation/open-vm-tools X fuse
x11-libs/cairo X
x11-libs/gtk+ X

# Gnome
gnome-base/gdm -gnome-shell
net-fs/cifs-utils -acl
net-fs/samba -client
gnome-extra/evolution-data-server vala

# Firefox
media-plugins/gst-plugins-meta ffmpeg
```

* Hostname, passwd y herramientas

**Hostname** Este sistema utilizará systemd, por lo tanto configuro locale, keymaps, fecha, etc. más adelante. Ahora solo preparo hostname.

Con systemd se deja de usar `/etc/conf.d/hostname`, así que voy a editar a mano directamente los dos ficheros que emplea:

```config
menhir

PRETTY_NAME="VM Gentoo Linux Menhir"
ICON_NAME="menhir"
```

**Contraseña de root**, fúndamental antes del siguiente boot !!!

```console 
(chroot) livecd init.d # passwd
New password:
Retype new password:
passwd: password updated successfully
```

**Herramientas indispensables de Gentoo**

```console 
# emerge -v eix genlop
# eix-update
```

**Entorno gráfico**

Aquí tienes que decidir qué prefieres, dado que es posible configurar esta máquina virtual de dos formas distintas.

- Modo UVESA Frame Buffer
- Modo VMWGFX Frame Buffer (mi preferida)

El primero, en modo UVESA, configuras en el kernel CONFIG_FB_UVESA. En este modo te va a funcionar el menú gráfico de Grub antes del boot, la splash screen durante el boot e incluso la aceleración 3D en X11. Ahora bien, lo malo es que no vas a poder conmutar a las consolas virtuales con Ctr-Alt-Fx, de hecho se cuelga la sesión X11.

Si quieres usar UVESA, aquí tienes el fichero .config para el modo de trabajo UVESA. El segundo, en modo VMWGFX usas el driver frame buffer recomendado para Guest's VMWare (CONFIG_DRM_VMWGFX_FBCON), soporta la aceleración 3D, se integra perfectamente con X11 y es posible conmutar a las consolas virtuales. La única desventaja es que no usa splash durante el boot, de hecho tampoco usa el menú gráfico de Grub antes del boot.

Si esta es tu elección, aquí tienes el fichero .config para el modo de trabajo VMWGFX (es mi opción preferida). Porqué prefiero VMWGFX?. Porque prefiero usar un modo de arranque Silencioso y totalmente automatizado, estamos hablando de una máquinas virtual donde busco un arranque super rápido, por lo tanto no voy a ver los "splash" de todas formas (quizá durante una décima de segundo), así que mejor tener bien integrado X11 con las consolas. Instalación del Kernel

**Descarga del kernel**

```console 
# emerge -v gentoo-sources
[ebuild N ] sys-devel/bc-1.06.95 USE="readline -libedit -static"
[ebuild N ] sys-kernel/gentoo-sources-3.10.17:3.10.17 USE="-build -deblob -experimental -symlink"
:
```

Descarga del fichero .config Descarga una copia del fichero .config que prefieras de los dos anteriores. En mi caso uso el .config para VMWGFX, ambas son versiones para el kernel gentoo-sources-3.10.17 optimizadas para systemd y VMWare. Copia/Pega dicho contenido en el fichero /usr/src/inux/.config **Instalación de v86d**
 
```console
# emerge -v v86d
# eselect python set --python3 python3.3
```

**Instalación de Splashutils (solo si usas UVESA)**

Los paquetes splash-themes-* se emplean para establecer el look durante el arranque y de las ventanas de consola. No los confundas con el tema de Grub que se usa antes del boot.
 
```console
# emerge -v splashutils
# emerge -v media-gfx/splash-themes-livecd media-gfx/splash-themes-gentoo
```

**Compilación e instalación**

```console
# cd /usr/src/linux
# make && make modules_install
# cp arch/x86_64/boot/bzImage /boot/kernel-3.10.17-gentoo
# cp System.map /boot/System.map-3.10.17-gentoo
 ```

**Grub 2**

Instalo Grub
 
```console
# emerge -v grub:2
# grub2-install /dev/sda
```

**Preparo Splash (solo si usas UVESA)**

La resolución 1680x1050 es la que yo he elegido, porque me encaja con mi monitor de 27". En tu caso adapta a la que más te convenga. Eso sí, ten en cuenta que en el siguiente reboot al cambiar a modo gráfico la ventana de VMWare se redimensiona a este tamaño.

```console 
# cd /etc/splash
# splash_geninitramfs -g /boot/initramfs-genkernel-3.10.17-gentoo -v -r 1680x1050 natural_gentoo
# splash_geninitramfs -a /boot/initramfs-genkernel-3.10.17-gentoo -v -r 1680x1050 emerge-world
:
```

Fichero /etc/default/grub

```bash
# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-boot/grub/files/grub.default-2,v 1.4 2013/09/21 18:10:55 floppym Exp $
#
# To populate all changes in this file you need to regenerate your
# grub configuration file afterwards:
# 'grub2-mkconfig -o /boot/grub/grub.cfg'
#
# See the grub info page for documentation on possible variables and
# their associated values.

GRUB_DISTRIBUTOR="Gentoo"

GRUB_DEFAULT=0
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_TIMEOUT=3 # Durante la inhalación uso 3, al terminar lo cambio a 0

# Arranque con systemd en modo verbose
# GRUB_CMDLINE_LINUX="init=/usr/lib/systemd/systemd rootfstype=ext4"
# Arranque con systemd en modo silencioso
GRUB_CMDLINE_LINUX="init=/usr/lib/systemd/systemd quiet rootfstype=ext4"

# Append parameters to the linux kernel command line for non-recovery entries
#GRUB_CMDLINE_LINUX_DEFAULT=""

# Nota: NO utilizo ninguno porque trabajo en modo VMWGFX Frame Buffer, sin splash
#
# Si queremos un boot verbose
#GRUB_CMDLINE_LINUX_DEFAULT="video=uvesafb:1680x1050-24,mtrr:3,ywrap splash=verbose,theme:natural_gentoo console=tty1"
#GRUB_CMDLINE_LINUX_DEFAULT="video=uvesafb:1680x1050-24,mtrr:3,ywrap splash=verbose,theme:emerge-world console=tty1"
# Si queremos un boot silencioso
#GRUB_CMDLINE_LINUX_DEFAULT="video=uvesafb:1680x1050-24,mtrr:3,ywrap splash=silent,fadein,theme:natural_gentoo console=tty1"
#GRUB_CMDLINE_LINUX_DEFAULT="video=uvesafb:1680x1050-24,mtrr:3,ywrap splash=silent,fadein,theme:emerge-world console=tty1"

# Uncomment to disable graphical terminal (grub-pc only)
#GRUB_TERMINAL=console

# The resolution used on graphical terminal.
# Note that you can use only modes which your graphic card supports via VBE.
# You can see them in real GRUB with the command \`vbeinfo'.
GRUB_GFXMODE=1680x1050
GRUB_GFXPAYLOAD_LINUX=1680x1050

# Path to theme spec txt file.
# The starfield is by default provided with use truetype.
# NOTE: when enabling custom theme, ensure you have required font/etc.
#GRUB_THEME=/boot/grub/themes/starfield/theme.txt

# Background image used on graphical terminal.
# Can be in various bitmap formats.
#GRUB_BACKGROUND="/boot/grub/mybackground.png"

# Uncomment if you don't want GRUB to pass "root=UUID=xxx" parameter to kernel
GRUB_DISABLE_LINUX_UUID=true

# Uncomment to disable generation of recovery mode menu entries
#GRUB_DISABLE_RECOVERY=true
```

**Instalar GRUB**
 
```console
# grub2-mkconfig -o /boot/grub/grub.cfg
```
Si en el futuro he de modificar el Kernel, estos son los pasos para su compilación/instalación:

```console
# cd /usr/src/linux
# make && make modules_install
# mount /boot
# cp arch/x86_64/boot/bzImage /boot/kernel-3.10.17-gentoo
# cp System.map /boot/System.map-3.10.17-gentoo
```

Las líneas de splash_geninitramfs solo en caso de usar UVESA:

```console
# splash_geninitramfs -g /boot/initramfs-genkernel-3.10.17-gentoo -v -r 1680x1050 natural_gentoo
# splash_geninitramfs -a /boot/initramfs-genkernel-3.10.17-gentoo -v -r 1680x1050 emerge-world

# grub2-mkconfig -o /boot/grub/grub.cfg
# umount /boot
```
 
**Instalación de systemd**

Ejecuto algunos retoques e instalaciones para evitar bloqueos o problemas posteriores...

 
```console
# rm /etc/mtab
# ln -sf /proc/self/mounts /etc/mtab
# USE="-systemd" emerge -v sys-apps/dbus
# emerge -v openrc
```

La "reinstalación" de openrc es importante (a una versión igual o superior a 0.12.4) para evitar conflicto con kmod

```console
# emerge -v systemd
``` 

**Reboot**

Salgo del chroot, desmonto y rearranco el equipo

```console 
# exit
# cd
# umount -l /mnt/gentoo/dev{/shm,/pts,}
# umount -l /mnt/gentoo{/boot,/proc,}
:
# reboot
``` 

**Configuración básica**

Continuamos con la configuración básica del sistema. Ya hemos boot con systemd por primera vez, pero estás con el teclado en inglés, no te funciona la red, etc. no tienes locales, etc. Ahora empezamos a arreglar estas cosas. Lo primero y fundamental, el teclado :-) Teclado y Locale

```console
# localectl set-keymap es # modifica /etc/vconsole.conf
# localectl set-x11-keymap es # modifica /etc/X11/xorg.conf.d/00-keyboard.conf
# localectl set-locale LANG=es_ES.UTF-8 # modifica /etc/locale.conf
# localectl
System Locale: LANG=es_ES.UTF-8
VC Keymap: es
X11 Layout: es
Locale-gen
```

Preparo el fichero locale.gen

```config
en_US ISO-8859-1
en_US.UTF-8 UTF-8
es_ES ISO-8859-1
es_ES@euro ISO-8859-15
es_ES.UTF-8 UTF-8
en_US.UTF-8@euro UTF-8
es_ES.UTF-8@euro UTF-8
Ejecuto "locale-gen"
```
 
```console
# locale-gen
```

**La red**

A "contectar"... Instalo, habilito y arranco DHCP. Los servicios en "systemd" se programan para futuros arranques con "systemctl enable" y se pueden arrancar o parar con "systemctl start/stop"

```console
# emerge -v dhcpcd
# systemctl enable dhcpcd.service
# systemctl start dhcpcd.service
```

Otro indispensable, habilito y arranco el daemon de SSH para poder conectar con esta VM vía ssh.

```console
# systemctl enable sshd.service
# systemctl start sshd.service
```

Nota: Si sshd no te funciona, prueba:

```console
# systemctl disable sshd.service
# systemctl enable sshd.socket
```

**Vixie-cron**

Instalo, habilito y arranco el cron

```console
# emerge -v vixie-cron
# systemctl enable vixie-cron.service
# systemctl start vixie-cron.service
```

**Fecha y hora**

Para configurar fecha/hora debe utilizarse "timedatectl"

```console
# timedatectl set-local-rtc 0
# timedatectl set-timezone Europe/Madrid
# timedatectl set-time 2012-10-30 18:17:16 <= Ponerlo primero en hora.
# timedatectl set-ntp true <= Activar NTP
``` 

**Open-VM y systemd-ui**

Instalo las tools de VMWare, su versión open source.

```console
# emerge -v open-vm-tools sys-apps/systemd-ui
```

Actualizo a lo último

Rearranco el equipo, y al volver lo primero es hacer un "perl-cleaner" y luego un update completo.

```console
# reboot
:
# perl-cleaner --reallyall
:
# emerge -DuvN system world
```

**Instalación Gnome**

Instalación

```console
# emerge -DuvN --keep-going world gnome-base/gnome
```

Nota: falló webkit-gtk (errores de falta de memoria ¿?). Esto afectó a otros programas que no se instalaron por la falta de la dependencia. Apagué la VM, le subí a 2GB su memoria, rearranco y ejecuto:

```console
# EMERGE_DEFAULT_OPTS="" emerge -v webkit-gtk
```

Terminó bien, repetí el comando anterior que terminó correctamente.

```console
# emerge -DuvN --keep-going world gnome-base/gnome
```

Este proceso instaló gnome-base/gnome-3.0.0-r1

Activo el modo gráfico por defecto

```console
# ln -sf /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target
```

Activación de Gnome

```console
# systemctl enable gdm.service
# systemctl start display-manager
```

Usuario y rearranque

Desde una shell añado un usuario normal y por último rearranco el equipo

```console
# groupadd -g 1400 luis
# useradd -u 1400 -g luis -m -G cron,audio,cdrom,games,cdrw,users,wheel,audio,vmware -d /home/luis -s /bin/bash luis
:
# reboot
```

### Notas

Cambiar entre modo Consola o X11

Cambia el enlace simbólico y arranca la máquina virtual

Modo Consola

```console
# ln -sf /usr/lib/systemd/system/multi-user.target /etc/systemd/system/default.target
# reboot
```

Modo X11

```console
# ln -sf /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target
# reboot
```

**Eliminar el mensaje "WRITE SAME failed"**

Si durante el boot y justo antes de arrancar X11 ves ese mensaje, la forma de quitarlo es la siguiente:

```console
# find /sys | grep max_write_same_blocks
/sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/scsi_disk/2:0:0:0/max_write_same_block
Añado este dispositivo a un nuevo fichero de configuración, debe terminar en .conf y residir en /etc/tmpfiles.d/:

# cat > /etc/tmpfiles.d/write_same.conf <<EOD
# Type Path Mode UID GID Age Argument
w /sys/devices/pci0000:00/0000:00:10.0/host2/target2:0:0/2:0:0:0/scsi_disk/2:0:0:0/max_write_same_blocks - - - - 0
EOD
```

### Ver el LOG

Uno de los cambios interesantes es que desaparece la forma tradicional de ver los ficheros de log. Dejo aquí algunos comandos útiles:

* Ver el log: `journalctl`  
* Ver el log de forma contínua: `journalctl -f`
* Ver el log del último boot: `journalctl -b`
* Log de boot, solo ERROR o superior: `journalctl -b -p err` 
* Log disco sda: `journalctl /dev/sda`
* Log entre fechas: `journalctl --since=2014-01-15 --until="2014-01-20 23:59:59`
* Desde ayer: `journalctl --since=yesterday` 
* Log de "ábaco": `journalctl /bin/abaco` 
* Log de "ábaco" y además "curl": `journalctl /bin/abaco /bin/curl`
* Log de Apache: `journalctl -u httpd --since=07:30 --until=08:30`
* SHHD de forma contínua: `journalctl -f /usr/sbin/sshd`

