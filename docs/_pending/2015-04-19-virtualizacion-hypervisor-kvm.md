---
title: "Virtualización: Hypervisor KVM (centos)"
date: "2015-04-19"
categories: apuntes virtualizacion
tags: centos host kvm linux virtualizacion
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/Main_Page), una solución de virtualización basada en el Kernel de Linux para hardware x86 que contenga las extensiones de virtualización Intel VT o AMD-V. Este equipo hará de Host para ejecutar múltiples Guests o VM's (Máquinas Virtuales"
    caption="Hypervisor basado en KVM"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/HyperKVM-1024x1002.png"
    caption="HyperKVM"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/?p=29) he decidido aprender KVM y darle una oportunidad por varios motivos: garantía de soporte del Hardware casero, menor consumo de memoria (ESXi consume aprox 2GB"
    caption="funcionando con éxito el Hypervisor ESXi"
    width="600px"
    %}

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**OJO!!!!!**: Este artículo está sin terminar.

[/dropshadowbox]

 

## Instalación

El optar por Centos 7 como distribución en vez de Gentoo (después de tantos años) es básicamente porque tengo ganar de "probar" otras cosas. Obviamente tiene la ventaja de que la instalación es infinitamente más sencilla, así que aquí solo dejo unas notas someras sobre la misma.

{% include showImagen.html
    src="/assets/img/original/). Se trata de una distribución soportada por la comunidad, estable y predecible y se deriba de los fuentes de Red Hat Enterprise Linux (RHEL"
    caption="Centos"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/CentOS-7-x86_64-DVD-1503-01.iso)"
    caption="CentOS-7-x86_64-DVD-1503-01.iso"
    width="600px"
    %}
- Por fin arranco el servidor con el USB y realizo la instalación. Selección de Software: **“Host de Virtualización mínimo”**, con las opciones: Depuración, cliente archivos de red, admon remota, plataforma de virtualización, herramientas de desarrollo
- Llamé a mi servidor "**edaddepiedrix**" (como siempre haciendo alusión a la aldea gala)
- Al terminar la instalación compruebo y veo qué se ha instalado y qué falta:

 qemu-kvm  (Instalado)
 qemu-img (Instalado)
 libvirt (Instalado)
 libvirt-python (Instalado)
 libvirt-client (Instalado)

 virt-install (NO LO INSTALA)
 virt-manager (NO LO INSTALA)

- Actualizo CentOS a lo último e instalo virt-manager y virt-install

[root@edaddepiedrix ~]# yum update
[root@edaddepiedrix ~]# yum install virt-manager
[root@edaddepiedrix ~]# yum install virt-install

- virt-manager es un GUI para gestionar las máquinas virtuales de forma cómoda. Necesita XOrg y en mi caso quiero que funcione vía SSH y ver los gráficos en mi Mac donde se ejecuta X11. Instalo xclock, xauth y compruebo que todo funciona.

[root@edaddepiedrix ~]# yum install xclock xauth
:
___DESDE MI ESTACIÓN DE TRABAJO, UN MACOS___
obelix:~ luis$ ssh -Y -l root -p 22 edaddepiedrix.tudominio.com
root@edaddepiedrix.tudominio.com's password:
:
[root@edaddepiedrix ~]# xclock
___FUNCIONA, EN EL MAC ARRANCA X11 Y SE VE EL RELOJ___

- Hago reboot y compruebo la instalación KVM

[root@edaddepiedrix ~]# lsmod|grep kvm
kvm_intel             148081  0
kvm                   461126  1 kvm_intel

[root@edaddepiedrix ~]# virsh -c qemu:///system list
 Id    Nombre                         Estado
——————————————————————————

root@edaddepiedrix ~]# osinfo-query os
 Short ID             | Name                                               | Version  | ID
----------------------+----------------------------------------------------+----------+————————————————————
:
:

{% include showImagen.html
    src="/assets/img/original/how-to-set-up-epel-repository-on-centos.html"
    caption="EPEL"
    width="600px"
    %}

[root@edaddepiedrix ~]# yum install epel-release
[root@edaddepiedrix ~]# yum repolist

- Instalo gparted

[root@edaddepiedrix ~]# yum install gparted

