---
title: "VMWare on Windows"
date: "2024-08-26"
categories: ["sysadmin"]
tags: ["vmware","windows","win11","linux","development"]
draft: false
cover:
  image: "/img/posts/logo-vmware-vm.svg"
  hidden: true
---


<img src="/img/posts/logo-vmware-vm.svg" alt="vmware win logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

I install **VMware Workstation Pro** on top of a Windows 11 Pro host and create a Guest VM running Windows 11 Pro (optionally without TPM 2.0) as an isolated development environment.

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

## Install VMware Workstation Pro

VMware Workstation Pro and VMware Fusion have been free for personal use since 2024. From the [VMware site](https://www.vmware.com/products/workstation-pro.html), go directly to [Workstation Pro (Win/Linux)](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware%20Workstation%20Pro&freeDownloads=true) or [Fusion Pro (Mac)](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware%20Fusion&freeDownloads=true).

You must register as a Broadcom user. Once on the downloads page, first open the *terms & conditions* or it won't let you accept them. Sign in before clicking Download. For updates: the in-app updater doesn't work well — better to hit the website and grab the new version.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-01.png" alt="VMware Workstation Pro install" width="400px" />
  <div class="image-caption">VMware Workstation Pro install</div>
</div>

I used `VMware-workstation-full-17.6.2-24409262.exe`. Run it, accept terms, and customize the install (location, shortcuts, etc.).

## Create a Windows 11 Pro VM

I download the Windows 11 ISO from [Microsoft's downloads](https://www.microsoft.com/software-download/windows11) — `Windows 11 (multi-edition ISO for x64 devices)`. The file `Win11_24H2_English_x64.iso` is around 5.4 GB.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-02.jpg" alt="Creating a VM manually" width="800px" />
  <div class="image-caption">Creating a VM manually</div>
</div>

VM specs (reasonable minimum for development): **4 vCPU, 16 GB RAM, 120 GB max disk**.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-03.jpg" alt="Finishing the VM creation" width="800px" />
  <div class="image-caption">Finishing the VM creation</div>
</div>

With the VM created, attach the official ISO to the CD/DVD from settings, boot, press a key/ESC to boot off the DVD, and proceed to the keyboard-layout screen.

### Bypass TPM 2.0 and Secure Boot (optional)

If you want to skip the TPM and Secure Boot requirements (useful for lab work, discouraged in production), do it **here**, on the keyboard screen, **before** proceeding. Important: when creating the VM, tell VMware the guest is Windows 10 even though the ISO is Windows 11.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-04.jpg" alt="Press Shift-F10 during boot to bypass TPM" width="800px" />
  <div class="image-caption">Press Shift-F10 during boot to bypass TPM</div>
</div>

1. Press **Shift + F10** to open a CMD console.
2. Run `regedit`.
3. Navigate to `HKEY_LOCAL_MACHINE\SYSTEM\Setup`.
4. Right-click on `Setup` → **New > Key** → `LabConfig`.
5. Inside `LabConfig`, create two DWORD (32-bit) values with value `1`:
   - `BypassTPMCheck`
   - `BypassSecureBootCheck`
6. Close regedit and the CMD. Back to the Windows wizard.

> If you're not going to bypass TPM, ignore this section and continue with the normal install.

### Continue with the install

Continue through the Windows wizard. The OOBE steps (keyboard, region, local account, PIN, "no" to diagnostics/location, etc.) are identical to those in post 1: see [Windows 11 OOBE]({{< relref "2024-08-23-dual-linux-win.md" >}}#windows-11-oobe-first-boot-setup).

### VMware-specific configuration

Once inside Windows:

- Install the **VMware Tools**: menu `VM > Install VMware Tools`, then `Win+R` → `D:\setup.exe`.
- Shut down the VM and disable the CD/DVD at boot.
- `VM > Options`:
  - **Enable Shared Folders** (to access the host's disk).
  - Sync the guest time with the host.
- Power the VM back on, go to `Settings > Options > Autologin` and enable it.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-05.jpg" alt="My Windows 11 VM is ready" width="730px" />
  <div class="image-caption">My Windows 11 VM is ready</div>
</div>

### Customize the VM's OS

I apply exactly the same steps to the Guest as to any Windows 11:

- [A decent Windows 11]({{< relref "2025-08-03-win-decente.md" >}}) to strip the cruft.
- [Windows for development]({{< relref "2024-08-25-win-desarrollo.md" >}}) to set up the dev environment.

When done, shut down the VM and keep the image as a base for future ones.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-06.jpg" alt="A new isolated development environment" width="730px" />
  <div class="image-caption">A new isolated development environment</div>
</div>

## Clone the VM as a template

Once the VM is polished, it's worth saving it as a **base** for spinning up new VMs quickly (tests, labs, etc.) or distributing it to other machines.

> If you're going to create template(s), delete SNAPSHOTS beforehand.

### Option A — Generalize with Sysprep + Clone

If you want each clone to prompt for its own initial configuration:

1. Run `C:\Windows\System32\Sysprep\sysprep.exe` → **Generalize**, **Shutdown**, **Out-of-box experience**. Next time the VM boots it'll ask for region, keyboard, device name, PIN, etc. (all the "no"s again).
2. The VM shuts down.
3. `VM > Manage > Clone` → Current state, Full clone, name it "Win11-Maestra".
4. VMware saves it under `Documents/Virtual Machines/Win11-Maestra/`.
5. Optional: ZIP that folder for distribution (takes a while).

To use the clone elsewhere:

- Copy the folder or extract the ZIP.
- Rename the `.vmx` and the folder if you want.
- Open the `.vmx` from VMware.
- When asked whether you moved or copied the VM → **"I copied it"** to regenerate UUID and MAC.

### Option B — VMware OVF Tool

Useful for migrating to another platform (ESXi, VirtualBox) or for public distribution (educational or demo images).

1. Download and install the [OVF Tool](https://developer.vmware.com/web/tool/ovf/) and add it to the PATH:

    ```PowerShell
    $ovfToolPath = "C:\Program Files\VMware\VMware OVF Tool"
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$ovfToolPath", [EnvironmentVariableTarget]::User)
    ```

2. From the CLI, inside the VM directory (takes a while):

    ```PowerShell
    ovftool.exe .\Win11-Maestra.vmx ..\Win11-Maestra.ova
    ```

Example: I moved the same VM (as a ZIP) to an Ubuntu 24.04 Linux host with VMware Workstation Pro and it just worked.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-09.jpg" alt="Same VM running on Ubuntu 24.04 Linux" width="800px" />
  <div class="image-caption">Same VM running on Ubuntu 24.04 Linux</div>
</div>
