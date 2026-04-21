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

Según la RAE, *Deshinchar: tr. Deshacer o reducir lo hinchado*. De eso va este apunte, de desinflamar, de quitar lo que personalmente creo que le sobra a Windows 11. En inglés lo llaman *debloat* o eliminación del *bloatware*. En este apunte explico como hacerlo en un Windows nuevo pero tambien vale para uno instalado.

Lo dicho, va de borrar aplicaciones, servicios y morralla preinstalada que no son esenciales, que consumen recursos y lo que es peor, afectan al rendimiento y el UX.

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

> Tengo una versión antigua de este apunte [aquí]({{< relref 2024-08-24-win-decente-obsoleto.md >}}), que dejo solo a modo de referencia.

---

## Introducción

El **bloatware** en Windows es como la morralla en el mar: una mezcla de pececillos innecesarios que estorban, ocupan espacio y te distrae de lo importante.

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-07.png" alt="Evitar la morralla (fuente dall-e)" width="400px" />
  <div class="image-caption">Evitar la morralla (fuente dall-e)</div>
</div>

Mi estrategia, una solución híbrida:

- Opcional: Instalo Windows [de forma desatendida pre-deshinchado](#instalar-de-forma-desatendida).
- Actualizo e instalo algunos imprescindibles (con un script propio)
- Activo usando MAS
- Deshincho mucho con [Win11Debloat](https://github.com/Raphire/Win11Debloat)
  - Alternativas:
  - [Winhance - Windows Enhancement Utility](https://github.com/memstechtips/Winhance)
  - [Debloat Windows 10/11 de Andrew Taylor](https://andrewstaylor.com/2022/08/09/removing-bloatware-from-windows-10-11-via-script/)
  - [Tiny 11 Builder](https://github.com/ntdevlabs/tiny11builder)) pero me decanté por el primero.
- Termino de deshinchar manualmente algunas cosillas.
- Opcional: Instalo mi [herramienta `devcli`](#herramienta-devcli)

---

## Paso 1 - Preparo el SO

Lo primero es tener un Windows 11 instalado. No lo explico aquí, pero puedes usar el proceso de instalación normal, desde la imagen oficial de Microsoft o podrías [Instalar de forma desatendida](#instalar-de-forma-desatendida) que te añade un extra (de sencillez).

Una vez que tengo Windows 11 instalado, empiezo por actuailizarlo,

**Actualización del sistema operativo:**

- Start > "Update " > Check for Updates > Hago todas las **actualizaciones** que me pide (con el o los correspondientes reboots).

**Instalalación de mi script:**

Ya se que este apunte va de quitar, pero hay algunos básicos que necesito: Chrome, 7-Zip, VSCode, PowerShell 7, PowerToys. Desde PowerShell 5 como administrador, preparo el entorno y ejecuto un script desde mi repositorio en GitHub

- Start/Search > "PowerShell" > botón derecho > Abrir como Administrador. Abre un terminal PS5.
- Habilito System Restore y permito la ejecución de scripts

```PS1
Enable-ComputerRestore -Drive "C:\"
vssadmin resize shadowstorage /for=C: /on=C: /maxsize=10GB
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

- Ejecuto **`winget`** y acepto el acuerdo. Simplemente para doble confirmar que lo tengo instalado, algo normal en un Windows 11 actualizado.

```PS1
winget list
```

- Hago un reboot.

- Ejecuto mi script para instalar: **Google Chrome, 7-Zip, Visual Studio Code, PowerShell 7 y PowerToys** y bajarme **Win11Debloat**. Si quieres instalarte otro navegador, hazlo manualmente.

- De nuevo: Start/Search > "PowerShell" > botón derecho > Abrir como Administrador. Abre un terminal PS5.

```PS1
iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/LuisPalacios/devcli/main/addons/windecente-inicio.ps1" -UseBasicParsing).Content
```

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-01.png" alt="Ejecución del primer script automático" width="800px" />
  <div class="image-caption">Ejecución del primer script automático</div>
</div>

> Nota: Mi script se baja **Win11Debloat** que lo usaremos mas tarde.

### Activación de Windows

Descubrí en internet que para VM's o laboratorio hay un proyecto por ahí (libre en internet) llamado Microsoft Activation Script (MAS). En cualquier caso, tienes dos opciones:

Si quieres puedes comprar una copia digital de Windows 11 Pro retail a un minorista autorizado. Es barato y asequible, te llega un correo con la clave de producto. `Start > Settings > Sytem Activation > Change product key`, añado la clave recibida y queda activado.

Otra opción es MAS, [Microsoft Activation Script](https://github.com/massgravel/Microsoft-Activation-Scripts), se trata de una activador de código abierto para Windows y Office 365, 2024, etc... que incluye los métodos de activación HWID, Ohook, TSforge, KMS38 y Online KMS. Recomendado [leerese la documentación](https://massgrave.dev/). El atajo rápido sería así, con PowerShell 7 que se instaló en el paso anterior.

- Start/Search > **PowerShell 7** > botón derecho > **Abrir como Administrador**.

```PS1
irm https://get.activated.win | iex
```

- Entre las opciones de activación, seleccionas `(1) HWID for Windows activation` y queda activado.
- Cuando termine podrás comprobar el estado de activación: `Start > Settings > System > Activation`

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-05.png" alt="Método MAS" width="600px" />
  <div class="image-caption">Método MAS</div>
</div>

- Si quieres descargar y/o activar la Office 265 entra en la opción `(2) Ohook`. Echa un ojo a [la documentación](https://massgrave.dev/).

---

## Paso 2 - Win11Debloat para deshinchar

Ya estamos listos para [Win11Debloat](https://github.com/Raphire/Win11Debloat), fácil de usar y ligero. Recomendable leerse su [wiki](https://github.com/Raphire/Win11Debloat/wiki/) y su ejecución [por defecto](https://github.com/Raphire/Win11Debloat/wiki/Default-Settings).

Mi script ya se bajó Win11Debloat (`C:\Users\[usuario]\Desktop\Win11Debloat\`).

Antes de ejecutarlo, modifico el fichero `Appslist.txt` con la lista de aplicaciones a desinstalar.

```PS1
PS C:\Users\luisp> cd Desktop\Win 11Debloat\Raphire-Win11Debloat-70ebe29>
PS C:\Users\luisp\Desktop\Win11Debloat\Raphire-Win11Debloat-70ebe29> notepad.exe Appslist.txt
```

Yo uso este [Appslist.txt](https://gist.githubusercontent.com/LuisPalacios/919d1150ad31bb0a19d1528a38e6da81/raw/Appslist.txt). He desmarcado unas cuantas más de las de por defecto, excepto `Edge` porque recomienda no hacerlo automáticamente, así que lo dejo para más tarde (lo de quitar Edge).

Ejecuto el script y selecciono la opción 1.

```PS1
.\Win11Debloat.ps1
```

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-02.png" alt="Win11Debloat" width="600px" />
  <div class="image-caption">Win11Debloat - opción 1</div>
</div>

Una vez que termina hago un reboot del equipo.

---

## Paso 3 - Deshinchar manualmente

A partir de aquí voy a terminar de *deshinchar* manualmente.

***Acciones directas en el registry:***. Nota: si hiciste [instalación desatendida](#instalar-de-forma-desatendida) ya está hecho.

Desactivo una opcion de Private & Security > General, "Let websites show me locally relevant content by accessing my language list"

```ps1
reg add "HKEY_CURRENT_USER\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d 1 /f
```

Cambio "User Account Control settings" a Never notify.

```ps1
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f
```

***Desinstalar Edge y poner Chrome por defecto:***

- **Start > Settings > Apps**
  - > Installed Apps: Elimino **Edge** (Sí, me cargo Edge como navegador del equipo. No es multiplataforma !!)
    - Arranco Google Chrome. Lo marco como browser por defecto y me aseguro de revisar:
  - > Default apps > Google Chrome > **Reviso que todo sea Chrome**
  - > Apps for Websites > **todo a off**

***Cambios en Privacidad:***

- **Privacy & Security**. Nota: si hiciste [instalación desatendida](#instalar-de-forma-desatendida) ya está hecho.
  - Security > Windows Security > `Open Windows Security`: **Todo en On**
  - Windows Permissions > **todo a off** en todas las opciones: General, Speech, etc...
  - App permissions > `Location`: **Todo en Off**, el **resto a valor por defecto**

***Cambio del Home de mi usuario:***. Nota: si hiciste [instalación desatendida](#instalar-de-forma-desatendida) ya está hecho.

Durante la instalación creó el nombre corto del usuario con los 5 primeros caracteres de dicho mail, por lo que quedó como `luisp` y el HOME de mi usuario en `C:\Users\luisp\`.

- Cambiar el nombre del directorio HOME ([guía](https://www.elevenforum.com/t/change-name-of-user-profile-folder-in-windows-11.2133/))
  - Habilito al Administrador
    - `net user Administrator /active:yes`
  - REBOOT y hago login con Administrador sin contraseña
    - Busca mi usuario (luisp) en la lista y anoto el SID correspondiente (S-1-5-21-.....).
    - PowerShell: `Get-LocalUser | Select-Object Name, SID`
    - ***`regedit`*** -> `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1* -> ProfileImagePath`
    - Explorer -> **Renombro el HOME**
    - PowerShell: `New-Item -ItemType SymbolicLink -Path "C:\Users\luisp" -Target "C:\Users\luis"`

- Compatibilidad: Durante el tiempo que estuvo la carpeta antigua, puede que se hayan instalado o registrado programas con ella, y quedarán "fantasmas" por todos sitios.
  - Si por lo que sea creaste un enlace simbólico problemático o se te ha recreado (por algún fantas la carpeta), pues la borro: `rmdir C:\Users\luisp`
  - Creo un Junction: `mklink /J C:\Users\luisp C:\Users\luis`

***Elimino Apps menos improtantes:***. Nota: si hiciste [instalación desatendida](#instalar-de-forma-desatendida) ya está hecho.

- Start > Botón derecho sobre los iconos que quiera hacer Unpin o "Uninstall"
  - Por ejemplo en mi caso **quité LinkedIn**, ...

***Personalizo el Taskbar:***. Nota: si hiciste [instalación desatendida](#instalar-de-forma-desatendida) ya está hecho.

- Botón derecho iconos que están en el taskbar y uno a uno **quito iconos que no uso**.
- Start > tecleo "Start settings" >
  - Layout > More pins
  - Show recently added apps > **Off**
  - Show recommmended files... > **Off**
  - Show account notifications > **Off**
  - Show recently opened > **Off**

***Elimino el teclado en inglés:***

- Elimino el teclado US que me instaló por defecto.
  - Start > Settings > Time & Language > Language & Region
    - > Preferred Languages > "..." > Options > Keyboards > **Quito US** (dejo solo el de Spanish)

***File Explorer***. Mostrar archivos y directorios ocultos, file extensions, etc.

- Start > Settings > `System` > `For developers`
  - Habilitar el modo para desarrolladores si no lo estaba ya.
  - Entrar en > `File Explorer`
    - `Show file extensios`: **On**
    - `Show hidden and system files`: **On**
    - `Show full path in title bar`: **On**
    - `Show empty drives`: **On**

***Habilitar File Sharing***. Es algo que voy a necesitar, así que lo configuro

- Start > Settings > `Network and Internet` > `Advanced network settings`
  - `Advance Sharing Settings`
  - `File & Printer sharing`: **On**
  - `Public folder sharing`: **On**
- Start > Settings > System > About
  - `Advance System Settings` > Computer Name > Change > "Me aseguro que está en **WORKGROUP**"
- Habilito SMB1.0
  - Start > busco "Control Panel"
  - `Programs` > `Programs and features`
  - `Turn Windows features on or off`
  - **Activo SMB 1.0/CIFS** File Sharing Support.

***Firewall de Windows***

- Lo configuro para minimizar alertas y notificaciones. En mi caso el ordenador está conectado a una red privada pero por defecto la instalación lo puso en red Pública
  - Start > Settings > Network & Internet > Ethernet (y también WiFi)
    - **Cambio ambas a `Private Network`**
- Configuro el Firewall de Windows para minimizar alertas y notificaciones
  - Start > busco "Control Panel" > System & Security > Windows Defender Firewall > Advanced Settings”
    - Reviso reglas de entrada y salida para bloquear o permitir aplicaciones específicas según lo necesite.
  - Start > busco "Control Panel" > System & Security > Windows Defender Firewall > Change notification settings"
    - Desactivo las notificaciones, **desmarco las casillas de “Notify me when Windows Defender Firewall blocks a new app”**

***Desactivar Cortana***

- Busco “gpedit.msc” en el menú de inicio y abro el Editor de directivas
  - Navego a “Computer Configuration > Administrative Templates > Windows Components > Search”.
  - Hago doble clic en “Allow Cortana” y selecciono “Disabled”. Aplico los cambios para desactivar Cortana.

***Quito más aplicaciones preinstaladas***

- Eliminar aplicaciones preinstaladas (bloatware o crapware) mediante PowerShell.
- ¿Qué desinstalar? pues depende del fabricante de tu PC puedes echarle un ojo a [Should I Remove It?](http://www.shouldiremoveit.com) que no está mal y te da indicaciones.
- Puede usarse PowerShell como administrador. Comando para listar todas las aplicaciones instaladas
  - `Get-AppxPackage | Select Name, PackageFullName`
- Luego, uso este comando para desinstalar las aplicaciones que no necesito
  - `Get-AppxPackage *NombreDeLaApp* | Remove-AppxPackage`

***Deshabilitar servicios innecesarios***

- Abro `services.msc` desde el menú de inicio.
  - Identifico los servicios que no necesito (por ejemplo, "xbox*", etc.). Hago doble clic en el servicio, cambio el “Startup type” a “Disabled” y aplico los cambios.

Con estas recomendaciones adicionales, el sistema estará preparado para ofrecer una experiencia de usuario más directa, sin distracciones ni interrupciones innecesarias.

Paso las pruebas de evaluación del sistema de Windows (WinSAT) se usan para analizar el rendimiento de varios componentes del sistema, como CPU, memoria, disco y gráficos.

```PowerShell
C:\Users\luis> winsat formal
C:\Users\luis> Get-CimInstance Win32_WinSat
```

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-04.png" alt="Idoneo para trabajar" width="600px" />
  <div class="image-caption">Idoneo para trabajar</div>
</div>

Seguí los pasos anteriores para optimizar también un [máquina virtual windows]({{< relref "2024-08-26-win-vmware.md" >}}) corriendo en un windows optimizado, como puedes observar el rendimiento de la máquina virtual es muy decente.

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-06.png" alt="Otro windows 11 optimizado, esta vez como Guest de VMWare Workstation" width="600px" />
  <div class="image-caption">Otro windows 11 optimizado, esta vez como Guest de VMWare Workstation</div>
</div>

***Mantenimiento: Comandos útiles***

Comandos útiles, que ejecuto como administrador

- `chkdsk`: Comprueba el estado del disco duro y nos muestra un informe con la información necesaria. Además, se encarga de corregir problemas e incluso recuperar información perdida.
- `sfc /SCANNOW`. Analizar la integridad de todos los archivos de sistema y solucionar problemas en los mismos. ***AVISO!!***: Microsoft tenía un problema conocido que llevaba años sin resolverse y hasta hace poco seguía por ahi danzando. Si te pasa y encuentra un problema en el archivo `bthmodem.sys` y lo elimina, verás que se refiere a `Corrupt File: bthmodem.sys`. Se resuelve ejecutando el comando siguiente.
- `dism /online /cleanup-image /restorehealth` para resolver el entuerto. Se conecta con el *Windows Update service* para bajarse y reemplazar cualquier archivo importante que falte o esté corrupto.

Ya hemos terminado, nos quedamos con un Windows 11 mucho más limpio, rápido y libre de distracciones.

<div class="image-box">
  <img src="/img/posts/2024-08-24-win-decente-02.png" alt="Versión minimalista de Start" width="450px" />
  <div class="image-caption">Versión minimalista de Start</div>
</div>

---

## Herramienta devcli

Si te gusta trabajar en el CLI, échale un ojo al apunte [Windows para desarrollo de software]({{< relref 2024-08-25-win-desarrollo.md >}}) donde hablo del CLI, el Terminal, WSL2 y herramientas adicionales.

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-05.png" alt="Por opciones que no sea" width="2560px" />
  <div class="image-caption">Por opciones que no sea</div>
</div>

En él menciono el proyecto **[devcli](https://github.com/LuisPalacios/devcli)** que tengo en GitHub, te permite configurar el entorno CLI en Linux, macOS, WSL2 y **Windows**. Después de *deshinchar* Windows, no viene mal preparar el CLI, sobre todo si eres adicto al CLI o desarrollador.

- Instala herramientas como: git, curl, wget, nano, htop, tmux, fzf, bat, fd-find, ripgrep, tree, jq, lsd, zoxide
- Instala Oh-My-Posh, para cualquier Shell, dicen que es el mejor prompt.
- Establece la variable LANG (por defecto a s_ES.UTF-8) en linux, macOS y WSL2
- Copia ficheros importanttes de configuración (ver el subdirectorio dotfiles)
- Copia mi caja de herramientas para git desde [gitbox](https://github.com/LuisPalacios/gitbox).
- Crea unos cuantos scripts en ~/bin que uso con frecuencia: e, s, confcat
- Instala automáticamente FiraCode Nerd Font para soportar iconos en herramientas como lsd.

---

## Instalar de forma desatendida

Si quieres probar a instalar de otra forma, estudié un par de proyectos y los he probado: [UnattendedWinstall](https://github.com/memstechtips/UnattendedWinstall) y [WIMUtil](https://github.com/memstechtips/WIMUtil), para poder hacer una instalación desatendida. Estos son los pasos que dí:

**Instalo ADK**:

- En un windows 11 instalé la herramienta oficial de Microsoft para personalizar imágenes (WindowsADK), para conseguir [oscdimg.exe](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/oscdimg-command-line-options) que se usa mas tarde.
  - Me bajo [Windows ADK](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install?source=recommendations), lo instalo y solo elijo las **Deployment Tools**.
  - Copio el contenido de `cd 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\'` a un directorio que tengo en el PATH.

**Ejecuto WIMUtil**:

- Arranco PowerShell como administrador y ejecuto lo siguiente.

```PowerShell
irm "https://github.com/memstechtips/WIMUtil/raw/main/src/WIMUtil.ps1" | iex
```

- Este proceso crea un ISO Custom (usando el `autounattend.xml` del proyecto [UnattendedWinstall](https://github.com/memstechtips/UnattendedWinstall))
  - Selecciono ISO, directorio temporal, START.
  - Next, personalizo windows > Download UW (automaticamente descarga el de UnattendedWinstall). No añado un answer file.
  - Next, opcionalmente "Add Drivers" del propio Windows donde estás ejecutándolo.
  - Next, Select Location > `win11-custom.iso`
  - Create ISO

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-08.png" alt="Crear un ISO desatendido" width="800px" />
  <div class="image-caption">Crear un ISO desatendido</div>
</div>

Creo una VM para probarla. Más sobre una máquina virtual con windows 11 -> [VMWare en Windows]({{< relref "2024-08-26-win-vmware.md" >}}).

- W11 VMWare Workstation > New virtual Machine > Typical > Installer disc > `win11-custom.iso`. Las "pocas" cosas que me pide son:
  - VMWare me pide: Nombre, tipo de de encriptación ("Only the files needed..."), resto por defecto.
  - El proceso de instalación: Lenguaje, hora y moneda, teclado, No tengo product key, Windows 11 Pro, Formato del disco; Region y teclado, usuario y contraseña, preguntas de seguridad.
  - IMPORTANTE: Cuando termina, está deshabilitado el Defender y el UAC. Puedes activarlos de nuevo
    - En mi caso Habilito solo el Defender.
  - Click en Restart, Instalo las *VMWare Tools*.

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-09.png" alt="Parametrización final" width="650px" />
  <div class="image-caption">Parametrización final</div>
</div>

Ya está, rápido y sencillo. Sigo con el [Paso 1: Preparo el SO](#paso-1---preparo-el-so) para desincharlo aún más.

---

## Enlaces interesantes

Te dejo algunos enlaces que estudié y me precieron útiles:

- ***[Clink](https://github.com/chrisant996/)***: Enriquece muchísimo el CMD (`command.com`) con una readline como el de Linux, añade múltiples funcionalidades, colores, history.
- ***[Ccleaner](https://www.ccleaner.com/)*** Muy buena pinta, aunque para tener acceso a lo "chulo" hay que comprar la licencia Profesinoal.
- ***[BleachBit](https://www.bleachbit.org/)*** Una alternativa Open Source a CCleaner, que tiene una pinta buenísima. Le falta la parte del Registry y la Optimización de rendimiento.
  - Antes de instalar la última versión, hay que bajarse el **[Visual Studio 2919 (VC++ 10.0) redistributable SP1 x86](https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe)**, es la versión x86. Aunque mi sistema es de 64-bit da igual porque va a usar la dll de la versión x86.
- ***[TCPView](https://learn.microsoft.com/en-us/sysinternals/downloads/tcpview)*** Herramienta gratuita de Microsoft (de la suite Sysinternals) que te permite ver en tiempo real todas las conexiones de red activas en tu sistema Windows.
- ***[Autoruns](https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns)*** Herramienta gratuita de Microsoft Sysinternals que te muestra todo lo que se ejecuta automáticamente cuando inicias Windows. Es mucho más poderosa y completa que el Administrador de tareas o MSConfig.
- ***[Sysinternals Suite](https://learn.microsoft.com/en-us/sysinternals/downloads/)*** Si con las dos anteriores no tienes suficiente, puedes instalarte el hermano mayor, la Sysinternals Suite, que las incluye. Son el conjunto de herramientas avanzadas creadas originalmente por Mark Russinovich y Bryce Cogswell, y ahora mantenidas por Microsoft. Están diseñadas para diagnosticar, monitorizar, depurar y entender en profundidad cómo funciona Windows.
- ***[Instalación desatendida](https://schneegans.de/windows/unattend-generator/)***: - Generar `autounattend.xml` para Windows 10/11

Por último, echa un ojo a [Winhance - Windows Enhancement Utility](https://github.com/memstechtips/Winhance), después de toda la limpieza, al final me la instalé y aún quedaban cosas por ahi que pude limpiar.

<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-03.png" alt="Winhance - Windows Enhancement Utility" width="650px" />
  <div class="image-caption">Winhance - Windows Enhancement Utility</div>
</div>

---
