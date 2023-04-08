---
title: "Plantillas en Proxmox"
date: "2023-04-07"
categories: administración
tags: linux pve proxmox kvm qemu cloud-init alpine debian ubuntu plantilla virtualización
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-proxmox-plantilla.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Proxmox VE es una plataforma de virtualización potente y fácil de usar con muchas características. Una de ellas es la posibilidad de usar **plantillas para crear máquinas virtuales**. Minimiza el tiempo dedicado a la creación de nuevas instancias.

En este apunte describo cómo combinar las *Plantillas de Proxmox* con **imágenes basada en la nube** y **cloud-init** para automatizar todo el proceso de instanciación de VM's. En este apunte utilizo Proxmox VE 7.4-3 y una imagen de Ubuntu 22.04 LTS.


<br clear="left"/>
<!--more-->

### Plantillas con imágenes basadas en la nube

Las **imágenes basadas en la nube** (VM cloud based images) son muy útiles porque tienen un tamaño mínimo y permite hacer despliegues ágiles de máquinas virtuales. Podemos bajarnos estas imágenes y configurarlas como el "disco" de nuestra VM (se trata del sistema operativo completamente instalado). Además podemos parametrizar la VM durante su primer boot usando [`cloud-init`](https://cloud-init.io). 

Las **Plantillas de Proxmox** permiten clonar (crar) VM's partiendo de una ya existente (que hemos convertido en Plantilla). Si combinamos todo (VM's que usan imágenes basadas en la nube, cloud-init y las plantillas) conseguimos un activo muy potente para crear VM's ágiles y ligeras. 

<br/>

#### Creación de una Plantilla (basada en Ubuntu)

Vamos a ver todo el proceso de creación de una VM y su conversión a Plantilla y usaremos una de estas imágenes basadas en la nube en vez de instalar el SO por completo.

