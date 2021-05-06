---
title: "VM Linux con iSCSI"
date: "2015-06-19"
categories: apuntes gentoo virtualizacion
tags: backup iscsi kvm linux
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/?p=3221"
    caption="Hypervisor KVM"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/linuxiscsi.png"
    caption="linuxiscsi"
    width="600px"
    %}

iSCSI, de Internet SCSI, permite usar el protocolo SCSI sobre redes TCP/IP para acceder al almacenamiento, se trata de una alternativa a las soluciones SAN basadas en Fibre Channel.

 

# NAS con soporte iSCSI

En este apunte vamos a ver cómo una NAS casera (QNAP) es capaz de entregar almacenamiento a través de iSCSI. Para situarnos, en terminología iSCSI un Target es un grupo de volúmenes (LUNs). Puedes optar por crear un único target con múltiples LUNs o varios targets donde cada uno solo tienen una única LUN. Esta última es la opción por la que he optado, para cada VM creo un "Target(grupo) con una única LUN". Las voy a crear desde el administrador web de QNAP.

Veamos un ejemplo donde creo un Target con su LUN asignándole 15GB de espacio libre a nivel de bloque (acceso en modo directo al disco, en vez de en modo fichero), que además se presentará al sistema operativo como si fuese un disco físico.

{% include showImagen.html
    src="/assets/img/original/disco-iscsi-1.png"
    caption="disco-iscsi-1"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/disco-iscsi-2.png"
    caption="disco-iscsi-2"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/disco-iscsi-3.png"
    caption="disco-iscsi-3"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/disco-iscsi-4.png"
    caption="disco-iscsi-4"
    width="600px"
    %}

Lo anterior era un ejemplo, veamos a continuación los tres Targets, cada uno con su LUN, que he creado para que puedan ser consumidos por las futuras VM's de KVM.

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-1-1024x619.png"
    caption="kvm-vm-gentoo-iscsi-1"
    width="600px"
    %}

Los nombres de los **Targets** son realmente impronunciables, pero es lo que hay... así que fíjate bien en cual es el nombre de tu Target porque lo usaremos a continuación. Para este ejemplo voy a usar el Target que llamé "TVMgentoo" y que el QNAP tradujo a: iqn.2004-04.com.qnap:ts-569pro:iscsi.tvmgentoo.d70ea1.

 

# iSCSI en virt-manager

Antes de iniciar la instalción de la VM, lo primero es configurar las fuentes iSCSI en el Host y para hacerlo la forma más sencilla es utilizar el programa virt-manager, nos conectaremos con el o los grupos (Targets) para que puedan ser consumidos por la VM más adelante.

{% include showImagen.html
    src="/assets/img/original/?p=3221"
    caption="apunte sobre KVM"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-2.png"
    caption="kvm-vm-gentoo-iscsi-2"
    width="600px"
    %}

Desde la lengüeta "Almacenamiento", pulsamos en el símbolo "+" para añadir un nuevo grupo (datastore) de tipo Target iSCSI (destino iSCSI).

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-3.png"
    caption="kvm-vm-gentoo-iscsi-3"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-4.png"
    caption="kvm-vm-gentoo-iscsi-4"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-5.png"
    caption="kvm-vm-gentoo-iscsi-5"
    width="600px"
    %}

Debes poner la dirección IP del NAS, en vez del nombre DNS, en el campo "Nombre del equipo".

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-6.png"
    caption="kvm-vm-gentoo-iscsi-6"
    width="600px"
    %}

Si todo ha ido bien, deberías ver lo siguiente:

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-7.png"
    caption="kvm-vm-gentoo-iscsi-7"
    width="600px"
    %}

Ya tengo un disco adicional disponible que usaré durante la instalación de la máquina virtual

 

### Comandos útiles iSCSI

Dejo aquí unos comandos útiles que te pueden venir bien cuando trabajas con discos iSCSI.

- Conectar disco iSCSI, desde línea de comandos o virt-manager

