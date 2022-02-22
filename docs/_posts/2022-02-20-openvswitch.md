---
title: "Linux, Open vSwitch y KVM"
date: "2022-02-20"
categories: administración
tags: linux kvm vlan ovs openvswitch sdn openflow vm qemu virtualización virt-manager libvirt
excerpt_separator: <!--more-->
---

![Logo OVS](/assets/img/posts/logo-ovs.svg){: width="150px" style="float:left; padding-right:25px" } 

Ya era hora de jugar con Open vSwitch (OVS), voy a aprovechar que instalo en breve un nuevo Servidor con Ubuntu Server, KVM, Máquinas Virtuales y VLAN's para montarlo todo con Open vSwitch en vez del Bridge de Linux tradicional. 

OVS es un bridge virtual desde donde haré toda la gestión de las conexiones de red tanto para el propio servidor como sus máquinas virtuales. Algunas VM's recibirán un interface en modo Trunk mientras que la gran mayoría se conectarán en modo Acceso a una VLAN en particular.

<br clear="left"/>
<!--more-->


## Introducción

[Open vSwitch](https://www.openvswitch.org) (OVS) es un bridge virtual de código abierto. Orientado a la automatización y a mejorar el switching en entornos de máquinas virtuales. Date un paseo por la [página de OVS en la Wikipedia](https://es.wikipedia.org/wiki/Open_vSwitch), para una introducción. 

- Permite trabajar en un único Hypervisor o de forma distribuida en varios. 
- Está considerada como la implementación más popular de [OpenFlow](https://opennetworking.org/sdn-resources/customer-case-studies/openflow/), un controlador/protocolo para manejar switches hardware (que soporten openflow), donde la red se puede programar por software, independiente de la marca del fabricante. Mi instalación va a ser **standlone**, sin controlador externo (no uso OpenFlow)
- Admite interfaces y protocolos de gestión estándar (p. ej. NetFlow, sFlow, IPFIX, RSPAN, CLI, LACP, 802.1ag). 
- Está diseñado para poder distribuir el switching a través de múltiples servidores físicos, similar a lo que se hace con `vNetwork distributed vswitch` de VMware o el `Nexus 1000V` de Cisco. 
- Soporta bastantes cosas más, [aquí](https://www.openvswitch.org/features/) tienes la lista completa.


Voy a hacer mención a un tema interesante. En linux tenemos las interfaces **TUN** / **TAP**. Son dispositivos virtuales de red que residen en el Kernel. TUN opera en nivel 3 (routing) y **TAP en nivel 2 (bridges/switching)**. Son como cualquier otra interfaz, con sus direcciones, conmutación de tráfico, etc; la diferencia es que se hará todo en *memoria* usando sockets, en el *espacio de usuario*, no en la red física. Tradicionalmente se han usado siempre junto con el Bridge de Linux y con KVM/QEMU, pero... NO LOS VAMOS A USAR con Open vSwitch.

Open vSwitch trata a los dispositivos `TAP` como si fuesen cualquier otro tipo de dispositivo, es decir, no los abre con `sockets` (modo estándar) sino como `un interfaz normal`. Eso supone ciertos problemas; para entender más las implicaciones te recomiendo leer *Q: I created a tap device tap0, configured an IP address on it, and added it to a bridge, like this:* en los [Common Configuration Issues de OVS](https://docs.openvswitch.org/en/latest/faq/issues/).

Me adelanto, en Open vSwitch vamos a utilizar `Internal Ports` en vez de interfaces `TAP` y ojo con las decenas de documentos y enlaces que hay en internet documentados con `tap`, pueden llevarte a confusión. Para el caso de KVM/QEMU que vemos aquí solo voy a usar `Internal Ports`. 

<br/>

#### Componentes

Los principales componentes son:

- **`ovs-vswitchd`**: Es el demonio (núcleo) de OVS junto con el módulo **`openvswitch_mod.ko`** (para el kernel). Ambos se encargan de la conmutación, VLAN's, bonding, monitorización. El *primer* paquete lo gestiona el daemon en el user-space, pero del *resto* de la conmutación se encarga el módulo del kernel (hablan entre ellos usando `netlink`). 
- **`ovsdb-server`**: Es el segundo al mando, se trata de un servidor de base de datos ligero que para guardar la configuración de OVS (`ovs-vswitchd` habla con él). 


{% include showImagen.html 
      src="/assets/img/posts/2022-02-20-openvswitch-1.jpg" 
      caption="Arquitectura de OVS (standalone)" 
      width="800px"
      %}

<br/>

## Instalación de OVS

Tras la instalación de un Ubuntu Server LTS 20.04, 

- Instalo OVS
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

## Networking en el Servidor

### Añadir el Bridge OVS

Los comandos que introduzcamos con `ovs-vsctl` **son persistentes** (recuerda la base de datos), en el siguiente reboot se volverán a activar. 

| Nota: **CUIDADO QUEDARSE SIN CONEXIÓN SI SE USA SSH**. Ahora mismo la tarjeta física `enp2s0f0` está conectada al Stack IP, pero si la renombro, muevo al bridge, cambio a VLAN's etc. rompería la conexión. Importante tener acceso a la consola. |

- Creo un bridge llamado `solbr`
```console
root@maclinux:~# ovs-vsctl add-br solbr
root@maclinux:~# ip link set solbr up
root@maclinux:~# ovs-vsctl show
83506d0f-e81b-4d47-be11-e25821d08d9a
    Bridge solbr
        Port solbr
            Interface solbr
                type: internal
    ovs_version: "2.13.3"
root@maclinux:~# ip link show dev solbr
8: solbr: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 9e:5f:90:fe:6a:42 brd ff:ff:ff:ff:ff:ff
```

<br/>

### Configuración estática

A continuación voy a configurar varias opciones **muy estáticas**, para que los ejemplos se vean claros. Más adelante en este mismo apunto veremos como hacerlo **un poco más dinámico** apoyándonos en la integración entre Libvirt (de QEMU) y Open vSwitch. 

De entrad, empezamos con estas opciones que quiero configurar en mi equipo: 

- Que el servidor reciba `eth0` en modo Trunk
- Probar que el servidor reciba `vlan100` en modo Acceso *directamente conectado a su Stack TCP/IP* y por supuesto asignarle una IP, aunque luego no lo usaré.
- Que el servidor instancie varias interfaces virtuales `vnetNNN` *a través del switch OVS* que puedan ser consumidas localmente por el propio servidor o por las VM's en modo Acceso. 
  - Las que llamo `vnet192` y `vnet500` serán usadas por el servidor con su propia IP. 
- Que los Guest's (VM's) se conecten a una de esas intefaces virtuales (una VLAN)
- Que los Guest's (VM's) puedan recibir un puerto Trunk con una o más VLAN's.

No olvides ir aplicando los cambios si vas haciendo pruebas con `netplan apply`


{% include showImagen.html 
      src="/assets/img/posts/2022-02-20-openvswitch-2.jpg" 
      caption="Diferentes tipos de interfaces en Linux" 
      width="500px"
      %}

Más adelante en este mismo apunte verás la configuración completa de `/etc/netplan/00-installer-config.yaml` y los comandos que usé para configura OVS (`ovs-vsctl`)

<br/>

#### Que el servidor reciba `eth0` en modo Trunk

- Añado el puerto `eth0` al bridge `solbr` como un puerto Trunk. No hace falta hacer nada especial, siempre se añaden los puertos físicos en modo Trunk por defecto
```console
root@maclinux:~# ovs-vsctl add-br solbr
root@maclinux:~# ovs-vsctl add-port solbr eth0
```
- Sección `eth0` de `/etc/netplan/00-installer-config.yaml`
```console
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
      dhcp4: no
:
```
- Aplico la nueva configuración
```console
root@maclinux:~# netplan apply
```

<br/>

#### Probar que el servidor reciba la `VLAN100` directamente

Si quiero quiero conectar el stack TCP/IP del Servidor directamente a la VLAN100. 

- Revisa y si no está, instala el soporte de VLAN's con `apt list vlan` y `apt install vlan`
- Sección `vlan100` de `/etc/netplan/00-installer-config.yaml`
```console
network:
  version: 2
  ethernets:
  :
  vlans:
    # Acceso directo a VLAN100 desde este Servidor
    # Además de crear el Internal Port para la vlan100 creo este
    # por si acaso... y así tengo acceso directo desde el Stack IP
    host100:
      id: 100
      link: eth0
      addresses: [192.168.100.33/24]
      gateway4: 192.168.100.1
      nameservers:
        addresses: [192.168.100.224]
        search: [parchis.org]
:
```

| Nota: Al final no he optado por esta opción. Necesito compartir mi acceso a la VLAN100 con las máquinas virtuales, he preferido dejar solo la `vnet100` a continuación... | 

<br/>

#### Que el servidor instancie varias interfaces virtuales `vnetNNN` vía OVS

- Quiero que el servidor instancie varias interfaces virtuales `vnetNNN` *a través del switch OVS* que puedan ser consumidas localmente por el propio servidor o por las VM's en modo Acceso. Tres de ellas, `vnet100`, `vnet192` y `vnet500`, serán usadas por el servidor con sus propias IPs. Recordatorio: en contra de lo que parecería normal no debo usar puertos **TAP** sino que es obligatorio usar puertos de tipo **Internal Port**'s configurados como puertos de acceso, se comportan exactamente igual a puertos virtuales TAP.
- Creo los puertos y los conecto al bridge. 
```console
root@maclinux:~# ovs-vsctl add-port solbr vnet006 tag=006 -- set Interface vnet006 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet100 tag=100 -- set Interface vnet100 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet192 tag=192 -- set Interface vnet192 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet221 tag=221 -- set Interface vnet221 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet300 tag=300 -- set Interface vnet300 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet400 tag=400 -- set Interface vnet400 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet500 tag=500 -- set Interface vnet500 type=internal
```

<br/>

#### Resumen de configuración de Netplan y lista completa de comandos ovs-vsctl

- Fichero [Netplan](https://netplan.io) completo:

```console
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
      dhcp4: no

    # Bridge principal OVS de este servidor
    # 'sol': nombre servidor. 'br': bridge
    solbr:
      dhcp4: no

    # Puertos `Internal` para Acceso a VLAN's, consumibles localmente o por VM's
    # Creados con:
    #  ovs-vsctl add-port solbr vlanNNN tag=NNN -- set Interface vlanNNN type=internal
    # Configuro todos para que se activen (UP) incluso los que no tienen IP.
    vnet006:
      dhcp4: no
    vnet100:
      addresses: [192.168.100.33/24]
      gateway4: 192.168.100.1
      nameservers:
        addresses: [192.168.100.224]
        search: [parchis.org]
    vnet192:
      addresses: [192.168.1.3/24]
    vnet221:
      dhcp4: no
    vnet300:
      dhcp4: no
    vnet400:
      dhcp4: no
    vnet500:
      addresses: [192.168.101.3/24]

#  vlans:
#
#    # Acceso directo a VLAN100 desde este Servidor
#    # Estoy utilizando la opción vnet100, pero dejo documentado
#    # cómo se haría mediante acceso directo desde el Stack IP
#    host100:
#      id: 100
#      link: eth0
#      addresses: [192.168.100.33/24]
#      gateway4: 192.168.100.1
#      nameservers:
#        addresses: [192.168.100.224]
#        search: [parchis.org]
#
```


- Comandos `ovs-vsctl`: 

```console
root@maclinux:~# ovs-vsctl add-br solbr
root@maclinux:~# ovs-vsctl show
root@maclinux:~# ovs-vsctl add-port solbr eth0
root@maclinux:~# ovs-vsctl add-port solbr vlan192 tag=192 -- set Interface vlan192 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vlan500 tag=500 -- set Interface vlan500 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet006 tag=006 -- set Interface vnet006 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet100 tag=100 -- set Interface vnet100 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet192 tag=192 -- set Interface vnet192 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet221 tag=221 -- set Interface vnet221 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet300 tag=300 -- set Interface vnet300 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet400 tag=400 -- set Interface vnet400 type=internal
root@maclinux:~# ovs-vsctl add-port solbr vnet500 tag=500 -- set Interface vnet500 type=internal
```

- Puertos

```console
root@maclinux:~# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master ovs-system state UP mode DEFAULT group default qlen 1000
    link/ether 3c:07:54:59:aa:cb brd ff:ff:ff:ff:ff:ff
3: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether c2:f0:e9:97:37:0d brd ff:ff:ff:ff:ff:ff
4: vnet100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 5e:55:9f:41:64:06 brd ff:ff:ff:ff:ff:ff
5: vnet221: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 92:f9:ca:3f:35:e3 brd ff:ff:ff:ff:ff:ff
6: vnet500: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether ee:c6:17:b8:5c:6e brd ff:ff:ff:ff:ff:ff
7: vnet192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether b6:9b:94:2e:7b:82 brd ff:ff:ff:ff:ff:ff
8: vnet300: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether ae:aa:8c:07:9a:53 brd ff:ff:ff:ff:ff:ff
9: vnet006: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether ca:f3:c8:15:0a:a8 brd ff:ff:ff:ff:ff:ff
10: vnet400: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 76:0c:7d:c8:46:53 brd ff:ff:ff:ff:ff:ff
11: solbr: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether 3c:07:54:59:aa:cb brd ff:ff:ff:ff:ff:ff
12: macvtap0@vnet100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 500
    link/ether 52:54:00:b8:d4:f0 brd ff:ff:ff:ff:ff:ff
13: macvtap1@vnet192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 500
    link/ether 52:54:00:e1:ff:22 brd ff:ff:ff:ff:ff:ff
```

- Bridge OVS

```console
root@maclinux:~# ovs-vsctl show
83506d0f-e81b-4d47-be11-e25821d08d9a
    Bridge solbr
        Port vnet100
            tag: 100
            Interface vnet100
                type: internal
        Port solbr
            Interface solbr
                type: internal
        Port eth0
            Interface eth0
        Port vnet192
            tag: 192
            Interface vnet192
                type: internal
        Port vnet300
            tag: 300
            Interface vnet300
                type: internal
        Port vnet400
            tag: 400
            Interface vnet400
                type: internal
        Port vnet500
            tag: 500
            Interface vnet500
                type: internal
        Port vnet006
            tag: 6
            Interface vnet006
                type: internal
        Port vnet221
            tag: 221
            Interface vnet221
                type: internal
    ovs_version: "2.13.3"
```

<br/>

## Añadimos KVM/QEMU

- Instalo `KVM/QEMU` y `virt-manager`. La instalación es relativamente sencilla, al principio del apunte sobre [Vagrant con Libvirt KVM]({% post_url 2021-05-15-vagrant-kvm %}) explico cómo hacerlo.
```console
root@maclinux:~# apt install qemu qemu-kvm libvirt-clients \
                   libvirt-daemon-system virtinst
root@maclinux:~# apt install virt-manager
```

| Nota: No instalo las `bridge-utils`, utilidades para configurar el Bridge Ethernet en Linux porque no las necesitamos, vamos a usar OVS |

- Añado mi usuario al grupo `libvirt` y `kvm`... y `reboot` para que luego funcione `qemu-system-x86_64`)
```console
root@maclinux:~# adduser luis libvirt
root@maclinux:~# adduser luis kvm
root@maclinux:~# systemctl reboot -f
```
- **Desahabilito el arranque del bridge que trae KVM por defecto**. En este apunte vemos cómo configurara todo con el Open vSwitch, así que no necesto el Bridge de Linux tradicional. Nota, para habilitarlo de nuevo basta con ejecutar `# virsh net-autostart default`
```console
root@maclinux:~# virsh net-autostart --disable default
```
- Descargo **Alpine Linux** para las pruebas. En la sección de [Downloads](https://alpinelinux.org/downloads/) > VIRTUAL > *Slimmed down kernel. Optimized for virtual systems*, me bajo la ISO para x86_64 (**solo 52MB**), es la versión más compacta posible y la usaré para .
```console
luis@maclinux:~$ wget https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-virt-3.15.0-x86_64.iso
luis@maclinux:~$ wget https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-virt-3.15.0-x86_64.iso.sha256
luis@maclinux:~$ sha256sum -c alpine-virt-3.15.0-x86_64.iso.sha256
alpine-virt-3.15.0-x86_64.iso: OK
luis@maclinux:~$ ls -hl alpine-virt-3.15.0-x86_64.iso
-rw-rw-r-- 1 luis luis 52M nov 24 09:23 alpine-virt-3.15.0-x86_64.iso
```
- Creo una *pequeña VM de pruebas* con Alpine Linux desde `virt-manager`: 768MB de RAM, 1 CPU, disco de 1GB, usando la imagen: `alpine-virt-3.15.0-x86_64.iso`, la llamo `alpine1` y en la Red virtual uso la `interno1: macvtap`.
```console
luis@maclinux:~$ virt-manager
```

{% include showImagen.html 
      src="/assets/img/posts/2022-02-20-openvswitch-4.png" 
      caption="Creo VM desde virt-manager" 
      width="450px"
      %}


- EJecuto el setup de Alpine (más info en [esta guía](https://wiki.alpinelinux.org/wiki/QEMU)). 
```console
localhost login: root
:
# setup-alpine
```
-  Selecciono DHCP para mi interfaz eth0. Nombre del equipo `alpine1`, Disco `sda`, modalidad `sys`, el resto por defecto.
- Al terminar rearranco
```console
# poweroff. 
```
- Cuando rearranca, hago login como root y pruebo el ping e instalo `iproute2` que me vendrá bien para hacer pruebas
```console
# apk add iproute2
```

{% include showImagen.html 
      src="/assets/img/posts/2022-02-20-openvswitch-5.png" 
      caption="La primera VM funciona correctamente" 
      width="450px"
      %}

{% include showImagen.html 
      src="/assets/img/posts/2022-02-20-openvswitch-6.jpg" 
      caption="Algunos detalles sobre las opciones de Red" 
      width="800px"
      %}

- Arriba algunos detalles, entre ellos el driver preferido para la red es `virtio`
  

<br/>

### Configuración dinámica

Ahora vamos a aprovechar las ventajas de la integración entre Libvirt y Open vSwitch. 

#### Integración de Open vSwitch con Libvirt

Open vSwitch soporta las redes que gestiona `libvirt` en modo `bridged` (no las NAT), más información [aquí](https://docs.openvswitch.org/en/latest/howto/libvirt/).

- Voy a crear una plantilla de red en Libvirt. Creo el fichero `/etc/libvirt/qemu/Networks/solbr.xml` 

```xml
<!--
WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
OVERWRITTEN AND LOST. Changes to this xml configuration should be made using:
  virsh net-edit net-solbr
or other application using the libvirt API.
-->

<network>
  <name>net-solbr</name>
  <uuid>fcaa986c-f900-4448-b897-d75556e59784</uuid>
  <forward mode='bridge'/>
  <bridge name='solbr'/>
  <virtualport type='openvswitch'/>
  <portgroup name='Sin vlan'>
  </portgroup>
  <portgroup name='Trunk Core'>
    <vlan trunk='yes'>
      <tag id='6'/>
      <tag id='100'/>
      <tag id='192'/>
      <tag id='221'/>
      <tag id='300'/>
      <tag id='400'/>
      <tag id='500'/>
    </vlan>
  </portgroup>
  <portgroup name='Vlan 6'>
    <vlan>
      <tag id='6'/>
    </vlan>
  </portgroup>
  <portgroup name='Vlan 100' default='yes'>
    <vlan>
      <tag id='100'/>
    </vlan>
  </portgroup>
  <portgroup name='Vlan 192'>
    <vlan>
      <tag id='192'/>
    </vlan>
  </portgroup>
  <portgroup name='Vlan 221'>
    <vlan>
      <tag id='221'/>
    </vlan>
  </portgroup>
  <portgroup name='Vlan 300'>
    <vlan>
      <tag id='300'/>
    </vlan>
  </portgroup>
  <portgroup name='Vlan 400'>
    <vlan>
      <tag id='400'/>
    </vlan>
  </portgroup>
  <portgroup name='Vlan 500'>
    <vlan>
      <tag id='500'/>
    </vlan>
  </portgroup>
</network>
```

- Lo activo desde Libvirt 
  
```console
root@maclinux:~# virsh net-define /etc/libvirt/qemu/networks/net-solbr.xml
Network net-solbr defined from /etc/libvirt/qemu/networks/net-solbr.xml

root@maclinux:~# virsh net-start net-solbr
Network net-solbr started

root@maclinux:~# virsh net-autostart net-solbr
Network net-solbr marked as autostarted

root@maclinux:~# virsh net-list
 Name        State    Autostart   Persistent
----------------------------------------------
 net-solbr   active   yes         yes
```

- Desde mis VM's veré las nuevas opciones cuando seleccione la Red

{% include showImagen.html 
      src="/assets/img/posts/2022-02-20-openvswitch-7.png" 
      caption="Tendré una nueva opción para mi bridge en OVS" 
      width="500px"
      %}

- Lo mejor está por llegar. Una vez que arranque la VM se va a crear dinámicamente un nuevo interfaz llamado vnetN con la configuración que establecí en el XML. En este ejemplo hemos seleccionado el llamado VLAN100, que en el XML tiene `tag id='100'`, por lo tanto **nos creará un virtual port interno** con el `tag: 100`.

{% include showImagen.html 
      src="/assets/img/posts/2022-02-20-openvswitch-8.png" 
      caption="Automáticamente se crea el vnet0 (en verde)" 
      width="300px"
      %}
      
- En la imagen anterior he marcado las interfaces virtuales activas, tras arrancar la VM. 
  - vnet0 en verde: Esta interfaz es dinámica y está perfectamente asociada a la VLAN100 de OVS. Cuando la VM se apague la interfaz desaparecerá.
  - En naranja: Son interfaces estáticas que quiero mantener, porque necesito que el HOST tenga su propia IP en ellas, así que las dejaré. 
  - En rojo: Son interfaces estáticas que YA NO NECESITO porque solo las voy a usar con Libvirt, así que las borro, tanto de OVS como de Netplan
- Elimino los puertos estáticos
 
```console
root@maclinux:~# ovs-vsctl del-port solbr vnet300
root@maclinux:~# ovs-vsctl del-port solbr vnet400
root@maclinux:~# ovs-vsctl del-port solbr vnet221
root@maclinux:~# ovs-vsctl del-port solbr vnet006
root@maclinux:~# ovs-vsctl show
83506d0f-e81b-4d47-be11-e25821d08d9a
    Bridge solbr
        Port vnet100
            tag: 100
            Interface vnet100
                type: internal
        Port solbr
            Interface solbr
                type: internal
        Port eth0
            Interface eth0
        Port vnet192
            tag: 192
            Interface vnet192
                type: internal
        Port vnet500
            tag: 500
            Interface vnet500
                type: internal
    ovs_version: "2.13.3"
```

- Versión final de Netplan:


```yaml
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
      dhcp4: no

    # Bridge principal OVS de este servidor
    # 'sol': nombre servidor. 'br': bridge
    solbr:
      dhcp4: no

    # Puertos `Internal` para Acceso a VLAN's, consumibles localmente o por VM's
    # Creados con:
    #  ovs-vsctl add-port solbr vlanNNN tag=NNN -- set Interface vlanNNN type=internal
    # Configuro todos para que se activen (UP) incluso los que no tienen IP.
    vnet100:
      addresses: [192.168.100.33/24]
      gateway4: 192.168.100.1
      nameservers:
        addresses: [192.168.100.224]
        search: [parchis.org]
    vnet192:
      addresses: [192.168.1.3/24]
    vnet500:
      addresses: [192.168.101.3/24]
```



----

<br/>

#### Referencias: 

- [OVS Common Configuration Issues](https://docs.openvswitch.org/en/latest/faq/issues/)
- [Open vSwitch with Libvirt](https://docs.openvswitch.org/en/latest/howto/libvirt/)
- [Libvirt networking](https://wiki.libvirt.org/page/Networking)
- [Libvirt network XML format](https://libvirt.org/formatnetwork.html)
- [OVS Deep Dive](https://arthurchiao.art/blog/ovs-deep-dive-6-internal-port/)
- [Alpine linux networking](https://wiki.alpinelinux.org/wiki/Configure_Networking)


<br/>



