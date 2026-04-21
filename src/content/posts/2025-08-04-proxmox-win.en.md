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

Complete guide with all the detailed steps to install, configure and access a Windows 11 Pro Virtual Machine (VM) running on top of [Proxmox VE](https://www.proxmox.com/en/proxmox-ve).

This virtualization platform enables the deployment and management of **virtual machines** running Windows Server/10/11 using [KVM](https://www.linux-kvm.org/page/Main_Page)/[QEMU](https://www.qemu.org). With advanced integration through the QEMU Guest Agent, VirtIO drivers, and even UEFI Secure Boot with TPM emulation for Windows 11.

<br clear="left"/>
<style>
table {
    font-size: 0.8em;
}
</style>
<!--more-->

{{< admonition note "Windows posts series">}}

- Prepare a PC for [Dualboot Linux / Windows]({{< relref "2024-08-23-dual-linux-win.md" >}}) and install Windows 11 Pro.
- Configure [a decent Windows 11]({{< relref 2025-08-03-win-decente.md >}}) by removing the bloatware.
- Prepare [Windows for software development]({{< relref 2024-08-25-win-desarrollo.md >}}), CLI, WSL2 and tools.
- Installation of [VMWare Workstation Pro on Windows 11]({{< relref 2024-08-26-win-vmware.md >}}) with a Windows 11 Pro VM.
- Installation of [Windows 11 VM on Proxmox]({{< relref 2025-08-04-proxmox-win.md >}}) to run Windows 11 Pro on a Proxmox host.

{{< /admonition >}}

---

## Introduction

Let's go step by step through how to install a **virtual machine (VM)** with **Windows 11** on **Proxmox VE**, using the **QEMU Guest Agent**, **VirtIO** drivers, and enabling graphical access (during and after installation).

---

## Prerequisites

- **Proxmox VE 8.x** or higher.
- Official **Windows 11** ISO image (`Win11_XXXX_64.iso`).
- **VirtIO Drivers** ISO image (paravirtualized drivers):
  - [Official](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/) download
  - File: `virtio-win.iso`
- At least **4 GB RAM**, **2 vCPU**, **64 GB disk**.
- Network connection with **DHCP** available.

---

## 1. VM Creation

From the **Proxmox node** or through the web interface.

| Parameter | Value |
|------------|-------|
| VM ID | `400` |
| Name | `vm-win11` |
| Operating system | Windows 11 (64-bit) |
| BIOS | `OVMF (UEFI)` |
| Machine | `q35` |
| TPM | `TPM 2.0` (required by Windows 11) |
| Storage | `local-lvm` or `zfs` (depending on environment) |
| Network | `virtio (paravirtualized)` |

**Creation via CLI**:

```bash
qm create 400   --name vm-win11   --memory 8192   --cores 4   --cpu host   --machine q35   --bios ovmf   --efidisk0 local-lvm:1,format=raw,efitype=4m,pre-enrolled-keys=1   --tpmstate0 local-lvm:1,version=v2.0   --scsihw virtio-scsi-pci   --scsi0 local-lvm:64,format=qcow2   --net0 virtio,bridge=vmbr0   --cdrom local:iso/Win11.iso   --boot order=scsi0;ide2;net0
```

Add the VirtIO drivers ISO:

```bash
qm set 400 --ide2 local:iso/virtio-win.iso
```

---

## 2. Windows 11 Installation

### Start the VM

From the Proxmox web interface or CLI:

```bash
qm start 400
```

Open the **graphical console**:

- In the Proxmox GUI -> select the VM -> **Console** tab.
- Or via CLI using SPICE:

```bash
qm spiceproxy 400
```

> Note: During installation, the Proxmox console (based on noVNC or SPICE) is used for graphical access.

### Load VirtIO drivers

In the Windows installation wizard:

1. At the "Where do you want to install Windows?" step, no disks will appear.
2. Click **Load driver**.
3. Select **Browse to VirtIO CD** (`virtio-win.iso`).
4. Path: `vioscsi/w11/amd64` -> accept -> the virtual disk will appear.
5. Continue the installation normally.

### Network configuration (DHCP)

During installation, if Windows doesn't detect a network:

1. Open console (Shift+F10).
2. Run:

   ```cmd
   drvload e:\NetKVM\w11\amd64\netkvm.inf
   ```

3. Close console, continue installation.

The VirtIO adapter will receive an IP via DHCP automatically.

---

## 3. Post-installation and optimization

### Install VirtIO tools

Once inside the system:

1. Open the **VirtIO CD** in the file explorer.
2. Run `virtio-win-guest-tools.exe`.
3. Install all components:
   - VirtIO drivers (storage, network, balloon).
   - QEMU Guest Agent.

Restart the system.

---

## 4. Enable QEMU Guest Agent

On the Proxmox host:

```bash
qm set 400 --agent enabled=1,fstrim_cloned_disks=1
```

Verify from the VM (elevated PowerShell):

```powershell
Get-Service QEMU-GA
```

If it's not running:

```powershell
Set-Service QEMU-GA -StartupType Automatic
Start-Service QEMU-GA
```

Now Proxmox can run:

```bash
qm guest ping 400
qm guest exec 400 -- cmd /c ipconfig
```

During backups you'll see:

```bash
INFO: issuing guest-agent 'fs-freeze'
INFO: issuing guest-agent 'fs-thaw'
```

---

## 5. Graphical access

### During installation

- Use the **Proxmox Console (noVNC or SPICE)**.
- SPICE offers better performance and clipboard support.

### Once installed (remote GUI)

Options:

#### a) **RDP (Remote Desktop Protocol)**

1. Inside Windows -> Control Panel -> System -> Remote settings.
2. Enable *Allow remote connections*.
3. From another Windows or Linux machine:

```bash
rdesktop <DHCP-IP>
# or from Windows: mstsc /v:<IP>
```

#### b) **SPICE (Proxmox GUI)**

- On the VM -> Hardware -> Add -> Display device -> `SPICE`.
- Install **Virt-Viewer** on your local client:

```bash
# Linux
sudo apt install virt-viewer

# Windows: Download from https://virt-manager.org/download/
```

- Click **Console (SPICE)** from Proxmox.

**Internal VNC**: Proxmox provides a VNC console accessible via browser -> *Console* tab.

---

## 6. Complete configuration (example)

File `/etc/pve/qemu-server/400.conf`:

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

## 7. Backup and snapshots

Windows 11 supports **snapshot** mode backups:

```bash
vzdump 400 --mode snapshot --compress zstd --storage vault-backup
```

Proxmox will run:

```bash
INFO: issuing guest-agent 'fs-freeze'
INFO: issuing guest-agent 'fs-thaw'
```

The VM will keep running without interruption.

---

## 8. Conclusion

Proxmox VE allows running Windows 10/11 with excellent performance, UEFI + TPM 2.0 support, and consistent backups thanks to the QEMU Guest Agent. Using VirtIO drivers is key for optimal performance.

**Main advantages:**

- Snapshot backups without stopping the VM.
- Full integration with guest agent (shutdown, IP, fs-freeze/thaw).
- Complete graphical access (noVNC, SPICE, RDP).
- Full compatibility with DHCP networks and modern storage.

---

> **Recommendation:** Keep the VirtIO ISO images and QEMU Guest Agent tools inside Windows up to date. This improves stability and support for future Proxmox versions.
