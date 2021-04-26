---
title: "Mis primeros pasos con Docker"
date: "2014-11-01"
categories: 
  - "apuntes"
tags: 
  - "docker"
---

Hace poco me hablaron de "[Docker](https://www.docker.com/)", por lo que entendí se trata de una herramienta que permite empaquetar "aplicaciones Linux y todas sus dependencias" en un contenedor virtual (algo así como sandboxes) autocontenido. Dicho "container" (contenedor) queda desacoplado del Hardware por completo y lo puedes ejecutar donde te de la gana, bueno donde tengas una "daemon Docker". ¿Dónde puedes tener un Daemon Docker?, pues solo necesitas un kernel linux, así que funciona obviamente en Linux.

Eso no nos dice mucho, pero si te digo que puedes ejecutar el daemon Docker (y por tanto tus aplicaciones) en otras plataformas como Windows o MacOsx poniendo una máquina virtual super ligera (estilo VirtualBox), que plataformas como Amazon EC, Google Cloud, Rackspace Cloud, etc. ya soportan contenedores Docker, entonces empezará a interesante. De hecho hay más, los contenedores Docker y todo lo que se está desarrollando a su alrededor está acelerando a una velocidad impresionante, no se trata de un Host Hypervisor al estilo ESX, KVM, Hyper-V vinculado al hardware con sus máquinas virtuales, sino que se trata de un virtualizador que ejecuta containers con aplicaciones aisladas autocontenidas en casi cualquier sitio, ofreciendo una flexibilidad y agilidad IT impresionante. Si tienes aplicaciones (linux) piensa que las puedes ejecutar en cualquier sitio, cientos de ellas por servidor, con una escalabiilidad impresionante

