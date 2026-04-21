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

La virtualización permite ejecutar múltiples sistemas operativos en un mismo equipo sin necesidad de realizar cambios en el disco principal. En este apunte muestro cómo instalo **VMWare Workstation Pro** como anfitrión sobre un Windows 11 Pro y como creo un Guest Windows 11 Pro sin TPM 2.0, con el propósito de tener un entorno de desarrollo aislado.

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

## VMWare Workstation Pro

Como decía, usaré VMWare Workstation Pro como virtualizador y el anfitrión (host) es un Windows 11 Pro. He descartado Hyper-V o VirtualBox como virtualizador, Broadcom decidió liberar gratuitamente VMware Workstation Pro y VMware Fusion como parte de su estrategia tras la adquisición de VMware.

Desde el [sitio](https://www.vmware.com/products/workstation-pro.html) de VMWare y en concreto desde este [post](https://blogs.vmware.com/workstation/2024/05/vmware-workstation-pro-now-available-free-for-personal-use.html) se anunció la disponibilidad gratuita. Para instalarlo, accede directamente a [VMWare Workstation Pro (Win/Linux)](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware%20Workstation%20Pro&freeDownloads=true) o [VMware Fusion Pro (Mac)](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware%20Fusion&freeDownloads=true). La primera vez tienes que darte de alta como usuario de Broadcom. Cuando estes en la página de descargas *entra en las terms & conditions* o no te dejará aceptarlas. Luego te tienes que identificar antes de hacer el Download. Para futuros updates lo que hago es entrar de nuevo y bajarme versiones posteriores, porque el Update de la propia aplicación no me funciona.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-01.png" alt="Instalación de VMWare Workstation Pro" width="400px" />
  <div class="image-caption">Instalación de VMWare Workstation Pro</div>
</div>

En mi caso usé `VMware-workstation-full-17.6.2-24409262.exe`, lo ejecutas, aceptas los términos de licencia y personaliza la instalación si lo deseas (ubicación, accesos directos, etc.).

Aunque no viene al caso, la Instalación en Linux es también muy sencilla, simplemente ejecuté lo siguiente:

```shell
⚡ luis@kymerax:VMWare % sudo ./VMware-Workstation-Full-17.6.2-24409262.x86_64.bundle
Extracting VMware Installer...done.
Installing VMware Workstation 17.6.2
    Configuring...
[######################################################################] 100%
Installation was successful.
```

## Creo una VM con Windows 11 Pro

Descargo Windows 11 desde [descargas](https://www.microsoft.com/software-download/windows11) de Microsoft. Sección ISO, opción `Windows 11 (multi-edition ISO for x64 devices)`. Selecciono el Product language y empiezo la descarga. El archivo `Win11_24H2_English_x64.iso` ocupa aproximadamente 5,4GB.

> Nota: Si quieres puedes, **evitar los requisitos de TPM y Secure Boot de Windows 11**. Es ideal para probar o ejecutar Windows 11 en hardware no compatible o en máquinas virtuales, desaconsejado en producción. Si lo vas a querer hacer es importante que al crear una nueva VM le digas que es Windows 10 (aunque luego uses un ISO de Windows 11).

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-02.jpg" alt="Creo una VM de forma manual" width="800px" />
  <div class="image-caption">Creo una VM de forma manual</div>
</div>

Utilizo 4 vCPU's, 16 GB, un disco máximo de 120 GB

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-03.jpg" alt="Termino con la creación de la VM" width="800px" />
  <div class="image-caption">Termino con la creación de la VM</div>
</div>

Una vez que tengo la VM, conecto el ISO oficial al CD/DVD (ajustes de la VM), hago boot, pulso una tecla/ESC para que arranque del DVD y cuando llego a la pregunta del tipo de teclado.

Hago una pausa: Si NO vas a hacer lo de TPM, salta al punto "Seguir con la instalación".

**Solo si quieres desactivar el tema TPM 2.0**,

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-04.jpg" alt="Durante el boot pulso Shift-F10 para evitar TPM" width="800px" />
  <div class="image-caption">Durante el boot pulso Shift-F10 para evitar TPM</div>
</div>

Presionamos **Shift + F10, aparece la caja de DOS y arranco regedit**.

- Navego a `HKEY_LOCAL_MACHINE\SYSTEM\Setup`
- Botón derecho sobre `Setup` y selecciono `New > Key` y la llamo `LabConfig`
- En *LabConfig*
  - Botón derecho en panel derecho: `New > DWORD (32-bit)`: `BypassTPMCheck`
    - Doble click sobre *BypassTPMCheck- y pongo valor a `1`
  - Botón derecho en panel derecho: `New > DWORD (32-bit)`: `BypassSecureBootCheck`
    - Doble click sobre *BypassSecureBootCheck- y pongo valor a `1`

Cierro el editor del registry y cierro el command prompt. Vuelve a donde estábamos.

### Seguir con la instalación

Sigo con la instalación, teclado, updates, ponerle mote/nombre al equipo, pide cómo usarlo (personal o trabajo), selecciono "Personal", hago login con mi cuenta de microsoft y continúo configurando como equipo nuevo. Creo PIN y le digo que no a localización, no a buscar dispositivo, diagnósticos, inking, typing, tailored experiences, ads ID, etc. Me salto lo del teléfono, pido que no haga backups, que no importe nada de otro navegador y tras algún que otro reboot termina. Ya lo tienes !!

### Personalización

- Instalo las VMWare Tools
  - Menú de VMWare Workstation `VM` -> `Install VMWare Tools`
    - **Win+R `D:\setup.exe`**
- Apago la VM
- Deshabilito el CD/DVD durante el power on.
- VM -> Options
  - Enable Shared Folders (para acceder al disco del Host)
  - Sincronizo la hora del guest con la del host.
- Enciendo la VM, vuelvo a Settings -> Options -> Autologin: Lo activo.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-05.jpg" alt="Ya tengo mi VM con Windows 11" width="730px" />
  <div class="image-caption">Ya tengo mi VM con Windows 11</div>
</div>

- Personalizo esta máquina virtual. Dejar un Windows "decente" sin morralla es un proceso tedioso, pero merece la pena.
  - Aplico el apunte: [Un Windows 11 decente]({{< relref "2025-08-03-win-decente.md" >}})
  - Apago la VM y me guardo la imagen tal cual por si quiero crear otra en el futuro.

A partir de este momento ya tengo otro Windows dentro de Windows, aislado, muy útil para entornos de desarrollo. De hecho a mi VM le aplico el apunte [Windows para desarrollo]({{< relref "2024-08-25-win-desarrollo.md" >}}) de software.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-06.jpg" alt="Un nuevo entorno de desarrollo aislado" width="730px" />
  <div class="image-caption">Un nuevo entorno de desarrollo aislado</div>
</div>

### Clonar la VM

El objetivo es poder tener una "base" buena de VM para poder crear múltiples para pruebas, laboratorios, etc.

> Nota: Si vas a crear plantilla(s), elimina antes los SNAPSHOTS.

Una vez que tienes tu VM perfecta, vacía, sin morralla, actualizada, lo suyo es Salvarla para que sea la base de otras futuras.

- Estando todavía en tu VM, ejecuta lo siguiente si quieres "Generalizarla"
  - `C:\Windows\System32\Sysprep\sysprep.exe`-> Generalize, Shutdown, Out-of-box experience.
    - Más adelante, cuando uses esta imagen te pedirá: región, teclado, nombre dispositivo, opciones de login, PIN y un montón de opciones a las que vuelvo a decir que "no quiero nada..."
  - Se apagará la VM
  - VM > Manage > Clone  (Current state, Full clone, "Win11-Maestra")
- Fíjate dónde la salvar normalmente en tu `Documents/Virtual Machines/Win11-Maestra/**`
- Opcional: Haz un ZIP de la carpeta "Win11-Maestra" con todo su contenido (nota: tarda mucho)

Usar el clone en ese mismo equipo o en otro

- Copiarte el directorio Win11-Maestra a otro sitio.
- O bien copiar y descomprimir el ZIP
- Renombrar el `.vmx` y carpeta
- Abrir el `.vmx` desde VMware.
- Cuando pregunte si moviste o copiaste la VM → elige "I copied it" para regenerar UUID y MAC.

- VMware OVF Tool (otra opción)
  - Descarga e instala el OVF Tool desde el [Enlace oficial](https://developer.vmware.com/web/tool/ovf/)
  - Añádelo al PATH de tu usuario:

  ```PowerShell
  $ovfToolPath = "C:\Program Files\VMware\VMware OVF Tool"
  [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$ovfToolPath", [EnvironmentVariableTarget
  ```

  - Desde el CLI te vas al directorio "Win11-Maestra" y ejecutas lo siguiente (nota: tarda mucho)

  ```PowerShell
  ovftool.exe .\Win11-Maestra.vmx ..\Win11-Maestra.ova
  ```

  - Te puedes llevar el `.ova` a otros sitios y crear VM's desde él.
    - Útil para migrar a otra plataforma (como ESXi, VirtualBox, etc.)
    - Útil para distribuir públicamente una VM (por ejemplo, una imagen educativa o de demo).

En el ejemplo siguiente me llevé el ZIP a un Linux con Ubuntu 24.04 y VMWare Workstation Pro, lo descomprimí y ha funcionado perfectamente.

<div class="image-box">
  <img src="/img/posts/2024-08-26-win-vmware-09.jpg" alt="Misma VM corriendo en un Linux Ubuntu 24.04" width="800px" />
  <div class="image-caption">Misma VM corriendo en un Linux Ubuntu 24.04</div>
</div>
