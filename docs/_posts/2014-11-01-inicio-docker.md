---
title: "Mis primeros pasos con Docker"
date: "2014-11-01"
categories: apuntes
tags: docker virtualización contenedores
excerpt_separator: <!--more-->
---

![logo microservices](/assets/img/posts/logo-microservices1.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

Por lo que entendí se trata de una herramienta que permite empaquetar "aplicaciones Linux y todas sus dependencias" en un contenedor virtual (algo así como sandboxes) autocontenido. Eso no nos dice mucho, pero si te digo que puedes ejecutar tus aplicaciones Linux (gracias al daemon Docker) siempre de la misma forma en cualquier plataforma? (por ejemplo Windows o MacOsx poniendo una máquina virtual super ligera, estilo VirtualBox). Eso ya mola más. 

<br clear="left"/>
<!--more-->

## Introducción

Plataformas como Amazon EC, Google Cloud, Rackspace Cloud, etc. ya soportan contenedores Docker, entonces empezará a interesante. De hecho hay más, los contenedores Docker y todo lo que se está desarrollando a su alrededor está acelerando a una velocidad impresionante, no se trata de un Host Hypervisor al estilo ESX, KVM, Hyper-V vinculado al hardware con sus máquinas virtuales, sino que se trata de un virtualizador que ejecuta containers con aplicaciones aisladas autocontenidas en casi cualquier sitio, ofreciendo una flexibilidad y agilidad IT impresionante. Si tienes aplicaciones (linux) piensa que las puedes ejecutar en cualquier sitio, cientos de ellas por servidor, con una escalabiilidad impresionante


Virtualiza el sistema operativo gracias a que usa recursos de *aislamiento* que ofrece el Kernel de Linux y permite ejecutar "contenedores independientes" dentro de una única instancia de Linux. Atención: ni es un hypervisor ni se ejecutan máquinas virtuales. Se apoya por un lado en los **espacios de nombres** del kernel de Linux, que ofrecen una visión aislada del entorno en el que opera la aplicación, incluyendo la lista de procesos, la red, el user ID y los file system montados. Por otro lado los **cgroups** ofrecen una visión aislada de los recursos de CPU, memoria, entrada/salida y Red.

Docker incluye la biblioteca **libcontainer** como una implementación de referencia para los contenedores, su desarrollo está basado en la librería **libvirt**, LXC (contenedores Linux) y systemd-nspawn, que proporcionan interfaces para acceder a las distintas capacidades proporcionadas por el núcleo de Linux.

<br/> 

### Instalación en Linux

Como siempre, esto lo he probado en un Host con Gentoo Linux. Aquí las modificaciones para el kernel: 

```conf
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
```

Añado lo siguiente en /etc/portage/accept_keywords

```conf
# Virtualizador Docker
=app-emulation/docker-1.3.1 ~amd64
```

Instalo el programa

```console
totobo ~ # emerge -v app-emulation/docker
```

Añado al boot, añado mi usuario "luis" para que pueda controlar Docker y lo arranco

```console
totobo ~ # rc-update add docker default
 * service docker added to runlevel default

totobo ~ # usermod -aG docker luis

totobo ~ # /etc/init.d/docker start
 * Caching service dependencies ... [ ok ]
 * /var/log/docker.log: creating file
 * /var/log/docker.log: correcting mode
 * /var/log/docker.log: correcting owner
 * Starting docker daemon ...
```

| **Nota**: Hay algunas cosas que no hice y que de momento no me han afectado. No he activado LVM, durante la instalación de docker se instalan su dependencia LVM y me sugiere que añada lvm al runlevel boot (rc-update add lvm boot) y que habilite "lvmetad" en el `/etc/lvm/lvm.conf` (si quiero lvm autoactivation + metadata caching). Tampoco he instalado ni tengo activo systemd: Docker dice que tiene dependencia con systemd en sus páginas |


<br/>

#### Instalación en MacOSX

**El instalador boot2docker**

- Crea una máquina virtual basada en VirtualBox
- Se guarda en /Users/luis/VirtualBox VMs (ocupa 25MB)

El siguiente paso consiste en ejecutar Boot2Docker desde Finder (Aplicaciones) **para arrancar el daemon**, abre Terminal.app y hace lo siguiente:

```conf
- La primera vez:
    - Crea ~/.boot2docker
    - Copia /usr/local/share/boot2docker/boot2docker.iso a ~/.boot2docker
- Ejecuta:
    - /usr/local/bin/boot2docker init
        - La primera vez crea claves publica/privada
    - /usr/local/bin/boot2docker up
    - $(/usr/local/bin/boot2docker shellinit)
```

<br/>

#### Ejecutar el primer contenedor de pruebas

En ambos equipos he hecho la misma prueba, tanto en Getoo como en el MacOSX (desde la ventana de Terminal.app que me abre).

**Hello-World**

Desde la shell de Gentoo o el Terminal.app ejecuto lo mismo con el mismo resultado

$ docker run hello-world

- El cliente Docker contacta al daemon Docker
- El daemon se baja la imagen "hello world" porque todavía no la teníamos
- El daemon crea un nuevo contenedor desde esta imagen y ejecuta
- El daemon hace un stream de la salida "Hello from Docker." al cliente
- El cliente lo muestra en pantalla (nuestro Terminal.app)


**Ejecutar Ubuntu**

La segunda prueba ha sido más ambiciosa,

```console
$ docker run -it ubuntu bash
```

El resultado es... espectacular, se baja Ubuntu (~200MB) y entra en él, y funciona :)