A continuación voy a configurar los discos de este servidor con LVM, un gestor de volúmenes lógicos fantástico, que si no conoces te recomiendo. En el caso de este servidor tengo 3 discos físicos, el primero es donde se ha instalado centos, tiene 2TB. Los otros dos son de 1,5TB y son los que voy a usar junto con LVM para que se presente un único disco de 3TB al sistema operativo y que usaré como ubicación para mis máquinas virtuales, ficheros de datos, etc...

- El disco 0 es el que se particionó de manera automática durante la instalación. Ahora particiono los dos discos extra con formato LVM2 utilizando gparted.

[root@edaddepiedrix ~]# gparted

- Cuando termino con gparted, creo dos "discos físicos LVM" que a su vez usan las dos particiones recién creadas con gparted.

[root@edaddepiedrix ~]# pvcreate /dev/sdb1 /dev/sdc1

- Creo un Virtual Group con ambos discos físicos, con un tamaño de PE de 32M, que significa que se crean 89424 PE's (son de 1,5TB)

[root@edaddepiedrix ~]# vgcreate -s 32M datastore /dev/sdb1 /dev/sdc1

- Sumo todo el espacio (suma de 1,5 y 1,5 TB) y creo un único Logical Volume

[root@edaddepiedrix ~]# lvcreate -l 89424 -n vm_datastore datastore

- Compruebo el tipo de particiones que tengo (la del nuevo Logical Volume todavía no la he creado)

[root@edaddepiedrix ~]# lvs --all --noheadings | while read lv vg rest; do file --dereference --special-files "/dev/mapper/$vg-$lv"; done

- Creo una partición nueva de tipo XFS

[root@edaddepiedrix ~]# mkfs.xfs /dev/datastore/vm_datastore
meta-data=/dev/datastore/vm_datastore isize=256    agcount=4, agsize=183140352 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=0        finobt=0
data     =                       bsize=4096   blocks=732561408, imaxpct=5
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
log      =internal log           bsize=4096   blocks=357696, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

- Monto el nuevo volumen

[root@edaddepiedrix ~]# mkdir /datastore
[root@edaddepiedrix ~]# mount /dev/datastore/vm_datastore /datastore/

[root@edaddepiedrix ~]# df -h
S.ficheros                         Tamaño Usados  Disp Uso% Montado en
/dev/mapper/centos-root               50G   1,7G   49G   4% /
devtmpfs                             5,8G      0  5,8G   0% /dev
tmpfs                                5,8G      0  5,8G   0% /dev/shm
tmpfs                                5,8G   8,9M  5,8G   1% /run
tmpfs                                5,8G      0  5,8G   0% /sys/fs/cgroup
/dev/mapper/centos-home              1,8T    33M  1,8T   1% /home
/dev/sda1                            497M   169M  328M  35% /boot
/dev/mapper/datastore-vm_datastore   2,8T    33M  2,8T   1% /datastore

- Lo añado a /etc/fstab

[root@edaddepiedrix ~]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Sat Apr 18 08:10:54 2015
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/centos-root /                       xfs     defaults        0 0
UUID=c240a05c-a387-4e13-a990-548f58c852bb /boot                   xfs     defaults        0 0
/dev/mapper/centos-home /home                   xfs     defaults        0 0
/dev/mapper/centos-swap swap                    swap    defaults        0 0

/dev/mapper/datastore-vm_datastore   /datastore xfs     defaults        0 0

 

## La Red

Primero hay que tener claro el diseño físico de la red, qué NIC's tenemos y qué NIC's virtuales van a presentarse (desde KVM) a la VM. Voy a configurar las vNICs con nombres predecibles, con IPs estáticas (sin dhcp) y que no cambie nada al hacer reboot. Es un servidor.

**Conexiones físicas con KVM**

{% include showImagen.html
    src="/assets/img/original/?p=266"
    caption="aquí"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/hyprevisor-kvm-fisico.png"
    caption="hyprevisor-kvm-fisico"
    width="600px"
    %}

Veamos cómo funciona la red en la distribución que he elegido. CentOS 7, Fedora o RedHat utilizan los scripts /etc/sysconfig/network-scripts/ifcfg-* para controlar y programar **La Red**. Al estar basadas en systemd lo que hacen es conectar Network Manager con sus propios scripts de networking mediante el uso del plugin ifcfg-rh:

[main]
plugins=ifcfg-rh

Por lo tanto, toda la configuración la voy a realizar modificando o creando ficheros /etc/sysconfig/network-scripts/ifcfg-*.

 

#### Ejercicio: configuración manual

Muestro a modo de ejercicio cómo se haría de forma manual y más adelante de manera automática durante el arranque del equipo, si te interesa ir rápido, salta a la sección siguiente (Configuración mediante ficheros).

**Bridge**: El Hypervisor (KVM) va a necesitar un bridge virtual y para conseguirlo usaremos el Linux Bridge, un código que implementa el estándar ANSI/IEEE 802.1d (en realidad un subconjunto de dicho estándar). Permite crear un bridge lógico al que conectaremos las interfaces que deseemos, en concreto la(s) física(s) y las lógicas de las máquinas virtuales.

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

{% include showImagen.html
    src="/assets/img/original/?p=2033"
    caption="tal como hice con el Hypervisor ESXi"
    width="600px"
    %}

[/dropshadowbox]  

Cuando instalas KVM y rearrancas el equipo se configura un Bridge llamado virbr0 con la dirección IP 192.168.122.1 y un interfaz con el nombre virbr0-nic. Voy a borrarlos para empezar sin nada configurado.

[root@edaddepiedrix ~]# ip link delete virbr0-nic
[root@edaddepiedrix ~]# ip link set dev virbr0 down
[root@edaddepiedrix ~]# brctl delbr virbr0

Creo una instancia de Bridge (un Switch virtual) y le asigno un nombre. Hace falta al menos una instancia lógica para que se pueda hacer bridging. Básicamente actúa como contenedor de las interfaces que van a formar parte del mismo, ya sean físicas como lógicas.

[root@edaddepiedrix ~]# ip link 
1: lo: mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp8s0: mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
    link/ether 00:24:1d:10:6d:73 brd ff:ff:ff:ff:ff:ff
:
[root@edaddepiedrix ~]# brctl addbr "vSwitch0" 

Añado la interfaz física enp8s0 al Bridge.

[root@edaddepiedrix ~]# brctl addif vSwitch0 enp8s0

**Dirección IP de gestión**: Ya tengo el Bridge y como es un Switch no hace falta darle dirección IP, ahora bien, como necesito acceder al Linux para gestionarlo voy a asignarle una: Creo un interfaz de tipo VLAN (la red gestión va por la vlan 100) y le asigno la direcció IP estática 192.168.1.24/24. Por último activo el Switch.

[root@edaddepiedrix ~]# ip link add name vlan100 link vSwitch0 type vlan id 100
[root@edaddepiedrix ~]# ip address add 192.168.1.24/24 dev vlan100
[root@edaddepiedrix ~]# ip link set dev vSwitch0 up

[root@edaddepiedrix ~]# brctl show
bridge name bridge id       STP enabled interfaces
vSwitch0        8000.00241d106d73   no      enp8s0
:
[root@edaddepiedrix ~]# ip link
1: lo: mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp8s0: mtu 1500 qdisc pfifo_fast master vSwitch0 state UP mode DEFAULT qlen 1000
    link/ether 00:24:1d:10:6d:73 brd ff:ff:ff:ff:ff:ff
6: vSwitch0: mtu 1500 qdisc noqueue state UP mode DEFAULT
    link/ether 00:24:1d:10:6d:73 brd ff:ff:ff:ff:ff:ff
7: vlan100@vSwitch0: mtu 1500 qdisc noqueue state UP mode DEFAULT
    link/ether 00:24:1d:10:6d:73 brd ff:ff:ff:ff:ff:ff
