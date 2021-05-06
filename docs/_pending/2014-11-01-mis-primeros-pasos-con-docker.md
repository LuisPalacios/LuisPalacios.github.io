---
title: "Mis primeros pasos con Docker"
date: "2014-11-01"
categories: apuntes
tags: docker
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/)", por lo que entendí se trata de una herramienta que permite empaquetar "aplicaciones Linux y todas sus dependencias" en un contenedor virtual (algo así como sandboxes) autocontenido. Dicho "container" (contenedor"
    caption="Docker"
    width="600px"
    %}

Eso no nos dice mucho, pero si te digo que puedes ejecutar el daemon Docker (y por tanto tus aplicaciones) en otras plataformas como Windows o MacOsx poniendo una máquina virtual super ligera (estilo VirtualBox), que plataformas como Amazon EC, Google Cloud, Rackspace Cloud, etc. ya soportan contenedores Docker, entonces empezará a interesante. De hecho hay más, los contenedores Docker y todo lo que se está desarrollando a su alrededor está acelerando a una velocidad impresionante, no se trata de un Host Hypervisor al estilo ESX, KVM, Hyper-V vinculado al hardware con sus máquinas virtuales, sino que se trata de un virtualizador que ejecuta containers con aplicaciones aisladas autocontenidas en casi cualquier sitio, ofreciendo una flexibilidad y agilidad IT impresionante. Si tienes aplicaciones (linux) piensa que las puedes ejecutar en cualquier sitio, cientos de ellas por servidor, con una escalabiilidad impresionante

{% include showImagen.html
    src="/assets/img/original/index.php?controller=post&action=view&id_post=27"
    caption="servidor casero"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/why-docker2bisv4-130725202710-phpapp01-thumbnail-4_2_o.jpg"
    caption="why-docker2bisv4-130725202710-phpapp01-thumbnail-4_2_o"
    width="600px"
    %}

Una de las ventajas de Docker que veo de forma inmediata: ahora que migrando mi servidor supone reinstalar todos mis servicios en el nuevo Hardware, si tuviese todo en "contenedores" la migración hubiese sido infinitamente más sencilla y rápida.

{% include showImagen.html
    src="/assets/img/original/"
    caption="Docker Hub"
    width="600px"
    %}

## ¿qué es Docker?

{% include showImagen.html
    src="/assets/img/original/Docker_%28software%29)"
    caption="WikipediA"
    width="600px"
    %}

Virtualiza el sistema operativo gracias a que usa recursos de aislamiento que ofrece el Kernel de Linux, tales como cgroups y espacios de nombres, y permite ejecutar "contenedores independientes" dentro de una única instancia de Linux. Atención: ni es un hypervisor ni se ejecutan máquinas virtuales.

Se apoya por un lado en los **espacios de nombres** del kernel de Linux, que ofrecen una visión aislada del entorno en el que opera la aplicación, incluyendo la lista de procesos, la red, el user ID y los file system montados. Por otro lado los **cgroups** ofrecen una visión aislada de los recursos de CPU, memoria, entrada/salida y Red.

Docker incluye la biblioteca **libcontainer** como una implementación de referencia para los contenedores, su desarrollo está basado en la librería **libvirt**, LXC (contenedores Linux) y systemd-nspawn, que proporcionan interfaces para acceder a las distintas capacidades proporcionadas por el núcleo de Linux.

 

# Instalación de Docker

## Docker Host con Gentoo Linux

{% include showImagen.html
    src="/assets/img/original/docker"
    caption="página de instalación de Gentoo"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/?p=831"
    caption=".config"
    width="600px"
    %}

# OBLIGATORIOS

CONFIG_NAMESPACES
CONFIG_NET_NS
CONFIG_PID_NS
CONFIG_IPC_NS
CONFIG_UTS_NS

CONFIG_DEVPTS_MULTIPLE_INSTANCES

CONFIG_CGROUPS 
CONFIG_CGROUP_CPUACCT
CONFIG_CGROUP_DEVICE
CONFIG_CGROUP_FREEZER 
CONFIG_CGROUP_SCHED
 
CONFIG_MACVLAN 
CONFIG_VETH 
CONFIG_BRIDGE
CONFIG_NF_NAT_IPV4
CONFIG_IP_NF_TARGET_MASQUERADE
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE
CONFIG_NETFILTER_XT_MATCH_CONNTRACK
CONFIG_NF_NAT
CONFIG_NF_NAT_NEEDED

CONFIG_BLK_DEV_DM
CONFIG_DM_THIN_PROVISIONING

# OPCIONALES

CONFIG_MEMCG_SWAP
CONFIG_RESOURCE_COUNTERS
CONFIG_CGROUP_PERF

# File Systems

CONFIG_EXT4_FS_POSIX_ACL
CONFIG_EXT4_FS_SECURITY

Añado lo siguiente en /etc/portage/accept_keywords

# Virtualizador Docker
=app-emulation/docker-1.3.1 ~amd64

Instalo el programa

totobo ~ # emerge -v app-emulation/docker

Añado al boot, añado mi usuario "luis" para que pueda controlar Docker y lo arranco

totobo ~ # rc-update add docker default
 * service docker added to runlevel default
