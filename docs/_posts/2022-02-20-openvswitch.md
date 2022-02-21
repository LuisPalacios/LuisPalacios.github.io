---
title: "Open vSwitch en Ubuntu Server"
date: "2022-02-20"
categories: administración
tags: linux kvm vlan ovs openvswitch sdn openflow vm qemu virtualización virt-manager libvirt
excerpt_separator: <!--more-->
---

![Logo OVS](/assets/img/posts/logo-ovs.svg){: width="150px" style="float:left; padding-right:25px" } 

Ya era hora de jugar con Open vSwitch (OVS), voy a aprovechar la instalación de mi nuevo servidor System76 con Ubuntu Server, KVM, Máquinas Virtuales y VLAN's para instalar Open vSwitch, un bridge virtual donde haré toda la gestión de las conexiones de red tanto para él como sus máquinas virtuales. Algunas VM's recibirán un interface en modo Trunk (varias VLANs) mientras que la gran mayoría estarán colocadas en una VLAN en particular.

<br clear="left"/>
<!--more-->


## Introducción

[Open vSwitch](https://www.openvswitch.org) (a partir de ahora OVS) es un bridge virtual de código abierto. Orientado a la automatización y a mejorar el switching en entornos de máquinas virtuales. No está de más consultar la [página de OVS en la Wikipedia](https://es.wikipedia.org/wiki/Open_vSwitch), está bastante bien descrito.

- OVS permite trabajar en un único Hypervisor o de forma distribuida en varios. 
- OVS Está considerada como la implementación más popular de [OpenFlow](https://opennetworking.org/sdn-resources/customer-case-studies/openflow/), un controlador/protocolo para manejar cualquier switch hardware (que soporte openflow), donde la red se puede programar por software, independiente de la marca del fabricante. Mi instalación va a ser **standlone**, sin controlador externo (No uso OpenFlow)
- OVS admite interfaces y protocolos de gestión estándar (p. ej. NetFlow, sFlow, IPFIX, RSPAN, CLI, LACP, 802.1ag). 
- Está diseñado para por distribuir el switching a través de múltiples servidores físicos, similar a lo que se hace con `vNetwork distributed vswitch` de VMware o el `Nexus 1000V` de Cisco. 
- Soporta bastantes cosas más, [aquí](https://www.openvswitch.org/features/) tienes la lista completa.

<br/>

#### Componentes

Los principales componentes son:

- **`ovs-vswitchd`**: Es el demonio núcleo de OVS junto con el módulo **`openvswitch_mod.ko`** (para el kernel). Ambos se encargan de la conmutación, VLAN's, bonding, monitorización. El *primer* paquete lo gestiona el daemon en el user-space, pero del *resto* de la conmutación se encarga el módulo del kernel (hablan entre ellos usando `netlink`). 
- **`ovsdb-server`**: Es el segundo al mando, se trata de un servidor de base de datos ligero que para guardar la configuración de OVS (`ovs-vswitchd` habla con él). 


{% include showImagen.html 
      src="/assets/img/posts/2022-02-20-openvswitch-1.jpg" 
      caption="Arquitectura de OVS (standalone)" 
      width="800px"
      %}

<br/>

### Instalación de OVS

sTras la instalación de un Ubuntu Server LTS 20.04 básica añado OVS. 

- Instalo el software
```console
root@maclinux:~# apt update && apt upgrade -y
root@maclinux:~# apt install openvswitch-switch
```
- Ubuntu habilita y arranca el servicio `openvswitch-switch.service` que a su vez arranca los dos daemons antes comentados. 
```console
root@maclinux:~# ps -ef | grep ovs
root         719       1  0 12:23 ?        00:00:00 ovsdb-server /etc/openvswitch/conf.db -vconsole:emer -vsyslog:err -vfile:info --remote=punix:/var/run/openvswitch/db.sock --private-key=db:Open_vSwitch,SSL,private_key --certificate=db:Open_vSwitch,SSL,certificate --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert --no-chdir --log-file=/var/log/openvswitch/ovsdb-server.log --pidfile=/var/run/openvswitch/ovsdb-server.pid --detach
root         772       1  0 12:23 ?        00:00:00 ovs-vswitchd unix:/var/run/openvswitch/db.sock -vconsole:emer -vsyslog:err -vfile:info --mlockall --no-chdir --log-file=/var/log/openvswitch/ovs-vswitchd.log --pidfile=/var/run/openvswitch/ovs-vswitchd.pid --detach
```

<br/>

#### Configuracion básica

Veamos la configuración desde la línea de comandos paso a paso. 

| Nota: Aunque todos estos pasos son reversibles, ten en cuenta que los comandos que introduzcamos con `ovs-vsctl` **son persistentes** (recuerda la base de datos que vimos antes), es decir, en el siguiente reboot se configurarán. Avisaré de su implicación. |

- Recapitulamos, tenemos un Ubuntu Server (sin KVM instalado) con una NIC (`enp2s0f0`), que recibe su IP (`192.168.100.33`) y ruta por defecto vía DHCP.
```console
root@maclinux:~# ip addr show enp2s0f0
2: enp2s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 3c:07:54:59:aa:cb brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.33/24 brd 192.168.100.255 scope global dynamic enp2s0f0
root@maclinux:~# ip route
default via 192.168.100.1 dev enp2s0f0 proto dhcp src 192.168.100.33 metric 100
192.168.100.0/24 dev enp2s0f0 proto kernel scope link src 192.168.100.33
192.168.100.1 dev enp2s0f0 proto dhcp scope link src 192.168.100.33 metric 100
```
- Creo un bridge de Open vSwitch
```console
root@maclinux:~# ovs-vsctl add-br sol
root@maclinux:~# ovs-vsctl show
83506d0f-e81b-4d47-be11-e25821d08d9a
    Bridge solbr
        Port solbr
            Interface solbr
                type: internal
    ovs_version: "2.13.3"
root@maclinux:~# ip link show dev solbr
8: solbr: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 9e:5f:90:fe:6a:42 brd ff:ff:ff:ff:ff:ff
```
- Activo el bridge
```console
root@maclinux:~# ip link set solbr up
root@maclinux:~# ip link show dev solbr
8: solbr: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 9e:5f:90:fe:6a:42 brd ff:ff:ff:ff:ff:ff
```

| Nota: **CUIDADO CON LO SIGUIENTE; SI ESTÁS CONECTADO VÍA SSH PERDERÁS LA CONEXIÓN**. Ahora mismo tienes conectada tu tarjeta física `enp2s0f0` al STACK IP. Al moverla a `solbr` rompes la conexión con el Stack IP, la solución es ejecutar los siguientes tres comandos desde la consola o hacerte un script para ejecutarlos uno tras otro a toda velocidad, SSH se reconectará si todo va bien... |

- Conecto la `enp2s0f0` al bridge, le quito su IP y ejecuto `dhclient` para el interfaz `mibridge`. Lo que provoca es que conectemos el Stack IP con `mibridge` que a su vez está conectado con la `enp2s0f0`. 
```console
root@maclinux:~# ovs-vsctl add-port solbr enp2s0f0
root@maclinux:~# ip addr del 192.168.100.33/24 dev enp2s0f0
root@maclinux:~# dhclient solbr
```
- AVISO PERSISTENCIA: El comando `ovs-vsctl add-port` ha cambiado la base de datos, por lo tanto en el siguiente `reboot` se volverá a ejecutar. **Debemos cambiar la configuración de [netplan](https://netplan.io) para adaptarla a los cambios** (por si nos da por hacer un reboot...)
```console
root@maclinux:~# cat /etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  ethernets:
    enp2s0f0:         # Líneas nuevas para declarar ambas,
      dhcp4: no       # enp2s0f0 y solbr (se pongan en UP)
    solbr:            # y que se solicite una dirección IP
      dhcp4: true     # vía DHCP por mibridge
  version: 2
```
- Veamos cómo tenemos la configuración del bridge
```console
root@maclinux:~# ovs-vsctl show
83506d0f-e81b-4d47-be11-e25821d08d9a
    Bridge solbr
        Port enp2s0f0
            Interface enp2s0f0
        Port solbr
            Interface solbr
                type: internal
    ovs_version: "2.13.3"
```

<br/>

## VLAN's, KVM y OVS

Como decía la principio, necesito configurar todo de forma que algunas VM's puedan recibir en su(s) interfac(s) las VLAN's en modo **Trunk** mientras que otras VM's recibirán una VLAN en particular en modo **Acceso**.

<br/>

#### Configuración de VLAN's

Tendremos que configurar lo siguiente: 

- En mi Servidor tengo que **configurar OVS/KVM para que presenten puertos trunk (con tags VLAN) y  puertos normales de acceso a una determinada VLAN**.
- Guests (VM) que esperan un puerto Trunk: Configurar el soporte de VLAN's 
- Guests (VM) que esperan un puerto Acceso: Configuración normal de red. 

{% include showImagen.html 
      src="/assets/img/posts/2022-02-20-openvswitch-2.jpg" 
      caption="Diferentes tipos de interfaces en Linux" 
      width="500px"
      %}

<br/>
-  Verifico que tengo soporte de VLAN's en mi servidor... 
```console
root@maclinux:~# apt list vlan
:
root@maclinux:~# apt install vlan
```
- **Conecto el servidor a un puerto Físico en modo TRUNK del Switch donde recibo varias VLAN's: 2, 3, 6, 100**. 
- Adapto mi fichero [netplan](https://netplan.io) por completo
  - Cambio el nombre de mi NIC a `eth0` 
  - Configuro la `VLAN100` para poder seguir trabajando.
  - Mantego el bridge `solbr` activo pero sin dirección

```console
root@maclinux:~# cat /etc/netplan/00-installer-config.yaml

# Config LuisPa

network:

  version: 2

  ethernets:

    # Interfaz principal
    eth0:
      # Buscar mac,original,nuevo para no errar en futuros matchs
      match:
        macaddress: "3c:07:54:59:aa:cb"
        name: enp2s0f0
        name: eth0
      set-name: eth0
        #addresses: [ "192.168.100.33/24" ]
        #nameservers:
        #  addresses: [ "192.168.100.224" ]
        #  search: [ parchis.org ]
        #routes:
        #  - to: default
        #    via: 192.168.100.1
      dhcp4: no

    # Bridge principal OVS de este servidor
    # 'sol': nombre servidor. 'br': bridge
    solbr:
      dhcp4: no


  vlans:

    # VLAN Principal
    vlan100:
      id: 100
      link: eth0
      addresses: [192.168.100.33/24]
      gateway4: 192.168.100.1
      nameservers:
        addresses: [192.168.100.224]
        search: [parchis.org]

```

- Aplico la nueva configuración
```console
root@maclinux:~# netplan apply
```

<br/>
#### Configuración de OVS






<br/>

#### Instalo KVM

- Instalo `KVM/QEMU` y `virt-manager`. La instalación es relativamente sencilla, al princpio del apunte sobre [Vagrant con Libvirt KVM]({% post_url 2021-05-15-vagrant-kvm %}) explico cómo hacerlo.
```console
root@maclinux:~# apt install qemu qemu-kvm libvirt-clients \
                   libvirt-daemon-system virtinst
root@maclinux:~# apt install virt-manager
```

| Nota: No instalo las `bridge-utils`, utilidades para configurar el Bridge Ethernet en Linux porque no las necesitamos, vamos a usar OVS |

- Añado mi usuario al grupo `libvirt` y `kvm`... Y HAGO REBOOT (importante, para que luego nos funcione `qemu-system-x86_64`)
```console
root@maclinux:~# adduser luis libvirt
root@maclinux:~# adduser luis kvm
```
- Como usuario `luis` me bajo Alpine Linux, en la sección de [Downloads](https://alpinelinux.org/downloads/) > VIRTUAL > *Slimmed down kernel. Optimized for virtual systems*, me bajo la ISO para x86_64 (**solo 52MB**), es la versión más compacta posible.
```console
luis@maclinux:~$ wget https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-virt-3.15.0-x86_64.iso
luis@maclinux:~$ wget https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-virt-3.15.0-x86_64.iso.sha256
luis@maclinux:~$ sha256sum -c alpine-virt-3.15.0-x86_64.iso.sha256
alpine-virt-3.15.0-x86_64.iso: OK
luis@maclinux:~$ ls -hl alpine-virt-3.15.0-x86_64.iso
-rw-rw-r-- 1 luis luis 52M nov 24 09:23 alpine-virt-3.15.0-x86_64.iso
```

<br/>


#### Puertos virtuales compatibles con KVM

Hay dos formas de configurar el acceso de KVM a los puertos de red (virtuales) del Host. 

1. Opción simple, utilizando el BRIDGE de Linux tradicional. Para una configuración simple de KVM bastaría con definir un bridge Linux en el host. De hecho, en mi caso, con un host standalone con unas pocas VLAN's sería más que suficiente quedarme en esta opción, pero voy a documentar cómo hacerlo con OVS.

- Desahabilito el arranque del bridge que trae KVM por defecto
```console
# virsh net-autostart --disable default
```
- Para habilitarlo basta con ejecutar `# virsh net-autostart default`

1. Opción OVS, que veremos aquí. Importante, **ojo con la configuración TAP + OVS + KVM**. Open vSwitch trata a los dispositivos "tap" como si fuesen cualquier otro tipo de dispositivo, es decir, no los abre como `tap sockets` (modo correcto) sino como `un interfaz normal`. Eso supone incompatibilidades y problemas. Lee la respuesta a *Q: I created a tap device tap0, configured an IP address on it, and added it to a bridge, like this:* en los [Common Configuration Issues de OVS](https://docs.openvswitch.org/en/latest/faq/issues/).

| Nota: Dejo aquí información sobre las interfaces **TUN** / **TAP** a modo de referencia, pero en esta primera fase no los vamos a usar. Son dispositivos virtuales de red que residen en el Kernel. TUN opera en nivel 3 (routing) y **TAP en nivel 2 (bridges/switching)**. Es como cualquier otra interfaz, tendrán sus direcciones, conmutarán tráfico, etc; la diferencia es que se hará todo en *memoria* usando sockets, en el *espacio de usuario*, no en la red física. |

{% include showImagen.html 
      src="/assets/img/posts/2022-02-20-openvswitch-3.svg" 
      caption="Diferentes tipos de interfaces en Linux" 
      width="800px"
      %}

<br/>

- Como decía, no usamos TUN ni TAP. **Vamos a usar puertos virtuales INTERNO presentado por Open vSwitch** que conectamos a `mibridge` para que lo utilicen mis VM's
- Damos de alta un par de puertos, sin dirección IP, dado que el Host no necesita, ya se la asignaremos en la VM. 
```console
root@maclinux:~# ovs-vsctl add-port mibridge interno1 -- set Interface interno1 type=internal
root@maclinux:~# ovs-vsctl add-port mibridge interno2 -- set Interface interno2 type=internal
root@maclinux:~# ovs-vsctl show
83506d0f-e81b-4d47-be11-e25821d08d9a
    Bridge mibridge
        Port eth0
            Interface eth0
        Port int1
            Interface interno1
                type: internal
        Port mibridge
            Interface mibridge
                type: internal
    ovs_version: "2.13.3"
root@maclinux:~# ip link set interno1 up
root@maclinux:~# ip link set interno2 up
root@maclinux:~# ip link show
:
17: interno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 66:dc:3d:12:9f:26 brd ff:ff:ff:ff:ff:ff
18: interno2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 82:0d:b7:ab:dc:87 brd ff:ff:ff:ff:ff:ff
```

#### Crear una VM con Alpine Linux desde `virt-manager`
 
- Creo una VM con 768MB de RAM, 1 CPU, disco de 1GB. Imagen: `alpine-virt-3.15.0-x86_64.iso`. Nombre `alpine1`. Selección de Red virtual: `interno1: macvtap`.
```console
luis@maclinux:~$ virt-manager
```

{% include showImagen.html 
      src="/assets/img/posts/2022-02-20-openvswitch-4.png" 
      caption="Creo VM desde virt-manager" 
      width="450px"
      %}


- Sigo [esta guía](https://wiki.alpinelinux.org/wiki/QEMU). 
```console
localhost login: root
:
# setup-alpine
```
-  Sigo los pasos de instalación y selecciono DHCP para mi interfaz eth0. Nombre del equipo `alpine1`, Disco `sda`, modalidad `sys`, el resto por defecto.
- Al terminar rearranco
```console
# poweroff. 
```
- Cuando rearranca, hago login como root y pruebo el ping... 

{% include showImagen.html 
      src="/assets/img/posts/2022-02-20-openvswitch-5.png" 
      caption="La primera VM funciona correctamente" 
      width="450px"
      %}


#### Crear una VM con Alpine Linux desde el CLI
 
- Lo primero que hago es eliminar el puerto virtual `interno2`, porque vamos a usar un script para crearlo bajo demanda. 
```console
root@maclinux:~# ip link set interno2 down
root@maclinux:~# ovs-vsctl del-port mibridge interno2 
```
- Creo un par de scripts
```
root@maclinux:~# ip link set interno2 down
root@maclinux:~# ovs-vsctl del-port mibridge interno2 
```
root@maclinux:~# cat /etc/ovs-ifup
#!/bin/sh

switch='mibridge'
ip link set $1 up
ovs-vsctl add-port ${switch} $1 -- set Interface interno2 type=internal

root@maclinux:~# cat /etc/ovs-ifdown
#!/bin/sh

switch='mibridge'
ip addr flush dev $1
ip link set $1 down
ovs-vsctl del-port ${switch} $1
```

- Creo una VM con 768MB de RAM, 1 CPU, disco de 1GB. Imagen: `alpine-virt-3.15.0-x86_64.iso`. Nombre `alpine1`. Selección de Red virtual: `interno1: macvtap`.
```console
luis@maclinux:~$ virt-manager
```
- Arranco una VM con dicho ISO desde la línea de comandos. 
```console
luis@maclinux:~$ qemu-img create -f qcow2 alpine2.qcow2 1G
Formatting 'alpine2.qcow2', fmt=qcow2 size=1073741824 cluster_size=65536 lazy_refcounts=off refcount_bits=16
luis@maclinux:~$ qemu-system-x86_64 -enable-kvm -m 512 -nic user \
                   -net tap,ifname=interno2,script=/etc/ovs-ifup,downscript=/etc/ovs-ifdown \
                   -boot d -cdrom alpine-virt-3.15.0-x86_64.iso \
                   -hda alpine2.qcow2
```
- Después de terminar la instalación
```console
$ qemu-system-x86_64 -m 512 -nic user -hda alpine2.qcow2
```

<br/>

qemu-system-x86_64 -enable-kvm -m 512 -nic user \
                   -netdev id=alpine3,type=tap,ifname=luispa4,script=/etc/ovs-ifup,downscript=/etc/ovs-ifdown \
                   -boot d -cdrom /home/luis/alpine-virt-3.15.0-x86_64.iso \
                   -hda alpine3.qcow2

qemu-system-x86_64 -enable-kvm -m 512 -nic user \
                   -netdev id=alpine3,type=tap,ifname=luispa4,script=no \
                   -boot d -cdrom /home/luis/alpine-virt-3.15.0-x86_64.iso \
                   -hda alpine3.qcow2

kvm -m 512 -net nic,macaddr=00:11:22:EE:EE:EE -net \
    tap,script=/etc/ovs-ifup,downscript=/etc/ovs-ifdown -drive \
    file=/path/to/disk-image,boot=on

kvm -m 512 -net nic,macaddr=00:11:22:EE:EE:EE \
-net tap,script=/etc/ovs-ifup,downscript=/etc/ovs-ifdown \
-boot d -cdrom /home/luis/alpine-virt-3.15.0-x86_64.iso \
-hda alpine3.qcow2




kvm -m 512 -nic user \
-net tap,ifname=luistap0,script=/etc/ovs-ifup,downscript=/etc/ovs-ifdown \
-boot d -cdrom /home/luis/alpine-virt-3.15.0-x86_64.iso \
-hda alpine3.qcow2

