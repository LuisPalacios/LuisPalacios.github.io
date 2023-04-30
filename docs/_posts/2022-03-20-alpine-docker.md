---
title: "Alpine para ejecutar contenedores"
date: "2022-03-20"
categories: linux
tags: linux servidor alpine docker
excerpt_separator: <!--more-->
---

![Logo docker](/assets/img/posts/logo-docker.svg){: width="150px" style="float:left; padding-right:25px" } 

En este apunte describo como instalar Alpine Linux en una máquina virtual en mi servidor QEMU/KVM y cómo instalar Docker en ella. Necesitaba, para pruebas de concepto y servicios caseros, poder instalar contenedores sobre un servidor con Docker que ocupase "poquísimo". ¿Se puede instalar un Host Docker encima de una Máquina Virtual?. La respuesta es un sí rotundo, de hecho es un lugar excelente para hacerlo, sobre todo en entornos de laboratorio, caseros, pequeños despliegues. 


<br clear="left"/>
<!--more-->


## Introducción

Necesitaba montar microservicios encima de Docker (hacía tiempo que no ([jugaba con Docker]({% post_url 2014-11-01-inicio-docker %})) dudé entre añadir Docker a mi servidor donde tengo KVM, dedicar un PC antiguo a Docker o pensar en algo más creativo... 

Al final decidí optar por la tercera opción: **montar máquinas virtuales dedicadas a contenedores Docker corriendo en mi servidor KVM**. Mi potente y pequeño servidor [Meerkat de System76](https://system76.com/desktops/meerkat) es donde tengo todas mis VM's, pues bien, algunas de ellas van a soportar microservicio encima de Docker. 

La segunda opción (añadir Docker a mi servidor donde tengo KVM) hubiese sido un infierno con el networking (openvswitch + docker switches + iptables), así que opté por aislar y contener problemas/troubleshooting de Docker en VM's dedicadas. Así que mi servidor de VM's queda como sigue: 

- Hardware: Meerkat de System76
- Software: [Pop!_OS](https://pop.system76.com), Ubuntu Server LTS.
- Networking: [Open vSwtich]({% post_url 2022-02-20-openvswitch %})
- QEMU/KVM con Hypervisor
- Varios Guest's con máquinas virtuales corriendo Linux (Ubuntu Server LTS) y servicios.
- Varios Guest's appliances como [Umbrella](https://umbrella.cisco.com) o [vWLC](https://www.cisco.com/c/en/us/products/wireless/wireless-lan-controller/index.html) de Cisco.
- Varios Guest's con **máquinas virtuales corriendo Alpine Linux con Docker y contenedores para servicios (git, nodered, ...)**. 

<br/>

### ¿Donde ejecutar Docker? 

Lo primero que necesitaba decidir es sobre qué SO iba a montar Docker, teniendo en cuenta que: 

- Voy a correr Docker dentro de una Máquina Virtual en mi Servidor QEMU/KVM. 
- El Sistema Operativo `Guest` solo va a tener Docker, no necesito una distribución enorme. 
- Busco algo pequeño, fácil de mantener y robusto

Entre las diferentes opciones que he visto por [ahí](https://kuberty.io/blog/best-os-for-docker/) he optado por [Alpine Linux](https://alpinelinux.org)

<br/>

#### Máquina virtual con Alpine Linux

Veamos un ejemplo creando una una VM l

- Descargo **Alpine Linux** desde [Downloads](https://alpinelinux.org/downloads/) > VIRTUAL > *Slimmed down kernel. Optimized for virtual systems*, x86_64 (**solo 52MB**), es la versión más compacta posible.
```console
luis@sol:~/kvm/base$ wget https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-virt-3.15.3-x86_64.iso
luis@sol:~/kvm/base$ wget https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-virt-3.15.3-x86_64.iso.sha256
luis@sol:~/kvm/base$ sha256sum -c alpine-virt-3.15.3-x86_64.iso.sha256
alpine-virt-3.15.3-x86_64.iso: La suma coincide
```
- Creo un puerto `estático` en mi switch virtual (más info aquí: [Open vSwitch y KVM]({% post_url 2022-02-20-openvswitch %})). 
```
luis@sol:~/kvm/base$ sudo ovs-vsctl list-br
solbr
luis@sol:~/kvm/base$ sudo ovs-vsctl list-ports solbr
eth0
:
v100vnet12  (miro cual es el último que tenía dado de alta)
:
luis@sol:~$ sudo ovs-vsctl add-port solbr v100vnet13 tag=100 -- set Interface v100vnet13 type=internal
```
- Creo el directorio donde ubicaré el fichero de la máquina virtual
```console
luis@sol:~/kvm$ mkdir docker
```
- Creo una **máquina virtual** desde `virt-manager` con **1GB de RAM, 1 CPU, disco de 4GB y una NIC virtio**, usando la imagen: `alpine-virt-3.15.3-x86_64.iso`, la llamo `docker.tudominio.com` y en la configuración de red uso el interfaz que acabo de crear `v100vnet13`.
```console
luis@sol:~$ virt-manager
```

{% include showImagen.html 
      src="/assets/img/posts/2022-03-20-alpine-docker-1.png" 
      caption="Creo VM desde virt-manager" 
      width="450px"
      %}


- Arranco la VM y entro en el setup de Alpine (más info en [esta guía](https://wiki.alpinelinux.org/wiki/QEMU)). 
```console
luis@sol:~/kvm/gitea-traefik-docker$ virsh console docker.tudominio.com
localhost login: root
Welcome to Alpine!
:
localhost:~#
:
# export SWAP_SIZE=0
# setup-alpine
Select keyboard layout: [none] es
Select variant (or 'abort'): es
Enter system hostname (fully qualified form, e.g. 'foo.example.org') [localhost] docker
Available interfaces are: eth0.
Which one do you want to initialize? (or '?' or 'done') [eth0]
Ip address for eth0? (or 'dhcp', 'none', '?') [dhcp] 192.168.100.225/24
Gateway? (or 'none') [none] 192.168.100.1
Do you want to do any manual network configuration? (y/n) [n] n
DNS domain name? (e.g 'bar.com') tudominio.com
DNS nameserver(s)? 192.168.100.224
Changing password for root
Which timezone are you in? ('?' for list) [UTC] Europe/Madrid
HTTP/FTP proxy URL? (e.g. 'http://proxy:8080', or 'none') [none]
Enter mirror number (1-71) or URL to add (or r/f/e/done) [1]
Which SSH server? ('openssh', 'dropbear' or 'none') [openssh]
Which disk(s) would you like to use? (or '?' for help or 'none') [none] vda
How would you like to use it? ('sys', 'data', 'crypt', 'lvm' or '?' for help) [?] sys
WARNING: Erase the above disk(s) and continue? (y/n) [n] y
Installation is complete. Please reboot.
docker:~# reboot
```

- Hago login como root e instalo unas cuantas herramientas útiles. 
```console
docker:~# apk add iproute2 nano tzdata
docker:~# cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime
docker:~# echo "Europe/Madrid" >  /etc/timezone
docker:~# apk del tzdata
```
- Creo mi usuario `luis` y configuro ssh
```console
docker:~# addgroup -g 1000 luis
docker:~# adduser -h /home/luis -s /bin/ash -G luis --u 1000 luis
docker:~# adduser luis wheel
docker:~# su - luis
docker:~$ 
docker:~$ ssh-keygen -t rsa -b 2048 -C "luis@docker.tudominio.com"
:
docker:~$ exit
```
- Creo `authorized_keys` ([apunte sobre SSH en linux]({% post_url 2009-02-01-ssh %}))
- Modifico SSH para que trabaje solo con clave pública/privada
```console
docker:~$ su -
Password:
docker:~# cat /etc/ssh/sshd_config
# Config LuisPa
Port 22
PubkeyAuthentication yes
PasswordAuthentication no
AuthenticationMethods publickey
AllowAgentForwarding yes
AllowTcpForwarding yes
GatewayPorts yes
AddressFamily inet
PrintMotd no
Subsystem sftp /usr/lib64/misc/sftp-server
AcceptEnv LANG LC_*
docker:~# service sshd restart
```
- Creo el fichero `/etc/nanorc` ([fuente aquí](https://gist.github.com/LuisPalacios/4e07adf45ec1ba074939317b59d616a4)) para el editor `nano` 
- Acelero el tiempo de boot a unos 5 segundos
```console
docker:~# cat /boot/extlinux.conf
# Generated by update-extlinux 6.04_pre1-r9
#DEFAULT menu.c32                        # Comento esta línea
DEFAULT virt                             # Añadida, virt = nombre más abajo
PROMPT 0
MENU TITLE Alpine/Linux Boot Menu
MENU HIDDEN
MENU AUTOBOOT Alpine will be booted automatically in # seconds.
TIMEOUT 30
LABEL virt
  MENU LABEL Linux virt
  LINUX vmlinuz-virt
  INITRD initramfs-virt
  APPEND root=UUID=bff03f67-29ee-4525-96d9-3096a1799fc7 modules=sd-mod,usb-storage,ext4 quiet rootfstype=ext4
MENU SEPARATOR
```

<br/>

#### Instalación de Docker y Docker Compose

- Habilito el **Community repository**
```console
git:~# cat /etc/apk/repositories
#/media/cdrom/apks
http://dl-cdn.alpinelinux.org/alpine/v3.15/main
http://dl-cdn.alpinelinux.org/alpine/v3.15/community   <== Descomento esta línea
```
- Añado la siguiente línea al fichero `/etc/sudoers`
```console
# User rules for luis
luis ALL=(ALL) NOPASSWD:ALL
```
- Creo un par de scripts de apoyo
```console
nodered:~# cat > /usr/bin/e
#!/bin/ash
/usr/bin/nano "${*}"
nodered:~# chmod 755 /usr/bin/e
:
nodered:~# cat > /usr/bin/confcat
#!/bin/ash
# By LuisPa 1998
# confcat: quita las lineas con comentarios, muy util como sustituto
# a "cat" para ver contenido sin los comentarios.
#
grep -vh '^[[:space:]]*#' "$@" | grep -v '^//' | grep -v '^;' | grep -v '^$' | grep -v '^!' | grep -v '^--'
nodered:~# chmod 755 /usr/bin/confcat
:
nodered:~# cat > /usr/bin/s
#!/bin/ash
/usr/bin/sudo -i
nodered:~# chmod 755 /usr/bin/s
```
- Actualizo el sistema e instalo herramientas muy útiles además de **docker** y **docker-compose**
```console
docker:~# apk update
docker:~# apk upgrade --available
docker:~# apk add bash-completion procps util-linux 
docker:~# apk add readline findutils sed coreutils sudo
docker:~# apk add docker docker-bash-completion docker-compose docker-compose-bash-completion docker-cli-compose
docker:~# rc-update add docker boot
docker:~# service docker start
```
- Añado mi usuario al grupo docker y hago un reboot...
```console
git:~# addgroup luis docker
git:~# reboot -f
```
- Pruebo Docker (con la última imagen de [alpine](https://hub.docker.com/_/alpine), que ocupa poquísimo...)
```console
docker:~$ docker pull alpine:latest
docker:~$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
alpine       latest    76c8fb57b6fc   3 days ago   5.57MB
docker:~$ docker create -t -i  --name myalpine alpine:latest
5f1fefa539848f9e0fe995bf2e9c426def69ca48bfacc51bdb509197939c041e
docker:~$ docker start myalpine
/ # exit
docker:~$ docker exec -it myalpine /bin/ash
docker:~$ docker stop myalpine
docker:~$ docker rm myalpine
```
- Que no te sorprenda que `docker stop myalpine`tarde un rato en pararse, [aquí](https://stackoverflow.com/questions/60493765/running-and-stopping-an-alpine-docker-container-takes-about-10x-as-long-as-cento) tienes la explicacion.
 