marte ~ # iscsiadm -m node -T iqn.2004-04.com.qnap:ts-569pro:iscsi.tvmgentoo.d70ea1 -p 192.168.1.2 --login
Logging in to [iface: default, target: iqn.2004-04.com.qnap:ts-569pro:iscsi.tvmgentoo.d70ea1, portal: 192.168.1.2,3260]
Login to [iface: default, target: iqn.2004-04.com.qnap:ts-569pro:iscsi.tvmgentoo.d70ea1, portal: 192.168.1.2,3260] successful.

{% include showImagen.html
    src="/assets/img/original/iSCSI-Start.png"
    caption="iSCSI-Start"
    width="600px"
    %}

marte ~ # iscsiadm -m node -T iqn.2004-04.com.qnap:ts-569pro:iscsi.tvmgentoo.d70ea1 -p 192.168.1.2 --logout
Logging out of session [sid: 1, target: iqn.2004-04.com.qnap:ts-569pro:iscsi.tvmgentoo.d70ea1, portal: 192.168.1.2,3260]
Logout of [sid: 1, target: iqn.2004-04.com.qnap:ts-569pro:iscsi.tvmgentoo.d70ea1, portal: 192.168.1.2,3260] successful.

{% include showImagen.html
    src="/assets/img/original/iSCSI-Stop.png"
    caption="iSCSI-Stop"
    width="600px"
    %}

 

# Instalar la máquina virtual

Ya estamos listos para crear la máquina virtual, así que nos vamos a virt-manager y la creamos utilizando el ISO de instalación del sistema operativo como disco de arranque. Como es "gentoo" voy a darle bastante memoria (8GB) y cpu (4 vCores) para que las compilaciones vayan rápido. Al terminar modificaré la VM para dejarla con 2GB y 1 vCore

{% include showImagen.html
    src="/assets/img/original/fastvm-1.png"
    caption="fastvm-1"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/fastvm-2.png"
    caption="fastvm-2"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/fastvm-3.png"
    caption="fastvm-3"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-8.png"
    caption="kvm-vm-gentoo-iscsi-8"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-9.png"
    caption="kvm-vm-gentoo-iscsi-9"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-10.png"
    caption="kvm-vm-gentoo-iscsi-10"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-11.png"
    caption="kvm-vm-gentoo-iscsi-11"
    width="600px"
    %}

Ahora podemos parametrizar la VM antes de arrancarla.

- Añado "input->Tableta Gráfica USB EvTouch" para que el ratón responda correctametne cuando manipulo más adelante la VM desde virt-manager.

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-12.png"
    caption="kvm-vm-gentoo-iscsi-12"
    width="600px"
    %}

- **MUY IMPORTANTE:** Cambiar los controladores de Disco y Red a VirtIO. Ambos ofrecen un rendimiento mejor y es mucho mejor cambiarlo ahora (sobre todo el de disco) que más adelante.

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-13.png"
    caption="kvm-vm-gentoo-iscsi-13"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/kvm-vm-gentoo-iscsi-13.1.png"
    caption="kvm-vm-gentoo-iscsi-13.1"
    width="600px"
    %}

Ya puedo aplicar los cambios y hacer clic en **Iniciar instalación**

{% include showImagen.html
    src="/assets/img/original/fastvm-6.png"
    caption="fastvm-6"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/fastvm-7-1024x878.png"
    caption="fastvm-7"
    width="600px"
    %}

Te recomiendo que dejes de trabajar en la consola y pases a un puesto de trabajo remoto vía SSH, asigno una contraseña a root y arranco el daemon:

 
livecd ~ # passwd
:
livecd ~ # /etc/init.d/sshd start 

 
obelix:~ luis$ ssh -l root 192.168.1.107

  **Crear las particiones del disco con Parted**

El disco que KVM presenta a la VM realmente está en la NAS (vía iSCSI), pero esto es transparente para la VM, que lo reconoce como un disco real físico y le asigna el nombre de dispositivo /dev/vda (recuerda que usamos el driver Virtio)

  
livecd ~ # fdisk -l

Disk /dev/vda: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