:
:
[root@edaddepiedrix ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp8s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master vSwitch0 state UP qlen 1000
    link/ether 00:24:1d:10:6d:73 brd ff:ff:ff:ff:ff:ff
20: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 500
    link/ether fe:50:56:c0:01:00 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::fc50:56ff:fec0:100/64 scope link
       valid_lft forever preferred_lft forever
21: vSwitch0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 00:24:1d:10:6d:73 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::224:1dff:fe10:6d73/64 scope link
       valid_lft forever preferred_lft forever
22: vlan100@vSwitch0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 00:24:1d:10:6d:73 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.24/24 scope global vlan100
       valid_lft forever preferred_lft forever
    inet6 fe80::224:1dff:fe10:6d73/64 scope link
       valid_lft forever preferred_lft forever 

Para que el Host KVM pueda llegar a internet (por ejemplo para instalar actualizaciones) puedes configurarle el fichero /etc/resolv.conf y añadirle una ruta por defecto:

[root@edaddepiedrix ~]# cat /etc/resolv.conf
search tudominio.com
nameserver 192.168.1.1
[root@edaddepiedrix ~]# ip route add default via 192.168.1.1

 

### Configuración mediante ficheros

A continuación puedes encontrar la configuración utilizando los ficheros /etc/sysconfig/network-scripts/ifcfg-*, de modo que al arrancar el Network Manager se configurará todo de forma automática.

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

{% include showImagen.html
    src="/assets/img/original/?p=2033"
    caption="en el ejemplo de Hypervisor ESXi"
    width="600px"
    %}

[/dropshadowbox]

TYPE="Ethernet"
NAME="enp8s0"
UUID="fc0c758a-3c6f-4951-8adf-68dbbc13fe61"
DEVICE="enp8s0"
ONBOOT="yes"
HWADDR="00:24:1d:10:6d:73"
BRIDGE=virbr0

DEVICE="virbr0"
TYPE=BRIDGE
ONBOOT=yes
BOOTPROTO=static

NAME="VLAN100"
VLAN=yes
TYPE=vlan
DEVICE="vlan100"
VLAN_ID=100
PHYSDEV="virbr0"
ONBOOT=yes
BOOTPROTO=none
IPV6INIT=no

# Management IP
NETWORK="192.168.1.0"
DNS1="192.168.1.246"
DNS2="192.168.1.1"
IPADDR=192.168.1.24
PREFIX=24
GATEWAY=192.168.1.1

NAME="VLAN2"
VLAN=yes
TYPE=vlan
DEVICE="vlan2"
VLAN_ID=2
PHYSDEV="virbr0"
ONBOOT=yes
BOOTPROTO=none
IPV4INIT=no
IPV6INIT=no

NAME="VLAN3"
VLAN=yes
TYPE=vlan
DEVICE="vlan3"
VLAN_ID=3
PHYSDEV="virbr0"
ONBOOT=yes
BOOTPROTO=none
IPV4INIT=no
IPV6INIT=no

NAME="VLAN6"
VLAN=yes
TYPE=vlan
DEVICE="vlan6"
VLAN_ID=6
PHYSDEV="virbr0"
ONBOOT=yes
BOOTPROTO=none
IPV4INIT=no
IPV6INIT=no

Puedes conseguir más detalle sobre estos intefaces con el comando nmcli -p con show o bien nmcli -p con show vlan100.

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**Atención**: a partir de aquí está incompleto.

[/dropshadowbox]

Pdte: Configuración completa de todas las VLAN's y cómo las consumen las VM's.

Pdte: Opciones de Routing.

# echo "net.ipv4.ip_forward = 1” > /etc/sysctl.d/99-ipforward.conf
# sysctl -p /etc/sysctl.d/99-ipforward.conf

 

## Máquinas virtuales

Arranco virt-manager y creo una nueva VM, con los siguientes parámetros:

[root@edaddepiedrix ~]# virt-manager

{% include showImagen.html
    src="/assets/img/original/kvm-guest-install.jpg"
    caption="kvm-guest-install"
    width="600px"
    %}

 

### Enlaces

{% include showImagen.html
    src="/assets/img/original/Home"
    caption="oVirt"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/Networking"
    caption="Ejemplos, casos de uso KVM"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/bridge) (Linux Foundation"
    caption="Linux bridge"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/?p=207"
    caption="Installar KVM en Centos7"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/ESXiNet-1.png"
    caption="Configuración equivalente con ESXi"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/Networking"
    caption="Ubuntu y KVM"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/#Connected%20routes"
    caption="iproute2"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/sec-Using_the_Command_Line_Interface.html#sec-Configuring_a_Network_Interface_Using_ifcg_Files"
    caption="Configurar una interfaz de red usando ifcfg-*"
    width="600px"
    %}
