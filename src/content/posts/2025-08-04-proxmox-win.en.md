---
title: "Windows 11 on Proxmox"
date: "2025-08-04"
categories: ["sysadmin"]
tags: ["windows","win11","qemu", "virtualization", "proxmox", "vm"]
draft: false
cover:
  image: "/img/posts/logo-proxmox-vm-win.svg"
  hidden: true
---


<img src="/img/posts/logo-proxmox-vm-win.svg" alt="vm win on proxmox logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

Install, configure, and access a Windows 11 Pro VM on top of [Proxmox VE](https://www.proxmox.com/en/proxmox-ve). Proxmox lets you deploy Windows VMs using [KVM](https://www.linux-kvm.org/page/Main_Page)/[QEMU](https://www.qemu.org), with integration via the QEMU Guest Agent and VirtIO drivers, including UEFI + emulated TPM 2.0 (required for Win11).

<br clear="left"/>
<style>
table {
    font-size: 0.8em;
}
</style>
<!--more-->

{{< admonition note "Windows series">}}

- Preparing a PC for [Dualboot Linux / Windows]({{< relref "2024-08-23-dual-linux-win.md" >}}) and installing Windows 11 Pro.
- Configuring [a decent Windows 11]({{< relref "2025-08-03-win-decente.md" >}}) by removing the cruft.
- Preparing [Windows for software development]({{< relref "2024-08-25-win-desarrollo.md" >}}): CLI, WSL2, and tools.
- Installing [VMWare Workstation Pro on Windows 11]({{< relref "2024-08-26-win-vmware.md" >}}) with a Windows 11 Pro VM.
- Installing a [Windows 11 VM on Proxmox]({{< relref "2025-08-04-proxmox-win.md" >}}) to run Windows 11 Pro on top of a Proxmox host.

{{< /admonition >}}

## Prerequisites

- **Proxmox VE 8.x** or newer.
- Official **Windows 11** ISO (`Win11_XXXX_64.iso`).
- **VirtIO Drivers** ISO ([official download](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/), file `virtio-win.iso`).
- **Minimum**: 4 GB RAM, 2 vCPU, 64 GB disk.
- **Recommended for comfortable use**: 8 GB RAM, 4 vCPU, 64+ GB disk.
- Network with DHCP available.

## Create the VM

From the Proxmox web GUI, or via CLI. These are the parameters I use:

| Parameter | Value |
|------------|-------|
| VM ID | `400` |
| Name | `vm-win11` |
| Operating system | Windows 11 (64-bit) |
| BIOS | `OVMF (UEFI)` |
| Machine | `q35` |
| TPM | `TPM 2.0` (required on Win11) |
| Storage | `local-lvm` or `zfs` (depending on your setup) |
| Network | `virtio (paravirtualized)` |

If you prefer the command line over the web GUI, the equivalent is:

```bash
qm create 400 --name vm-win11 --memory 8192 --cores 4 --cpu host --machine q35 --bios ovmf --efidisk0 local-lvm:1,format=raw,efitype=4m,pre-enrolled-keys=1 --tpmstate0 local-lvm:1,version=v2.0 --scsihw virtio-scsi-pci --scsi0 local-lvm:64,format=qcow2 --net0 virtio,bridge=vmbr0 --cdrom local:iso/Win11.iso --boot order=scsi0;ide2;net0
```

Attach the VirtIO ISO as a second CD/DVD:

```bash
qm set 400 --ide2 local:iso/virtio-win.iso
```

## Install Windows 11

Start the VM from the GUI or with:

```bash
qm start 400
```

Access the graphical console from the VM's **Console** tab (noVNC in the browser). For SPICE with better performance and clipboard support:

```bash
qm spiceproxy 400
```

### Load the VirtIO drivers

In the Windows wizard, when you reach "Where do you want to install Windows?" no disk shows up (Windows doesn't ship VirtIO drivers out of the box):

1. Click **Load driver**.
2. Select the VirtIO CD (`virtio-win.iso`).
3. Path: `vioscsi/w11/amd64` → accept. The disk appears.
4. Continue the install normally.

### DHCP network during install

If Windows doesn't detect the network, from the console:

1. Press `Shift + F10`.
2. Load the VirtIO network driver:

   ```cmd
   drvload e:\NetKVM\w11\amd64\netkvm.inf
   ```

3. Close the console and continue. The adapter will get an IP via DHCP.

### Windows 11 OOBE

The first-boot steps (keyboard, region, local account, PIN, "no" to diagnostics/location) are the same as the rest of the series: see [Windows 11 OOBE]({{< relref "2024-08-23-dual-linux-win.md" >}}#windows-11-oobe-first-boot-setup).

## Post-install

### Install the VirtIO tools

1. Open the VirtIO CD in Explorer.
2. Run `virtio-win-guest-tools.exe`.
3. Install every component (VirtIO drivers: storage/network/balloon, and QEMU Guest Agent).
4. Reboot.

### Enable the QEMU Guest Agent

On the Proxmox host:

```bash
qm set 400 --agent enabled=1,fstrim_cloned_disks=1
```

Verify inside the VM (PowerShell as admin):

```powershell
Get-Service QEMU-GA
```

If it's not running:

```powershell
Set-Service QEMU-GA -StartupType Automatic
Start-Service QEMU-GA
```

From here Proxmox can execute commands inside the guest:

```bash
qm guest ping 400
qm guest exec 400 -- cmd /c ipconfig
```

> Keep the VirtIO ISOs and QEMU Guest Agent tools updated inside Windows — it improves stability and compatibility with future Proxmox releases.

## Graphical access

Three options, by use case:

**RDP (typical post-install use)**. Control Panel → System → Remote Settings → enable *Allow remote connections*. From another machine:

```bash
rdesktop <DHCP-IP>        # Linux
mstsc /v:<IP>             # Windows
```

**SPICE (remote console with better performance)**. In the VM: Hardware → Add → Display → `SPICE`. On the client:

```bash
# Linux
sudo apt install virt-viewer

# Windows: https://virt-manager.org/download/
```

From Proxmox, click **Console (SPICE)**.

**Internal VNC**. Proxmox provides a browser-based VNC console in the VM's *Console* tab — handy during install and for emergency access.

## Backup and snapshots

With the QEMU Guest Agent enabled, backups are consistent (fs-freeze/fs-thaw) without stopping the VM:

```bash
vzdump 400 --mode snapshot --compress zstd --storage vault-backup
```

In the output you'll see:

```bash
INFO: issuing guest-agent 'fs-freeze'
INFO: issuing guest-agent 'fs-thaw'
```

## Reference configuration file

Example of `/etc/pve/qemu-server/400.conf` with everything above applied:

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