Empiezo a preparar las particiones. Notar que voy a usar UEFI y GPT (en vez de MBR):

  
livecd ~ # parted -a optimal /dev/vda
:
GNU Parted 3.2
Using /dev/vda
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
Model: Virtio Block Device (virtblk)
Disk /dev/vda: 10.7GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name    Flags
 1      1049kB  3146kB  2097kB               grub    bios_grub
 2      3146kB  137MB   134MB                boot
 3      137MB   674MB   537MB                swap
 4      674MB   10.7GB  10.1GB               rootfs

(parted) quit

A continuación creo los file systems

  

livecd ~ # fdisk -l

Disk /dev/vda: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: DFA5DB69-5DA5-4AAB-8C4F-0266592CFB48

Device           Start          End   Size Type
/dev/vda1         2048         6143     2M BIOS boot partition
/dev/vda2         6144       268287   128M Linux filesystem
/dev/vda3       268288      1316863   512M Linux filesystem
/dev/vda4      1316864     20969471   9.4G Linux filesystem

livecd ~ # mkfs.ext2 /dev/vda2
livecd ~ # mkfs.ext4 /dev/vda4
livecd ~ # mkswap /dev/vda3
livecd ~ # swapon /dev/vda3 

**Montamos los file systems**

  
livecd ~ # mount /dev/vda4 /mnt/gentoo
livecd ~ # mkdir /mnt/gentoo/boot
livecd ~ # mount /dev/vda2 /mnt/gentoo/boot 

**Ajustar la hora**

 
livecd ~ # date 060711572015   <== MMDDHHMMAAAA 

**Descarga de Stage 3**

{% include showImagen.html
    src="/assets/img/original/Main_Page"
    caption="Wiki de Gentoo"
    width="600px"
    %}

  
livecd ~ # cd /mnt/gentoo
livecd gentoo # links http://distfiles.gentoo.org

Descargo el último "stage3", el último "portage":

  
../releases/amd64/autobuilds/current-stage3-amd64/ --> stage3-amd64-<FECHA>.tar.bz2
../snapshots --> portage-latest.tar.bz2
:
livecd gentoo # tar xjpf stage3-*.tar.bz2
livecd gentoo # cd /mnt/gentoo/usr
livecd usr # tar xjpf ../portage-*.tar.bz2 

**chroot al nuevo entorno**

A partir de ahora "/" (root) apuntará al disco SSD que hemos formateado y donde hemos descomprimido Stage 3 y Portage. Antes de hacer el chroot debes copiar el /etc/resolv.conf para que la red siga funcionando (sobre todo la resolución de nombres :-))

  

___ NO OLVIDES COPIAR RESOLV.CONF ____

cp /etc/resolv.conf /mnt/gentoo/etc

___ COMANDOS PARA HACER EL CHROOT ____
 
mount -t proc none /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"

(chroot) livecd / #

Modificamos el fichero make.conf

#
# Opciones de compilacion, by LuisPa. -l'n' n=+1 CPUs
CFLAGS="-O2 -march=native -pipe"
CXXFLAGS="${CFLAGS}"
MAKEOPTS="-j5 -l10"
EMERGE_DEFAULT_OPTS="--nospinner --keep-going --jobs=5 --load-average=10"

# CHOST
CHOST="x86_64-pc-linux-gnu"

# USE Flags (NOTAR QUE QUITO udev, porque usaré "mdev"/busybox)
USE="aes avx fma3 mmx mmxext popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3 -gnome -kde -bindist"

# Nuevo CPU Flags
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

# PHP TARGETS
PHP_TARGETS="php5-6"

**Leemos todas las "News"**

(chroot) livecd ~ # eselect news list
(chroot) livecd ~ # eselect news read ’n’

**Establecemos la Zona horaria**

(chroot) livecd ~ # cd /
(chroot) livecd / # cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime
(chroot) livecd / # echo "Europe/Madrid" > /etc/timezone

**Preparo el /etc/fstab**

/dev/vda2 /boot ext2 noauto,noatime 1 2
/dev/vda3 none swap sw 0 0
/dev/vda4 / ext4 noatime 0 1

**Instalo herramientas útiles**

Instalo herramientas útiles a la hora de trabajar con Portage y con el sistema en general.

