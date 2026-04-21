---
title: "Windows 11 sobre Proxmox"
date: "2025-08-04"
categories: ["administración"]
tags: ["windows","win11","qemu", "virtualización", "proxmox", "vm"]
draft: false
cover:
  image: "/img/posts/logo-proxmox-vm-win.svg"
  hidden: true
---


<img src="/img/posts/logo-proxmox-vm-win.svg" alt="logo vm win en proxmox" width="150px" height="150px" style="float:left; padding-right:25px"  />

Guía completa, con todos los pasos detallados para instalar, configurar y acceder a una Máquina Virtual (VM) Windows 11 Pro corriendo encima de [Proxmox VE](https://www.proxmox.com/en/proxmox-ve).

Esta plataforma de virtualización permite el despliegue y la gestión de **máquinas virtuales** Windows Server/10/11 usando [KVM](https://www.linux-kvm.org/page/Main_Page)/[QEMU](https://www.qemu.org). Mediante integración avanzada a través del agente QEMU Guest, drivers VirtIO drivers, incluso UEFI Secure Boot con emulación TPM para Windows 11.

<br clear="left"/>
<style>
table {
    font-size: 0.8em;
}
</style>
<!--more-->

{{< admonition note "Serie de apuntes sobre Windows">}}

- Preparar un PC para [Dualboot Linux / Windows]({{< relref "2024-08-23-dual-linux-win.md" >}}) e instalar Windows 11 Pro.
- Configurar [un Windows 11 decente]({{< relref 2025-08-03-win-decente.md >}}) quitando la morralla.
- Preparar [Windows para desarrollo de software]({{< relref 2024-08-25-win-desarrollo.md >}}), CLI, WSL2 y herramientas.
- Instalación de [VMWare Workstation Pro en Windows 11]({{< relref 2024-08-26-win-vmware.md >}}) con una VM de Windows 11 Pro.
- Instalación de [VM Windows 11 sobre Proxmox]({{< relref 2025-08-04-proxmox-win.md >}}) para tener un Windows 11 Pro sobre Host Proxmox.

{{< /admonition >}}

---

## Introducción

Veamos paso a paso cómo instalar una **máquina virtual (VM)** con **Windows 11** en **Proxmox VE**, utilizando el **QEMU Guest Agent**, controladores **VirtIO**, y habilitando acceso gráfico (durante y después de la instalación).

---

## 🧩 Requisitos previos

- **Proxmox VE 8.x** o superior.
- Imagen ISO oficial de **Windows 11** (`Win11_XXXX_64.iso`).
- Imagen ISO de **VirtIO Drivers** (controladores paravirtualizados):
  - Descarga [oficial](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/)
  - Archivo: `virtio-win.iso`
- Al menos **4 GB RAM**, **2 vCPU**, **64 GB disco**.
- Conexión a red con **DHCP** disponible.

---

## ⚙️ 1. Creación de la VM

Desde el **nodo Proxmox** o mediante la interfaz web.

| Parámetro | Valor |
|------------|-------|
| VM ID | `400` |
| Nombre | `vm-win11` |
| Sistema operativo | Windows 11 (64-bit) |
| BIOS | `OVMF (UEFI)` |
| Máquina | `q35` |
| TPM | `TPM 2.0` (requerido por Windows 11) |
| Almacenamiento | `local-lvm` o `zfs` (según entorno) |
| Red | `virtio (paravirtualized)` |

**Creación vía CLI**:

```bash
qm create 400   --name vm-win11   --memory 8192   --cores 4   --cpu host   --machine q35   --bios ovmf   --efidisk0 local-lvm:1,format=raw,efitype=4m,pre-enrolled-keys=1   --tpmstate0 local-lvm:1,version=v2.0   --scsihw virtio-scsi-pci   --scsi0 local-lvm:64,format=qcow2   --net0 virtio,bridge=vmbr0   --cdrom local:iso/Win11.iso   --boot order=scsi0;ide2;net0
```

Agregar el ISO de controladores VirtIO:

```bash
qm set 400 --ide2 local:iso/virtio-win.iso
```

---

## 🪟 2. Instalación de Windows 11

### Iniciar la VM

Desde la interfaz web de Proxmox o CLI:

```bash
qm start 400
```

Abrir la **consola gráfica**:

- En la GUI de Proxmox → seleccionar la VM → pestaña **Consola**.
- O vía CLI usando SPICE:

```bash
qm spiceproxy 400
```

> Nota: Durante la instalación, se usa la consola de Proxmox (basada en noVNC o SPICE) para acceso gráfico.

### Cargar controladores VirtIO

En el asistente de instalación de Windows:

1. En el paso “¿Dónde desea instalar Windows?”, no aparecerán discos.
2. Clic en **Cargar controlador (Load driver)**.
3. Seleccionar **Buscar en el CD de VirtIO** (`virtio-win.iso`).
4. Ruta: `vioscsi/w11/amd64` → aceptar → aparecerá el disco virtual.
5. Continuar la instalación normalmente.

### Configuración de red (DHCP)

Durante la instalación, si Windows no detecta red:

1. Abrir consola (Shift+F10).
2. Ejecutar:

   ```cmd
   drvload e:\NetKVM\w11\amd64\netkvm.inf
   ```

3. Cerrar consola, continuar instalación.

El adaptador VirtIO recibirá IP vía DHCP automáticamente.

---

## 🧠 3. Post-instalación y optimización

### Instalar herramientas VirtIO

Una vez dentro del sistema:

1. Abrir el **CD de VirtIO** en el explorador.
2. Ejecutar `virtio-win-guest-tools.exe`.
3. Instalar todos los componentes:
   - Controladores VirtIO (almacenamiento, red, balloon).
   - QEMU Guest Agent.

Reiniciar el sistema.

---

## 💡 4. Activar QEMU Guest Agent

En el host Proxmox:

```bash
qm set 400 --agent enabled=1,fstrim_cloned_disks=1
```

Verificar desde la VM (PowerShell con privilegios):

```powershell
Get-Service QEMU-GA
```

Si no está en ejecución:

```powershell
Set-Service QEMU-GA -StartupType Automatic
Start-Service QEMU-GA
```

Ahora Proxmox podrá ejecutar:

```bash
qm guest ping 400
qm guest exec 400 -- cmd /c ipconfig
```

Durante backups verás:

```bash
INFO: issuing guest-agent 'fs-freeze'
INFO: issuing guest-agent 'fs-thaw'
```

---

## 🖥️ 5. Acceso gráfico

### Durante instalación

- Usar la **Consola Proxmox (noVNC o SPICE)**.
- SPICE ofrece mejor rendimiento y soporte de portapapeles.

### Una vez instalado (GUI remota)

Opciones:

#### a) **RDP (Remote Desktop Protocol)**

1. Dentro de Windows → Panel de control → Sistema → Configuración remota.
2. Activar *Permitir conexiones remotas*.
3. Desde otra máquina Windows o Linux:

```bash
rdesktop <IP-DHCP>
# o desde Windows: mstsc /v:<IP>
```

#### b) **SPICE (Proxmox GUI)**

- En la VM → Hardware → Agregar → Dispositivo de visualización → `SPICE`.
- Instalar en cliente local el **Virt-Viewer**:

```bash
# Linux
sudo apt install virt-viewer

# Windows: Descargar desde https://virt-manager.org/download/
```

- Clic en **Consola (SPICE)** desde Proxmox.

**VNC interno**: Proxmox ofrece una consola VNC accesible vía navegador → pestaña *Consola*.

---

## 🧾 6. Configuración completa (ejemplo)

Archivo `/etc/pve/qemu-server/400.conf`:

```ini
boot: order=scsi0;ide2;net0
description: Windows 11 Pro VM
efidisk0: local-lvm:vm-400-disk-1,size=4M,efitype=4m,pre-enrolled-keys=1
memory: 8192
cores: 4
cpu: host
disk: scsi0=local-lvm:vm-400-disk-0,discard=on,iothread=1,size=64G
net0: virtio=DE:AD:BE:EF:11:22,bridge=vmbr0
ide2: local:iso/virtio-win.iso,media=cdrom
cdrom: local:iso/Win11.iso
scsihw: virtio-scsi-pci
bios: ovmf
machine: q35
tpmstate0: local-lvm:vm-400-disk-2,version=v2.0
agent: enabled=1,fstrim_cloned_disks=1
```

---

## 🔄 7. Backup y snapshots

Windows 11 soporta backups en modo **snapshot**:

```bash
vzdump 400 --mode snapshot --compress zstd --storage vault-backup
```

Proxmox ejecutará:

```bash
INFO: issuing guest-agent 'fs-freeze'
INFO: issuing guest-agent 'fs-thaw'
```

La VM seguirá funcionando sin interrupción.

---

## 🧩 8. Conclusión

Proxmox VE permite ejecutar Windows 10/11 con excelente rendimiento, soporte de UEFI + TPM 2.0, y backups consistentes gracias al QEMU Guest Agent. El uso de controladores VirtIO es clave para un rendimiento óptimo.

**Ventajas principales:**

- Copias snapshot sin detener la VM.
- Integración total con agente invitado (shutdown, IP, fs-freeze/thaw).
- Acceso gráfico completo (noVNC, SPICE, RDP).
- Total compatibilidad con redes DHCP y almacenamiento moderno.

---

> 📘 **Recomendación:** Mantén actualizadas las imágenes ISO de VirtIO y las herramientas de QEMU Guest Agent dentro de Windows. Esto mejora la estabilidad y el soporte de futuras versiones de Proxmox.