- Como decía he elegido Ubuntu, así que descargo una de sus [imágenes basadas en la nube de Ubuntu](https://cloud-images.ubuntu.com/minimal/releases/jammy/release/) en mi iMac.
```console
$ curl -O https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  285M  100  285M    0     0  70.1M      0  0:00:04  0:00:04 --:--:-- 70.2M
$ mv ubuntu-22.04-minimal-cloudimg-amd64.img ubuntu-22.04.img
```
- La subo a Proxmox, a un disco remoto NFS que tengo en un QNAP.
{% include showImagen.html
    src="/assets/img/posts/2023-04-07-proxmox-plantilla-vm-01.jpg"
    caption="Subo la imagen a Proxmox (a mi servidor NFS para imágenes)"
    width="600px"
    %}
- Creo una VM nueva sin *medio de instalación* asociado (no voy a hacer la instalación del Sistema Operativo) y *sin disco duro* (ya que su disco será la *cloud image* que me bajé antes). Uso lo mínimo, 1 CPU, 1024 RAM...
{% include showImagen.html
    src="/assets/img/posts/2023-04-07-proxmox-plantilla-vm-02.jpg"
    caption="Creo la máquina virtual"
    width="600px"
    %}
- Se recomienda (OpenStack) que *cloud-init* encuentre su parametrizació en un dispositivo de tipo CD-ROM asociado a la VM. Tenemos la ventaja de que Proxmox VE nos genera automáticamente una imagen ISO para esto. Creo este dispositivo desde `Hardware -> Add -> CloudInit Drive (ide0)`.
{% include showImagen.html
    src="/assets/img/posts/2023-04-07-proxmox-plantilla-vm-03.jpg"
    caption="Asocio un dispositivo CDROM para Cloud-Init"
    width="600px"
    %}
- Parametrizo *cloud-init* indicando *usuario, password, parámetros DNS, mi clave ssh pública y muy importante* **configuro la red en modo DHCP**. 
{% include showImagen.html
    src="/assets/img/posts/2023-04-07-proxmox-plantilla-vm-04.jpg"
    caption="Parametrizo cloud-init y pulso en [Regenerate Image]"
    width="600px"
    %}
- Pulso en **Regenerate Image**. La ventaja que me da es que me ahorro tener que configurar todo eso en todas las futuras VMs.
- Sigo desde el CLI (vía SSH) en el nodo donde creé la VM. *Importante a partir de ahora*: Usa el mismo número de VM (ID) que usaste durante la creación (en mi caso el **900**).
```console
➜  ~ ssh root@pve-tierra.parchis.org
Last login: Sat Apr  8 10:20:18 2023 from 192.168.100.3
root@pve-tierra:~#
```
- Asocio una consola serie de tipo VGA para poder *ver la consola* desde Proxmox.
  - `qm set 900 --serial0 socket --vga serial0`
- Averiguo el Path a la imagen a importar
```console
root@pve-tierra:~# pvesm list panoramix
Volid                                                 Format  Type           Size VMID
panoramix:iso/ubuntu-22.04-minimal-cloudimg-amd64.img iso     iso       299827200
root@pve-tierra:~# pvesm path panoramix:iso/ubuntu-22.04-minimal-cloudimg-amd64.img
/mnt/pve/panoramix/template/iso/ubuntu-22.04-minimal-cloudimg-amd64.img
```
- Importo la *imagen basada en la nube* a la VM. El siguiente comando copia la imagen y la configura como un disco disponible para la VM. 
```console
root@pve-tierra:~# qm importdisk 900 /mnt/pve/panoramix/template/iso/ubuntu-22.04-minimal-cloudimg-amd64.img local-zfs
importing disk '/mnt/pve/panoramix/template/iso/ubuntu-22.04-minimal-cloudimg-amd64.img' to VM 900 ...
:
transferred 2.2 GiB of 2.2 GiB (100.00%)
Successfully imported disk as 'unused0:local-zfs:vm-900-disk-0'
```
{% include showImagen.html
    src="/assets/img/posts/2023-04-07-proxmox-plantilla-vm-05.png"
    caption="Tras la importación veo el disco disponible, aunque no asociado"
    width="600px"
    %}
- Asocio este disco a la VM como un dispositivo SCSI.
{% include showImagen.html
    src="/assets/img/posts/2023-04-07-proxmox-plantilla-vm-06.jpg"
    caption="Asocio el disco con las opciones indicadas, dado que mi disco es SSD"
    width="600px"
    %}  
- **MUY IMPORTANTE** Esta imagen tiene dos problemas, el primero es que no permitirá hacer boot y el segundo que tiene un tamaño muy pequeño (2,2GB). Para corregir ambos vamos a redimensionarla (que de paso corrige el tema del boot). Podría haberlo hecho con `qemu-img` antes de importarla, pero vamos a usar `qm resize` después de hacer la importación:
  - `qm disk resize 900 scsi0 32G` 
{% include showImagen.html
    src="/assets/img/posts/2023-04-07-proxmox-plantilla-vm-07.png"
    caption="Disco asociado a la VM y redimensionado a 32GB"
    width="600px"
    %}  
- Cambio el orden de arranque y activo poder arrancar desde este nuevo disco.
{% include showImagen.html
    src="/assets/img/posts/2023-04-07-proxmox-plantilla-vm-08.jpg"
    caption="Cambio el orden de arranque, lo subo a la segunda posición"
    width="600px"
    %}  
- El paso final es **convertir la VM a una Plantilla**. Es irreversible, así que es un buen momento para repasar las opciones. Una vez convertida vemos cómo cambia su *icono*.
{% include showImagen.html
    src="/assets/img/posts/2023-04-07-proxmox-plantilla-vm-09.jpg"
    caption="Convierto la VM a una Plantilla"
    width="600px"
    %}  



<br />

#### Creación de una Plantilla (basada en Debian)

- El proceso es exactamente el mismo pero usaremos una imagen distinta. En este caso selecciono una imagen basada en la nube de [Debian 11 (Bulls Eye)](https://cloud.debian.org/images/cloud/) en formato `.raw`, en concreto el fichero [debian-11-genericcloud-amd64.raw](https://laotzu.ftp.acc.umu.se/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.raw). La versión que elijo es la `genericcloud` (la diferencia con la `generic` es que la primera excluye los drivers de hardware físico, que no necesito para nada).
- Me bajo la imagen a mi iMac y la renombro a `.img` para poder subirla a mi NFS Server conectado a Proxmox
```console
$ curl -O https://laotzu.ftp.acc.umu.se/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.raw
$ mv debian-11-genericcloud-amd64.raw debian-11-genericcloud-amd64.img
```
- Como decía el proceso es exactamente el mismo, teniendo cuidado de usar un VM ID, nombres y path's (a la imagen) distintos.

<br/>

#### Crear una nueva máquina virtual

Ya podemos crear todas las máquinas virtuales que queramos partiendo de la(s) Plantilla(s). Se realiza con la Función **Clonar**. Veamos un ejemplo con la plantilla de Ubuntu, aunque para la de Debian sería prácticamente igual.

- Pulso con el botón derecho sobre la Plantilla, selecciono **Clone**, asigno el **VM ID**, su **nombre** y el **modo de clonado** (a mi me gusta hacer clonados completos). Cuando termina arranco la VM y hago click en **Console** para ver el proceso de arranque completo. **Importante no tocar nada, no hacer Login** hasta que termine la ejecución de **cloud-init**.
{% include showImagen.html
    src="/assets/img/posts/2023-04-07-proxmox-plantilla-vm-10.jpg"
    caption="Creo una VM (clonando la plantilla) y la arranco."
    width="600px"
    %}  
- Cuando termina `cloud-init`  entro con mi usuario `luis`, averiguo qué IP he recibido por DHCP (para futuras conexiones vía SSH), instalo `qemu-guest-agent` (para controlar mejor la VM desde Proxmox) y rearranco la VM.
  - `ip a`
  - `sudo apt install qemu-guest-agent`
  - `sudo reboot -f`
{% include showImagen.html
    src="/assets/img/posts/2023-04-07-proxmox-plantilla-vm-11.jpg"
    caption="Termino de instalar qemu-guest-agent."
    width="600px"
    %}
- Ya tenemos un nuevo Ubuntu instanciado. Si vamos a darle un uso de largo recorrido recomiendo asignarle una dirección IP estática. En mi caso siempre lo hago asignando IP's estáticas por dirección MAC desde mi DHCP Server.



<br />

### Referencias

- Imágenes basadas en la nube de Ubuntu: [22.04 LTS (Jammy Jellyfish)](https://cloud-images.ubuntu.com/minimal/releases/jammy/release/): *[ubuntu-22.04-minimal-cloudimg-amd64.img](https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img)*. Se trata de la imagen utilizada en este apunte.
- Imágenes basadas en la nube de Debian: [11 (Bulls Eye)](https://cloud.debian.org/images/cloud/): *[debian-11-genericcloud-amd64.raw](https://laotzu.ftp.acc.umu.se/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.raw)*. La versión `genericcloud` puede correr en cualquier entorno virtual y la diferencia con la `generic` es que excluye los drivers de hardware físico.
- Un par de enlaces, un buen artículo [aquí](https://codingpackets.com/blog/proxmox-import-and-use-cloud-images/) y un video interesante [aquí](https://www.learnlinux.tv/proxmox-ve-how-to-build-an-ubuntu-22-04-template-updated-method/).
- Reutilizaré la imagen que voy a crear en este apunte en un futuro post sobre cómo implementar máquinas virtuales en Proxmox a través de Terraform