(chroot) livecd ~ # emerge -v eix genlop pciutils gentoolkit
(chroot) livecd ~ # eix-update

**Instalo v86d y Python**

(chroot) livecd / # emerge -v v86d
(chroot) livecd / # eselect python set --python3 python3.3 

**Instalo DHCP Cliente**

Para el futuro arranque tras el primer boot, mejor instalar ahora el paquete cliente de DHCP

(chroot) livecd / # emerge -v dhcpcd

**Preparo portage**

Preparo los ficheros de portage

# Virtualizador Docker
app-emulation/docker ~amd64

# New Kernel
sys-kernel/gentoo-sources ~amd64

# Benchmark
app-benchmarks/phoronix-test-suite ~amd64

net-misc/iputils -caps -filecaps

dev-lang/php truetype curl gd pcntl zip

**Descargo y compilo el último Kernel**

Primero nos bajamos los fuentes del Kernel con el comando siguiente:

(chroot) livecd / # emerge -v gentoo-sources

Los fuentes quedan instalados en /usr/src/linux (realmente es un link simbólico), a continuación lo parametrizas con "make menuconfig" y luego compilas con "make" y "make modules_install".

{% include showImagen.html
    src="/assets/img/original/2015-05-07-config-4.0.4-Gentoo_KVM_Guest.txt"
    caption="2015-05-07-config-4.0.4-Gentoo_KVM_Guest.txt"
    width="600px"
    %}

 cd /usr/src/linux

 wget https://raw.githubusercontent.com/LuisPalacios/Linux-Kernel-configs/master/configs/2015-05-07-config-4.0.4-Gentoo_KVM_Guest.txt -O .config 

 make && make modules_install
 cp arch/x86_64/boot/bzImage /boot/kernel-4.0.4-gentoo
 cp System.map /boot/System.map-4.0.4-gentoo

 

## Instalo "systemd"

**Selecciono el Perfil systemd**

Voy a configurar esta VM con systemd, así que selecciono el perfil adecuado:

(chroot) livecd / # eselect profile list
:
[5] default/linux/amd64/13.0/desktop/gnome/systemd
:
(chroot) livecd / # eselect profile set 5
 

**Recompilo con el nuevo Profile systemd**

Una vez que se selecciona un Profile distinto lo que ocurre es que cambias los valores USE de por defecto del sistema y esto significa que tenemos que "recompilarlo" por completo, así que lo siguiente que vamos a hacer es un emerge que actualice "world" :

# emerge -avDN @world

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**NOTA**: El proceso re-compila más de 150 paquetes y es normal que tarde varias horas (2 en mi caso), por eso asigné 4 virtual cpu's a esta VM, para acortar este tiempo al máximo.

[/dropshadowbox]  

**Hostname**

Con systemd se deja de usar /etc/conf.d/hostname, así que voy a editar a mano directamente los dos ficheros que emplea systemd. - Llamé a mi servidor "**edaddepiedrix**" (como siempre haciendo alusión a la aldea gala)

gentoo

PRETTY_NAME="KVM Gentoo Linux"
ICON_NAME="gentoo"

**Contraseña de root**

Antes de rearrancar es importante que cambies la contraseña de root.

(chroot) livecd ~ # passwd
New password:
Retype new password:
passwd: password updated successfully

**Fichero mtab**

Es necesario realizar un link simbólico especial:

# rm /etc/mtab
# ln -sf /proc/self/mounts /etc/mtab

**Grub 2**

Necesitamos un "boot loader" y nada mejor que Grub2.

# emerge -v grub:2

Instalamos el boot loader en el disco

# grub2-install /dev/vda

Modifico el fichero de configuración de Grub /etc/default/grub, la siguientes son las líneas importantes:

GRUB_CMDLINE_LINUX="init=/usr/lib/systemd/systemd quiet rootfstype=ext4" GRUB_TERMINAL=console GRUB_DISABLE_LINUX_UUID=true

Ah!, en el futuro, cuando te sientas confortable, cambia el timeout del menu que muestra Grub a "0", de modo que ganarás 5 segundos en cada rearranque de tu servidor Gentoo desde vSphere Client :-)

