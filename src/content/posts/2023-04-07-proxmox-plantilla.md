---
title: "Proxmox: VM con plantilla"
date: "2023-04-07"
categories: ["administración"]
tags: ["linux","pve","proxmox","kvm","qemu","cloud-init","alpine","debian","ubuntu","plantilla","virtualización"]
draft: false
cover:
  image: "/img/posts/logo-proxmox-plantilla.svg"
  hidden: true
---


<img src="/img/posts/logo-proxmox-plantilla.svg" alt="logo linux router" width="150px" height="150px" style="float:left; padding-right:25px"  />

[Proxmox VE](https://www.proxmox.com/en/proxmox-ve) es una plataforma de virtualización de código abierto potente y fácil de usar que permite el despliegue y la gestión de **máquinas virtuales** (VM's con [KVM](https://www.linux-kvm.org/page/Main_Page)/[QEMU](https://www.qemu.org)) y **contenedores** (CT's basados en [LXC](https://linuxcontainers.org/lxc/introduction/)). Proxmox nos ofrece **Plantillas** para minimizar el tiempo de creación de nuevas instancias de estas máquinas virtuales o contendores.

En este apunte me concentro en cómo crear mi propia **Plantillas de máquina virtual** junto con una **imagen basada en la nube** y **cloud-init**.

<br clear="left"/>
<!--more-->

{{< admonition note "Aviso a navegantes">}}

Aunque este apunte va de plantillas para VM (Virtual Machines), nunca dejes de intentar montar tus servicios usando **LXC**, ocupa menos memoria, CPU y recursos. Tienes el proyecto [Proxmox VE Helper-Scripts](https://community-scripts.github.io/ProxmoxVE/scripts), donde encontrarás cientos de "scripts" para automatizar la instalacion. Un proyecto FOSS [espectacular](https://github.com/community-scripts/ProxmoxVE).

{{< /admonition >}}

### Plantillas con imágenes basadas en la nube

¿Qué es una **Plantilla de VM en Proxmox**?, se trata de una VM normal y corriente que convertimos en "Plantilla" y a partir de ella podemos clonar nuevas VM's idénticas rápidamente. Si las combinamos con imágenes basadas en la nube y cloud-init conseguimos un activo muy potente para crear VM's ágiles y ligeras.

Estas **imágenes basadas en la nube** (VM cloud based images) son discos ya preinstalador, muy útiles porque tienen un tamaño mínimo y permite hacer despliegues ágiles de máquinas virtuales. **[`cloud-init`](https://cloud-init.io)** es un estandar para la personalización de instancias en la "nube" (en mi caso instancias en Proxmox). Permite parametrizar el usuario, su contraseña, claves SSH y otras lindezas para ahorrarnos curro durante la instalación.

---

### Creación de una Plantilla

> Nota: Los comandos CLI difieren de las imágenes; actualicé el apunte con nuevas versiones y diferentes paths.

La primero es bajarse una imagen basada en la nube. Me conecto al servidor Proxmox y me cambio al directorio del "storage" que tengo para imágenes:

- Basada en [Ubuntu](https://cloud-images.ubuntu.com/minimal/releases/jammy/release/): Hay que bajarse un fichero `.img`.

```shell
curl -O -J -L https://cloud-images.ubuntu.com/minimal/releases/noble/release/ubuntu-24.04-minimal-cloudimg-amd64.img
# La renombro por comodidad
mv ubuntu-24.04-minimal-cloudimg-amd64.img ubuntu-24.04.img
```

- Basada en [Debian](https://cloud.debian.org/images/cloud/trixie/latest/). Hay que bajarse un `.raw` y renombrarlo.

```shell
cd /mnt/rapid/isos/template/iso
curl -O -J -L https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.raw
# Tiene que terminar en .img, la renombro por comodidad
mv debian-13-genericcloud-amd64.raw debian-13.img
```

- Basada en [Alpine](https://alpinelinux.org/cloud/). Elejí Generic (Alpha), Release 3.22.1, Arch x86_64, Firmware UEFI, Bootstrap cloud-init, Machine Virtual. Te ofrece bajarse un `.qcow2`. Me copié el enlace, lo bajé desde Proxmox y convertí a `.img`.

```shell
cd /mnt/rapid/isos/template/iso
curl -O -J -L https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/cloud/generic_alpine-3.22.1-x86_64-uefi-cloudinit-r0.qcow2
qemu-img convert -f qcow2 -O raw generic_alpine-3.22.1-x86_64-uefi-cloudinit-r0.qcow2 alpine-3.22.1.img
```

A partir de aquí he usado el ejemplo con Ubuntu, pero con Debian o Alpine es exáctamente igual.

- Creo una VM nueva sin *medio de instalación* asociado (no voy a hacer la instalación del Sistema Operativo) y *sin disco duro* (ya que su disco será la *cloud image* que me bajé antes). Le concedo lo mínimo: 1 CPU, 1024 RAM (podré cambiarlo en las futuras VM's que clone).

<div class="image-box">
  <img src="/img/posts/2023-04-07-proxmox-plantilla-vm-02.jpg" alt="Creo la máquina virtual" width="600px" />
  <div class="image-caption">Creo la máquina virtual</div>
</div>

- Se recomienda (desde el proyecto OpenStack) que *cloud-init* encuentre su parametrización en un dispositivo de tipo CD-ROM asociado a la VM. Tenemos la ventaja de que Proxmox VE nos genera automáticamente una imagen ISO preparada para esto: `Hardware -> Add -> CloudInit Drive (ide0)`.

<div class="image-box">
  <img src="/img/posts/2023-04-07-proxmox-plantilla-vm-03.jpg" alt="Asocio un dispositivo CDROM para Cloud-Init" width="600px" />
  <div class="image-caption">Asocio un dispositivo CDROM para Cloud-Init</div>
</div>

- Parametrizo *cloud-init* indicando *usuario, password, parámetros DNS, mi clave ssh pública y muy importante* **configuro la red en modo DHCP**.

<div class="image-box">
  <img src="/img/posts/2023-04-07-proxmox-plantilla-vm-04.jpg" alt="Parametrizo cloud-init y pulso en [Regenerate Image]" width="600px" />
  <div class="image-caption">Parametrizo cloud-init y pulso en [Regenerate Image]</div>
</div>

| Importante: No te olvides de darle a **Regenerate Image**. La ventaja de `cloud-init` es que me ahorro configurar varias cosas en las futuras VMs. |

- Sigo desde el CLI (vía SSH) en el nodo donde creé la VM. *Importante a partir de ahora*: Usa el mismo número de VM (ID) que usaste durante la creación (en mi caso el **900**).

```shell
➜  ~ ssh root@pve-tierra.tudominio.com
Last login: Sat Apr  8 10:20:18 2023 from 192.168.100.3
root@pve-tierra:~#
```

- Asocio una consola serie de tipo VGA para poder *ver la consola* desde Proxmox.

```shell
qm set 900 --serial0 socket --vga serial0
```

- Averiguo el Path de la imagen a importar

```shell
 ❯ pvesm list rapid-isos
Volid                            Format  Type            Size VMID
rapid-isos:iso/alpine-3.22.1.img iso     iso        226492416
rapid-isos:iso/debian-13.img     iso     iso       3221225472
rapid-isos:iso/ubuntu-24.04.img  iso     iso        255393792

pvesm path rapid-isos:iso/ubuntu-24.04.img
/mnt/rapid/isos/template/iso/ubuntu-24.04.img

pvesm path rapid-isos:iso/debian-13.img
/mnt/rapid/isos/template/iso/debian-13.img

pvesm path rapid-isos:iso/alpine-3.22.1.img
/mnt/rapid/isos/template/iso/alpine-3.22.1.img
```

- Importo la *imagen basada en la nube*. El siguiente comando copia la imagen al storage de Proxmox y la configura como un disco disponible para la VM.

```shell
qm importdisk 900 /mnt/rapid/isos/template/iso/debian-13.img local-lvm
importing disk '/mnt/rapid/isos/template/iso/debian-13.img' to VM 900 ...
:
```

<div class="image-box">
  <img src="/img/posts/2023-04-07-proxmox-plantilla-vm-05.png" alt="Tras la importación veo el disco disponible, aunque no asociado" width="600px" />
  <div class="image-caption">Tras la importación veo el disco disponible, aunque no asociado</div>
</div>

- Asocio este disco a la VM como un dispositivo SCSI.

<div class="image-box">
  <img src="/img/posts/2023-04-07-proxmox-plantilla-vm-06.jpg" alt="Asocio el disco con las opciones indicadas, dado que mi disco es SSD" width="600px" />
  <div class="image-caption">Asocio el disco con las opciones indicadas, dado que mi disco es SSD</div>
</div>

- **MUY IMPORTANTE** La imagen que nos hemos bajado no permitirá hacer boot y normalmente tamaños pequeños (2-3GB). Usamos `qm disk resize` que nos corrige ambos.

```shell
qm disk resize 900 scsi0 32G
```

<div class="image-box">
  <img src="/img/posts/2023-04-07-proxmox-plantilla-vm-07.png" alt="Disco asociado a la VM y redimensionado a 32GB" width="600px" />
  <div class="image-caption">Disco asociado a la VM y redimensionado a 32GB</div>
</div>

- Cambio el orden de arranque y activo poder arrancar desde este nuevo disco.

<div class="image-box">
  <img src="/img/posts/2023-04-07-proxmox-plantilla-vm-08.jpg" alt="Cambio el orden de arranque, lo subo a la segunda posición" width="600px" />
  <div class="image-caption">Cambio el orden de arranque, lo subo a la segunda posición</div>
</div>

- El paso final es **convertir la VM a una Plantilla**. Es irreversible, así que es un buen momento para repasar las opciones. Una vez convertida vemos cómo cambia su *icono*.

<div class="image-box">
  <img src="/img/posts/2023-04-07-proxmox-plantilla-vm-09.jpg" alt="Convierto la VM a una Plantilla" width="600px" />
  <div class="image-caption">Convierto la VM a una Plantilla</div>
</div>

---

#### Crear una nueva máquina virtual

Ya podemos crear todas las máquinas virtuales que queramos partiendo de la(s) Plantilla(s). Se realiza con la Función **Clonar**. Veamos un ejemplo con la de Ubuntu (para la de Debian o Apline es igual).

- Pulso con el botón derecho sobre la Plantilla, selecciono **Clone**, asigno el **VM ID**, su **nombre** y el **modo de clonado** (a mi me gusta hacer clonados completos). Cuando termina arranco la VM y hago click en **Console** para ver el proceso de arranque completo. **Importante no tocar nada, no hacer Login** hasta que termine la ejecución de **cloud-init**.

<div class="image-box">
  <img src="/img/posts/2023-04-07-proxmox-plantilla-vm-10.jpg" alt="Creo una VM (clonando la plantilla) y la arranco." width="600px" />
  <div class="image-caption">Creo una VM (clonando la plantilla) y la arranco.</div>
</div>

- Cuando `cloud-init` termina entro con mi usuario (`luis`), averiguo qué IP he recibido (para futuras conexiones vía SSH), instalo `qemu-guest-agent` (para controlar mejor la VM desde Proxmox) y rearranco la VM.
  - `ip a`
  - `sudo apt install qemu-guest-agent`
  - `sudo reboot -f`

<div class="image-box">
  <img src="/img/posts/2023-04-07-proxmox-plantilla-vm-11.jpg" alt="Termino de instalar qemu-guest-agent." width="600px" />
  <div class="image-caption">Termino de instalar qemu-guest-agent.</div>
</div>

- Ya tenemos un nuevo Ubuntu, Debian o Alpine instanciado. Si vamos a darle un uso de largo recorrido recomiendo asignarle una dirección IP estática. En mi caso siempre lo hago asignando IP's a MAC's de forma estática desde mi DHCP Server.

<br />

### Referencias

- Un par de enlaces
  - Un buen artículo [aquí](https://codingpackets.com/blog/proxmox-import-and-use-cloud-images/)
  - Un video interesante [aquí](https://www.learnlinux.tv/proxmox-ve-how-to-build-an-ubuntu-22-04-template-updated-method/).
