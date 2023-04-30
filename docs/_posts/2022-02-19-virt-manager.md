---
title: "Virt-Manager remoto"
date: "2022-02-19"
categories: administración
tags: linux kvm vm qemu virtualización virt-manager libvirt
excerpt_separator: <!--more-->
---

![Logo Virt Manager](/assets/img/posts/logo-virtmanager.svg){: width="150px" style="float:left; padding-right:25px" } 


El objetivo es poder ejecutar **[virt-manager](https://virt-manager.org)** desde mi Mac para administrar las VM's de un par de servidores anfitriones KVM/QEMU remotos sin necesidad de instalarles un entorno X11. He documentado dos opciones, la primera es mediante **máquina virtual** local (Virtualbox/Parallels/...) con un ubuntu y entorno mínimo GUI (solo `Xorg/X11` y `virt-manager`), la segunda es mediante **HomeBrew**.


<br clear="left"/>
<!--more-->


## Opción Máquina Virtual 

Tengo [Parallels](https://www.parallels.com/es/) como software de Virtualización pero debe funcionar exactamente igual con [VirtualBox](https://www.virtualbox.org) o cualquier otro virtualizador en tu Mac. 

{% include showImagen.html 
      src="/assets/img/posts/2022-02-19-virt-manager-1.png" 
      caption="Instalación de VM con Ubuntu" 
      width="500px"
      %}

- Creo una VM con [Ubuntu Server 20.04 LTS](https://ubuntu.com/server/docs/installation): ubuntu-20.04.3-live-server-amd64.iso
- Instalo las [Parallel Tools](https://kb.parallels.com/en/121370) (opciónal)
- Red compartida, me asignará una IP automáticamente del rango privado.

{% include showImagen.html 
      src="/assets/img/posts/2022-02-19-virt-manager-2.png" 
      caption="Configuración de red desde Parallels" 
      width="500px"
      %}

- Parallels crea una entrada en el `/etc/hosts` con el nombre de la máquina virtual y su IP. Compruebo que funciona y de paso quito el motd (Mensaje del Día) del ubuntu

```
luis@macos:~$ ssh -p 22 ubuntu-linux
: 
luis@ubuntu:~$ touch $HOME/.hushlogin
```

- Preparo el entorno mínimo Xorg/X11 ([más info](https://help.ubuntu.com/community/ServerGUI)): 
  
```
luis@ubuntu:~$ sudo apt install xauth
:
luis@ubuntu:~$ sudo apt install virt-manager ssh-askpass-gnome --no-install-recommends

luis@ubuntu:~$ sudo apt install -y spice-client-gtk

```

-  Prepararo SSH, para conectar desde mi VM `ubuntu` a un servidor llamado `tierra` con KVM/QEMU. Aquí tienes una [guía sobre SSH en Linux](https://www.luispa.com/linux/2006/11/13/ssh.html) y otra sobre [SSH y X11 como root](https://www.luispa.com/linux/2017/02/11/x11-desde-root.html). 
  
```
 virt-manager                   libvirtd
 host:ubuntu                    host:tierra
+-------------+               +--------------+
| luis@ubuntu | ---- ssh ---> | luis@tierra  |
+-------------+               +--------------+
```

- Configuro el cliente SSH en `ubuntu`. En mi caso el servidor `tierra` exige autenticar vía clave pública.

```
luis@ubuntu $ ssh-keygen -t rsa -b 2048
```

- En el servidor `@tierra` añado el usuario al grupo `libvirt`

```
root@tierra # cat /etc/group
:
libvirt:x:116:luis
```

- Compruebo... 
  
```
luis@macos:$ ssh -Y -a luis@ubuntu-linux
:
luis@ubuntu:~$ ssh tierra
Enter passphrase for key '/home/luis/.ssh/id_rsa':

luis@tierra:~$
luis@tierra:~$ id
uid=1000(luis) gid=1000(luis) grupos=1000(luis),4(adm),24(cdrom),27(sudo),116(libvirtd)
```

#### Conexión desde virt-manager en máquina virtual

``` 
luis@macos:$ ssh -Y -a -p 22 luis@ubuntu-linux
:
luis@ubuntu:~$ virt-manager
```

- Archivo > Añadir conexión 
  - Hypervisor: QEMU/KVM
  - (x) Xonectar a anfitrión remoto mediante SSH
  - Nombre de usuario: luis
  - Nombre de equipo: tierra.tudominio.com
  - Autoconectar: (X)
  - URI generado: qemu+ssh://luis@tierra... 


{% include showImagen.html 
      src="/assets/img/posts/2022-02-19-virt-manager-3.png" 
      caption="Configuración de conexión remota SSH" 
      width="500px"
      %}

{% include showImagen.html 
      src="/assets/img/posts/2022-02-19-virt-manager-4.png" 
      caption="Gestor virt-manager" 
      width="600px"
      %}

- Conexión desde línea de comandos

También tienes la opción de conectar directamente desde la línea de comandos o si tienes tu servidor remoto escuchando por otro puerto para SSH, cambia XXXXX por el puerto.

```
luis@ubuntu$ virt-manager -c 'qemu+ssh://luis@tierra.tudominio.com/system?keyfile=id_rsa'

luis@ubuntu$ virt-manager -c 'qemu+ssh://luis@tierra.tudominio.com:XXXXX/system?keyfile=id_rsa'

```

<br/>

## Opción HomeBrew

- Virt-manager no está disponible en HomeBrew, existe una [fórmula](https://github.com/jeffreywildman/homebrew-virt-manager) personalizada que permite instalarlo pero está obsoleta y falla. Gracias a este [Issues/184](https://github.com/jeffreywildman/homebrew-virt-manager/issues/184) y múltiples forks he encontrado el de *Damenly*, que tiene buena pinta. Ojo, es super simple, solo instala virt-manager, no instala libvirt ni soporta ciertas dependencias (como por ejemplo la contraeña de ssh, leer el [README](https://github.com/Damenly/homebrew-virt-manager)). 
- He tenido algún que otro problema al instalarlo y lo desinstalé, lo dejo aquí para hacer seguimiento a este proyecto. 
```
brew tap Damenly/homebrew-virt-manager
brew install virt-manager --HEAD
brew install virt-viewer
```
- Una vez instalado ejecutamos: 
```
export XDG_DATA_DIRS="/opt/homebrew/share/".
virt-manager -c test:///default
```


<br/>

