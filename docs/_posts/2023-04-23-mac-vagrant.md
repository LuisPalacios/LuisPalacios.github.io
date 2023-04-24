---
title: "MAC con Vagrant"
date: "2023-04-23"
categories: desarrollo
tags: macos homebrew desarrollo virtualbox linux virtualización 
excerpt_separator: <!--more-->
---

![logo vagrant kvm](/assets/img/posts/logo-mac-vagrant.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 


[Vagrant](https://www.vagrantup.com/) permite crear y configurar entornos de desarrollo virtuales, ligeros y reproducibles. Lo hace creando máquinas virtuales y necesita un **Virtualizador**. Le da igual qué virtualizador usar, soporta Virtualbox, KVM, Docker, VMWare y otros [30 más](https://github.com/hashicorp/vagrant/wiki/Available-Vagrant-Plugins#providers). Es una herramienta fantástica para poder montar **Servidores** para nuestros desarrollos de software. 

Este apunte solo vale, de momento, para trabajar con chip **INTEL**. De momento no he sido capaz de hacerlo funcionar en un Mac con ARM (Apple Silicon) como anfitrión.


<br clear="left"/>
<!--more-->

### VirtualBox

[VirtualBox](https://www.virtualbox.org) es un software de virtualización que permite instalar sistemas operativos adicionales, conocidos como «sistemas invitados, guest, máquinas virtuales», dentro de tu sistema operativo «anfitrión», cada uno con su propio ambiente virtual. Puedes crear máquinas virtuales basadas en FreeBSD, GNU/Linux, OpenBSD, OS/2 Warp, Windows, Solaris, MS-DOS, Genode y muchos otros.

Para instalarlo descargo el binario de VirtualBox desde [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads), el proceso de instalación es muy sencillo. Una vez instalado no necesitas crear ninguna máquina virtual, lo haremos directamente desde Vagrant.

{% include showImagen.html
    src="/assets/img/posts/2023-04-23-mac-vagrant-01.jpeg"
    caption="VirtualBox queda instalado en mi Mac"
    width="400px"
    %}


Hace tiempo escribí un apunte sobre cómo trabajar con Vagrant en Linux usando otro virtualizador: [Vagrant con Libvirt KVM]({% post_url 2021-05-15-vagrant-kvm %}).

| Nota: He visto que VirtualBox tiene una versión que corre de forma nativa sobre ARM y funciona correctamente, pero todavía no he conseguido que Vagrant levante una VM Linux ARM nativa o una VM Windows ARM nativa. |

A modo de curiosidad, si haberlo probado todavía, parece que otro virtualizador, `Parallels Desktop`,  permite instalar Windows 11 sobre ARM descargando la imagen desde los servidores de MS. Se puede activar con cualquier licencia válida de W7/8/10/11, dado que las licencias no tienen dependencia de la arquitectura. Así que en teoría se puede comprar W11 sobre ARM y hacerlo funcionar en un Parallels Desktop sobre M1/M2. 

<br/>

### Vagrant

Recomiendo instalar Vagrant usando `Homebrew`. Si tienes un Mac lee el apunte [MAC para desarrollo]({% post_url 2023-04-15-mac-desarrollo %}) donde describo cómo instalar Homebrew y un montón de herramientas muy últiles para poder desarrollar en un Mac.

```zsh
brew update && brew upgrade
brew install vagrant

source ~/.zshrc
```

Una vez instalado compruebo la verisón y que funciona correctamente

{% include showImagen.html
    src="/assets/img/posts/2023-04-23-mac-vagrant-02.jpeg"
    caption="VirtualBox queda instalado en mi Mac"
    width="600px"
    %}

<br/>

#### Crear un servidor de prueba

Creo una máquina virtual para pruebas, la levanto y la destruyo para comprobar todo el proceso. 

Creo un directorio temporal y una VM de pruebas usando la imagen (Vagran los llama boxes) `trusty64`. Puedes encontrar mucho más en [Discover Vagrant Boxes](https://app.vagrantup.com/boxes/search).

```zsh
mkdir prueba
cd prueba
vagrant init ubuntu/trusty64
vagrant up
```

El disco virtual se crea en el HOME de tu usuario, en el subdiretorio ` ~/VirtualBox\ VMs`

```zsh
ls -al ~/VirtualBox\ VMs/prueba_default_1682326653672_96128
total 3119136
drwx------  6 luis  staff         192 23 abr 10:59 .
drwx------  3 luis  staff          96 23 abr 10:57 ..
drwx------  5 luis  staff         160 23 abr 10:59 Logs
-rw-------  1 luis  staff  1584726016 23 abr 10:59 box-disk1.vmdk
-rw-------  1 luis  staff        4495 23 abr 10:59 prueba_default_1682326653672_96128.vbox
-rw-------  1 luis  staff        4904 23 abr 10:59 prueba_default_1682326653672_96128.vbox-prev
```

Conecto con la VM usando SSH

```zsh
ssh -p 2222 vagrant@127.0.0.1  <== La constraseña es 'vagrant'
```

Podemos destruir esta máquina virtual rápidamente con 

```zsh
➜  prueba vagrant destroy
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default: Destroying VM and associated drives...
```

<br/>

#### VM para desarrolladores

En este repositorio en GitHub tienes un [maquina virtual para desarrollo de software preparada con Vagrant](https://github.com/LuisPalacios/devbox). 

Se trata de un repositorio con todo lo necesario para crear una máquina virtual orientada al Desarrollo de Software con Python y JupyterLabs. 

Podrás utilizar esta VM para conectar con servicios adicionales de Bases de Datos, cuadernos Jupyter de ejercicios. Tienes toda la información en el README del repositorio.

Otra referencias interesantes: 

- [Comenzxar con vagrant en Mac](https://blog.puntoycomalab.com/2021/10/10/comenzar-con-vagrant-en-mac/)

