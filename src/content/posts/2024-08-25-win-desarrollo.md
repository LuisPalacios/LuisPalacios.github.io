---
title: "Windows para desarrollo"
date: "2024-08-25"
categories: ["desarrollo"]
tags: ["windows","wsl","wsl2","linux","ubuntu","desarrollo","visual","studio","python","git","cli","vscode","compilador"]
draft: false
cover:
  image: "/img/posts/logo-win-desarrollo.svg"
  hidden: true
---

<img src="/img/posts/logo-win-desarrollo.svg" alt="logo win desarrollo" width="150px" height="150px" style="float:left; padding-right:25px"  />

Preparo un Windows 11 como equipo de desarrollo multiplataforma (Linux, macOS y Windows), no *solo-microsoft*. Parto de una instalación limpia en inglés, parametrizada de forma [ligera]({{< relref "2025-08-03-win-decente.md" >}}) (opcionalmente tras un [dualboot]({{< relref "2024-08-23-dual-linux-win.md" >}})). El apunte empieza por el CLI y WSL2 y termina con las herramientas y lenguajes de programación.

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

> Nota: apuntes hermanos para preparar cada S.O. para desarrollo: [macOS]({{< relref "2023-04-15-mac-desarrollo.md" >}}) y [Linux]({{< relref "2024-07-25-linux-desarrollo.md" >}}).

## Nota sobre el PATH

En Linux y macOS modificar el PATH es directo. En Windows hay dos: el de **Usuario** y el de **Sistema**, que se combinan. Durante el apunte toca modificarlo varias veces — esta es la vía:

