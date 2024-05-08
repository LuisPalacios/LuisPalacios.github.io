---
title: "Vagrant con Libvirt KVM"
date: "2021-05-15"
categories: virtualización
tags: linux kvm virtualización python jupyter virtualbox desarrollo
excerpt_separator: <!--more-->
---

![logo vagrant kvm](/assets/img/posts/logo-vagrantkvm.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }


[Vagrant](https://www.vagrantup.com/) crea y ejecuta máquinas virtuales, apoyándose en proveedores de virtualización como Virtualbox, KVM, Docker, VMWare y otros [30 más](https://github.com/hashicorp/vagrant/wiki/Available-Vagrant-Plugins#providers). Siempre tenderá a arrancar la VM con Virtualbox a menos que le digamos explícitamente un proveedor específico. En esta guía explico cómo he montado **Vagrant con el proveedor Libvirt KVM  en Linux**.


<br clear="left"/>
<!--more-->

## Instalación de KVM

Como no tenía KVM instlado seguí estos pasos en mi Desktop Linux (*debian 11 - bullseye*) para instalar KVM.

### Soporte de virtualización en el Hardware

Primero compruebo que mi equipo soporta virtualización en el hardware. Busco "vmx" (Intel-VT) o "svm" (AMD-V) en la salida del comando:

```console
luis@jupiter:~$ egrep --color -i "svm|vmx" /proc/cpuinfo
```

{% include showImagen.html
      src="/assets/img/posts/vagrantkvm-1.png"
      caption="Busco 'vmx' (Intel-VT) o 'svm' (AMD-V)"
      width="500px"
      %}

En algunos modelos de CPU, el soporte de VT puede estar deshabilitado en la BIOS. Compruébalo para habilitarlo...

Otro método es usar el comando:

```console
luis@jupiter:~$ lscpu | grep -i Virtualiz
Virtualización: VT-x
```

<br>

### Instalación de KVM y las dependencias

Instalo KVM y todas las dependencias necesarias para configurar un entorno de virtualización.

```console
luis@jupiter:~$ sudo apt install qemu qemu-kvm libvirt-clients libvirt-daemon-system virtinst bridge-utils
```

<br/>

* qemu - Un emulador y virtualizador de máquinas genérico,
* qemu-kvm - Metapaquete de QEMU para soporte de KVM (es decir, virtualización completa de QEMU en hardware x86),
* libvirt-clients - programas para la biblioteca libvirt,
* libvirt-daemon-system - archivos de configuración del demonio de Libvirt,
* virtinst - programas para crear y clonar máquinas virtuales,
* bridge-utils - utilidades para configurar el Bridge Ethernet en Linux.

El servicio debería haber arrancado (ubuntu arranca los servicios cuando los instala), en cualquier caso se haría así:

```console
$ sudo systemctl enable libvirtd
$ sudo systemctl start libvirtd
```

**Añado mi usuario como parte del grupo `libvirt`**

```console
sudo adduser luis libvirt
```

**Verifico que está todo funcionando**

```console
$ systemctl status libvirtd
```

{% include showImagen.html
      src="/assets/img/posts/vagrantkvm-2.png"
      caption="Compruebo los servicios"
      width="500px"
      %}

**Instalo Virt-Manager** y lo arranco. Aunque es el software indicado para gestionar VMs, en este apunte lo uso como monitor, me va a venir bien para ver cómo Vagrant las crea, arranca, para y destruye.


```console
luis@jupiter:~$ sudo apt install virt-manager
```

{% include showImagen.html
      src="/assets/img/posts/vagrantkvm-3.png"
      caption="Arranco el Gestor de VMs"
      width="500px"
      %}

<br/>

| ¡Ya tenemos una instalación operativa donde podemos empezar a crear y manipular máquinas virtuales, **con Vagrant**! |

<br/>


## Instalación de Vagrant.


Instalo `vagrant` y el plugin `vagrant-libvirt`.

```console
luis@jupiter:~$ sudo apt update
luis@jupiter:~$ sudo apt upgrade -y
:
luis@jupiter:~$ sudo apt-get install vagrant-libvirt
```

**Creo mi primera VM**

Siempre en un directorio dedicado creo el fichero `Vagrantfile` y levanto mi primera VM, en este ejemplo un simple `Vanilla Debian box`.

| Nota: Aquí tienes la lista de [boxes](https://app.vagrantup.com/boxes/search) (equipos) que puedes instalarte. Te recomiendo leer esta [guía](https://www.vagrantup.com/vagrant-cloud/boxes/catalog) |

```console
luis@jupiter:~$ mkdir miproyecto
luis@jupiter:~$ cd miproyecto/
luis@jupiter:~/miproyecto$ vagrant init debian/buster64
A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.

luis@jupiter:~/miproyecto$ vagrant up --provider=libvirt
```

{% include showImagen.html
      src="/assets/img/posts/vagrantkvm-4.png"
      caption="Desde el gestor vemos la VM"
      width="500px"
      %}

**Pruebo a conectarme con la VM**

```console
luis@jupiter:~/miproyecto$ vagrant ssh
Linux buster 4.19.0-16-amd64 #1 SMP Debian 4.19.181-1 (2021-03-19) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
-bash: warning: setlocale: LC_ALL: cannot change locale (es_ES.UTF-8)
vagrant@buster:~$
```

<br/>

## Networking

Por defecto las máquinas virtuales con Vagrant se crean una red privada y usan DHCP. Yo prefiero usar IP fija para mi laboratorio, pero eso va por gustos y caso de uso. Estas son las configuraciones que suelo manejar:

**Networking privado + IP fija**, fichero `Vagrantfile`:

```config
    # Networking Privado, con IP fija para que sea más fácil hacer SSH desde el Host.
    config.vm.network :private_network,
                      :ip => "10.20.30.40",
                      :libvirt__domain_name => "coder.local"
```

**Networking público + IP fija**, fichero `Vagrantfile`:

```console
    # Networking Público, con IP fija
    config.vm.network "public_network",
                      :dev => "br0",
                      :mode => "bridge",
                      :type => "bridge",
                      :ip => "192.168.1.100"
```

Ojo!... si vas a usar la versión de IP pública tienes que prearar el Host (tu servidor linux). Es necesario configurar la interfaz Ethernet con un bridge y recomiendo hacer una configuración manual (no usar NetworkManager o similar). Aquí tienes un ejemplo de lo que he hecho en Linux con Debian 11:

```console
root@jupiter:~# cat /etc/network/interfaces.d/br0
#
# Configuración IP estática en interfaz principal Ethernet.
# Uso Vagrant con IP's públicas, necesito crear un Bridge
#
# Tras modificar este fichero: service networking restart
#
auto br0
iface br0 inet static
	address 192.168.1.200
	broadcast 192.168.1.255
	netmask 255.255.255.0
	gateway 192.168.1.1

	# Instalé también el paquete "resolvconf" para no tener que
	# editar el fichero /etc/resolv.conf sino que se ponga
	# la IP del DNS server desde aquí.
	dns-nameservers 192.168.1.253

	# Añado mi interfaz física al Bridge. Las interfaces que
	# configure con Vagrant en modo pública con IP fija se añadirán
	# serán añadidas a este bridge.
	#
	bridge_ports enp0s25
	bridge_stp off       # Deshabilito Spanning Tree Protocol
	bridge_waitport 0    # No espero antes de habilitar el puerto
	bridge_fd 0          # No meter ningún retardo en el forwarding
```

* Instalo `resolvconf` y rearranco el servicio de networking

```console
# apt install resolvconf
# service networking restart  (quizá necesites hacer reboot)
```

<br/>

## Caso de uso

En este repositorio en GitHub tienes un [maquina virtual para desarrollo de software preparada con Vagrant](https://github.com/LuisPalacios/devbox). Además podrás encontrar en el apunte "[Servicios Systemd de usuario]({% post_url 2021-05-30-systemd-usuario %})" cómo ejecutar procesos de usuario durante el arranque del sistema, para arrancar esta máquina virtual con Vagrant durante el boot.
