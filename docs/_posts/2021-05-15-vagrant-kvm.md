---
title: "Vagrant con proveedor Libvirt KVM"
date: "2021-05-15"
categories: virtualización
tags: linux kvm virtualización python jupyter
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
Virtualización:                      VT-x
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

**Arranco el servicio**

Once KVM is installed, start libvertd service (If it is not started already):

```console
$ sudo systemctl enable libvirtd
$ sudo systemctl start libvirtd
```

**Añado mi usuario como parte del grupo `libvirt`**

```console
sudo adduser $LOGNAME libvirt
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

```console
luis@jupiter:~$ virsh list --all
 Id   Nombre   Estado
-----------------------
```


**Instalo Virt-Manager**

```console
luis@jupiter:~$ sudo apt install virt-manager
```

{% include showImagen.html 
      src="/assets/img/posts/vagrantkvm-3.png" 
      caption="Arranco el Gestor de VMs"
      width="500px"
      %}

<br/>

| ¡Ya tenemos una instalación operativa donde podemos empezar a crear y manipular máquinas virtuales! |

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

En un directorio distinto creo el fichero `Vagrantfile` y levanto mi primera VM, un simple `Vanilla Debian box`. 

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

Por defecto, KVM configura un bridge virtual privado, para que todas las máquinas virtuales puedan comunicarse entre sí dentro del ordenador anfitrión (host), con su propia subred y DHCP para configurar la red del invitado (guest) y utiliza NAT para acceder a la red del host. Si trabajas solo desde el Desktop del Linux pues genial, pero si quieres acceder a estas máquinas virtuales desde fuera (desde tu LAN) entonces hay que hacer más cosas. Actualizaré este artículo más adelante. 
