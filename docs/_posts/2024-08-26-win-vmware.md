---
title: "VMWare en Windows"
date: "2024-08-26"
categories: administración
tags: vmware windows win11 linux desarrollo
excerpt_separator: <!--more-->
---


![logo vmware win](/assets/img/posts/logo-vmware-vm.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

La virtualización permite ejecutar múltiples sistemas operativos en un mismo equipo sin necesidad de realizar cambios en el disco principal. En este apunte muestro cómo instalo VMWare Workstation Pro como anfitrión en Windows 11 Pro y como creo un Guest Windows 11 Pro sin TPM 2.0, con el propósito de tener un entorno de desarrollo aislado.

<br clear="left"/>
<style>
table {
    font-size: 0.8em;
}
</style>
<!--more-->

| Este apunte pertenece a la serie de desarrollo de software con Windows:<br>• Preparar un PC para [Dualboot Linux / Windows]({% post_url 2024-08-23-dual-linux-win %}) e instalar Windows 11 Pro.<br>• Configurar [un Windows 11 decente]({% post_url 2024-08-24-win-decente %}), dejarlo en su esencia minima, quitando la morralla.<br>• Preparar [Windows para desarrollo de software]({% post_url 2024-08-25-win-desarrollo %}) de software, CLI, WSL2 y herramientas.<br>• Instalación de [VMWare en Windows]({% post_url 2024-08-26-win-vmware %}) para tener una VM con Windows 11 Pro. |

## VMWare Workstation Pro

Como decía, usaré VMWare Workstation Pro como virtualizador y el anfitrión (host) es un Windows 11 Pro. He descartado Hyper-V o VirtualBox como virtualizador, Broadcom decidió liberar gratuitamente VMware Workstation Pro y VMware Fusion como parte de su estrategia tras la adquisición de VMware.

Desde el [sitio](https://www.vmware.com/products/workstation-pro.html) de VMWare y en concreto desde este [post](https://blogs.vmware.com/workstation/2024/05/vmware-workstation-pro-now-available-free-for-personal-use.html) se anunció la disponibilidad gratuita. Para instalarlo, accede directamente a [VMWare Workstation Pro (Win/Linux)](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Workstation+Pro) o [VMware Fusion Pro (Mac)](https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware+Fusion). La primera vez tienes que darte de alta como usuario de Broadcom.

{% include showImagen.html
      src="/assets/img/posts/2024-08-26-vmware-00.png"
      caption="Instalación de VMWare Workstation Pro"
      width="400px"
      %}

En mi caso usé `VMware-workstation-full-17.6.2-24409262.exe`, lo ejecutas, aceptas los términos de licencia y personaliza la instalación si lo deseas (ubicación, accesos directos, etc.).

## VM con Windows 11 Pro

Partiendo de estos requisitos:

- VMWare Workstation Pro instalado en Windows 11 Pro.
- Tener el ISO de Windows 11, descargable desde el sitio oficial de Microsoft.
- Espacio en disco para la máquina virtual (al menos 64GB).
- Memoria RAM suficiente, en mi caso le asigno 16GB.

Descargo Windows 11 desde [descargas](https://www.microsoft.com/software-download/windows11) de Microsoft. Sección ISO, opción `Windows 11 (multi-edition ISO for x64 devices)`. Selecciono el Product language y empiezo la descarga. El archivo `Win11_24H2_English_x64.iso` ocupa aproximadamente 5,4GB.

Ahora toca crear la Máquina Virtual. Quiero evitar los requisitos de TPM y Secure Boot de Windows 11. A continuación explico el método que sigo para hacerlo. Es ideal para probar o ejecutar Windows 11 en hardware no compatible o en máquinas virtuales, desaconsejado en producción.

- Desde VMWare Workstation Pro, crear una Nueva Máquina Virtual, de forma manual, indicando que es un Windows 10 (aunque voy a instalar Windows 11, lo vi recomendado por el tema de TPM, ante la duda hago caso).

{% include showImagen.html
      src="/assets/img/posts/2024-08-26-vmware-01.jpg"
      caption="Creo una VM de forma manual"
      width="800px"
      %}

Utilizo 4 vCPU's, 16 GB, un disco máximo de 120 GB

{% include showImagen.html
      src="/assets/img/posts/2024-08-26-vmware-02.jpg"
      caption="Termino con la creación de la VM"
      width="800px"
      %}

Una vez que tengo la VM, conecto el ISO oficial al CD/DVD (ajustes de la VM), hago boot, pulso una tecla/ESC para que arranque del DVD y cuando llego a la pregunta del tipo de teclado, hago una pausa para cambiar entradas del registro y desactivar el tema TPM 2.0.

{% include showImagen.html
      src="/assets/img/posts/2024-08-26-vmware-03.jpg"
      caption="Durante el boot pulso Shift-F10 para evitar TPM"
      width="800px"
      %}

Presionamos **Shift + F10, aparece la caja de DOS y arranco regedit**.

- Navego a `HKEY_LOCAL_MACHINE\SYSTEM\Setup`
- Botón derecho sobre `Setup` y selecciono `New > Key` y la llamo `LabConfig`
- En *LabConfig*
  - Botón derecho en panel derecho: `New > DWORD (32-bit)`: `BypassTPMCheck`
    - Doble click sobre *BypassTPMCheck- y pongo valor a `1`
  - Botón derecho en panel derecho: `New > DWORD (32-bit)`: `BypassSecureBootCheck`
    - Doble click sobre *BypassSecureBootCheck- y pongo valor a `1`

Cierro el editor del registry y cierro el command prompt. Vuelve a donde estábamos. Sigo con la instalación, teclado, updates, ponerle mote/nombre al equipo, pide cómo usarlo (personal o trabajo), selecciono "Personal", hago login con mi cuenta de microsoft y continúo configurando como equipo nuevo. Creo PIN y le digo que no a localización, no a buscar dispositivo, diagnósticos, inking, typing, tailored experiences, ads ID, etc. Me salto lo del teléfono, pido que no haga backups, que no importe nada de otro navegador y tras algún que otro reboot termina. Ya lo tienes !!

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

{% include showImagen.html
      src="/assets/img/posts/2024-08-26-vmware-04.jpg"
      caption="Ya tengo mi VM con Windows 11"
      width="730px"
      %}

- Personalizo esta máquina virtual. Dejar un Windows "decente" sin morralla es un proceso tedioso, pero merece la pena.
  - Aplico el apunte: [Un Windows 11 decente]({% post_url 2024-08-24-win-decente %})
  - Apago la VM y me guardo la imagen tal cual por si quiero crear otra en el futuro.

- VM para desarrollo de software. Este era el propósito inicial.
  - Aplico el apunte: [Windows para desarrollo]({% post_url 2024-08-25-win-desarrollo %}) de software.
  - Apago la VM y guardo una copia de seguridad.

A partir de este momento ya tengo otro Windows dentro de Windows, aislado, muy útil para entornos de desarrollo.

{% include showImagen.html
      src="/assets/img/posts/2024-08-26-vmware-05.jpg"
      caption="Un nuevo entorno de desarrollo aislado"
      width="730px"
      %}