Como tiene pinta de ser una solución muy flexible, ágil y portable, pensé en aprender sobre ello y qué mejor forma que usarlo para instalar mis Servicios en modo contenedores en mi nuevo [servidor casero](http://blog.luispa.com/index.php?controller=post&action=view&id_post=27). Un ejemplo sobre lo que quiero decir: en vez de instalar el servidor web apache junto con este blog encima del propio Gentoo de mi servidor, lo que haré es crearlo como un contenedor Docker.

[![why-docker2bisv4-130725202710-phpapp01-thumbnail-4_2_o](https://www.luispa.com/wp-content/uploads/2014/12/why-docker2bisv4-130725202710-phpapp01-thumbnail-4_2_o.jpg)](https://www.luispa.com/wp-content/uploads/2014/12/why-docker2bisv4-130725202710-phpapp01-thumbnail-4_2_o.jpg)

Una de las ventajas de Docker que veo de forma inmediata: ahora que migrando mi servidor supone reinstalar todos mis servicios en el nuevo Hardware, si tuviese todo en "contenedores" la migración hubiese sido infinitamente más sencilla y rápida.

Por otro lado me interesa aprender algo nuevo, me ha llamado la atención que también permite ejecutar contenedores en la nube pública y que la comunidad de desarrolladores está compartiendo los suyos propios, así que rápidamente me he dado de alta en el [Docker Hub](https://hub.docker.com/account/signup/).

## ¿qué es Docker?

Más en detalle (fuente [WikipediA](http://en.wikipedia.org/wiki/Docker_%28software%29)), Docker es un proyecto de código abierto que automatiza el despliegue de aplicaciones situadas dentro de "contenedores". Crea una capa de abstracción y automatización virtualizando el Sistema Operativo Linux.

Virtualiza el sistema operativo gracias a que usa recursos de aislamiento que ofrece el Kernel de Linux, tales como cgroups y espacios de nombres, y permite ejecutar "contenedores independientes" dentro de una única instancia de Linux. Atención: ni es un hypervisor ni se ejecutan máquinas virtuales.

Se apoya por un lado en los **espacios de nombres** del kernel de Linux, que ofrecen una visión aislada del entorno en el que opera la aplicación, incluyendo la lista de procesos, la red, el user ID y los file system montados. Por otro lado los **cgroups** ofrecen una visión aislada de los recursos de CPU, memoria, entrada/salida y Red.

Docker incluye la biblioteca **libcontainer** como una implementación de referencia para los contenedores, su desarrollo está basado en la librería **libvirt**, LXC (contenedores Linux) y systemd-nspawn, que proporcionan interfaces para acceder a las distintas capacidades proporcionadas por el núcleo de Linux.

 

# Instalación de Docker

## Docker Host con Gentoo Linux

Mi objetivo es instalar Docker en mi [nuevo servidor basado en Gentoo GNU/Linux](https://www.luispa.com/?p=7). Está bastante bien documentado en la [página de instalación de Gentoo](https://docs.docker.com/installation/gentoolinux/), así que aquí solo voy a detallar los comandos que he ejecutado. Ofrece dos métodos, uno es ir a lo último mediante un overlay y otro es usando la versión estable que está en portage. En mi caso opto por la versión estable (app-emulation/docker):

Preparo el Kernel, recompilo, instalo y hago reboot. Aquí tienes mi [.config](https://www.luispa.com/?p=831) completo

\# OBLIGATORIOS

CONFIG\_NAMESPACES
CONFIG\_NET\_NS
CONFIG\_PID\_NS
CONFIG\_IPC\_NS
CONFIG\_UTS\_NS

CONFIG\_DEVPTS\_MULTIPLE\_INSTANCES

CONFIG\_CGROUPS 
CONFIG\_CGROUP\_CPUACCT
CONFIG\_CGROUP\_DEVICE
CONFIG\_CGROUP\_FREEZER 
CONFIG\_CGROUP\_SCHED
 
CONFIG\_MACVLAN 
CONFIG\_VETH 
CONFIG\_BRIDGE
CONFIG\_NF\_NAT\_IPV4
CONFIG\_IP\_NF\_TARGET\_MASQUERADE
CONFIG\_NETFILTER\_XT\_MATCH\_ADDRTYPE
CONFIG\_NETFILTER\_XT\_MATCH\_CONNTRACK
CONFIG\_NF\_NAT
CONFIG\_NF\_NAT\_NEEDED

CONFIG\_BLK\_DEV\_DM
CONFIG\_DM\_THIN\_PROVISIONING

\# OPCIONALES

CONFIG\_MEMCG\_SWAP
CONFIG\_RESOURCE\_COUNTERS
CONFIG\_CGROUP\_PERF

\# File Systems

CONFIG\_EXT4\_FS\_POSIX\_ACL
CONFIG\_EXT4\_FS\_SECURITY

Añado lo siguiente en /etc/portage/accept\_keywords

\# Virtualizador Docker
=app-emulation/docker-1.3.1 ~amd64

Instalo el programa

totobo ~ # emerge -v app-emulation/docker

Añado al boot, añado mi usuario "luis" para que pueda controlar Docker y lo arranco

totobo ~ # rc-update add docker default
 \* service docker added to runlevel default
totobo ~ # usermod -aG docker luis
totobo ~ # /etc/init.d/docker start
 \* Caching service dependencies ... \[ ok \]
 \* /var/log/docker.log: creating file
 \* /var/log/docker.log: correcting mode
 \* /var/log/docker.log: correcting owner
 \* Starting docker daemon ...

Todo ha instalado correctamente, así que ya tengo la plataforma, ahora el siguiente paso es sacarle provecho, algo que detallo en mi siguiente post: "[Servidor "gitolite" en Contenedor Docker](https://www.luispa.com/?p=184)"

**Nota**: Hay algunas cosas que no hice y que de momento no me han afectado. No he activado LVM, durante la instalación de docker se instalan su dependencia LVM y me sugiere que añada lvm al runlevel boot (rc-update add lvm boot) y que habilite "lvmetad" en el /etc/lvm/lvm.conf (si quiero lvm autoactivation + metadata caching). Tampoco he instalado ni tengo activo systemd: Docker dice que tiene dependencia con systemd en sus páginas.

 

## Docker en Host basado en MacOSX

Otra opción con la que también estoy probando es [instalarme Docker en mi iMac](https://docs.docker.com/installation/mac/), así podré verificar y probar a trabajar con "hosts" diferentes, una vez vaya creando mis propios contenedores.

Dado que Docker depende del kernel de Linux, la versión de Mac realmente es una Virtual Machine con Virtual Box que por dentro contiene Linux y Docker. La última versión que me bajo es el instalador [boot2docker (última versión)](https://github.com/boot2docker/osx-installer/releases) que monta Docker en Linux dentro de una máquina virtual VirtualBox.

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

Hay más [ideas y ejemplos en la guía del usuario de Docker](http://docs.docker.com/userguide/), te recomiendo que dediques tiempo a leer los manuales de Docker y a hacer pruebas, aquí [registry oficial, un repositorio con cientos de imágenes](https://registry.hub.docker.com). También te dejo aquí un artículo sobre cómo he hecho mi primer contenedor para un servicio real que he activado en mi Host Linux: [Servidor "gitolite" en Contenedor Docker](http://blog.luispa.com/index.php?controller=post&action=view&id_post=39)  

# ¿Imágenes en disco NFS?

El directorio donde Docker deja las imágenes (/var/lib/docker) puede llenarse rápidamente, sobre todo cuando empiezas a crearlas durante el aprendizaje. Una solución que puedes probar es a sacarlo a una NAS externa. En mi caso lo probé y aunque finalmente NO lo estoy usando dejo aquí documentado cómo lo hice:

## Modificaciones en mi equipo Gentoo (Host)

### Configurar NFS client en el Kernel

totobo ~ # cd /usr/src/linux
totobo linux # make menuconfig
 ---> File Systems->Network File Systems (En mi caso he activado todos los clientes 2,3,4)

 

### /etc/fstab

Modifico el fichero fstab (notar que mi NAS se llama panoramix). Notar que en mi equipo utilizo jumbo frames (ver configuración de [/etc/conf.d/net aquí](https://www.luispa.com/?p=785))

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
\* Caching service dependencies ... \[ ok \]
\* Starting rpcbind ... \[ ok \]
\* Starting NFS statd ... \[ ok \]

:
totobo etc # rc-update add rpc.statd default
\* service rpc.statd added to runlevel default

### Montar el directorio remoto

totobo etc # mount /mnt/NAS/

totobo etc # cat /proc/mounts
:
panoramix.parchis.org:/NAS /mnt/NAS nfs rw,nosuid,nodev,relatime,vers=3,
      rsize=8192,wsize=8192,namlen=255,hard,proto=tcp,timeo=5,retrans=2,
      sec=sys,mountaddr=192.168.1.2,mountvers=3,mountport=50004, 
      mountproto=udp,local\_lock=none,addr=192.168.1.2 0

 

\[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**Recuerda**: Aunque he explicado cómo hacerlo, en mi caso no utilizo un disco remoto para dejar las imágenes, según vas aprendiendo sobre docker y para un uso casero acabas teniendo "pocas" imágenes.

\[/dropshadowbox\]