GRUB_TIMEOUT=0

Cada vez que se modifica el fichero /etc/default/grub hay que ejecutar el programa grub2-mkconfig -o /boot/grub/grub.cfg porque es él el que crea la versión correcta del fichero de configuración de Grub: /boot/grub/grub.cfg.

# mount /boot (por si acaso se te había olvidado :-))
# grub2-mkconfig -o /boot/grub/grub.cfg

Nota, si en el futuro tienes que modificar el Kernel, no olvides ejecutar grub2-mkconfig tras la compilación (y posterior copiado a /boot) del kernel, tampoco te olvides de haber montado /boot (mount /boot) previamente.

**Preparo la red**

{% include showImagen.html
    src="/assets/img/original/). Asigno un nombre específico a la interfaz principal (cambia la MAC a la de tu interfaz"
    caption="upstream"
    width="600px"
    %}

# Interfaz conectada a la red ethernet
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="b8:ae:ed:12:34:56", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"

En la sección de KVM veremos la configuración completa de La Red. De momento creo un fichero bajo /etc/systemd/network, el nombre puede ser cualquiera pero debe terminar en .network. En este caso solo tengo una interfaz física:

#
# Interfaz principal de la VM
#
[Match]
Name=eth0

[Network]
Address=192.168.1.24/24
DNS=192.168.1.1
Gateway=192.168.1.1

A continuación debes habilitar el servicio para el próximo arranque con: systemctl enable systemd-networkd

Otras opciones: * Arrancar manualmente: systemctl start systemd-networkd * Re-arrancar (si cambias algo): systemctl restart systemd-networkd * Verificar: networkctl

 

### Reboot

Salgo del chroot, desmonto y rearranco el equipo...

 
# exit
# cd
# umount -l /mnt/gentoo/dev{/shm,/pts,}
# umount -l /mnt/gentoo{/boot,/proc,}
:
# reboot

 

### Terminar la configuración

Tras el primer reboot nos faltan piezas importantes, vamos a arreglarlo empezando por lo básico, el teclado :-)

**Teclado y Locale**

Parametrizo con systemd el teclado y los locales ejecutando los tres comandos siguientes:

El primer comando modifica /etc/vconsole.conf

 localectl set-keymap es

El siguiente modifica /etc/X11/xorg.conf.d/00-keyboard.conf

 localectl set-x11-keymap es 

El siguiente modifica /etc/locale.conf

 localectl set-locale LANG=es_ES.UTF-8 

El ultimo simplemente para comprobar

 localectl
System Locale: LANG=es_ES.UTF-8
VC Keymap: es
X11 Layout: es

Preparo el fichero locale.gen

en_US ISO-8859-1
en_US.UTF-8 UTF-8
es_ES ISO-8859-1
es_ES@euro ISO-8859-15
es_ES.UTF-8 UTF-8
en_US.UTF-8@euro UTF-8
es_ES.UTF-8@euro UTF-8

Compilo los "locales"

edaddepiedrix ~ # locale-gen

**Activo SSHD**

Otro indispensable, habilito y arranco el daemon de SSH para poder conectar vía ssh. Si en el futuro quieres poder hacer forward de X11 recuerda poner X11Forwarding yes en el fichero /etc/ssh/sshd_config

# systemctl enable sshd.service

**Vixie-cron**

Instalo, habilito y arranco el cron

edaddepiedrix ~ # emerge -v vixie-cron
edaddepiedrix ~ # systemctl enable vixie-cron.service
edaddepiedrix ~ # systemctl start vixie-cron.service

**Fecha y hora**

{% include showImagen.html
    src="/assets/img/original/?p=881"
    caption="servicio NTP"
    width="600px"
    %}

edaddepiedrix ~ # timedatectl set-local-rtc 0
edaddepiedrix ~ # timedatectl set-timezone Europe/Madrid
edaddepiedrix ~ # timedatectl set-time 2012-10-30 18:17:16 <= Ponerlo primero en hora.
edaddepiedrix ~ # timedatectl set-ntp true <= Activar NTP

 

**Actualizo portage**

Lo primero es hacer un "perl-cleaner" y luego un update completo.