totobo ~ # usermod -aG docker luis
totobo ~ # /etc/init.d/docker start
 * Caching service dependencies ... [ ok ]
 * /var/log/docker.log: creating file
 * /var/log/docker.log: correcting mode
 * /var/log/docker.log: correcting owner
 * Starting docker daemon ...

{% include showImagen.html
    src="/assets/img/original/?p=184"
    caption="Servidor "gitolite" en Contenedor Docker"
    width="600px"
    %}

**Nota**: Hay algunas cosas que no hice y que de momento no me han afectado. No he activado LVM, durante la instalación de docker se instalan su dependencia LVM y me sugiere que añada lvm al runlevel boot (rc-update add lvm boot) y que habilite "lvmetad" en el /etc/lvm/lvm.conf (si quiero lvm autoactivation + metadata caching). Tampoco he instalado ni tengo activo systemd: Docker dice que tiene dependencia con systemd en sus páginas.

 

## Docker en Host basado en MacOSX

{% include showImagen.html
    src="/assets/img/original/"
    caption="instalarme Docker en mi iMac"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/releases"
    caption="boot2docker (última versión)"
    width="600px"
    %}

**El instalador boot2docker**

- Crea una máquina virtual basada en VirtualBox
- Se guarda en /Users/luis/VirtualBox VMs (ocupa 25MB)

El siguiente paso consiste en ejecutar Boot2Docker desde Finder (Aplicaciones) **para arrancar el daemon**, abre Terminal.app y hace lo siguiente:

- La primera vez:
    - Crea ~/.boot2docker
    - Copia /usr/local/share/boot2docker/boot2docker.iso a ~/.boot2docker
- Ejecuta:
    - /usr/local/bin/boot2docker init
        - La primera vez crea claves publica/privada
    - /usr/local/bin/boot2docker up
    - $(/usr/local/bin/boot2docker shellinit)

 

## Ejecutar el primer contenedor de pruebas

En ambos equipos he hecho la misma prueba, tanto en Getoo como en el MacOSX (desde la ventana de Terminal.app que me abre).

**Hello-World**

Desde la shell de Gentoo o el Terminal.app ejecuto lo mismo con el mismo resultado

$ docker run hello-world

- El cliente Docker contacta al daemon Docker
- El daemon se baja la imagen "hello world" porque todavía no la teníamos
- El daemon crea un nuevo contenedor desde esta imagen y ejecuta
- El daemon hace un stream de la salida "Hello from Docker." al cliente
- El cliente lo muestra en pantalla (nuestro Terminal.app)

**Ubuntu**

La segunda prueba ha sido más ambiciosa,

$ docker run -it ubuntu bash

El resultado es... espectacular, se baja Ubuntu (~200MB) y entra en él, y funciona :)

## **Siguientes pasos...**

{% include showImagen.html
    src="/assets/img/original/index.php?controller=post&action=view&id_post=39"
    caption="Servidor "gitolite" en Contenedor Docker"
    width="600px"
    %}

# ¿Imágenes en disco NFS?

El directorio donde Docker deja las imágenes (/var/lib/docker) puede llenarse rápidamente, sobre todo cuando empiezas a crearlas durante el aprendizaje. Una solución que puedes probar es a sacarlo a una NAS externa. En mi caso lo probé y aunque finalmente NO lo estoy usando dejo aquí documentado cómo lo hice:

## Modificaciones en mi equipo Gentoo (Host)

### Configurar NFS client en el Kernel

totobo ~ # cd /usr/src/linux
totobo linux # make menuconfig
 ---> File Systems->Network File Systems (En mi caso he activado todos los clientes 2,3,4)

 

### /etc/fstab

{% include showImagen.html
    src="/assets/img/original/?p=785)"
    caption="/etc/conf.d/net aquí"
    width="600px"
    %}

/etc/fstab
:
:
# NAS !!
# Equivale a:
#   mount -t nfs panoramix.parchis.org:/NAS /mnt/NAS -o nfsvers=3,rsize=8192,wsize=8192,hard,intr
# 
panoramix.parchis.org:/NAS /mnt/NAS nfs auto,user,exec,rsize=8192,wsize=8192,hard,intr,timeo=5 0 0
:

### Instalar nfs-utils

totobo ~ # emerge -v net-fs/nfs-utils

### Activar statd

totobo etc # /etc/init.d/rpc.statd start
* Caching service dependencies ... [ ok ]
* Starting rpcbind ... [ ok ]
* Starting NFS statd ... [ ok ]

:
totobo etc # rc-update add rpc.statd default
* service rpc.statd added to runlevel default

### Montar el directorio remoto

totobo etc # mount /mnt/NAS/

totobo etc # cat /proc/mounts
:
panoramix.parchis.org:/NAS /mnt/NAS nfs rw,nosuid,nodev,relatime,vers=3,
      rsize=8192,wsize=8192,namlen=255,hard,proto=tcp,timeo=5,retrans=2,
      sec=sys,mountaddr=192.168.1.2,mountvers=3,mountport=50004, 
      mountproto=udp,local_lock=none,addr=192.168.1.2 0

 

[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**Recuerda**: Aunque he explicado cómo hacerlo, en mi caso no utilizo un disco remoto para dejar las imágenes, según vas aprendiendo sobre docker y para un uso casero acabas teniendo "pocas" imágenes.

[/dropshadowbox]
