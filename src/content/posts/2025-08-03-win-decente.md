---
title: "Un Windows decente"
date: "2025-08-03"
categories: ["administración"]
tags: ["linux","wsl","windows","win11","ubuntu","desarrollo","dualboot","limpio","lean","tiny","mini"]
draft: false
cover:
  image: "/img/posts/logo-win-decente.svg"
  hidden: true
---


<img src="/img/posts/logo-win-decente.svg" alt="logo linux desarrollo" width="150px" height="150px" style="float:left; padding-right:25px"  />

Según la RAE, *Deshinchar: tr. Deshacer o reducir lo hinchado*. De eso va este apunte: quitar a Windows 11 las apps, servicios y opciones que sobran — *bloatware* en inglés — que consumen recursos y ensucian la experiencia. Vale igual para un Windows recién instalado que para uno ya en uso.

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

## Estrategia

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-07.png" alt="Evitar la morralla (fuente dall-e)" width="400px" />
  <div class="image-caption">Evitar la morralla (fuente dall-e)</div>
</div>

El plan, en orden:

1. Preparar el SO: actualizaciones e imprescindibles (con un script propio).
2. Activar Windows con [MAS](https://github.com/massgravel/Microsoft-Activation-Scripts).
3. Deshinchar con [Win11Debloat](https://github.com/Raphire/Win11Debloat). Alternativas: [Winhance](https://github.com/memstechtips/Winhance), [Debloat 10/11 de Andrew Taylor](https://andrewstaylor.com/2022/08/09/removing-bloatware-from-windows-10-11-via-script/), [Tiny11 Builder](https://github.com/ntdevlabs/tiny11builder).
4. Rematar manualmente lo que no cubre el script.
5. Opcional: [instalación desatendida pre-deshinchada](#instalación-desatendida) para repetir el proceso en más equipos.

## Paso 1 — Preparar el SO

Con Windows 11 ya instalado (instalación normal desde la ISO oficial, o la [desatendida](#instalación-desatendida)):

### Actualiza el sistema

Start > "Update" > **Check for Updates** > aplica todas las actualizaciones pendientes y reinicia cuando toque.

### Ejecuta el script de imprescindibles

Este apunte va de quitar, pero hay algunos básicos que necesito sí o sí: Chrome, 7-Zip, VSCode, PowerShell 7 y PowerToys. Los instalo desde PowerShell 5 como administrador, ejecutando un script propio en mi repositorio.

1. Abre PowerShell como Administrador: Start > busca "PowerShell" > botón derecho > **Abrir como Administrador**.
2. Habilita System Restore y permite ejecutar scripts:

    ```PS1
    Enable-ComputerRestore -Drive "C:\"
    vssadmin resize shadowstorage /for=C: /on=C: /maxsize=10GB
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

3. Verifica que `winget` está presente (en Win11 actualizado suele estarlo) y acepta su acuerdo:

    ```PS1
    winget list
    ```

4. Reinicia.
5. Ejecuta el script, que instala Chrome, 7-Zip, VSCode, PowerShell 7, PowerToys y descarga Win11Debloat. Si prefieres otro navegador, instálalo a mano:

    ```PS1
    iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/LuisPalacios/devcli/main/addons/windecente-inicio.ps1" -UseBasicParsing).Content
    ```

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-01.png" alt="Ejecución del primer script automático" width="800px" />
  <div class="image-caption">Ejecución del primer script automático</div>
</div>

> El script deja Win11Debloat descargado listo para el Paso 3.

## Paso 2 — Activar Windows

Dos opciones:

**Clave retail.** Compra una copia digital de Windows 11 Pro a un minorista autorizado (barato y rápido, te llega la clave por correo). Luego: `Start > Settings > System > Activation > Change product key` y añades la clave.

**MAS — [Microsoft Activation Script](https://github.com/massgravel/Microsoft-Activation-Scripts).** Activador de código abierto para Windows y Office. Incluye HWID, Ohook, TSforge, KMS38 y Online KMS. Recomendable leerse [la documentación](https://massgrave.dev/). Lo uso para VMs y laboratorio:

1. Abre **PowerShell 7** como Administrador (el que instaló el script del Paso 1).
2. Ejecuta:

    ```PS1
    irm https://get.activated.win | iex
    ```

3. Elige `(1) HWID for Windows activation`.
4. Verifica en `Start > Settings > System > Activation`.

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-05.png" alt="Método MAS" width="600px" />
  <div class="image-caption">Método MAS</div>
</div>

> Para activar Office usa `(2) Ohook` desde el mismo script. Ver [la documentación](https://massgrave.dev/).

## Paso 3 — Deshinchar con Win11Debloat

[Win11Debloat](https://github.com/Raphire/Win11Debloat) es ligero y directo. Merece la pena leerse su [wiki](https://github.com/Raphire/Win11Debloat/wiki/) y la [configuración por defecto](https://github.com/Raphire/Win11Debloat/wiki/Default-Settings).

El script del Paso 1 ya lo dejó en `C:\Users\[usuario]\Desktop\Win11Debloat\`.

1. Edita `Appslist.txt` con las apps a desinstalar:

    ```PS1
    cd Desktop\Win11Debloat\Raphire-Win11Debloat-70ebe29
    notepad.exe Appslist.txt
    ```

    Puedes partir de [este Appslist.txt](https://gist.githubusercontent.com/LuisPalacios/919d1150ad31bb0a19d1528a38e6da81/raw/Appslist.txt) — marca unas cuantas más que las de por defecto, excepto **Edge**: el propio Win11Debloat recomienda no tocarlo automáticamente. Lo haremos a mano en el Paso 4.

2. Ejecuta el script y elige la opción 1:

    ```PS1
    .\Win11Debloat.ps1
    ```

    <div class="image-box">
      <img src="/img/posts/2025-08-03-win-decente-02.png" alt="Win11Debloat" width="600px" />
      <div class="image-caption">Win11Debloat - opción 1</div>
    </div>

3. Reinicia.

## Paso 4 — Deshinchar manualmente

Aquí queda rematar lo que Win11Debloat no cubre.

{{< admonition tip "Si instalaste de forma desatendida" >}}
Varios apartados siguientes (registro, privacidad, renombrar Home, apps preinstaladas, taskbar) ya vienen aplicados en el ISO generado con [UnattendedWinstall](#instalación-desatendida). Los marco como **`[desatendida ✓]`** en cada apartado — puedes saltártelos.
{{< /admonition >}}

### Ajustes de registro `[desatendida ✓]`

Abre PowerShell como administrador y ejecuta:

Desactivar "Let websites show me locally relevant content by accessing my language list":

```PS1
reg add "HKEY_CURRENT_USER\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d 1 /f
```

Poner UAC en "Never notify":

```PS1
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f
```

### Eliminar Edge y poner Chrome por defecto

Edge no es multiplataforma, así que lo quito del equipo.

- **Start > Settings > Apps**:
  - **Installed Apps**: elimina **Edge**.
  - Arranca Google Chrome y márcalo como navegador por defecto.
  - **Default apps > Google Chrome**: revisa que todo queda asignado a Chrome.
  - **Apps for Websites**: todo a **off**.

### Privacidad `[desatendida ✓]`

- **Privacy & Security**:
  - Security > Windows Security > `Open Windows Security`: todo **On**.
  - Windows Permissions: **todo off** (General, Speech, etc.).
  - App permissions > `Location`: **off**. El resto a valores por defecto.

### Renombrar la carpeta del usuario `[desatendida ✓]`

Durante la instalación Windows crea el nombre corto del usuario con los 5 primeros caracteres del email (en mi caso `luisp`, con HOME en `C:\Users\luisp\`). Para renombrarlo ([guía completa](https://www.elevenforum.com/t/change-name-of-user-profile-folder-in-windows-11.2133/)):

1. Habilita la cuenta Administrator:

    ```PS1
    net user Administrator /active:yes
    ```

2. Reinicia e inicia sesión como Administrator (sin contraseña).
3. Localiza el SID de tu usuario:

    ```PS1
    Get-LocalUser | Select-Object Name, SID
    ```

4. En `regedit`, edita `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-...\ProfileImagePath` con la ruta nueva.
5. En Explorer, renombra la carpeta de `C:\Users\luisp` a `C:\Users\luis`.
6. Crea un enlace simbólico para compatibilidad con programas que apuntaban a la carpeta vieja:

    ```PS1
    New-Item -ItemType SymbolicLink -Path "C:\Users\luisp" -Target "C:\Users\luis"
    ```

Si el enlace da problemas o se recrea la carpeta vieja, bórrala y usa un Junction:

```PS1
rmdir C:\Users\luisp
mklink /J C:\Users\luisp C:\Users\luis
```

### Quitar apps preinstaladas `[desatendida ✓]`

Start > botón derecho sobre los iconos que no uses > **Unpin** o **Uninstall** (en mi caso quité LinkedIn y similares).

### Personalizar el Taskbar `[desatendida ✓]`

- Botón derecho sobre los iconos del taskbar y quita los que no uses.
- Start > busca "Start settings":
  - Layout > **More pins**.
  - Show recently added apps: **off**.
  - Show recommended files...: **off**.
  - Show account notifications: **off**.
  - Show recently opened: **off**.

### Eliminar el teclado en inglés

Start > Settings > Time & Language > Language & Region > Preferred Languages > "..." > Options > Keyboards > **quita US** (deja solo Spanish).

### File Explorer

Mostrar archivos ocultos, extensiones y ruta completa:

- Start > Settings > `System` > `For developers`:
  - Habilita el modo desarrollador si no lo estaba.
  - Entra en `File Explorer`:
    - `Show file extensions`: **On**.
    - `Show hidden and system files`: **On**.
    - `Show full path in title bar`: **On**.
    - `Show empty drives`: **On**.

### File Sharing (SMB)

- Start > Settings > `Network and Internet` > `Advanced network settings > Advanced Sharing Settings`:
  - `File & Printer sharing`: **On**.
  - `Public folder sharing`: **On**.
- Start > Settings > System > About > `Advanced System Settings` > Computer Name > **Change**: verifica que está en **WORKGROUP**.
- Habilita SMB 1.0 solo si necesitas compatibilidad con equipos antiguos:
  - Start > "Control Panel" > `Programs` > `Programs and features` > `Turn Windows features on or off`.
  - Activa **SMB 1.0/CIFS File Sharing Support**.

### Firewall

La instalación por defecto pone la red en **Pública**. Si es una red privada, cámbialo:

Start > Settings > Network & Internet > Ethernet (y WiFi) > **Private Network**.

Para minimizar alertas del Firewall:

- Start > "Control Panel" > System & Security > Windows Defender Firewall:
  - `Advanced Settings`: revisa reglas de entrada y salida.
  - `Change notification settings`: desmarca "Notify me when Windows Defender Firewall blocks a new app".

### Desactivar Cortana

- Start > busca `gpedit.msc` y abre el Editor de directivas.
  - Navega a `Computer Configuration > Administrative Templates > Windows Components > Search`.
  - Doble click en **Allow Cortana** > **Disabled** > Aplicar.

### Más apps preinstaladas

Desinstalar crapware del fabricante mediante PowerShell. Qué desinstalar depende del OEM; [Should I Remove It?](http://www.shouldiremoveit.com) ayuda a decidir.

Listar todas las aplicaciones:

```PS1
Get-AppxPackage | Select Name, PackageFullName
```

Desinstalar una concreta:

```PS1
Get-AppxPackage *NombreDeLaApp* | Remove-AppxPackage
```

### Servicios innecesarios

Abre `services.msc`, identifica servicios que no uses (por ejemplo, los `xbox*`), doble click > **Startup type: Disabled** > Aplicar.

### Rendimiento: WinSAT

Para comprobar CPU, memoria, disco y gráficos:

```PowerShell
winsat formal
Get-CimInstance Win32_WinSat
```

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-04.png" alt="Idoneo para trabajar" width="600px" />
  <div class="image-caption">Idoneo para trabajar</div>
</div>

Los mismos pasos aplican a [máquinas virtuales Windows]({{< relref "2024-08-26-win-vmware.md" >}}), con muy buen rendimiento.

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-06.png" alt="Otro windows 11 optimizado, esta vez como Guest de VMWare Workstation" width="600px" />
  <div class="image-caption">Otro Windows 11 optimizado, esta vez como Guest de VMWare Workstation</div>
</div>

### Mantenimiento

Comandos útiles como administrador:

- `chkdsk`: comprueba el disco y corrige problemas.
- `sfc /SCANNOW`: analiza la integridad de archivos de sistema.
- `dism /online /cleanup-image /restorehealth`: descarga y reemplaza archivos corruptos desde Windows Update.

> **Aviso**: `sfc` tuvo durante años un falso positivo con `bthmodem.sys` (lo eliminaba como corrupto). Si te pasa, ejecuta `dism ... /restorehealth` para recuperarlo.

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-02.png" alt="Versión minimalista de Start" width="450px" />
  <div class="image-caption">Versión minimalista de Start</div>
</div>

## Herramienta devcli

Si trabajas mucho en el CLI, complementa este apunte con [Windows para desarrollo]({{< relref "2024-08-25-win-desarrollo.md" >}}), donde cubro CLI, Terminal, WSL2 y herramientas.

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-05.png" alt="Por opciones que no sea" width="2560px" />
  <div class="image-caption">Por opciones que no sea</div>
</div>

Allí menciono **[devcli](https://github.com/LuisPalacios/devcli)**, un proyecto propio para configurar el entorno CLI en Linux, macOS, WSL2 y Windows. Después de *deshinchar*, viene bien preparar el CLI:

- Instala herramientas: git, curl, wget, nano, htop, tmux, fzf, bat, fd-find, ripgrep, tree, jq, lsd, zoxide.
- Instala Oh-My-Posh para cualquier shell.
- Establece `LANG` (por defecto `es_ES.UTF-8`) en Linux, macOS y WSL2.
- Copia ficheros de configuración (ver el subdirectorio `dotfiles`).
- Copia mi caja de herramientas Git desde [gitbox](https://github.com/LuisPalacios/gitbox).
- Crea scripts útiles en `~/bin`: `e`, `s`, `confcat`.
- Instala FiraCode Nerd Font para iconos en herramientas como `lsd`.

## Instalación desatendida

Para repetir el proceso en más equipos conviene automatizar la propia instalación de Windows. Probé [UnattendedWinstall](https://github.com/memstechtips/UnattendedWinstall) y [WIMUtil](https://github.com/memstechtips/WIMUtil).

**1. Instala Windows ADK** (para obtener [oscdimg.exe](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/oscdimg-command-line-options), que se usa después):

- Descarga [Windows ADK](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install?source=recommendations), instálalo y marca solo **Deployment Tools**.
- Copia el contenido de `C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\` a un directorio en tu PATH.

**2. Ejecuta WIMUtil** desde PowerShell como administrador:

```PowerShell
irm "https://github.com/memstechtips/WIMUtil/raw/main/src/WIMUtil.ps1" | iex
```

Esto genera un ISO custom usando el `autounattend.xml` de [UnattendedWinstall](https://github.com/memstechtips/UnattendedWinstall):

- Selecciona ISO, directorio temporal, **START**.
- Next > personalizar Windows > **Download UW** (descarga el de UnattendedWinstall). Sin answer file.
- Next > opcionalmente "Add Drivers" del Windows donde estás ejecutándolo.
- Next > Select Location > `win11-custom.iso`.
- **Create ISO**.

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-08.png" alt="Crear un ISO desatendido" width="800px" />
  <div class="image-caption">Crear un ISO desatendido</div>
</div>

**3. Prueba el ISO en una VM** (ver [VMWare en Windows]({{< relref "2024-08-26-win-vmware.md" >}})):

- VMware Workstation > New virtual Machine > Typical > Installer disc > `win11-custom.iso`.
- La instalación solo pide lenguaje, hora, teclado, tipo de disco, usuario y preguntas de seguridad. Rapidísima.

> **Importante**: al terminar la instalación desatendida, **Defender y UAC quedan deshabilitados**. Reactiva al menos Defender.

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-09.png" alt="Parametrización final" width="650px" />
  <div class="image-caption">Parametrización final</div>
</div>

Tras reiniciar, instala las VMware Tools y vuelve al **Paso 1** para rematar.

## Enlaces útiles

- **[Clink](https://github.com/chrisant996/)**: enriquece el CMD (`cmd.exe`) con readline al estilo Linux — colores, historial, autocompletado.
- **[CCleaner](https://www.ccleaner.com/)**: limpieza general, aunque lo interesante requiere licencia Pro.
- **[BleachBit](https://www.bleachbit.org/)**: alternativa Open Source a CCleaner (sin Registry ni Optimización de rendimiento). Antes de instalar la última versión, baja el [Visual Studio 2019 (VC++ 10.0) redistributable SP1 x86](https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe).
- **[TCPView](https://learn.microsoft.com/en-us/sysinternals/downloads/tcpview)**: conexiones de red en tiempo real (Sysinternals).
- **[Autoruns](https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns)**: todo lo que arranca automáticamente con Windows (más completo que Task Manager o MSConfig).
- **[Sysinternals Suite](https://learn.microsoft.com/en-us/sysinternals/downloads/)**: la suite completa de herramientas avanzadas (Russinovich/Cogswell, mantenida por Microsoft).
- **[Generador de autounattend.xml](https://schneegans.de/windows/unattend-generator/)** para Windows 10/11.
- **[Winhance](https://github.com/memstechtips/Winhance)**: tras toda la limpieza, aún quedaban cosas que pude pulir con Winhance.

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-03.png" alt="Winhance - Windows Enhancement Utility" width="650px" />
  <div class="image-caption">Winhance - Windows Enhancement Utility</div>
</div>
