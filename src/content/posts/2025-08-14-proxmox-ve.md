---
title: "ProxmoxVE Helper Scripts"
date: "2025-08-14"
categories: ["administración"]
tags: ["linux","pve","proxmox","kvm","qemu","cloud-init","alpine","debian","ubuntu","plantilla", "virtualización", "container", "ct"]
draft: false
cover:
  image: "/img/posts/logo-proxmox-ve.svg"
  hidden: true
---


<img src="/img/posts/logo-proxmox-ve.svg" alt="logo linux router" width="150px" height="150px" style="float:left; padding-right:25px"  />

[Proxmox VE](https://www.proxmox.com/en/proxmox-ve) es una plataforma de virtualización de código abierto potente y fácil de usar que permite el despliegue y la gestión de **máquinas virtuales** (VM's con [KVM](https://www.linux-kvm.org/page/Main_Page)/[QEMU](https://www.qemu.org)) y **contenedores** (CT's basados en [LXC](https://linuxcontainers.org/lxc/introduction/)).

Si tienes poca experiencia puede que te cueste un poco, por lo que te recomiendo este proyecto maravilloso: [Proxmox VE Helper-Scripts](https://community-scripts.github.io/ProxmoxVE/scripts), donde encontrarás cientos de "scripts" para **facilitarte la vida instalando CT's o VM's** encima de tu Proxmox.

<br clear="left"/>
<!--more-->

### Introducción

De verdad que este proyecto es espectacular, aquí es donde tienes que ir cuando quieras instalar algo:

- 👉 [Proxmox VE Helper-Scripts](https://community-scripts.github.io/ProxmoxVE/scripts). Busca lo que quieras y sigue las instrucciones.

<div class="image-box">
  <img src="/img/posts/2025-08-14-proxmox-ve-01.png" alt="+350 scripts para instalarte tus CT's o VM's" width="800px" />
  <div class="image-caption">+350 scripts para instalarte tus CT's o VM's</div>
</div>

El proyecto FOSS lo tienes en [ProxmoxVE](https://github.com/community-scripts/ProxmoxVE). Incluye scripts organizados por categorías para contenedores y para máquinas virtuales. Cada script automatiza el despliegue de un servicio o aplicación específica dentro de un LXC o una VM.

**Ejemplo: Contenedor LXC basado en Alpine Linux minimalista**:

```bash
# Desde la Shell de Proxmox
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/alpine.sh)"
```

Durante la ejecución, el script solicitará parámetros como el ID del contenedor, el Hostname, usuario y contraseña, así como asignación de recursos (CPU, RAM, almacenamiento)

Al finalizar, tendrás el contenedor (CT) listo y configurado.

**Ejemplo: Máquina Virtual VM para Docker (basado en Debian 12)**:

```bash
# Desde la Shell de Proxmox
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/vm/docker-vm.sh)"
```

Monta una VM para servidor Docker en un par de minutos, un ejemplo: ID del contenedor: `100`, máquina `Q35`, disco `32GB`, disk Cache `None (default)`, hostname: `docker`, CPU Model `Host`, Cores `4`, memoria: `8192`, bridge: `vmbr1`.

Una vez arranca, entro como `root` en el GUI de Proxmox (password `docker` si la pide). Desde ahí monto SSH, creo un usuario y listo...

```bash
apt install openssh-server locales
adduser luis
usermod -aG sudo luis
usermod -aG docker luis
passwd luis
echo "luis ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/10luis
dpkg-reconfigure locales
timedatectl set-timezone Europe/Madrid
timedatectl set-ntp on
```

### Buenas prácticas

- **Plantillas base**: Usa plantillas oficiales de Proxmox (Alpine, Debian, Ubuntu) como base antes de personalizar.
- **Backups previos**: Antes de ejecutar un script en producción, realiza snapshot o backup del nodo.
- **Revisión de código**: Siempre revisa el contenido del script para entender qué instala y configura.

### Recursos

- 📦 [Repositorio completo en GitHub](https://github.com/community-scripts/ProxmoxVE)
- 📜 [Lista de scripts con descripciones](https://community-scripts.github.io/ProxmoxVE/scripts)
- 💬 [Foro de soporte Proxmox](https://forum.proxmox.com/)