- `Start > Settings > System > About > Advanced System Settings` (o busca "Environment Variables" en `Search`).
- Modificar en `System variables` y/o `User variables`.
- Ejemplo de mi PATH final: [Gist](https://gist.github.com/LuisPalacios/d38dd10a92fa1ab6bbaec799e8afe2f3).

## CLI

Para desarrollo multiplataforma la línea de comandos es fundamental. Instalo estos CLIs:

- **CMD (`cmd.exe`)**: La línea de comandos tradicional de Windows, sus scripts son los famosos ***`*.BAT, *.CMD`***.
- **PowerShell**: Entorno de scripting y línea de comandos avanzada desarrollada por Microsoft.
- **[Git for Windows](https://git-scm.com/install/windows):** porque además de `git.exe` incluye el programa *Git Bash*, un terminal emulador de Bash para Windows que incorpora ejecutables nativos a comandos "linux" bajo `/c/Program Files/Git/usr/bin`
- ***Windows Terminal***: Una aplicación moderna que permite utilizar múltiples pestañas con diferentes consolas, como `CMD`, `PowerShell`, `WSL`, `Git Bash`, ... Es muy personalizable y soporta características avanzadas como temas y configuraciones de fuentes.  Entro en detalle más adelante.
- ***Windows Subsystem for Linux (WSL 2)***: permite ejecutar un entorno Linux nativo en Windows sin la necesidad de una máquina virtual. Puedes instalar distribuciones de Linux (como Ubuntu, Debian, etc.) y usar la **Shell de Unix** (`zsh o bash`) y **las herramientas de línea de comandos Open Source existentes para Linux** (`ls, cd, mkdir, cp, tar, sed, awk, nano, vi, etc.`). Está completamente integrado con el File System de Windows (excepto los permisos).

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-01.svg" alt="Shell+Herramientas Linux = mismo entorno" width="350px" />
  <div class="image-caption">Shell+Herramientas Linux = mismo entorno</div>
</div>

<br/>

---

## PowerShell

 Es más potente que CMD, permite el uso de comandos más complejos, scripts, y el acceso al framework .NET. ***Los scripts terminan en `*.PS1`***. Muy ***útil para desarrolladores que trabajan exclusivamente en .NET, con C#, en entornos solo Microsoft***, para automatizaciones y para el mundo DevOps CI en entornos Windows/Azure.

Hay dos ejecutables:

- Windows 11 trae la PowerShell **5.x** - (**powershell.exe**), conocido como "**Desktop**". Funciona **exclusivamente en Windows**.

  1. Basado en el motor PowerShell 5.1.
  2. Totalmente integrado con Windows, soportando todas las características, módulos y cmdlets específicos de Windows.
  3. Corre sobre el .NET Framework.
  4. Ideal para gestionar entornos Windows, incluyendo Active Directory, Exchange y otros servicios específicos de Windows.

- ***Powershell 7***: (**pwsh.exe**), conocido como "**Core**". **Multiplataforma** (Windows, macOS, Linux).

  1. Basado en el motor de PowerShell 6.0+.
  2. Diseñado para ser más modular y liviano, pero puede carecer de algunas características y módulos específicos de Windows.
  3. Corre sobre .NET Core (ahora .NET 5+).
  4. Adecuado para gestionar entornos diversos, incluyendo servicios en la nube y sistemas no Windows.

Instala [PowerShell 7](https://github.com/PowerShell/PowerShell/tags) > "Downloads" > última versión `.msi`. En el futuro te avisará si existe una actualización, descargas, instalas y actualizará.

```PowerShell
luis@kymeraw:~ ❯ $PSVersionTable

Name                           Value
----                           -----
PSVersion                      7.5.1
PSEdition                      Core
:
```

**Perfiles de PowerShell al arrancar (`$PROFILE`)**:

PowerShell carga hasta **cuatro archivos de perfil** en este orden, si no se utiliza el parámetro `-NoProfile`:

| Orden | Alcance        | Tipo de host    | Ruta                                                                                                                      |
| ----- | -------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------- |
| 1     | Global         | Todos los hosts | `$PSHOME\Microsoft.PowerShell_profile.ps1`                                                                                |
| 2     | Usuario actual | Todos los hosts | `$HOME\Documents\PowerShell\profile.ps1`                                                                                  |
| 3     | Usuario actual | Host específico | `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` *(o `VSCode_profile.ps1`, `ConsoleHost_profile.ps1`, etc.)* |
| 4     | Global         | Host específico | `$PSHOME\Microsoft.PowerShell_profile.ps1`<br>*(host-specific variant)*                                                   |

> `$PROFILE` es una variable automática que apunta al perfil actual del usuario y del host (`$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`). Puedes ver todas las rutas con:
>
> ```powershell
> $PROFILE | Format-List *
> ```

Yo utilizo un único fichero, que siempre dejo en `$PROFILE`. Dejo aquí un enlace al proyecto [`devcli`](https://github.com/LuisPalacios/devcli) que tengo en GitHub donde podrás encontrar mi última versión de este fichero y editar el tuyo con **`code $PROFILE`**:

- Mi fichero [Microsoft.PowerShell_profile.ps1](https://raw.githubusercontent.com/LuisPalacios/devcli/refs/heads/main/dotfiles/Microsoft.PowerShell_profile.ps1)

---

<br/>

## Terminal mejorado

### Windows Terminal

Instala **[Windows Terminal](https://github.com/microsoft/terminal)**, podrás tener múltiples pestañas para `CMD`, `PowerShell`, `WSL`, `[Git Bash](https://git-scm.com/install/windows)`, o cualquier terminal que encuentres por ahi. Personalizable y soporta características avanzadas como temas y configuraciones de fuentes.

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-08.png" alt="Uso el terminal que quiero según el caso de uso" width="450px" />
  <div class="image-caption">Uso el terminal que quiero según el caso de uso</div>
</div>

- Microsoft Store, `Start` > busco por "Store" > Busco por "Windows Terminal". Instalo o Actualizo
- `Start` busco "Terminal". Accedo a la configuración > 'flecha abajo' > `Settings` o `Ctrl + ,`
- Configurar perfiles de consola:
  - En el panel izquierdo, veo perfiles como `Windows PowerShell`, `CMD`, `Ubuntu`, etc. Aquí puedo personalizar cada uno de ellos.
  - Cambiar el shell predeterminado: Si deseas que siempre se abra un perfil específico al iniciar Windows Terminal, selecciona el perfil en el menú "Startup" bajo "Default profile".
- Personalizar apariencia:
  - Puedes cambiar el tema, fuente, esquema de colores y más para cada perfil.
- Agregar nuevas consolas (opcional)

Anclar Windows Terminal al Taskbar: Tras ejecutarlo, clic derecho en su icono, "Pin to taskbar" (Anclar al taskbar).

Usar múltiples pestañas en Windows Terminal:

- Abrir nuevas pestañas: ícono `+` o atajo `Ctrl + Shift + T`.
- Cambiar entre pestañas: `Ctrl + Tab`
- Cerrar pestañas: ícono `X` o `Ctrl + Shift + W`.
- Sacar las pestañas como ventanas independientes: Botón derecho sobre la pestaña

Empiezo a trabajar de manera más eficiente y organizada. Tengo la posibilidad de abrir la consola que necesite, he cambiado los colores ligeramente para diferenciar dónde estoy y en el caso de `cmd.exe` he puesto otro tipo de fuente de letra.

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-05.png" alt="Por opciones que no sea" width="2560px" />
  <div class="image-caption">Por opciones que no sea</div>
</div>

**Configuración `settings.json` y `state.json`**: Gran parte de esta personalización de Windows Terminal se gestiona a través de dos archivos clave: `settings.json` (nucleo de la personalización, puedes editarlo desde el propio menú) y `state.json` (estado actual del Terminal).

Aquí tienes el [mi fichero de configuración settings.json](https://gist.github.com/LuisPalacios/ba989c7d8f2f65cd49308402754df82e) que utilizo en mi ordenador. Nota: los `uuid` del mismo serán distintos en tu caso. No lo copies/pegues tal cual o no te funcionará.

### Nerd Fonts

Instalo una fuente de tipo **Nerd Font**, fundamental cuando trabajas con la línea de comandos. Desde su [repositorio oficial](https://www.nerdfonts.com/) > `Fonts Downloads`. A mi me gusta `FiraCode`. La descargo, unzip del fichero, selecciono todos los `.ttf` > botón derecho > `Install`.

Lo configuro como fuente por defecto en Windows Terminal, Settings -> Profiles -> Defaults -> Appearance -> Font Face `FiraCode`.

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-21.png" alt="Por opciones que no sea" width="500px" />
  <div class="image-caption">Este es el Nerd Font que a mi me gusta</div>
</div>

---

### Oh My Posh

Instalo **[Oh My Posh](https://ohmyposh.dev/)**, el **prompt definitivo**, el que mejor funciona con repositorios Git grandes, incluso bajo WSL2. Es un motor de temas de prompt para cualquier shell. Lo instalo en todos los sistemas operativos y CLI's con los que trabajo. Sigue las instrucciones de su site para hacer la instalación:

- [Windows Powershell](https://ohmyposh.dev/docs/installation/windows) - `winget install JanDeDobbeleer.OhMyPosh -s winget`
- [Windows CMD](https://ohmyposh.dev/docs/installation/prompt) - No trae soporte nativo, pero sí cuando se usa junto con *Clink*, lo explico en el siguiente punto.
- Para WSL2 uso [devcli](https://github.com/LuisPalacios/devcli) - Script automático para Configura el entorno CLI en sistemas basados en Unix: Linux, macOS y WSL2.

Oh-My-Posh usa temas, aqui tienes una copia del mío: [~/.oh-my-posh.yaml](https://raw.githubusercontent.com/LuisPalacios/zsh-zshrc/main/.oh-my-posh.yaml)

Para que mi tema funcione bien necesito hacer esto seguido de un reboot. Uso esa variable en mi tema.

```PowerShell
setx OMP_OS_ICON "🪟"
```

> Nota: Si alguna vez necesitas borrar dicha variable se hace así: `Remove-ItemProperty -Path "HKCU:\Environment" -Name "OMP_OS_ICON"`

---

### Clink

**[Clink](https://github.com/chrisant996/clink/)** añade al CMD todo lo que le falta, la readline (de linux), colores, historia, Scriptable Prompt; y ademas se integra con Oh-My-Posh

Sigue las [instrucciones](https://github.com/chrisant996/clink?tab=readme-ov-file#installation) para configurarlo de forma adecuada y sobre todo para inyectarlo en el CMD, de tal forma que arranque automáticamente al arrancar `cmd.exe`.

```conf
  Computer\HKEY_CURRENT_USER\Software\Microsoft\Command Processor
    |
    +--> AutoRun   "C:\Program Files (x86)\clink\clink.bat" inject --autorun
```

Aunque Clink soporta [Scriptable Prompt](https://chrisant996.github.io/clink/clink.html#customizing-the-prompt), yo utilizo Oh-My-Posh junto con Clink.

Edito `C:\Users\luis\AppData\Local\clink\oh-my-posh.lua`, salgo y vuelvo a entrar de CMD.

```lua
load(io.popen('oh-my-posh init cmd'):read("*a"))()
```

Salgo y vuelvo a entrar del CMD y ejecuto lo siguiente:

```PowerShell
clink config prompt use oh-my-posh
clink set ohmyposh.theme c:\Users\luis\.oh-my-posh.yaml
```

---

### LSDeluxe

**[LSDeluxe](https://github.com/lsd-rs/lsd)** (`lsd`) es un reemplazo moderno de `ls`, escrito en Rust, con colores, iconos (via Nerd Fonts) y vista en árbol. Multiplataforma. Lo instalo en todos mis sistemas (Windows, macOS, Linux y WSL2).

- Instalación: `winget install lsd`

- Alias para PowerShell. Mira arriba en la sección de Terminal mi `$PROFILE`.

```PowerShell
# Añadido al .\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# Cambio el alias interno de ls a lsd https://github.com/lsd-rs/lsd
#
if (Get-Alias ls -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force
}
function ls {
    lsd --group-directories-first @args
}
```

- Alias para CMD: Creo `C:\Users\luis\cmd_aliases.cmd` y luego edito mi acceso directo de `cmd.exe` (en Terminal) y cambio la línea de destino: `%SystemRoot%\System32\cmd.exe /k "C:\Users\Luis\cmd_aliases.cmd"`

```PowerShell
REM Fichero C:\Users\Luis\cmd_aliases.cmd
@echo off
doskey ls=lsd --group-directories-first $
```

**Colores**: en Windows se configuran con la variable `LS_COLORS` vía `setx` (y requiere reboot — sí, reboot). Ejemplo:

```PowerShell
setx LS_COLORS "fi=00:mi=00:mh=00:ln=01;94:or=01;31:di=01;36:ow=04;01;34:st=34:tw=04;34:pi=01;33:so=01;33:do=01;33:bd=01;33:cd=01;33:su=01;35:sg=01;35:ca=01;35:ex=01;32:*.cmd=00;32:*.exe=01;32:*.com=01;32:*.bat=01;32:*.btm=01;32:*.dll=01;32:*.tar=00;31:*.tbz=00;31:*.tgz=00;31:*.rpm=00;31:*.deb=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.zip=00;31:*.zoo=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31:*.bz2=00;31:*.tb2=00;31:*.tz2=00;31:*.tbz2=00;31:*.avi=01;35:*.bmp=01;35:*.fli=01;35:*.gif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mng=01;35:*.mov=01;35:*.mpg=01;35:*.pcx=01;35:*.pbm=01;35:*.pgm=01;35:*.png=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.xbm=01;35:*.xpm=01;35:*.dl=01;35:*.gl=01;35:*.wmv=01;35"
```

---

### Git for Windows

**[Git for Windows](https://git-scm.com/)** trae **`git.exe`** y **`Git Bash`**, una herramienta que proporciona un emulador de Bash para Windows. Otro terminal más, algo parecido a lo que vemos en un terminal WSL2 de Ubuntu, pero usando un emulador de terminal y ejecutables nativos de Windows. Lo veremos.

<img src="/img/posts/2024-08-25-win-desarrollo-06.png" alt="Git para Windows" width="150px" height="150px" style="float:left; padding-right:25px"  />

El objetivo principal es tener acceso a `git.exe` desde las consolas nativas `CMD`, `PowerShell` y aplicaciones de terceros. Queda instalado rn `C:\Program Files\Git`.

> Nota: incluye el ejecutable `C:\Program Files\Git\bin\bash.exe` pero verás que hay otro en el sistema `C:\Windows\System32\bash.exe`, así que tenlo MUY en cuenta en el orden en el PATH. El segundo  es el que trae WSL2 para arrancar una shell dentro del linux que hayas instalado.

Decisiones que tomo durante la instalación:

- **Bundled OpenSSH & OpenSSL**: selecciono *Use the bundled OpenSSH and bundle OpenSSL* para aislar Git de la versión de SSH del sistema.
- **Handling of CRLF**: selecciono *Checkout as-is, commit Unix-style line endings*. Ver la sección [CRLF vs LF](#crlf-vs-lf).
- **PATH (Git Bash)**: selecciono *Git from the command line and also from 3rd-party software* y añado manualmente las rutas al PATH del sistema (más abajo).

Ejemplo con `Git-2.46.0-64-bit.exe`:

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-09.png" alt="Proceso de instalaicón de Git for Windows" width="1024px" />
  <div class="image-caption">Proceso de instalaicón de Git for Windows</div>
</div>

Aunque no uso Git Bash como shell, sí me aprovecho de sus ejecutables "estilo Linux" desde CMD/PowerShell. Añado al PATH del sistema `C:\Program Files\Git\mingw64\bin` y `C:\Program Files\Git\usr\bin`:

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-10.png" alt="Aprovecho los ejecutables que trae Git for Windows" width="1024px" />
  <div class="image-caption">Aprovecho los ejecutables que trae Git for Windows</div>
</div>

Git for Windows además te instala MinGW-w64, una bifurcación de MinGW (Minimalist GNU for Windows) que proporciona un conjunto de herramientas y un entorno de desarrollo para compilar y ejecutar aplicaciones de código abierto, principalmente en C y C++, en sistemas Windows. Es crucial si compilas aplicaciones para Windows usando herramientas y entornos tradicionales de GNU/Linux.

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-11.png" alt="Y además los que instala del proyecto mingw64" width="1024px" />
  <div class="image-caption">Y además los que instala del proyecto mingw64</div>
</div>

Por cierto, cuando no sepas dónde está el ejecutable...

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-12.png" alt="¿De dónde va a cargar el ejecutable?" width="1024px" />
  <div class="image-caption">¿De dónde va a cargar el ejecutable?</div>
</div>

---

### Otras herramientas

**[Cmder](https://cmder.app/)**: consola basada en [ConEmu](https://conemu.github.io/) + Clink. Alternativa razonable si prefieres un emulador todo-en-uno en lugar de Windows Terminal.

**[Starship](https://starship.rs/)**: prompt multiplataforma, rápido y minimalista, alternativa a Oh-My-Posh. Requiere una Nerd Font. Instalación: `winget install starship`. Luego añades el init a tu shell:

- PowerShell: `Invoke-Expression (&starship init powershell)` en `$PROFILE`.
- CMD (con Clink): crea `C:\Users\<usuario>\AppData\Local\clink\starship.lua` con `load(io.popen('starship init cmd'):read("*a"))()` y elimina el `prompt_filters.lua` si existía.

**[fzf — Fuzzy Finder](https://github.com/junegunn/fzf)**: buscador interactivo imprescindible para CLI. Combinado con [bat](https://github.com/sharkdp/bat), [fd](https://github.com/sharkdp/fd) y [ripgrep](https://github.com/BurntSushi/ripgrep), subes otro nivel. Instalación en Windows:

```PowerShell
luis@kymeraw:~ ❯ winget install fzf
Found fzf [junegunn.fzf] Version 0.59.0
This application is licensed to you by its owner.
Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
Downloading https://github.com/junegunn/fzf/releases/download/v0.59.0/fzf-0.59.0-windows_amd64.zip
  ██████████████████████████████  1.73 MB / 1.73 MB
:
Command line alias added: "fzf"
Successfully installed
```

<br/>

## WSL 2

Merece toda una seccion, el **Windows Subsystem for Linux (WSL 2)** permite ejecutar un entorno Linux directamente en Windows sin la necesidad de una máquina virtual. Puedes instalar distribuciones de Linux (como Ubuntu, Debian, etc.) y usar la Shell que quieras de forma nativa, con altísimo rendimiento, completamente integrado con el File System de Windows (excepto los permisos).

```shell
luis@kymeraw:/mnt/c/Users/luis$ ls -al
```

WSL2 utiliza una máquina virtual ligera con un **kernel real completo de Linux**, tiene un **rendimiento** altísimo, está super **integrado con Windows**, permite que los archivos y scripts de Linux se ejecuten desde el explorador de Windows, y viceversa; y muy importante, tiene **compatibilidad con Docker**, de hecho WSL2 es el backend preferido para [Docker Desktop en Windows](https://www.docker.com/products/docker-desktop/) (que instalaré más adelante).

> ***Aviso:*** A WSL2 le he encontrado un pero, al acceder a `/mnt/c (C:)` si trabajas en un directorio del que cuelgan cientos o miles de archivos, por ejemplo un repositorio GIT grande, irá muy muy lento. En esos casos, solo me ha pasado con Git, es mejor trabajar dessde CMD o Powershell.

Mis **casos de uso de WSL2**:

- Tener Shell + Herramientas con acceso nativo a `C:\` (vía `/mnt/c`).
- Tener una distro Linux con acceso a **todas las herramientas open source disponibles en Linux**.
- Equipararme a lo que uso en [MacOS]({{< relref "2023-04-15-mac-desarrollo.md" >}}) o [Linux]({{< relref "2024-07-25-linux-desarrollo.md" >}}) para desarrollo de software.
- Poder instalar Docker Desktop en Windows
- Poder desarrollar aplicaciones "Servidor" en linux directamente (por ejemplo cosas hechas en Go) en mi Windows

Proceso de instalación:

- Abrir **“Características de Windows**” - Win + R, `optionalfeatures`. Marco las opciones:
  - Virtual Machine Platform (Plataforma de Máquina Virtual)
  - Windows Subsystem for Linux (Subsistema de Windows para Linux)
  - Hyper-V (recomendado para Docker con WSL2).

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-02.png" alt="Activar características VM" width="2560px" />
  <div class="image-caption">Activar características VM</div>
</div>

- **Reboot**
- **Instalo WSL**, desde PowerShell como administrador

  ```PowerShell
  wsl --install
  ```

- Miro las distribuciones disponibles

  ```PowerShell
  wsl --list --online
  ```

- **Instalo una distribución**, en mi caso Ubuntu 24.04 (podrías instalar otra como Debian, Kali-Linux, Suse, ...). Abro PowerShell como Administrador

  ```PowerShell
  wsl --install -d Ubuntu-24.04
  ```

  - Durante la instalación requirió actualizar el núcleo de Linux:
    - Descargué el [Paquete de actualización del kernel de Linux en WSL 2 para máquinas x64](https://learn.microsoft.com/es-es/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package)
    - Lo ejecuté e hice un reboot y tuve que volver a lanzar la instalación de la distribución, creé el usuario linux (`luis`) y le puse contraseña.

    ```PowerShell
    wsl --install -d Ubuntu-24.04
    ```

  - Cuando termina lanza la consola con el CLI de `bash`. Me salgo con `exit`, ya volveremos.

- Abro PowerShell como Administrador, muestro que tengo y me aseguro de que siempre sea la versión 2 (en mi caso no hace falta, solo si tienes otra versión)

  ```PowerShell
  wsl --list --verbose
  wsl --set-default-version 2
  ```

- Actualizo

  ```PowerShell
  wsl --update
  ```

Opcionalmente puedo añadir un icono a Ubuntu en el Taskbar. Busco en la lista de aplicaciones instaladas: `Start > All > "Ubuntu 24.04"` y con el botón derecho hago un *Pin to taskbar* para tener un acceso rápido a mi `bash` (Ubuntu 24.04 en WSL2). Nota: Luego lo quité, una vez que instalo "Windows Terminal".

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-03.png" alt="bash para Windows :-)" width="650px" />
  <div class="image-caption">bash para Windows :-)</div>
</div>

Efectivamente estamos en una máquina virtual con Ubuntu, así que puedo instalar la herramienta que quiera. Lo siguiente imporante a hacer es actualizala.

```shell
luis@kymeraw:~$ sudo apt update && sudo apt upgrade -y
```

- Cambiar HOME a /mnt/c/Users: No lo recomiendo, pero te digo cómo se hace.

El único propósito por el que puede interesarte es para que al ejecutar "cd" te lleve a /mnt/c/Users/<usuario>, unificando el HOME en sesiones CMD, PowerShell y WSL2. Yo **no lo recomiendo** porque algunas aplicaciones y herramientas (Docker Desktop) se rompen. Hay Apps que tienen *hard-coded* que el $HOME esté en su sitio dentro de WSL2 (/home/<usuario>) y cambiarlo hará que no funcionen correctamente o incluso que tengas errores inesperados.

En mi caso me he creado un alias para ir rápido al HOME de Windows que pongo en `.bashrc` o `.zshrc`: `alias c="cd /mnt/c/Users/<usuario>`.

De todas formas, si necesitas cambiarlo, se haría así:

- Desde Powershell, pido que WSL arranque como `root`:

```PowerShell
PS C:\Users\luis> ubuntu2404.exe config --default-user root
```

- Abro una nueva Shell y cambio el HOME de `luis`

```shell
C:\Users\luis> ubuntu2404.exe
root@kymeraw:~# usermod --home /mnt/c/Users/luis/ luis
```

- Vuelvo a dejar que el login por defecto lo haga con `luis`

```PowerShell
PS C:\Users\luis> ubuntu2404.exe config --default-user luis
```

### Configuración: /etc/wsl.conf

Lo menciono en varias partes de este apunte, dejo aquí la copia final que utilizo en mi ordenador, hay que editarla en WSL2 como root.

```zsh
[boot]
systemd=true
[automount]
options = "metadata,uid=1000,gid=1000,umask=022,fmask=11,case=off"
[interop]
enabled=true
appendWindowsPath=false
```

Importante: Cuando modificas este fichero hay que salirse de WSL y pararlo, esperar a que nos diga que no hay nada ejecutándose y volver a ejecutarlo. Veamos un ejemplo, donde estoy en una sesíón WSL2 en la shell como root.

```PowerShell
root@kymeraw:~# exit
logout
luis@kymeraw:~$ exit
logout
PS C:\Users\luis> wsl --shutdown
:
PS C:\Users\luis> wsl --list --running
There are no running distributions.
```

La línea `options` bajo `[automount]` sirve para establecer bien los permisos de los ficheros. Ten en cuenta que los permisos de los archivos Linux que se crean en el disco NTFS [se intepretan de una forma muy concreta](https://learn.microsoft.com/en-us/windows/wsl/file-permissions). Los archivos/directorios que se crean en el disco NTFS (debajo de `/mnt/c/Users/<usuario>`) van con permisos 777.

A mi eso no me gusta. Quiero que WSL sea coherente, además hay programas a los que no les gusta tanto permiso, un ejemplo es SSH. El cliente de OpenSSH necesita que el directorio y los archivos bajo `~/.ssh` tengan unos permisos específicos.

La solución es activar los ***metadatos*** en la [configuración avanzada de WSL](https://learn.microsoft.com/en-us/windows/wsl/wsl-config), en el fichero `/etc/wsl.conf` en la sección `[automount]`.

Cuando vuelvo a entrar en la Shell me aseguro de que mis archivos son míos (si has cambiado de distribución podría ocurrirte que pertenecen a otro usuario, por ejemplo `ubuntu:lxd`).

```PowerShell
PS C:\Users\luis>  ubuntu2404.exe
luis@kymeraw:~$ pwd
/mnt/c/Users/luis
luis@kymeraw:~$ sudo chown -R luis:luis /mnt/c/Users/luis
[sudo] password for luis:
```

### Configuración: .wslconfig

Esto es opcional, pero yo lo hago siempre. Me da mucha pereza el tema de NAT en el WSL2. Optimizo la pila de red de WSL 2 activando el modo Mirrored, lo que elimina la arquitectura NAT tradicional para que la instancia de Linux comparta directamente la interfaz de red e identidad IP del host Windows, permitiendo así que las aplicaciones que ejecute en el WSL sean accesibles desde la LAN sin necesidad de reenvío de puertos. Adicionalmente, habilita dnsTunneling para mejorar la estabilidad de la resolución de nombres (especialmente útil bajo VPNs) y activa la sincronización del firewall, asegurando que las reglas de seguridad del Firewall de Windows se apliquen automáticamente al tráfico de la instancia de Linux para una protección integrada.

Creo el archivo `C:\Users\luis\.wslconfig` en el la raíz de mi usuario de windows.

```zsh
[wsl2]
networkingMode=mirrored
dnsTunneling=true
firewall=true
```

Importante salirse de WSL2 y cerrarlo por completo, antes de volver a abrirlo.

```PowerShell
root@kymeraw:~# exit
logout
PS C:\Users\luis> wsl --shutdown
PS C:\Users\luis> net stop wslservice
PS C:\Users\luis> net start wslservice
```

Si te da algún error al volver a abrir la sesión WSL2, haz un reboot del equipo, suele resolverlo.

### ZSH y tmux

La shell que viene por defecto en Ubuntu para WSL2 es `bash` pero como expliqué en [¡Adiós Bash, hola Zsh!]({{< relref "2024-04-23-zsh.md" >}}), me paso a `zsh` ([un apunte interesante]({{< relref "2024-07-25-linux-desarrollo.md" >}})). También me instalo ["tmux"]({{< relref "2024-04-25-tmux.md" >}}), un multiplexor de terminales opcional potentísimo.

Primero `zsh`

```shell
luis@kymeraw:~$ sudo apt update && sudo apt upgrade -y
luis@kymeraw:~$ sudo apt install zsh
```

Compruebo las shells disponibles

```shell
luis@kymeraw:~$ cat /etc/shells
:
/bin/zsh
/usr/bin/zsh
```

Cambio la shell por defecto

```shell
luis@kymeraw:~$ chsh -s $(which zsh)
Password:
```

Salgo y vuelvo a entrar. La primera vez que entras con `zsh` te ofrece ayuda para crear el fichero `.zshrc`. En mi caso ya lo tengo creado porque uso el mismo para MacOS, Linux y ahora Windows. Me lo descargo **[~/.zshrc](https://gist.github.com/LuisPalacios/7507ce0b84adcad067320e9631648fd7)** y lo copio al HOME `/mnt/c/Users/luis`.

Instalo tmux, que lo suelo utilizar:

```shell
sudo apt install tmux
```

Aquí tengo un **[~/.tmux.conf](https://gist.github.com/LuisPalacios/065f4f0491d472d65ef62f67f1f418a1)**, que también copio al HOME (`/mnt/c/Users/luis`).

### Scripts útiles

Me instalo los scripts que suelo usar en todos mis Linux/macOS:

- Script [/usr/bin/e](https://gist.githubusercontent.com/LuisPalacios/14b0198abc35c26ab081df531a856971/raw/8b6e278b4e89f105b2d573ebc79c67e915e6ab47/e).
- Fichero [/etc/nanorc](https://gist.githubusercontent.com/LuisPalacios/4e07adf45ec1ba074939317b59d616a4/raw/b50efd22130a0129e408bca10fc7b8dbab7e03ff/nanorc) personalizado para `nano`. Crea los directorios de backup: `sudo mkdir /root/.nano` y `mkdir ~/.nano`.
- Script [/usr/bin/confcat](https://gist.githubusercontent.com/LuisPalacios/d646638f7571d6e74c20502b3033cf07/raw/f0f015d9b1d806919ec0295a22f3710b4f3096e0/confcat): un `cat` sin líneas de comentarios.
- Script [/usr/bin/s](https://gist.githubusercontent.com/LuisPalacios/8e334583ad28e681326c65b665457eaa/raw/201a2ace950dcbb14b341b31ae70c9fffde29540/s) para cambiar a root rápido. Añade tu usuario a sudoers: `echo 'luis ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-mi-usuario`.
- Permisos: `sudo chmod 755 /usr/bin/e /usr/bin/confcat /usr/bin/s`.

### CRLF vs LF

Al trabajar en desarrollo de software, uno de los aspectos más sutiles pero cruciales que debes tener en cuenta es la diferencia entre los finales de línea en archivos de texto entre Windows y Linux.

En este apunte [CRLF vs LF]({{< relref "2024-09-28-crlf-vs-lf.md" >}}) puedes encontrar cómo manejo este tema.

### Oh-My-Posh en WSL

Ver la sección [Oh My Posh](#oh-my-posh) en Terminal mejorado más arriba. Para WSL2 uso mi herramienta [devcli](https://github.com/LuisPalacios/devcli).

### Cambiar UID/GID

Durante la instalación tube un problema, la primera vez me instaló Ubuntu22.04 y puso a mi usuario `luis` el UID/GID 1000:1000, activé metada como mencionaba antes para la gestión de permisos y todo bajo `/mnt/c` pasó a ser propiedad de 1000:1000. Hasta ahí todo bien.

El problema vino al instalar Ubuntu24.04 y eliminar la 22.04. Observé que crea por defecto el usuario `ubuntu y el grupo lxc` con UID/GID 1000, y al usuario `luis` le asignó el `1002`. Eso provocó un líó de permisos enorme.

Esto es lo que hice para arreglarlo:

``` bash
PS > wsl --install Ubuntu24-04
PS > ubuntu2404.exe config --default-user root
PS > wsl --shutdown
PS > ubuntu2404.exe

nano /etc/group cambié los gid
lxc 1000 -> 1001
ubuntu 1001 -> 1002
luis 1002 -> 1000

nano /etc/passwd cambié los uid
ubuntu 1000 -> 1002
luis 1002 -> 1000

cd /home
chown -R luis:luis luis
chown -R ubuntu:ubuntu ubuntu
```

Reviso el fichero de configuración. Aquí tienes una copia: [/etc/wsl.conf](#configuración-etcwslconf).

```Powershell
PS > ubuntu2404.exe config --default-user luis
PS > wsl --shutdown
PS > ubuntu2404.exe
```

Nota: Para hacer búsquedas de los permisos y que no se eternice entrando en `/mnt/c` uso el comando siguiente:

```shell
cd /
find . -not \( -path "./mnt*" -type d -prune \) -user ubuntu
```

### Modificar el PATH

**PATH de Windows (para `CMD`, `PowerShell`)**:

Consulta la nota sobre el PATH que puse al principio de este apunte.

**WSL2**:

En mi caso prefiero que WSL2 no me añada todos las entradas del PATH de Windows al de Linux, modifico `/etc/wsl.conf` y añado la sección:

```conf
[interop]
appendWindowsPath=false
```

Aquí tienes una copia: [/etc/wsl.conf](#configuración-etcwslconf).

- Salgo de WSL, lo apago (`wsl --shutdown`), vuelvo a entrar y edito `~/.bashrc` o `.zshrc`. Este es un ejemplo de cómo queda (soy selectivo en qué quiero del PATH de windows en mi sesión WSL2).

```shell
⚡ luis@kymeraw:~ % echo $PATH
/mnt/c/Users/luis/.gems/bin:.:/mnt/c/Users/luis/Nextcloud/priv/bin:/usr/local/bin:/usr/local/sbin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/mnt/c/Windows/System32:/mnt/c/Windows:/mnt/c/Windows/System32/wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:/mnt/c/Program Files/PowerShell/7
```

<br/>

## SSH en Windows 11

OpenSSH en Windows 11 es una característica **nativa del sistema operativo**, no tiene nada que ver con WSL2. El servicio `sshd` se ejecuta en Windows, usa tus credenciales de Windows y su configuración vive en `C:\ProgramData\ssh\`. La única integración opcional con WSL (o con Git Bash) es decidir **qué shell recibe** las conexiones entrantes, y lo dejo para el final.

### Cliente SSH

Para poder conectar desde `CMD`, `PowerShell`, `Git Bash` o WSL2 a equipos remotos.

- Verifico que el cliente de OpenSSH está instalado (PowerShell como Administrador):

```powershell
Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
```

- Creo el par pública/privada en el HOME de Windows (normalmente uso el cliente SSH de Windows):

```powershell
# PowerShell
ssh-keygen.exe -t ed25519 -a 200 -C "luis@kymeraw" -f $env:USERPROFILE\.ssh\id_ed25519_luispa

# CMD
ssh-keygen.exe -t ed25519 -a 200 -C "luis@kymeraw" -f %USERPROFILE%\.ssh\id_ed25519_luispa

# WSL2 (apuntando a la misma ruta de Windows)
ssh-keygen -t ed25519 -a 200 -C "luis@kymeraw" -f /mnt/c/Users/luis/.ssh/id_ed25519_luispa
```

Te dejo un enlace a otro apunte muy interesante, [Git multicuenta]({{< relref "2024-09-21-git-multicuenta.md" >}}), donde trato el tema de SSH como alternativa.

### Servidor SSH

Agrego el Servidor OpenSSH (si no estuviera ya):

```powershell
Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
:
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

Arranco el servicio, compruebo y lo dejo en arranque automático:

```powershell
Start-Service sshd
Get-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
```

El Servidor SSH se ejecuta en Windows (no en WSL2/Ubuntu), así que los ***credenciales*** son los de Windows — mi usuario LOCAL `luis` (no uso Microsoft Account) y su contraseña de Windows. El fichero **sshd_config** se encuentra en `C:\ProgramData\ssh\sshd_config`.

Desactivo `administrators_authorized_keys` porque prefiero que use el del HOME de mi usuario en `C:\Users\luis\.ssh\authorized_keys`:

```config
AuthorizedKeysFile .ssh/authorized_keys
AcceptEnv LANG LC_*
Subsystem sftp sftp-server.exe
#Match Group administrators
# AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

Lo edito y rearranco el servicio:

```powershell
notepad C:\ProgramData\ssh\sshd_config
Restart-Service sshd
```

Edito las claves que acepto en `authorized_keys`:

```powershell
notepad C:\Users\luis\.ssh\authorized_keys
```

Compruebo si el puerto 22 está abierto. Aquí tienes un script de ayuda: [VerificarPuertoFirewall.ps1](https://gist.github.com/LuisPalacios/f1013d3a0cc0d540b94df2d7d42c2f40). Si necesitas abrir el puerto en el firewall:

```powershell
New-NetFirewallRule -DisplayName "Allow SSH Port 22" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
```

A partir de aquí ya puedo entrar por SSH desde cualquier equipo de la red. Por defecto me recibirá una `cmd.exe`.

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-04.png" alt="Conexión vía SSH desde un Mac" width="550px" />
  <div class="image-caption">Conexión vía SSH desde un Mac</div>
</div>

#### Shell por defecto al conectar (opcional)

Por defecto OpenSSH entrega al cliente una sesión de `cmd.exe`. Puedo cambiar la shell que reciben las conexiones SSH entrantes escribiendo el valor `DefaultShell` en el registro `HKLM:\SOFTWARE\OpenSSH`. Hay un detalle importante: **esa clave del registro no siempre existe** tras instalar OpenSSH (me ha pasado con instalaciones vía `winget` de Git), así que la creo primero con `New-Item -Force`, que es idempotente — si ya existe no pasa nada.

Paso previo común (PowerShell como Administrador):

```powershell
# Creo la clave del registro si no existe (idempotente)
New-Item -Path "HKLM:\SOFTWARE\OpenSSH" -Force | Out-Null
```

A partir de aquí elijo **una** de las dos opciones según qué shell quiero recibir.

**Opción A — WSL 2 como shell por defecto**:

Las conexiones entrantes aterrizan directamente en mi distro de WSL2. Importante usar `C:\Windows\System32\wsl.exe` y **no** el de `C:\Users\luis\AppData\Local\Microsoft\WindowsApps\wsl.exe` (ese tarda varios segundos en dar prompt).

```powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell `
  -Value "C:\Windows\System32\wsl.exe" -PropertyType String -Force | Out-Null
```

**Opción B — Git Bash como shell por defecto**:

Las conexiones entrantes aterrizan en `bash.exe` de Git for Windows (nativo Windows, sin WSL). Útil para que los scripts remotos aterricen en Bash en vez de `cmd.exe`:

```powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell `
  -Value "C:\Program Files\Git\bin\bash.exe" -PropertyType String -Force | Out-Null
```

Paso final común — recargo el PATH en esta sesión y reinicio `sshd` para que los cambios apliquen a las **nuevas** conexiones SSH:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
Restart-Service sshd
```

<br/>

## Herramientas de desarrollo

Cubierta la shell y WSL2, paso a las herramientas multiplataforma (las instalo en todo equipo, sea Windows, Linux o macOS), luego los lenguajes de programación, y dejo `.NET` y Visual Studio para el final.

### VSCode

<img src="/img/posts/logo-vscode.svg" alt="VSCode" width="150px" height="150px" style="float:left; padding-right:25px"  />

Lo ***instalo*** desde el [sitio oficial de Visual Studio Code](https://code.visualstudio.com/). Editor potente, con cientos de extensiones útiles, terminales integrados (CMD, PowerShell, [Git Bash](https://git-scm.com/install/windows), WSL), soporte para múltiples lenguajes y desarrollo remoto.

***Settigs y Sincronización***: Echa un ojo al apunte [VSCode settings y extensiones]({{< relref "2023-06-20-vscode.md" >}}) donde mantengo cómo lo gestiono y mi configuración.

Creo una especie de ***alias***, en linux y en Mac me gusta crear un alias que llamo "***e***" (de **e**ditor), para llamar a mi editor preferido. Desde una sesión de Administrador edito el script `c:\windows\e.cmd`. Ya tengo mi alias, será válido para cmd y powershell

```cmd
@echo off
"C:\Users\luis\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd" %*
```

---

<br/>

### Docker Desktop

<img src="/img/posts/logo-docker.svg" alt="Docker Desktop" width="150px" height="150px" style="float:left; padding-right:25px"  />

Imprescindible para desarrollo en entornos aislados: procesos contenerizados (bases de datos, etc.), dockerizar servicios propios (Go, Node.js), pruebas de CI, laboratorios de microservicios. ***Instalo*** desde el [sitio oficial de Docker](https://www.docker.com/products/docker-desktop). La integración con WSL2 es la pieza clave, y por eso WSL2 se preparó antes.

Durante el proceso de instalación selecciono usar WSL2 en vez de Hyper-V

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-07.png" alt="Opción WSL2" width="300px" />
  <div class="image-caption">Opción WSL2</div>
</div>

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-13.png" alt="Consola de Docker" width="600px" />
  <div class="image-caption">Consola de Docker</div>
</div>

#### Integración con WSL2

La integración con WSL2 es inmediata, no tienes que hacer nada. Bueno, casi nada. Hay un tema importante "El contexto".

Al entrar en una sesión de WSL2 es importante estar en el Contexto adecuado de Docker. Si no tienes el correcto puedes encontrarte con el error `Failed to initialize: protocol not available`.

```shell
PS > ubuntu2404.exe

$ docker ps -a
Failed to initialize: protocol not available

$ docker context ls
NAME              DESCRIPTION                               DOCKER ENDPOINT                             ERROR
default           Current DOCKER_HOST based configuration   unix:///var/run/docker.sock
desktop-linux *   Docker Desktop                            npipe:////./pipe/dockerDesktopLinuxEngine
```

En este caso estamos en el contexto `desktop-linux` lo que provocará que WSL2 no se pueda comunicar correctamente con Docker. Puedes cambiar de contexto con el comando `docker context use default` pero no será permanente. Lo mejor es editar el fichero `~/.docker/config.json`

```shell
notepad.exe C:\Users\<tu-usuario>\.docker\config.json
:
        "currentContext": "default",
:
```

A partir de este momento funcionará correctamente

```shell
PS > ubuntu2404.exe

$ docker context ls
NAME            DESCRIPTION                               DOCKER ENDPOINT                             ERROR
default *       Current DOCKER_HOST based configuration   unix:///var/run/docker.sock
desktop-linux   Docker Desktop                            npipe:////./pipe/dockerDesktopLinuxEngine

$ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
:
```

> **Cuidado**: si has cambiado el HOME de WSL2 a `/mnt/c/Users/<usuario>`, Docker sobrescribe `.docker\config.json` al arrancar, así que editarlo es inútil. Solución: añade `docker context use default` al final de tu `.bashrc`/`.zshrc`.

<br/>

---

### Postman

Puedes instalar desde el [sitio oficial de Postman](https://www.postman.com/). Es una herramienta muy conocida para probar y documentar APIs. Es muy útil para desarrolladores que trabajan con servicios web. En mi caso de momento la dejo en la recámara, quizá la instale más adelante.

<br/>

---

### HTTPie

<img src="/img/posts/logo-httpie.svg" alt="Docker HTTPie" width="150px" height="150px" style="float:left; padding-right:25px"  />

Alternativa a Postman para probar y depurar APIs, con CLI y GUI. Prefiero HTTPie por su línea de comandos. La ***instalo*** desde el [sitio oficial de HTTPie](https://httpie.io/).

En Windows, el instalador oficial pasa por [Chocolatey](https://chocolatey.org/install).

<br/>

---

## Lenguajes de programación

### Python, pip, pipx, venv

<img src="/img/posts/logo-python.svg" alt="logo python" width="150px" height="150px" style="float:left; padding-right:25px"  />

**[`python`](https://www.python.org)** es un lenguaje de programación interpretado, versátil y fácil de aprender, lo que más me gusta es que es muy legible y soporta múltiples paradigmas como la programación orientada a objetos, funcional e imperativa. Hay mucha herramienta que lo necesita y tiene muchos casos de uso. Aunque en mi caso no lo uso casi nunca, siempre lo instalo.

**[`pip`](https://pypi.org/project/pip/)** es una herramienta fundamental para gestionar paquetes de Python. Es el sistema utilizado para instalar y manejar librerías de terceros desde el [Python Package Index (PyPI)](https://pypi.org), el repositorio oficial de Python.

**[`pipx`](https://pypi.org/project/pipx/)** es la opción más recomendada para instalar aplicaciones CLI que quieres usar desde cualquier lugar. Crea automáticamente un entorno virtual aislado para cada aplicación, la instala junto con sus dependencias en ese entorno, y añade el ejecutable a tu PATH.

**[`venv`](https://docs.python.org/3/library/venv.html)** venv es un módulo incluido en Python que permite crear entornos virtuales. Un entorno virtual es un espacio aislado en el sistema donde puedes instalar paquetes y bibliotecas de Python de manera independiente, sin que afecten ni sean afectados por otras instalaciones de Python en el sistema.

**Instala** directamente desde [python.org](https://www.python.org/downloads/windows/). Instala siempre una versión estable. Yo personalmente prefiero instalar la que tenga más "wheels" precompilados, así te ahorras que tenga que compilar paquetes (cuando hagas `pip instal ...`). Por ejemplo, cuando salió la version 3.14, yo sigo usando la 3.13 estable.

Antes de ejecutar el instalador: **Importante quitar los alias que Windows 11 trae por defecto a `python.exe` o `python3.exe`**. Ejecuta desde `Search` > "`Manage app execution aliases`". Desactiva los dos alias "python" and "python3".

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-15.png" alt="Desactivar los dos alias a python/python3" width="450px" />
  <div class="image-caption">Desactivar los dos alias a python/python3</div>
</div>

Durante la instalación selecciono las siguientes opciones, para tener disponible `py.exe`, `python.exe` desde cualquier terminal.

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-16.png" alt="Opciones durante la instalación" width="2048px" />
  <div class="image-caption">Opciones durante la instalación</div>
</div>

Además creo un ***alias*** a `python3`, creo el script `c:\windows\python3.cmd`.

```cmd
@echo off
"C:\Program Files\Python312\python.exe" %*
```

**Instala `pip`**:

```cmd
C:> py get-pip.py
```

**Instala `pipx`**:

```cmd
scoop install pipx
pipx ensurepath
```

---

**Instalar una aplicacion global con `pipx`**:

Esto no es para desarrollar, sino para el caso de necesitar instalarte una aplicación hecha en python que es de tipo CLI y quieres usarla desde cualquier lugar. `pipx` te facilita la vida, crea automáticamente un entorno virtual aislado, instala junto con sus dependencias en ese entorno, y añade el ejecutable a tu PATH.

- Cada aplicación tiene sus propias dependencias aisladas
- No hay conflictos entre diferentes aplicaciones
- Puedes usar la aplicación desde cualquier terminal sin activar ningún entorno
- Es más limpio y seguro que instalar globalmente con `pip`

Veamos un ejemplo. Voy a instalar el programa [pdfly](https://github.com/py-pdf/pdfly) en mi Windows. Por cierto, aquí tienes un apunte sobre [pdfly, la navaja suiza para PDF's]({{< relref "2025-11-30-navaja-pdfly.md" >}}).

Lo que va a hacer `pipx` es crear `.local\bin\pdfly.exe`, un pequeño programa envoltorio (conocido técnicamente como wrapper o shim) que actua como puente. Cuando lo ejecute, busca dónde está su entorno virtual (`<home>\pipx\venvs`), localiza el intérprete de Python dentro de ese entorno y le pasa el script de inicio de pdfly para que se ejecute.

```PS1
[🪟] luis@kymeraw:~ ❯ pipx install pdfly

# Añado .local\bin a mi PATH
[🪟] luis@kymeraw:~ ❯ pipx ensurepath

# Salgo y vuelvo a entrar en el terminal
[🪟] luis@kymeraw:~ ❯ where pdfly
c:\Users\luis\.local\bin\pdfly.exe
```

---

**Trabajar en un entorno virtual con venv**:

Esto es lo normal que querrás hacer siempre, como desarrollador es mejor tener entornos virtuales para cada aplicación.

**venv** permite crear un entorno virtual, pero ¿para qué sirve?

- Aislamiento de dependencias: Evita conflictos entre paquetes instalados para diferentes proyectos. Por ejemplo, un proyecto puede requerir Django 3.2, mientras que otro necesita Django 4.0.
- Gestión de proyectos: Cada proyecto puede tener su propio entorno con las versiones específicas de los paquetes que necesita.
- Evita problemas con el sistema global: No modifica ni depende de la instalación global de Python o sus paquetes.

Preparar el entorno para Python:

- Crear el entorno: `python -m venv myenv`.
- Activar:
  - Windows: `.\myenv\Scripts\Activate.ps1` (o `.bat`).
  - macOS/Linux: `source myenv/Scripts/activate`.
- Instalar paquetes: `pip install idna`.
- Crear `requirements.txt`: `pip freeze > requirements.txt`.
- Instalaciones futuras: `pip install -r requirements.txt`.
- Desactivar:
  - Windows: `.\myenv\Scripts\deactivate.bat`.
  - macOS/Linux: `deactivate`.

Un ejemplo de la primera vez en Windows:

```shell
python -m venv myenv
.\myenv\Scripts\Activate.ps1
pip install requests idna
pip freeze > requirements.txt
```

**VSCode**: Entro en el directorio de un proyecto, activo el entorno, arranco VSCode y selecciono el intérprete

```shell
.\myenv\Scripts\Activate.ps1
code .
```

Seleccionar el interprete correcto. Command Palette (Ctrl+Shift+P) > Python: Select Interpreter. Selecciono el Global `C:\Program Files\Python312\python.exe`

**Prueba de concepto**: Veamos un mini proyecto, un único fuente llamado `main.py` bajo el entorno virtual `pipenv`, con una única librería `requests`.

```cmd
luis@kymeraw:tmp ❯ cd prueba
luis@kymeraw:prueba ❯ python -m venv myenv
luis@kymeraw:prueba ❯ .\myenv\Scripts\Activate.ps1
luis@kymeraw:prueba via 🐍 v3.12.8 (myenv) ❯
```

Creo el fuente con `notepad main.py`

```python
import requests
response = requests.get('https://httpbin.org/ip')
print('Tu dirección IP es: {0}'.format(response.json()['origin']))
```

Instalo las dependencias

```PowerShell
luis@kymeraw:prueba via 🐍 v3.12.8 (myenv) ❯ notepad main.py
luis@kymeraw:prueba via 🐍 v3.12.8 (myenv) ❯ cat .\main.py
import requests
response = requests.get('https://httpbin.org/ip')
print('Tu dirección IP es: {0}'.format(response.json()['origin']))

luis@kymeraw:prueba via 🐍 v3.12.8 (myenv) ❯ pip install requests
Collecting requests
:
Successfully installed certifi-2024.12.14 charset-normalizer-3.4.1 idna-3.10 requests-2.32.3 urllib3-2.3.0
luis@kymeraw:prueba via 🐍 v3.12.8 (myenv) ❯
```

Ejecuto la prueba de concepto con `python main.py`

```PowerShell
luis@kymeraw:prueba via 🐍 v3.12.8 (myenv) ❯ python.exe .\main.py
Tu dirección IP es: 12.138.199.230
```

---

### Actualización

Para actualizar:

- **Python** - Descargo la última version desde [python.org](https://www.python.org/downloads/windows/) y ejecuto el instalador.
- **Pip**: `py -m ensurepip --upgrade`
- **Pipx**: `scoop update pipx`
- **Programas CLI instalados con `pipx`**: `pipx upgrade-all`

<br/>

---

### C/C++

<img src="/img/posts/logo-llvm.svg" alt="LLVM" width="150px" height="150px" style="float:left; padding-right:25px"  />

Como este es un apunte multiplataforma, para trabajar en C/C++ elijo el compilador **CLang**, pertenece al proyecto **LLVM** (Low-Level Virtual Machine). Es un compilador de C, C++, y Objective-C. Es modular, rápido y definitivamente multiplataforma.

En la tabla [C++ Support in Clang](https://clang.llvm.org/cxx_status.html) puedes ver qué versión del estandar ISO C++ soporta Clang y más importante, cuál es el estado de implementación de del estándar del lenguaje (C++98, C++11, ..., C++2x).

Si quieres ver un ejemplo de proyecto multiplataform con Clang, echa un ojo a [`git-repo-eol-analyzer`](https://github.com/LuisPalacios/git-repo-eol-analyzer), funciona en Windows, Linux y MacOS.

Para instalar, descarga e instala ***LLVM X.X.X*** desde las [Releases oficiales](https://github.com/llvm/llvm-project/releases). Como ejemplo, aquí tienes un enlace directo a [LLVM 64bits 21.1.2 para Windows)](https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.2/LLVM-21.1.2-win64.exe).

<br/>

---

#### CMake

<img src="/img/posts/logo-cmake.svg" alt="CMake" width="150px" height="150px" style="float:left; padding-right:25px"  />

Muy vinculado a C/C++, CMake es una herramienta de código abierto que gestiona la configuración y generación de scripts de compilación para proyectos multiplataforma. Permite abstraer las configuraciones específicas de cada plataforma, simplificando la creación de archivos de construcción (Makefiles, proyectos de Visual Studio, etc.). En proyectos C++ en Windows, CMake se integra perfectamente con VSCode, permite generar de forma automática los proyectos, etc.

Para instalarlo en Windows: desde el [sitio oficial](https://cmake.org/download/), me bajo el *Windows x64 Installer*. También te recomiendo instalar **Ninja (Generador)** desde [su repositorio oficial](https://github.com/ninja-build/ninja/releases) y guardarlo en un directorio que ya tengas en el PATH.

El proceso básico de CMake consta de dos pasos:

1. **Configurar (Configure)**: Analiza el archivo `CMakeLists.txt`, crea todos los scripts y ficheros específicos para que el sistema luego pueda generar (compilar) el código. El resultado de la configuración se realiza en el subdirectorio **./build**.

2. **Generar (Build)**: A partir del paso anterior, CMake compila para el entorno de desarrollo y sistema en el que estemos, por ejemplo un proyecto con un `Makefile` o cosas más complejas.

CMake sigue un enfoque declarativo, se define lo que el proyecto necesita (fuentes, bibliotecas, dependencias) en el archivo `CMakeLists.txt`. Repasa el que he creado en el proyecto que mencionaba antes: [`git-repo-eol-analyzer`](https://github.com/LuisPalacios/git-repo-eol-analyzer).

<br/>

---

### Golang

<img src="/img/posts/logo-golang.svg" alt="Golang" width="150px" height="150px" style="float:left; padding-right:25px"  />

Golang es un lenguaje que combina la simplicidad y eficiencia de lenguajes antiguos como C, con las características modernas necesarias para el desarrollo de software concurrente y de alto rendimiento. Es especialmente popular en el desarrollo de sistemas distribuidos, servicios en la nube y herramientas de red, gracias a su enfoque en la concurrencia y la escalabilidad.

- Para ***instalarlo en Windows***, ve a la página de [descargas de Go](https://go.dev/dl/) me bajo la útima versión del MSI para windows-amd64, lo instala por defecto con `C:\Program Files\Go\bin` que añade al PATH.
- Para ***integrarlo con VSCode*** instalo la extensión [`golang.go`](https://marketplace.visualstudio.com/items?itemName=golang.Go).

Algunas variables críticas para un entorno de desarrollo eficiente en Go:

- `$GOROOT`: Ruta de instalación (por defecto `C:\Program Files\Go`).
- `$GOPATH`: Directorio de trabajo por defecto `C:\Users\<usuario>\go`.
- La instalación añade al PATH `$GOROOT\bin` y `$GOPATH\bin`.

A partir de Go 1.11, se introdujo el sistema de módulos **Go Modules** que gestiona dependencias de manera más eficiente. Lo habilito con `go env -w GO111MODULE=on` y hago un pequeño programa para comprobar que todo está bien.

Inicializo el módulo del proyecto:

```shell
go mod init hola
```

Creo el archivo `main.go`:

```go
package main

import "fmt"

func main() {
    fmt.Println("Hola, mundo")
}
```

Compilo y ejecuto y luego compilo el binario `hola.exe`

```shell
go run main.go

go build
```

<br/>

---

## .NET

Hoy conviven dos líneas:

- **.NET Framework 4.8** (Windows-only, ya sin evolución): necesario por compatibilidad con aplicaciones existentes y herramientas que aún requieren el runtime clásico.
- **.NET 5+** (multiplataforma: Windows, Linux, macOS): unifica .NET Core, .NET Framework y Xamarin. La versión 9 salió en noviembre de 2024.

### .NET Framework

Windows-only, última versión 4.8. Útil hoy para:

- **Compatibilidad**: apps antiguas y herramientas modernas que aún requieren el runtime.
- **Desarrollo legacy**: mantenimiento de aplicaciones basadas en .NET Framework (instala además el Developer Pack).

Para instalar .NET Framework 4.8, entra en **Programas y características** del panel de control o desde la Web de Microsoft. Por el primer método, verifico antes qué tengo y luego instalo.

1. Abro **Control Panel** > **Programs** > **Programs and Features** > **Turn Windows features on or off**.
2. Aquí se puede ver la versión de .NET Framework instaladas.
3. En la lista de características, busca las versiones de .NET Framework disponibles (por ejemplo, .NET Framework 3.5 o .NET Framework 4.8).
4. Marca la casilla junto a la versión que deseas instalar.
5. Haz clic en **Aceptar** y espera a que Windows complete la instalación.

Si la versión no está en la lista, puedo ir a la Web de microsoft, ([ejemplo para la 4.8.1](https://dotnet.microsoft.com/en-us/download/dotnet-framework/net481)). Si vas a hacer desarrollos instala el Developer Pack.

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-14.png" alt="Opción de instalar .NET desde la Web" width="640px" />
  <div class="image-caption">Opción de instalar .NET desde la Web</div>
</div>

Puedes comprobar qué version tienes instalada y el número que muestra en la página de [.NET Framework versions and dependencies](https://learn.microsoft.com/en-us/dotnet/framework/migration-guide/versions-and-dependencies):

```PowerShell
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' | Get-ItemPropertyValue -Name Release
```

Puedes usar la herramienta [.NET Version Detector](https://www.asoft.be/prod_netver.html), una herramienta ligera que proporciona información sobre las diferentes versiones de Microsoft .NET y .NET Core que están instaladas en una máquina.

```PowerShell
dotnetver.exe
```

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-17.png" alt=".NET Version Detector" width="500px" />
  <div class="image-caption">.NET Version Detector</div>
</div>

### .NET 5+

Plataforma moderna y multiplataforma (Windows, Linux, macOS) que unifica .NET Core, .NET Framework y Xamarin en un único modelo. El nombre *Core* desaparece y la numeración salta de 3.1 al 5 para marcar el nuevo ciclo.

Antes de instalar, desactivo la telemetría ([opt-out](https://aka.ms/dotnet-cli-telemetry)): añado la variable de entorno `DOTNET_CLI_TELEMETRY_OPTOUT=1` en **System variables** (ver [Nota sobre el PATH](#nota-sobre-el-path) para cómo abrir el editor de variables).

Me bajo la última version y empiezo la instalación:

- **Desde la página oficial de descargas**:
  - [dotnet.microsoft.com/download](https://dotnet.microsoft.com/download).
  - Selecciona la versión de .NET que deseas instalar (Runtime o SDK). En mi caso SDK porque voy a desarrollar aplicaciones.

- **Descarga el instalador**:
  - Elige la opción correspondiente a tu sistema operativo (Windows x64 para la mayoría de los usuarios).

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-18.png" alt="Instalacion de .NET 5+" width="350px" />
  <div class="image-caption">Instalacion de .NET 5+</div>
</div>

- **Ejecuta el instalador**:
  - Sigue las instrucciones en pantalla para completar la instalación. Si estoy actualizando, elijo "Reparar".
  - En mi caso se instalaron los siguientes productos (actualización abril'25):
    - SDK de .NET 9.0.203
    - .NET Runtime 9.0.4
    - ASP.NET Core Runtime 9.0.4
    - .NET Windows Desktop Runtime 9.0.4

- Enlaces a Recursos
  - Documentación de .NET [https://aka.ms/dotnet-docs](https://aka.ms/dotnet-docs)
  - Documentación de SDK [https://aka.ms/dotnet-sdk-docs](https://aka.ms/dotnet-sdk-docs)
  - Notas de la versión [https://aka.ms/dotnet9-release-notes](https://aka.ms/dotnet9-release-notes)
  - Tutoriales [https://aka.ms/dotnet-tutorials](https://aka.ms/dotnet-tutorials)

Verifico la instalación, que por cierto, se instala en `C:\Program Files\dotnet`

```PowerShell
luis@kymeraw:~ ❯ dotnet --version
9.0.203
```

Con .NET instalado, puedes crear tu primer programa en C# fácilmente utilizando la CLI de .NET.

1. Abre terminal (CMD, PowerShell o terminal en tu editor de código).
2. Navega al directorio donde quieres crear el proyecto:

```PowerShell
luis@kymeraw:tmp ❯ dotnet new console -n HolaMundo
The template "Console App" was created successfully.

Processing post-creation actions...
Restoring C:\Users\luis\tmp\HolaMundo\HolaMundo.csproj:
Restore succeeded.
luis@kymeraw:tmp ❯ cd .\HolaMundo\
```

Este es el programa que genera

```csharp
// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");
```

```PowerShell
luis@kymeraw:HolaMundo ❯ dotnet run
Hello, World!
```

Para crear un ejecutable

```PowerShell
luis@kymeraw:HolaMundo ❯ dotnet build
Restore complete (0,1s)
  HolaMundo succeeded (0,1s) → bin\Debug\net9.0\HolaMundo.dll

Build succeeded in 0,5s
luis@kymeraw:HolaMundo ❯ .\bin\Debug\net9.0\HolaMundo.exe
Hello, World!
```

#### Eliminar versiones de SDK/Runtime

Cuando trabajas con .NET en Windows, especialmente en entornos de desarrollo activos, es común acumular múltiples versiones del SDK y runtime. Aquí te muestro cómo ver qué versiones tienes instaladas y cómo desinstalar las que ya no necesitas. Desde el terminal, para ver los SDKs y los Runtimes:

```PowerShell
luis@kymeraw:~ ❯ dotnet --list-sdks
8.0.408 [C:\Program Files\dotnet\sdk]
9.0.105 [C:\Program Files\dotnet\sdk]
9.0.203 [C:\Program Files\dotnet\sdk]

luis@kymeraw:~ ❯ dotnet --list-runtimes
Microsoft.AspNetCore.App 8.0.15 [C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App]
Microsoft.AspNetCore.App 9.0.4 [C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App]
Microsoft.NETCore.App 8.0.15 [C:\Program Files\dotnet\shared\Microsoft.NETCore.App]
Microsoft.NETCore.App 9.0.4 [C:\Program Files\dotnet\shared\Microsoft.NETCore.App]
Microsoft.WindowsDesktop.App 8.0.15 [C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App]
Microsoft.WindowsDesktop.App 9.0.4 [C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App]
```

A diferencia de otros entornos, .NET no tiene un comando para desinstalar versiones desde el CLI. Debes desinstalarlas manualmente desde el Panel de Control o la nueva interfaz de Configuración:

- Win + I para abrir Configuración.
- Aplicaciones → Aplicaciones instaladas.
- En la barra de búsqueda, escribe .NET.
- Busco entradas como:
  - Microsoft .NET SDK 8.0.408
  - Microsoft .NET SDK 9.0.105
  - Microsoft .NET Runtime 8.0.15

Desde los tres puntos (⋮) -> Desinstalar.

También se puede usar `winget` si fueron instaladas con ese sistema:

```PowerShell
luis@kymeraw:~ ❯ winget list "Microsoft .NET"
Name                                              Id                                                Version     Source
-----------------------------------------------------------------------------------------------------------------------
:
Microsoft Windows Desktop Runtime - 8.0.15 (x64)  Microsoft.DotNet.DesktopRuntime.8                 8.0.15      winget
:
luis@kymeraw:~ ❯ winget uninstall "Microsoft.DotNet.DesktopRuntime.8"
Found Microsoft Windows Desktop Runtime - 8.0.15 (x64) [Microsoft.DotNet.DesktopRuntime.8]
Starting package uninstall...
Successfully uninstalled
```

<br/>

---

### Ruby

<img src="/img/posts/logo-ruby.svg" alt="logo ruby" width="150px" height="150px" style="float:right; padding-right:25px"  />

Windows no trae Ruby, así que lo voy a instalar. No es que programe con él, pero lo necesito para ejecutar `Bundler` y `Jekyll` para trabajar en mi blog en local (más info [aquí]({{< relref "2021-04-19-nuevo-blog.md" >}})). **Ruby** es un lenguaje de programación interpretado, reflexivo y orientado a objetos, creado por el programador japonés Yukihiro "Matz" Matsumoto, quien comenzó a trabajar en Ruby en 1993, y lo presentó públicamente en 1995.

Instalación: Sigo la [documentación desde Jekyll](https://jekyllrb.com/docs/installation/windows/)

<br/>

---

### Node.js

<img src="/img/posts/logo-nodejs.svg" alt="logo nodejs" width="150px" height="150px" style="float:left; padding-right:25px"  />

Node.js es un entorno de ejecución de JavaScript en el servidor, que permite crear *aplicaciones Servidor* rápidas, escalables y asincrónicas. Lo utilizo para proyectos de backend, microservicios o herramientas de línea de comandos escritas en JS/TS.

- Descargo desde [https://nodejs.org](https://nodejs.org)
- Instalo la versión **LTS (Long Term Support)** para mayor estabilidad.
- El instalador incluye automáticamente `npm`, el gestor de paquetes de Node.

Verifico la instalación:

```powershell
node -v
npm -v
npm install -g yarn            # Alternativa a npm
npm install -g typescript      # Compilador TS
npm install -g eslint          # Linter
npm install -g http-server     # Servidor estático
```

Uso npx para ejecutar binarios sin necesidad de instalación global.

```powershell
npx create-react-app myapp
```

VSCode detecta automáticamente node y npm. Instalo las extensiones recomendadas: ESLint, Prettier, JavaScript / TypeScript Snippets

<br/>

---

### JDK de Java

<img src="/img/posts/logo-java.svg" alt="logo java" width="150px" height="150px" style="float:left; padding-right:25px"  />

Aunque no programo en Java, lo necesito para ejecutar algunas herramientas (como SDKs Android o herramientas de terceros que requieren JVM). En esos casos instalo el JDK de [Adoptium (Temurin)](https://adoptium.net/), una versión open source sin telemetría. Alternativamente puedes usar el [JDK oficial desde Oracle](https://www.oracle.com/java/technologies/javase-downloads.html).

En mi caso me bajé la últuma versión de Adoptium, (`OpenJDK21U-jdk_x64_windows_hotspot_21.0.6_7.msi`) y ejecuté el proceso de instalación

Durante la instalación me aseguré de que:

- Añadiese `JAVA_HOME\bin` al `PATH`
- Configurase la variable de entorno `JAVA_HOME`

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-20.png" alt="Instalación del JDK desde Adoptium" width="350px" />
  <div class="image-caption">Instalación del JDK desde Adoptium</div>
</div>

Una vez termina,

```powershell
PowerShell 7.5.0
C:\Users\luis>
luis@kymeraw:~ ❯ echo $env:JAVA_HOME
C:\Program Files\Eclipse Adoptium\jdk-21.0.6.7-hotspot\
luis@kymeraw:~ ❯
luis@kymeraw:~ ❯ java --version
openjdk 21.0.6 2025-01-21 LTS
OpenJDK Runtime Environment Temurin-21.0.6+7 (build 21.0.6+7-LTS)
OpenJDK 64-Bit Server VM Temurin-21.0.6+7 (build 21.0.6+7-LTS, mixed mode, sharing)
luis@kymeraw:~ ❯
luis@kymeraw:~ ❯
```

Opcionalmente puedo también instalar Maven o Gradle según el proyecto.

```powershell
winget install Apache.Maven
winget install Gradle.Gradle
```

Cuando trabajas en proyectos Java medianos o grandes, gestionar las dependencias y el proceso de build manualmente es inviable. Para eso existen herramientas como **Maven** y **Gradle**: automatizan la compilación, testeo, empaquetado y gestión de librerías de terceros.

**[Apache Maven](https://maven.apache.org/)** es una herramienta de gestión de proyectos y construcción de software basada en el concepto de un archivo de configuración central (`pom.xml`). Define las dependencias, plugins, fases del ciclo de vida, etc.

Características principales:

- XML como sistema de configuración (`pom.xml`)
- Convención sobre configuración
- Gran repositorio de librerías (Maven Central)
- Muy usado en proyectos empresariales

```xml
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.miempresa</groupId>
  <artifactId>miproyecto</artifactId>
  <version>1.0.0</version>
</project>
```

**[Gradle](https://gradle.org/)** es una herramienta más moderna y flexible que Maven, basada en un enfoque declarativo e imperativo. Usa un DSL en Groovy o Kotlin (build.gradle o build.gradle.kts).

Características principales:

- Más rápido (caché de builds, ejecución paralela)
- Sintaxis más limpia y expresiva
- Compatible con Maven y otros sistemas
- Muy usado en proyectos Android

```groovy
plugins {
    id 'java'
}

group 'com.miempresa'
version '1.0.0'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'com.google.guava:guava:32.1.2-jre'
    testImplementation 'junit:junit:4.13.2'
}
```

<br/>

---

### BBDD locales

Me gusta tener disponibles varias bases de datos en local para pruebas o desarrollo sin depender de servidores externos. Las gestiono vía Docker o instalación directa.

**MySQL / MariaDB**:

- Instalo Docker Desktop
- Arranco contenedor:

```powershell
docker run --name mysql-dev -e MYSQL_ROOT_PASSWORD=admin -p 3306:3306 -d mysql:8
```

Cliente gráfico recomendado: [DBeaver](https://dbeaver.io/)

**PostgreSQL**:

```powershell
docker run --name pg-dev -e POSTGRES_PASSWORD=admin -p 5432:5432 -d postgres
```

Cliente gráfico: [DBeaver](https://dbeaver.io/) o pgAdmin

**SQLite**:

No necesita servidor. Uso SQLite para scripts, pequeños proyectos o tests.

- Instalo desde [https://sqlite.org](https://sqlite.org)
- También está disponible vía `winget install SQLite.sqlite`
- Puedo consultar desde línea de comandos: `sqlite3 database.db`

VSCode tiene extensiones para navegar por fichero `.db`

<br/>

---

## Actualizaciones

**Sistema operativo**: `Start > Settings > Windows Update > Check for updates`.

**Aplicaciones** (depende del propietario de cada app, sigue siendo un rollo tener que estar pendiente):

- Manual: entrar en cada aplicación y mirar versión + opciones de actualización.
- Instaladas con `winget`:
  - `winget update <Id>` para actualizar una concreta.
  - `winget update --all` para actualizar todo.
- Instaladas con `scoop`:
  - `scoop update` se actualiza a sí mismo.
  - `scoop update *` actualiza todas las apps instaladas con scoop.

<div class="image-box">
  <img src="/img/posts/2024-08-25-win-desarrollo-19.png" alt="Ejemplo de uso de winget" width="500px" />
  <div class="image-caption">Ejemplo de uso de winget</div>
</div>

<br/>

---

## Aprendizaje continuo

Para terminar, voy a insistir un poco más sobre ***Shell y Linux***. Si vienes de Windows, te recomiendo aprender a utilizar la Shell; es una habilidad fundamental para cualquier desarrollador de software. La Shell permite automatizar tareas, ejecutar comandos, y manejar el sistema de una manera más eficiente y rápida que a través de interfaces gráficas. Existen muchos recursos disponibles para aprender a utilizar la Shell, tanto en `bash` como en `zsh`, te dejo algunas referencias

- **Curso en Español**: [Curso de Introducción a la Terminal y Comandos Básicos](https://platzi.com/cursos/comandos-terminal/)
- **Curso en Inglés**: [Command Line Basics (Udemy)](https://www.udemy.com/course/command-line-bash-for-beginners/)
- **Comandos Bash**: [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html)
- **Comandos Zsh**: [Zsh Users Guide](https://zsh.sourceforge.io/Guide/zshguide.html)

Además te recomiendo que eches un ojo a algún curso sobre la filosofía de trabajo en Unix, fundamental para comprender Linux. Cómo y por qué los comandos y programas de Unix/Linux están diseñados de la manera en que lo están. La idea principal es que un programa ‘debería hacer una cosa y hacerla bien’. Esta filosofía también abarca conceptos clave como la entrada y salida, el sistema de archivos, la estructura de directorios y la idea de que ‘todo es un fichero’ en Unix. Te dejo algunos cursos cortos y didácticos que cubren estos temas:

- **Curso en Español**: [Introducción a Unix y Linux - Filosofía y Conceptos Básicos](https://cursoswebgratis.com/curso-de-linux/), donde se abordan la estructura de directorios, la gestión de ficheros, y la filosofía Unix de diseño de programas.
- **Curso en Inglés**: [The Unix Workbench (Coursera)](https://www.coursera.org/learn/unix), un curso introductorio que explica la filosofía de Unix, incluyendo la entrada y salida, y cómo interactuar con el sistema de archivos.
- **Curso en Inglés**: [Linux Command Line Basics - Learn the Shell, Philosophy, and More (Udemy)](https://www.udemy.com/course/linux-command-line-basics/), un curso que cubre tanto los comandos esenciales como los principios filosóficos de Unix/Linux.
- **Curso en Inglés**: [Understanding the Unix Philosophy (LinkedIn Learning)](https://www.linkedin.com/learning/understanding-the-unix-philosophy), un curso corto que ofrece una visión general sobre la filosofía de Unix y su aplicación práctica.

Por último, he seleccionado 50 comandos (hay muchos más) que deberías conocer como desarrollador de software multiplataforma. Son esenciales para la navegación del sistema de archivos, gestión de procesos, manipulación de texto, y otras tareas comunes en el desarrollo de software. Cada comando incluye un enlace a su respectiva manpage en Ubuntu 24.04.

| Comando                                                                   | Descripción                                                       | Comando                                                                       | Descripción                                                               |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| **[ls](https://manpages.ubuntu.com/manpages/noble/man1/ls.1.html)**       | Lista los archivos y directorios en el directorio actual.         | **[alias](https://manpages.ubuntu.com/manpages/noble/man1/alias.1.html)**     | Crea un alias para un comando o una serie de comandos.                    |
| **[cd](https://manpages.ubuntu.com/manpages/noble/man1/cd.1.html)**       | Cambia el directorio de trabajo actual.                           | **[unalias](https://manpages.ubuntu.com/manpages/noble/man1/unalias.1.html)** | Elimina un alias previamente definido.                                    |
| **[pwd](https://manpages.ubuntu.com/manpages/noble/man1/pwd.1.html)**     | Muestra el directorio de trabajo actual.                          | **[history](https://manpages.ubuntu.com/manpages/noble/man1/history.1.html)** | Muestra el historial de comandos utilizados.                              |
| **[cp](https://manpages.ubuntu.com/manpages/noble/man1/cp.1.html)**       | Copia archivos y directorios.                                     | **[env](https://manpages.ubuntu.com/manpages/noble/man1/env.1.html)**         | Muestra o modifica las variables de entorno.                              |
| **[mv](https://manpages.ubuntu.com/manpages/noble/man1/mv.1.html)**       | Mueve o renombra archivos y directorios.                          | **[export](https://manpages.ubuntu.com/manpages/noble/man1/export.1.html)**   | Define variables de entorno para los procesos secundarios.                |
| **[rm](https://manpages.ubuntu.com/manpages/noble/man1/rm.1.html)**       | Elimina archivos y directorios.                                   | **[source](https://manpages.ubuntu.com/manpages/noble/man1/source.1.html)**   | Ejecuta comandos desde un archivo en el contexto de la Shell actual.      |
| **[mkdir](https://manpages.ubuntu.com/manpages/noble/man1/mkdir.1.html)** | Crea nuevos directorios.                                          | **[uname](https://manpages.ubuntu.com/manpages/noble/man1/uname.1.html)**     | Muestra información sobre el sistema operativo.                           |
| **[rmdir](https://manpages.ubuntu.com/manpages/noble/man1/rmdir.1.html)** | Elimina directorios vacíos.                                       | **[uptime](https://manpages.ubuntu.com/manpages/noble/man1/uptime.1.html)**   | Muestra el tiempo que lleva encendido el sistema.                         |
| **[touch](https://manpages.ubuntu.com/manpages/noble/man1/touch.1.html)** | Cambia las marcas de tiempo de un archivo o crea archivos vacíos. | **[whoami](https://manpages.ubuntu.com/manpages/noble/man1/whoami.1.html)**   | Muestra el nombre del usuario actual.                                     |
| **[echo](https://manpages.ubuntu.com/manpages/noble/man1/echo.1.html)**   | Muestra una línea de texto o variable.                            | **[which](https://manpages.ubuntu.com/manpages/noble/man1/which.1.html)**     | Localiza un comando y muestra su ruta completa.                           |
| **[cat](https://manpages.ubuntu.com/manpages/noble/man1/cat.1.html)**     | Concatenar y mostrar el contenido de archivos.                    | **[head](https://manpages.ubuntu.com/manpages/noble/man1/head.1.html)**       | Muestra las primeras líneas de un archivo.                                |
| **[grep](https://manpages.ubuntu.com/manpages/noble/man1/grep.1.html)**   | Busca patrones en el contenido de archivos.                       | **[tail](https://manpages.ubuntu.com/manpages/noble/man1/tail.1.html)**       | Muestra las últimas líneas de un archivo.                                 |
| **[find](https://manpages.ubuntu.com/manpages/noble/man1/find.1.html)**   | Busca archivos y directorios en una jerarquía de directorios.     | **[sort](https://manpages.ubuntu.com/manpages/noble/man1/sort.1.html)**       | Ordena líneas de texto en un archivo o entrada.                           |
| **[chmod](https://manpages.ubuntu.com/manpages/noble/man1/chmod.1.html)** | Cambia los permisos de acceso de los archivos.                    | **[uniq](https://manpages.ubuntu.com/manpages/noble/man1/uniq.1.html)**       | Muestra o filtra líneas repetidas consecutivas en un archivo.             |
| **[chown](https://manpages.ubuntu.com/manpages/noble/man1/chown.1.html)** | Cambia el propietario de archivos y directorios.                  | **[diff](https://manpages.ubuntu.com/manpages/noble/man1/diff.1.html)**       | Compara archivos línea por línea.                                         |
| **[ps](https://manpages.ubuntu.com/manpages/noble/man1/ps.1.html)**       | Muestra el estado de los procesos actuales.                       | **[tee](https://manpages.ubuntu.com/manpages/noble/man1/tee.1.html)**         | Lee de la entrada estándar y escribe en la salida estándar y en archivos. |
| **[kill](https://manpages.ubuntu.com/manpages/noble/man1/kill.1.html)**   | Envía señales a procesos, como detenerlos.                        | **[xargs](https://manpages.ubuntu.com/manpages/noble/man1/xargs.1.html)**     | Construye y ejecuta líneas de comando desde la entrada estándar.          |
| **[top](https://manpages.ubuntu.com/manpages/noble/man1/top.1.html)**     | Muestra los procesos en ejecución y el uso de recursos.           | **[jobs](https://manpages.ubuntu.com/manpages/noble/man1/jobs.1.html)**       | Muestra el estado de los trabajos en segundo plano.                       |
| **[df](https://manpages.ubuntu.com/manpages/noble/man1/df.1.html)**       | Muestra el uso del espacio en disco de los sistemas de archivos.  | **[bg](https://manpages.ubuntu.com/manpages/noble/man1/bg.1.html)**           | Reanuda un trabajo suspendido en segundo plano.                           |
| **[du](https://manpages.ubuntu.com/manpages/noble/man1/du.1.html)**       | Estima el uso del espacio en disco por archivos y directorios.    | **[fg](https://manpages.ubuntu.com/manpages/noble/man1/fg.1.html)**           | Trae un trabajo suspendido al primer plano.                               |
| **[tar](https://manpages.ubuntu.com/manpages/noble/man1/tar.1.html)**     | Manipula archivos tar.                                            | **[alias](https://manpages.ubuntu.com/manpages/noble/man1/alias.1.html)**     | Crea un alias para un comando o una serie de comandos.                    |
| **[zip](https://manpages.ubuntu.com/manpages/noble/man1/zip.1.html)**     | Comprime archivos en formato ZIP.                                 | **[unalias](https://manpages.ubuntu.com/manpages/noble/man1/unalias.1.html)** | Elimina un alias previamente definido.                                    |
| **[unzip](https://manpages.ubuntu.com/manpages/noble/man1/unzip.1.html)** | Descomprime archivos en formato ZIP.                              | **[history](https://manpages.ubuntu.com/manpages/noble/man1/history.1.html)** | Muestra el historial de comandos utilizados.                              |
| **[ssh](https://manpages.ubuntu.com/manpages/noble/man1/ssh.1.html)**     | Se conecta a servidores remotos de forma segura a través de SSH.  | **[env](https://manpages.ubuntu.com/manpages/noble/man1/env.1.html)**         | Muestra o modifica las variables de entorno.                              |
| **[scp](https://manpages.ubuntu.com/manpages/noble/man1/scp.1.html)**     | Copia archivos entre servidores de forma segura.                  | **[export](https://manpages.ubuntu.com/manpages/noble/man1/export.1.html)**   | Define variables de entorno para los procesos secundarios.                |
| **[wget](https://manpages.ubuntu.com/manpages/noble/man1/wget.1.html)**   | Descarga archivos desde la web.                                   | **[source](https://manpages.ubuntu.com/manpages/noble/man1/source.1.html)**   | Ejecuta comandos desde un archivo en el contexto de la Shell actual.      |
| **[curl](https://manpages.ubuntu.com/manpages/noble/man1/curl.1.html)**   | Transfiere datos desde o hacia un servidor.                       | **[uname](https://manpages.ubuntu.com/manpages/noble/man1/uname.1.html)**     | Muestra información sobre el sistema operativo.                           |
| **[nano](https://manpages.ubuntu.com/manpages/noble/man1/nano.1.html)**   | Editor de texto simple para la terminal.                          | **[uptime](https://manpages.ubuntu.com/manpages/noble/man1/uptime.1.html)**   | Muestra el tiempo que lleva encendido el sistema.                         |
| **[vim](https://manpages.ubuntu.com/manpages/noble/man1/vim.1.html)**     | Editor de texto avanzado en la terminal.                          | **[whoami](https://manpages.ubuntu.com/manpages/noble/man1/whoami.1.html)**   | Muestra el nombre del usuario actual.                                     |
| **[man](https://manpages.ubuntu.com/manpages/noble/man1/man.1.html)**     | Muestra el manual de usuario de cualquier comando.                | **[which](https://manpages.ubuntu.com/manpages/noble/man1/which.1.html)**     | Localiza un comando y muestra su ruta completa.                           |