:
edaddepiedrix ~ # perl-cleaner --reallyall
:
edaddepiedrix ~ # emerge --sync
edaddepiedrix ~ #
edaddepiedrix ~ # emerge -DuvN system world

**Usuario y rearranque**

Desde una shell añado un usuario normal y por último rearranco el equipo. Mira un ejemplo:

edaddepiedrix ~ # groupadd -g 1400 luis
edaddepiedrix ~ # useradd -u 1400 -g luis -m -G cron,audio,cdrom,cdrw,users,wheel -d /home/luis -s /bin/bash luis
:
edaddepiedrix ~ # passwd luis
Nueva contraseña:
Vuelva a escribir la nueva contraseña:
:

**Instalo herramientas y paquetes adicionales**

x11-libs/cairo X
dev-libs/libxml2 python

edaddepiedrix ~ # emerge -v mlocate sudo  emacs tcpdump traceroute mlocate xclock gparted procmail net-snmp bmon dosfstools sys-boot/syslinux

**nfs-utils para montar volúmenes remotos desde mi NAS**

# emerge -v nfs-utils
:

Tienes dos opciones, utilizar **/etc/fstab** o **automount**.

Ejemplo con /etc/fstab para acceder a recursos remotos NFS.

# Recursos en la NAS via NFS
nas.parchis.org:/NAS  /mnt/NAS  nfs auto,user,exec,rsize=8192,wsize=8192,hard,intr,timeo=5   0 0

Ejemplo usando automount

[Unit]
Description=Montar por NFS el directorio NAS
Wants=network.target rpc-statd.service
After=network.target rpc-statd.service

[Mount]
What=panoramix.parchis.org:/NAS
Where=/mnt/NAS
Options=
Type=nfs
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target

[Unit]
Description=Automount /mnt/NAS

[Automount]
Where=/mnt/NAS

[Install]
WantedBy=multi-user.target

En mi caso prefiero el segundo método:

 
edaddepiedrix ~ # systemctl enable rpcbind.service
edaddepiedrix ~ # systemctl enable mnt-NAS.mount
edaddepiedrix ~ # systemctl enable mnt-NAS.automount
edaddepiedrix ~ # mkdir /mnt/NAS

Por fin, rearranco de nuevo el equipo, deberías tener ya todos los servicios que hemos configurado.

edaddepiedrix ~ # reboot.  (O bien "halt" para pararla)

   

# Pruebas de rendimiento

 

### Benchmark con Phoronix

Si quieres comprobar el rendimiento te recomiendo el benchmark pts/aio-stress de Phoronix:

 

# emerge -v phoronix-test-suite

# phoronix-test-suite benchmark pts/aio-stress

{% include showImagen.html
    src="/assets/img/original/1506191-SO-20150619236"
    caption="aquí"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/phoronix-vm-iscsi-1024x324.png"
    caption="phoronix-vm-iscsi"
    width="600px"
    %}

   

# Backup y Recuperación

### Backup de la VM

Para hacer backup de este tipo de VM lo que hacemos es backup del "disco iSCSI" usando las herramientas de la propia NAS guardándolo en un fichero en un NFS externo.

{% include showImagen.html
    src="/assets/img/original/iSCSI-Backup0.png"
    caption="iSCSI-Backup0"
    width="600px"
    %}
    
- Apago la máquina virtual desde virt-manager o ejecutando un shudown o halt en el Linux.
    
{% include showImagen.html
    src="/assets/img/original/iSCSI-Stop.png"
    caption="iSCSI-Stop"
    width="600px"
    %}
    
- Desde un navegador y el interfaz GUI de mi NAS creo un trabajo de Backup instantáneo hacia un fichero en un directorio NFS remoto (/Volumes/Terabyte/0.BACKUP/iSCSI) en mi OSX (obelix.parchis.org):
    

{% include showImagen.html
    src="/assets/img/original/iSCSI-Backup_1-1024x497.png"
    caption="iSCSI-Backup_1"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Backup2.png"
    caption="iSCSI-Backup2"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Backup3.png"
    caption="iSCSI-Backup3"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Backup4.png"
    caption="iSCSI-Backup4"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Backup5.png"
    caption="iSCSI-Backup5"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Backup6.png"
    caption="iSCSI-Backup6"
    width="600px"
    %}

