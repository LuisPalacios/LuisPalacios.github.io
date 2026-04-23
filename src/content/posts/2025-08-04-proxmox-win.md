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

Instalación, configuración y acceso a una VM Windows 11 Pro sobre [Proxmox VE](https://www.proxmox.com/en/proxmox-ve). Proxmox permite desplegar VMs Windows con [KVM](https://www.linux-kvm.org/page/Main_Page)/[QEMU](https://www.qemu.org), integración vía QEMU Guest Agent y drivers VirtIO, incluyendo UEFI + TPM 2.0 emulado (obligatorio para Win11).

<br clear="left"/>
<style>
table {
    font-size: 0.8em;
}
</style>
<!--more-->

{{< admonition note "Serie de apuntes sobre Windows">}}

- Preparar un PC para [Dualboot Linux / Windows]({{< relref "2024-08-23-dual-linux-win.md" >}}) e instalar Windows 11 Pro.
- Configurar [un Windows 11 decente]({{< relref "2025-08-03-win-decente.md" >}}) quitando la morralla.
- Preparar [Windows para desarrollo de software]({{< relref "2024-08-25-win-desarrollo.md" >}}), CLI, WSL2 y herramientas.
- Instalación de [VMWare Workstation Pro en Windows 11]({{< relref "2024-08-26-win-vmware.md" >}}) con una VM de Windows 11 Pro.
- Instalación de [VM Windows 11 sobre Proxmox]({{< relref "2025-08-04-proxmox-win.md" >}}) para tener un Windows 11 Pro sobre Host Proxmox.

{{< /admonition >}}

## Requisitos previos

- **Proxmox VE 8.x** o superior.
- ISO oficial de **Windows 11** (`Win11_XXXX_64.iso`).
- ISO de **VirtIO Drivers** ([descarga oficial](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/), archivo `virtio-win.iso`).
- **Mínimo**: 4 GB RAM, 2 vCPU, 64 GB disco.
- **Recomendado para trabajar cómodo**: 8 GB RAM, 4 vCPU, 64+ GB disco.
- Red con DHCP disponible.

## Crear la VM

Desde la GUI web de Proxmox, o vía CLI. Estos son los parámetros que uso:

| Parámetro | Valor |
|------------|-------|
| VM ID | `400` |
| Nombre | `vm-win11` |
| Sistema operativo | Windows 11 (64-bit) |
| BIOS | `OVMF (UEFI)` |
| Máquina | `q35` |
| TPM | `TPM 2.0` (obligatorio en Win11) |
| Almacenamiento | `local-lvm` o `zfs` (según entorno) |
| Red | `virtio (paravirtualized)` |

Si prefieres la línea de comandos en lugar de la GUI web, el equivalente es:

```bash
qm create 400 --name vm-win11 --memory 8192 --cores 4 --cpu host --machine q35 --bios ovmf --efidisk0 local-lvm:1,format=raw,efitype=4m,pre-enrolled-keys=1 --tpmstate0 local-lvm:1,version=v2.0 --scsihw virtio-scsi-pci --scsi0 local-lvm:64,format=qcow2 --net0 virtio,bridge=vmbr0 --cdrom local:iso/Win11.iso --boot order=scsi0;ide2;net0
```

Agrega el ISO de VirtIO como segundo CD/DVD:

```bash
qm set 400 --ide2 local:iso/virtio-win.iso
```

## Instalar Windows 11

Arranca la VM desde la GUI o con:

```bash
qm start 400
```

Accede a la consola gráfica desde la pestaña **Consola** de la VM (noVNC en navegador). Para SPICE con mejor rendimiento y portapapeles:

```bash
qm spiceproxy 400
```

### Cargar los drivers VirtIO

En el asistente de Windows, al llegar a "¿Dónde desea instalar Windows?" no aparece ningún disco (Windows no trae drivers VirtIO de serie):

1. Clic en **Load driver**.
2. Selecciona el CD de VirtIO (`virtio-win.iso`).
3. Ruta: `vioscsi/w11/amd64` → aceptar. Aparece el disco.
4. Continúa la instalación normalmente.

### Red DHCP durante la instalación

Si Windows no detecta red, desde la consola:

1. Pulsa `Shift + F10`.
2. Carga el driver VirtIO de red:

   ```cmd
   drvload e:\NetKVM\w11\amd64\netkvm.inf
   ```

3. Cierra la consola y sigue. El adaptador recibirá IP vía DHCP.

### OOBE de Windows 11

Los pasos del primer arranque (teclado, región, cuenta local, PIN, "no" a diagnósticos/localización) son los mismos que en el resto de la serie: ver [Windows 11 OOBE]({{< relref "2024-08-23-dual-linux-win.md" >}}#windows-11-oobe-setup-inicial).

## Post-instalación

### Instalar las herramientas VirtIO

1. Abre el CD de VirtIO en el explorador.
2. Ejecuta `virtio-win-guest-tools.exe`.
3. Instala todos los componentes (drivers VirtIO: almacenamiento/red/balloon, y QEMU Guest Agent).
4. Reinicia.

### Activar QEMU Guest Agent

En el host Proxmox:

```bash
qm set 400 --agent enabled=1,fstrim_cloned_disks=1
```

Verifica dentro de la VM (PowerShell como admin):

```powershell
Get-Service QEMU-GA
```

Si no está corriendo:

```powershell
Set-Service QEMU-GA -StartupType Automatic
Start-Service QEMU-GA
```

A partir de aquí Proxmox puede ejecutar comandos en el guest:

```bash
qm guest ping 400
qm guest exec 400 -- cmd /c ipconfig
```

> Mantén actualizadas las ISOs de VirtIO y las herramientas de QEMU Guest Agent dentro de Windows — mejoran estabilidad y compatibilidad con futuras versiones de Proxmox.

## Acceso gráfico

Tres opciones, según uso:

**RDP (uso habitual tras la instalación)**. Panel de control → Sistema → Configuración remota → activar *Permitir conexiones remotas*. Desde otro equipo:

```bash
rdesktop <IP-DHCP>        # Linux
mstsc /v:<IP>             # Windows
```

**SPICE (consola remota con mejor rendimiento)**. En la VM: Hardware → Add → Display → `SPICE`. En el cliente:

```bash
# Linux
sudo apt install virt-viewer

# Windows: https://virt-manager.org/download/
```

Desde Proxmox, pulsa **Consola (SPICE)**.

**VNC interno**. Proxmox ofrece consola VNC vía navegador en la pestaña *Consola* de la VM — útil durante la instalación y para acceso de emergencia.

## Backup y snapshots

Con QEMU Guest Agent activo, los backups se hacen consistentes (fs-freeze/fs-thaw) sin parar la VM:

```bash
vzdump 400 --mode snapshot --compress zstd --storage vault-backup
```

En la salida verás:

```bash
INFO: issuing guest-agent 'fs-freeze'
INFO: issuing guest-agent 'fs-thaw'
```

## Fichero de configuración de referencia

Ejemplo de `/etc/pve/qemu-server/400.conf` con todo lo anterior aplicado:

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
