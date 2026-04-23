---
title: "VMWare en Windows"
date: "2024-08-26"
categories: ["administración"]
tags: ["vmware","windows","win11","linux","desarrollo"]
draft: false
cover:
  image: "/img/posts/logo-vmware-vm.svg"
  hidden: true
---


<img src="/img/posts/logo-vmware-vm.svg" alt="logo vmware win" width="150px" height="150px" style="float:left; padding-right:25px"  />

Instalo **VMware Workstation Pro** sobre un Windows 11 Pro anfitrión y creo una VM Guest con Windows 11 Pro (opcionalmente sin TPM 2.0) como entorno de desarrollo aislado.

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

## Instalar VMware Workstation Pro

VMware Workstation Pro y VMware Fusion son gratis para uso personal desde 2024. Desde el [sitio de VMware](https://www.vmware.com/products/workstation-pro.html) accede directamente a [Workstation Pro (Win/Linux)](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware%20Workstation%20Pro&freeDownloads=true) o [Fusion Pro (Mac)](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware%20Fusion&freeDownloads=true).

Darse de alta como usuario de Broadcom es obligatorio. Una vez en la página de descargas, entra primero en las *terms & conditions* o no te dejará aceptarlas. Identifícate antes de pulsar Download. Para los updates: el update interno de la app no funciona bien — mejor entrar a la web y bajar la versión nueva.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-01.png" alt="Instalación de VMWare Workstation Pro" width="400px" />
  <div class="image-caption">Instalación de VMware Workstation Pro</div>
</div>

Usé `VMware-workstation-full-17.6.2-24409262.exe`. Ejecutas, aceptas términos y personalizas la instalación (ubicación, accesos directos, etc.).

## Crear una VM con Windows 11 Pro

Descargo el ISO de Windows 11 desde [descargas de Microsoft](https://www.microsoft.com/software-download/windows11) — `Windows 11 (multi-edition ISO for x64 devices)`. El archivo `Win11_24H2_English_x64.iso` ocupa unos 5,4 GB.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-02.jpg" alt="Creo una VM de forma manual" width="800px" />
  <div class="image-caption">Creo una VM de forma manual</div>
</div>

Specs de la VM (mínimo razonable para desarrollo): **4 vCPU, 16 GB RAM, disco máximo 120 GB**.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-03.jpg" alt="Termino con la creación de la VM" width="800px" />
  <div class="image-caption">Termino con la creación de la VM</div>
</div>

Con la VM creada, conecto el ISO oficial al CD/DVD desde los ajustes, hago boot, pulso una tecla/ESC para arrancar del DVD y llego a la pantalla del tipo de teclado.

### Bypass de TPM 2.0 y Secure Boot (opcional)

Si quieres saltarte los requisitos de TPM y Secure Boot (útil para laboratorio, desaconsejado en producción), hay que hacerlo **aquí**, en la pantalla del teclado, **antes** de continuar. Importante: al crear la VM, dile a VMware que el sistema es Windows 10, aunque el ISO sea de Windows 11.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-04.jpg" alt="Durante el boot pulso Shift-F10 para evitar TPM" width="800px" />
  <div class="image-caption">Durante el boot pulso Shift-F10 para evitar TPM</div>
</div>

1. Pulsa **Shift + F10** para abrir la consola CMD.
2. Ejecuta `regedit`.
3. Navega a `HKEY_LOCAL_MACHINE\SYSTEM\Setup`.
4. Botón derecho sobre `Setup` → **New > Key** → `LabConfig`.
5. Dentro de `LabConfig`, crea dos DWORD (32-bit) con valor `1`:
   - `BypassTPMCheck`
   - `BypassSecureBootCheck`
6. Cierra regedit y la CMD. Vuelves al asistente de Windows.

> Si no vas a saltarte TPM, ignora esta sección y sigue con la instalación normal.

### Continuar con la instalación

Continúa con el asistente de Windows. Los pasos del OOBE (teclado, región, cuenta local, PIN, "no" a diagnósticos/localización, etc.) son idénticos a los del post 1: ver [Windows 11 OOBE]({{< relref "2024-08-23-dual-linux-win.md" >}}#windows-11-oobe-setup-inicial).

### Configuración específica de VMware

Una vez dentro de Windows:

- Instala las **VMware Tools**: menú `VM > Install VMware Tools`, luego `Win+R` → `D:\setup.exe`.
- Apaga la VM y deshabilita el CD/DVD al arrancar.
- `VM > Options`:
  - **Enable Shared Folders** (para acceder al disco del host).
  - Sincroniza la hora del guest con la del host.
- Enciende la VM, vuelve a `Settings > Options > Autologin` y actívalo.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-05.jpg" alt="Ya tengo mi VM con Windows 11" width="730px" />
  <div class="image-caption">Ya tengo mi VM con Windows 11</div>
</div>

### Personalizar el SO de la VM

Aplico al Guest exactamente los mismos pasos que a cualquier Windows 11:

- [Un Windows 11 decente]({{< relref "2025-08-03-win-decente.md" >}}) para quitar la morralla.
- [Windows para desarrollo]({{< relref "2024-08-25-win-desarrollo.md" >}}) para montar el entorno de desarrollo.

Al terminar, apaga la VM y guarda la imagen como base para futuras.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-06.jpg" alt="Un nuevo entorno de desarrollo aislado" width="730px" />
  <div class="image-caption">Un nuevo entorno de desarrollo aislado</div>
</div>

## Clonar la VM como plantilla

Con la VM ya pulida, conviene guardarla como **base** para crear nuevas VMs rápidamente (pruebas, laboratorios, etc.) o distribuirla a otras máquinas.

> Si vas a crear plantilla(s), elimina antes los SNAPSHOTS.

### Opción A — Generalizar con Sysprep + Clone

Si quieres que cada clon pida su propia configuración inicial:

1. Ejecuta `C:\Windows\System32\Sysprep\sysprep.exe` → **Generalize**, **Shutdown**, **Out-of-box experience**. La próxima vez que arranque la VM pedirá región, teclado, nombre del equipo, PIN, etc. (otra vez todos los "no").
2. La VM se apaga.
3. `VM > Manage > Clone` → Current state, Full clone, nombre "Win11-Maestra".
4. VMware la guarda en `Documents/Virtual Machines/Win11-Maestra/`.
5. Opcional: ZIP de esa carpeta para distribución (tarda bastante).

Para usar el clon en otro sitio:

- Copia la carpeta o descomprime el ZIP.
- Renombra el `.vmx` y la carpeta si quieres.
- Abre el `.vmx` desde VMware.
- Cuando pregunte si moviste o copiaste la VM → **"I copied it"** para regenerar UUID y MAC.

### Opción B — VMware OVF Tool

Útil para migrar a otra plataforma (ESXi, VirtualBox) o distribuir públicamente (imágenes educativas o demos).

1. Descarga e instala [OVF Tool](https://developer.vmware.com/web/tool/ovf/) y añádelo al PATH:

    ```PowerShell
    $ovfToolPath = "C:\Program Files\VMware\VMware OVF Tool"
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$ovfToolPath", [EnvironmentVariableTarget]::User)
    ```

2. Desde el CLI, en el directorio de la VM (tarda bastante):

    ```PowerShell
    ovftool.exe .\Win11-Maestra.vmx ..\Win11-Maestra.ova
    ```

Ejemplo: moví la misma VM (vía ZIP) a un Linux Ubuntu 24.04 con VMware Workstation Pro y funcionó sin tocar nada.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-09.jpg" alt="Misma VM corriendo en un Linux Ubuntu 24.04" width="800px" />
  <div class="image-caption">Misma VM corriendo en un Linux Ubuntu 24.04</div>
</div>