- Se pondrá inmediatamente a trabajar. Observa el resultado final, tanto en la pantalla de configuración del QNAP como en el Finder de mi iMAC, vemos un fichero de ~10GB que contiene el backup completo del disco físico utilizado para esta máquina virtual.

{% include showImagen.html
    src="/assets/img/original/iSCSI-Backup7-1024x468.png"
    caption="iSCSI-Backup7"
    width="600px"
    %}

- Conecto de nuevo el disco iSCSI desde virt-manager para poder volver a trabajar con la VM.

{% include showImagen.html
    src="/assets/img/original/kvm-storage-restart.png"
    caption="kvm-storage-restart"
    width="600px"
    %}

Nota: En el caso de haber activado la compresión (mientras indicas la ubicación del fichero destino) el proceso tarda mucho más, pero obtendrás a cambio un fichero mucho más pequeño, mira la diferencia:

{% include showImagen.html
    src="/assets/img/original/iSCSI-Backup8.png"
    caption="iSCSI-Backup8"
    width="600px"
    %}

 

### Restaurar la VM

Para restaurar la VM volvemos a usar las herramientas que incluye la propia NAS. Voy a mostrar un ejemplo simulando que hemos perdido por completo el NAS, así que parto de una instalación de un NAS vacío donde tengo que volver a crear los grupos (targets) y LUN's de nuevo para recuperar el BACKUP desde el fichero en el servidor NFS remoto que utilicé en el paso anterior. Recomiendo hacer este tipo de pruebas para verificar que efectivamente tus backups funcionan :-)

- Desde el QNAP, creo un nuevo target/LUN de 10GB.

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-1-1024x600.png"
    caption="iSCSI-Restaura-1"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-2-1024x599.png"
    caption="iSCSI-Restaura-2"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-3-1024x600.png"
    caption="iSCSI-Restaura-3"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-4-1024x598.png"
    caption="iSCSI-Restaura-4"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-5-1024x600.png"
    caption="iSCSI-Restaura-5"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-6-1024x599.png"
    caption="iSCSI-Restaura-6"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-9-1024x599.png"
    caption="iSCSI-Restaura-9"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-10-1024x601.png"
    caption="iSCSI-Restaura-10"
    width="600px"
    %}

- Desde el QNAP, nuevo trabajo de recuperación para restaurar desde el fichero de backup

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-11-1024x598.png"
    caption="iSCSI-Restaura-11"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-12-1024x599.png"
    caption="iSCSI-Restaura-12"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-13-1024x600.png"
    caption="iSCSI-Restaura-13"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-14-1024x601.png"
    caption="iSCSI-Restaura-14"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-15-1024x600.png"
    caption="iSCSI-Restaura-15"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-16-1024x600.png"
    caption="iSCSI-Restaura-16"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-17-1024x601.png"
    caption="iSCSI-Restaura-17"
    width="600px"
    %}

- Desde el Host KVM y virt-manager elimino el Target/LUN antiguo, creo el nuevo iqn.2004-04.com.qnap:ts-569pro:iscsi.vmgentoo.d70ea1
    
    y en la VM borro el disco antiguo y creo uno nuevo asociando el nuevo recurso disponible.

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-18.png"
    caption="iSCSI-Restaura-18"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-19.png"
    caption="iSCSI-Restaura-19"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-20.png"
    caption="iSCSI-Restaura-20"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-21.png"
    caption="iSCSI-Restaura-21"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-22.png"
    caption="iSCSI-Restaura-22"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-23.png"
    caption="iSCSI-Restaura-23"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-24.png"
    caption="iSCSI-Restaura-24"
    width="600px"
    %}

- A partir de ahí ya puedo volver a arrancar la VM y ver que funciona correctamente.

{% include showImagen.html
    src="/assets/img/original/iSCSI-Restaura-25.png"
    caption="iSCSI-Restaura-25"
    width="600px"
    %}

* * *
